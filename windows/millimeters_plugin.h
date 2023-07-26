#ifndef FLUTTER_PLUGIN_MILLIMETERS_PLUGIN_H_
#define FLUTTER_PLUGIN_MILLIMETERS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace millimeters {

class MillimetersPlugin : public flutter::Plugin {
  public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  MillimetersPlugin(flutter::PluginRegistrarWindows* registrar, std::shared_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel);

  virtual ~MillimetersPlugin();

  // Disallow copy and assign.
  MillimetersPlugin(const MillimetersPlugin&) = delete;
  MillimetersPlugin& operator=(const MillimetersPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  
  flutter::EncodableValue GetSize();

  flutter::EncodableValue GetResolution();

  private:
  flutter::PluginRegistrarWindows *registrar;
  std::shared_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel;
  int window_proc_id;
};

}  // namespace millimeters

#endif  // FLUTTER_PLUGIN_MILLIMETERS_PLUGIN_H_
