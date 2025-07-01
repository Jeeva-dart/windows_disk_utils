#include "include/windows_disk_utils/windows_disk_utils_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "windows_disk_utils_plugin.h"

void WindowsDiskUtilsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  windows_disk_utils::WindowsDiskUtilsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
