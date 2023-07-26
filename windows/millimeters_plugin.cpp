#include "millimeters_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>
#include <ShellScalingApi.h>

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
      std::make_shared<flutter::MethodChannel<flutter::EncodableValue>>(
        registrar->messenger(), "millimeters",
        &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<MillimetersPlugin>(registrar, channel);

    channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

    registrar->AddPlugin(std::move(plugin));
  }

  MillimetersPlugin::MillimetersPlugin(flutter::PluginRegistrarWindows* registrar, std::shared_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel) : registrar(registrar), channel(channel) {
    window_proc_id = registrar->RegisterTopLevelWindowProcDelegate([this](HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam) {
      switch (message) {
        case WM_MOVE:
        case WM_SIZE:
        case CCM_DPISCALE:
          auto size_map = std::make_unique<flutter::EncodableValue>(GetSize());
          auto resolution_map = std::make_unique<flutter::EncodableValue>(GetResolution());
          this->channel->InvokeMethod("updateSize", std::move(size_map));
          this->channel->InvokeMethod("updateResolution", std::move(resolution_map));
      }
      std::optional<LRESULT> result;
      return result;
    });
  }

  MillimetersPlugin::~MillimetersPlugin() {
    registrar->UnregisterTopLevelWindowProcDelegate(window_proc_id);
  }

  void MillimetersPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    if (method_call.method_name().compare("getSize") == 0) {
      auto size_map = GetSize();
      result->Success(size_map);
    }
    else if (method_call.method_name().compare("getResolution") == 0) {
      auto resolution_map = GetResolution();
      result->Success(resolution_map);
    }
    else {
      result->NotImplemented();
    }
  }

  flutter::EncodableValue MillimetersPlugin::GetSize() {
    HWND current_view = this->registrar->GetView()->GetNativeWindow();
    HMONITOR monitor = MonitorFromWindow(current_view, MONITOR_DEFAULTTONEAREST);
    DISPLAY_DEVICE display_device;
    display_device.cb = sizeof(display_device);
    DisplayDeviceFromHMonitor(monitor, display_device);

    short WidthMm = 0;
    short HeightMm = 0;
    GetSizeForDevID(display_device.DeviceID, WidthMm, HeightMm);
    return flutter::EncodableValue(flutter::EncodableMap{
      { flutter::EncodableValue("Width"), flutter::EncodableValue(WidthMm) },
      { flutter::EncodableValue("Height"), flutter::EncodableValue(HeightMm) },
    });
  }

  flutter::EncodableValue MillimetersPlugin::GetResolution() {
    HWND current_view = registrar->GetView()->GetNativeWindow();
    HMONITOR monitor = MonitorFromWindow(current_view, MONITOR_DEFAULTTONEAREST);
    MONITORINFO monitor_info;
    monitor_info.cbSize = sizeof(MONITORINFO);
    GetMonitorInfo(monitor, &monitor_info);
    DEVICE_SCALE_FACTOR scale_factor;
    GetScaleFactorForMonitor(monitor, &scale_factor);
    return flutter::EncodableValue(flutter::EncodableMap{
        { flutter::EncodableValue("Width"), flutter::EncodableValue((monitor_info.rcMonitor.right - monitor_info.rcMonitor.left) * (100.0 / scale_factor)) },
        { flutter::EncodableValue("Height"), flutter::EncodableValue((monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top) * (100.0 / scale_factor)) },
    });
  }
}  // namespace millimeters
