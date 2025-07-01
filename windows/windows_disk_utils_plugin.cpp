#include "windows_disk_utils_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>
#include <filesystem>
#include <fstream>
#include <codecvt>
#include <locale>

namespace windows_disk_utils {
namespace fs = std::filesystem;

// static
void WindowsDiskUtilsPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "windows_disk_utils",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<WindowsDiskUtilsPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

WindowsDiskUtilsPlugin::WindowsDiskUtilsPlugin() {}

WindowsDiskUtilsPlugin::~WindowsDiskUtilsPlugin() {}

void WindowsDiskUtilsPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getPlatformVersion") == 0) {
    std::ostringstream version_stream;
    version_stream << "Windows ";
    if (IsWindows10OrGreater()) {
      version_stream << "10+";
    } else if (IsWindows8OrGreater()) {
      version_stream << "8";
    } else if (IsWindows7OrGreater()) {
      version_stream << "7";
    }
    result->Success(flutter::EncodableValue(version_stream.str()));
    return;
  }

  if (method_call.method_name().compare("getDisks") == 0) {
    std::vector<flutter::EncodableValue> disks;
    DWORD drives = GetLogicalDrives();
    for (char letter = 'A'; letter <= 'Z'; ++letter) {
      if (drives & (1 << (letter - 'A'))) {
        std::wstring root = std::wstring(1, letter) + L":\\";
        ULARGE_INTEGER freeBytesAvailable, totalNumberOfBytes, totalNumberOfFreeBytes;
        if (GetDiskFreeSpaceExW(root.c_str(), &freeBytesAvailable, &totalNumberOfBytes, &totalNumberOfFreeBytes)) {
          std::string name(1, letter);
          name += ":";
          wchar_t volumeNameBuffer[MAX_PATH + 1] = {0};
          wchar_t fileSystemNameBuffer[MAX_PATH + 1] = {0};
          DWORD serialNumber = 0, maxComponentLen = 0, fileSystemFlags = 0;
          std::string volumeLabel = "";
          std::string fileSystem = "";
          if (GetVolumeInformationW(
                  root.c_str(),
                  volumeNameBuffer, MAX_PATH,
                  &serialNumber, &maxComponentLen, &fileSystemFlags,
                  fileSystemNameBuffer, MAX_PATH)) {
            int len = WideCharToMultiByte(CP_UTF8, 0, volumeNameBuffer, -1, nullptr, 0, nullptr, nullptr);
            if (len > 0) {
              std::vector<char> buf(len);
              WideCharToMultiByte(CP_UTF8, 0, volumeNameBuffer, -1, buf.data(), len, nullptr, nullptr);
              volumeLabel = std::string(buf.data());
            }
            len = WideCharToMultiByte(CP_UTF8, 0, fileSystemNameBuffer, -1, nullptr, 0, nullptr, nullptr);
            if (len > 0) {
              std::vector<char> buf(len);
              WideCharToMultiByte(CP_UTF8, 0, fileSystemNameBuffer, -1, buf.data(), len, nullptr, nullptr);
              fileSystem = std::string(buf.data());
            }
          }
          flutter::EncodableMap disk_info = {
            {flutter::EncodableValue("name"), flutter::EncodableValue(name)},
            {flutter::EncodableValue("totalBytes"), flutter::EncodableValue(static_cast<int64_t>(totalNumberOfBytes.QuadPart))},
            {flutter::EncodableValue("freeBytes"), flutter::EncodableValue(static_cast<int64_t>(totalNumberOfFreeBytes.QuadPart))},
            {flutter::EncodableValue("availableBytes"), flutter::EncodableValue(static_cast<int64_t>(freeBytesAvailable.QuadPart))},
            {flutter::EncodableValue("volumeLabel"), flutter::EncodableValue(volumeLabel)},
            {flutter::EncodableValue("fileSystem"), flutter::EncodableValue(fileSystem)},
            {flutter::EncodableValue("serialNumber"), flutter::EncodableValue(static_cast<int64_t>(serialNumber))},
            {flutter::EncodableValue("fileSystemFlags"), flutter::EncodableValue(static_cast<int64_t>(fileSystemFlags))}
          };
          disks.push_back(flutter::EncodableValue(disk_info));
        }
      }
    }
    result->Success(flutter::EncodableValue(disks));
    return;
  }

  // List folder contents
  if (method_call.method_name().compare("listFolder") == 0) {
    const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    std::string path = std::get<std::string>(args->at(flutter::EncodableValue("path")));
    std::vector<flutter::EncodableValue> entries;
    try {
      for (const auto& entry : fs::directory_iterator(fs::u8path(path))) {
        flutter::EncodableMap info;
        info[flutter::EncodableValue("path")] = flutter::EncodableValue(entry.path().u8string());
        info[flutter::EncodableValue("isDirectory")] = flutter::EncodableValue(entry.is_directory());
        if (!entry.is_directory()) {
          info[flutter::EncodableValue("size")] = flutter::EncodableValue(static_cast<int64_t>(fs::file_size(entry)));
        }
        entries.push_back(flutter::EncodableValue(info));
      }
      result->Success(flutter::EncodableValue(entries));
    } catch (...) {
      result->Error("listFolder_error", "Failed to list folder");
    }
    return;
  }

  // Create folder
  if (method_call.method_name().compare("createFolder") == 0) {
    const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    std::string path = std::get<std::string>(args->at(flutter::EncodableValue("path")));
    try {
      bool created = fs::create_directories(fs::u8path(path));
      result->Success(flutter::EncodableValue(created));
    } catch (...) {
      result->Success(flutter::EncodableValue(false));
    }
    return;
  }

  // Delete folder
  if (method_call.method_name().compare("deleteFolder") == 0) {
    const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    std::string path = std::get<std::string>(args->at(flutter::EncodableValue("path")));
    try {
      bool removed = fs::remove_all(fs::u8path(path)) > 0;
      result->Success(flutter::EncodableValue(removed));
    } catch (...) {
      result->Success(flutter::EncodableValue(false));
    }
    return;
  }

  // List files
  if (method_call.method_name().compare("listFiles") == 0) {
    const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    std::string path = std::get<std::string>(args->at(flutter::EncodableValue("path")));
    std::vector<flutter::EncodableValue> files;
    try {
      for (const auto& entry : fs::directory_iterator(fs::u8path(path))) {
        if (!entry.is_directory()) {
          flutter::EncodableMap info;
          info[flutter::EncodableValue("path")] = flutter::EncodableValue(entry.path().u8string());
          info[flutter::EncodableValue("isDirectory")] = flutter::EncodableValue(false);
          info[flutter::EncodableValue("size")] = flutter::EncodableValue(static_cast<int64_t>(fs::file_size(entry)));
          files.push_back(flutter::EncodableValue(info));
        }
      }
      result->Success(flutter::EncodableValue(files));
    } catch (...) {
      result->Error("listFiles_error", "Failed to list files");
    }
    return;
  }

  // Create file
  if (method_call.method_name().compare("createFile") == 0) {
    const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    std::string path = std::get<std::string>(args->at(flutter::EncodableValue("path")));
    std::string content = "";
    auto it = args->find(flutter::EncodableValue("content"));
    if (it != args->end() && !it->second.IsNull()) {
      content = std::get<std::string>(it->second);
    }
    try {
      std::ofstream file(fs::u8path(path), std::ios::out | std::ios::trunc);
      file << content;
      file.close();
      result->Success(flutter::EncodableValue(true));
    } catch (...) {
      result->Success(flutter::EncodableValue(false));
    }
    return;
  }

  // Delete file
  if (method_call.method_name().compare("deleteFile") == 0) {
    const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    std::string path = std::get<std::string>(args->at(flutter::EncodableValue("path")));
    try {
      bool removed = fs::remove(fs::u8path(path));
      result->Success(flutter::EncodableValue(removed));
    } catch (...) {
      result->Success(flutter::EncodableValue(false));
    }
    return;
  }

  // Read file
  if (method_call.method_name().compare("readFile") == 0) {
    const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    std::string path = std::get<std::string>(args->at(flutter::EncodableValue("path")));
    try {
      std::ifstream file(fs::u8path(path));
      std::stringstream buffer;
      buffer << file.rdbuf();
      file.close();
      result->Success(flutter::EncodableValue(buffer.str()));
    } catch (...) {
      result->Success(flutter::EncodableValue(""));
    }
    return;
  }

  // Write file
  if (method_call.method_name().compare("writeFile") == 0) {
    const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    std::string path = std::get<std::string>(args->at(flutter::EncodableValue("path")));
    std::string content = std::get<std::string>(args->at(flutter::EncodableValue("content")));
    try {
      std::ofstream file(fs::u8path(path), std::ios::out | std::ios::trunc);
      file << content;
      file.close();
      result->Success(flutter::EncodableValue(true));
    } catch (...) {
      result->Success(flutter::EncodableValue(false));
    }
    return;
  }

  // Get file metadata
  if (method_call.method_name().compare("getFileMetadata") == 0) {
    const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    std::string path = std::get<std::string>(args->at(flutter::EncodableValue("path")));
    try {
      fs::directory_entry entry(fs::u8path(path));
      flutter::EncodableMap info;
      info[flutter::EncodableValue("path")] = flutter::EncodableValue(entry.path().u8string());
      info[flutter::EncodableValue("isDirectory")] = flutter::EncodableValue(false);
      info[flutter::EncodableValue("size")] = flutter::EncodableValue(static_cast<int64_t>(fs::file_size(entry)));
      // You can add more metadata as needed
      result->Success(flutter::EncodableValue(info));
    } catch (...) {
      result->Success(flutter::EncodableValue());
    }
    return;
  }

  // Get folder metadata
  if (method_call.method_name().compare("getFolderMetadata") == 0) {
    const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    std::string path = std::get<std::string>(args->at(flutter::EncodableValue("path")));
    try {
      fs::directory_entry entry(fs::u8path(path));
      flutter::EncodableMap info;
      info[flutter::EncodableValue("path")] = flutter::EncodableValue(entry.path().u8string());
      info[flutter::EncodableValue("isDirectory")] = flutter::EncodableValue(true);
      // You can add more folder metadata here
      result->Success(flutter::EncodableValue(info));
    } catch (...) {
      result->Success(flutter::EncodableValue());
    }
    return;
  }

  result->NotImplemented();
}

}  // namespace windows_disk_utils
