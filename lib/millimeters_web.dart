// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:ui' show Size;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'millimeters_platform_interface.dart';

/// A web implementation of the MillimetersPlatform of the Millimeters plugin.
class MillimetersWeb extends MillimetersPlatform {
  /// Constructs a MillimetersWeb
  MillimetersWeb();

  static void registerWith(Registrar registrar) {
    MillimetersPlatform.instance = MillimetersWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = window.navigator.userAgent;
    return version;
  }

  @override
  Future<Size?> getSize() async {
    /// clientWidth and clientHeight are in pixels,
    /// so we have to test for a larger size to minimize rounding errors.
    const multiplicator = 50;
    final fResolution = getResolution();
    var element = window.document.getElementById("millimetersPluginProbe");

    if (element == null) {
      element = DivElement()
        ..id = "millimetersPluginProbe"
        ..style.position = "absolute"
        ..style.top = "0"
        ..style.left = "0"
        ..style.width = "${multiplicator}mm"
        ..style.height = "${multiplicator}mm"
        ..style.visibility = "hidden";
      window.document.getElementsByTagName("body").first.append(element);
    }

    final ratio = Size(element.clientWidth / multiplicator,
        element.clientHeight / multiplicator);
    final resolution = (await fResolution)!;

    return Size(
        resolution.width / ratio.width, resolution.height / ratio.height);
  }

  @override
  Future<Size?> getResolution() async {
    final width = window.screen?.width;
    final height = window.screen?.height;
    if (width == null || height == null) return null;
    return Size(width.toDouble(), height.toDouble());
  }
}
