import 'dart:ui';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'millimeters_method_channel.dart';

abstract class MillimetersPlatform extends PlatformInterface {
  /// Constructs a MillimetersPlatform.
  MillimetersPlatform({void Function(Size size)? onResolutionChanged})
      : updateResolution = onResolutionChanged,
        super(token: _token);

  static final Object _token = Object();

  static MillimetersPlatform _instance = MethodChannelMillimeters();

  /// The default instance of [MillimetersPlatform] to use.
  ///
  /// Defaults to [MethodChannelMillimeters].
  static MillimetersPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MillimetersPlatform] when
  /// they register themselves.
  static set instance(MillimetersPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void Function(Size resolution)? updateResolution;

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Size?> getPhysicalSize() {
    throw UnimplementedError('getPhysicalSize() has not been implemented.');
  }

  Future<Size?> getResolution() {
    throw UnimplementedError('getResolution() has not been implemented.');
  }
}
