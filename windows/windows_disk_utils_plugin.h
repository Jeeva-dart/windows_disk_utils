#ifndef FLUTTER_PLUGIN_WINDOWS_DISK_UTILS_PLUGIN_H_
#define FLUTTER_PLUGIN_WINDOWS_DISK_UTILS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace windows_disk_utils {

class WindowsDiskUtilsPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  WindowsDiskUtilsPlugin();

  virtual ~WindowsDiskUtilsPlugin();

  // Disallow copy and assign.
  WindowsDiskUtilsPlugin(const WindowsDiskUtilsPlugin&) = delete;
  WindowsDiskUtilsPlugin& operator=(const WindowsDiskUtilsPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace windows_disk_utils

#endif  // FLUTTER_PLUGIN_WINDOWS_DISK_UTILS_PLUGIN_H_
