#include "millimeters_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

#include "monitor_size_from_edid.h"

namespace millimeters {

  // static
  void MillimetersPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
    auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
        registrar->messenger(), "millimeters",
        &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<MillimetersPlugin>(registrar);

    channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

    registrar->AddPlugin(std::move(plugin));
  }

  MillimetersPlugin::MillimetersPlugin(flutter::PluginRegistrarWindows* registrar) : registrar(registrar) {}

  MillimetersPlugin::~MillimetersPlugin() {}

  void MillimetersPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    if (method_call.method_name().compare("getPlatformVersion") == 0) {
      std::ostringstream version_stream;
      version_stream << "Windows ";
      if (IsWindows10OrGreater()) {
        version_stream << "10+";
      }
      else if (IsWindows8OrGreater()) {
        version_stream << "8";
      }
      else if (IsWindows7OrGreater()) {
        version_stream << "7";
      }
      result->Success(flutter::EncodableValue(version_stream.str()));
    }
    else if (method_call.method_name().compare("getSize") == 0) {
      HWND current_view = registrar->GetView()->GetNativeWindow();
      HMONITOR monitor = MonitorFromWindow(current_view, MONITOR_DEFAULTTONEAREST);
      DISPLAY_DEVICE display_device;
      display_device.cb = sizeof(display_device);
      DisplayDeviceFromHMonitor(monitor, display_device);

      short WidthMm = 0;
      short HeightMm = 0;
      GetSizeForDevID(display_device.DeviceID, WidthMm, HeightMm);

      result->Success(flutter::EncodableValue(flutter::EncodableMap{
        { flutter::EncodableValue("Width"), flutter::EncodableValue(WidthMm) },
        { flutter::EncodableValue("Height"), flutter::EncodableValue(HeightMm) },
      }));
    }
    else if (method_call.method_name().compare("getResolution") == 0) {
      HWND current_view = registrar->GetView()->GetNativeWindow();
      HMONITOR monitor = MonitorFromWindow(current_view, MONITOR_DEFAULTTONEAREST);
      MONITORINFO monitor_info;
      monitor_info.cbSize = sizeof(MONITORINFO);
      GetMonitorInfo(monitor, &monitor_info);
      result->Success(flutter::EncodableValue(flutter::EncodableMap{
        { flutter::EncodableValue("Width"), flutter::EncodableValue(monitor_info.rcMonitor.right - monitor_info.rcMonitor.left) },
        { flutter::EncodableValue("Height"), flutter::EncodableValue(monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top) },
      }));
    }
    else {
      result->NotImplemented();
    }
  }

}  // namespace millimeters
