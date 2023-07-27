import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'millimeters_method_channel.dart';

abstract class MillimetersPlatform extends PlatformInterface {
  /// Constructs a MillimetersPlatform.
  MillimetersPlatform({
    StreamController<Size>? resolution,
    StreamController<Size>? size,
  })  : resolutionController = resolution ?? StreamController<Size>.broadcast(),
        sizeController = size ?? StreamController<Size>.broadcast(),
        super(token: _token);

  static final Object _token = Object();

  @protected
  static MillimetersPlatform? _instance;

  /// The default instance of [MillimetersPlatform] to use.
  ///
  /// Defaults to [MethodChannelMillimeters].
  static MillimetersPlatform get instance => _instance ??= MethodChannelMillimeters();

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MillimetersPlatform] when
  /// they register themselves.
  static set instance(MillimetersPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  @protected
  final StreamController<Size> resolutionController;
  @protected
  final StreamController<Size> sizeController;

  Stream<Size> get size => sizeController.stream;
  Stream<Size> get resolution => resolutionController.stream;

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Size?> getSize() {
    throw UnimplementedError('getPhysicalSize() has not been implemented.');
  }

  Future<Size?> getResolution() {
    throw UnimplementedError('getResolution() has not been implemented.');
  }
}
