import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:millimeters/millimeters.dart';
import 'package:millimeters/millimeters_platform_interface.dart';
import 'package:millimeters/millimeters_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMillimetersPlatform
    with MockPlatformInterfaceMixin
    implements MillimetersPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Size?> getPhysicalSize() {
    // TODO: implement getPhysicalSize
    throw UnimplementedError();
  }

  @override
  Future<Size?> getResolution() {
    // TODO: implement getResolution
    throw UnimplementedError();
  }
  
  @override
  void Function(Size resolution)? updateResolution;
}

void main() {
  final MillimetersPlatform initialPlatform = MillimetersPlatform.instance;

  test('$MethodChannelMillimeters is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMillimeters>());
  });

  test('getPlatformVersion', () async {
    Millimeters millimetersPlugin = Millimeters();
    MockMillimetersPlatform fakePlatform = MockMillimetersPlatform();
    MillimetersPlatform.instance = fakePlatform;

    expect(await millimetersPlugin.getPlatformVersion(), '42');
  });
}
