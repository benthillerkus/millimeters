#include "include/millimeters/millimeters_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "millimeters_plugin.h"

void MillimetersPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  millimeters::MillimetersPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
