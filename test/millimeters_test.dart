import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:millimeters/millimeters.dart';
import 'package:millimeters/millimeters_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMillimetersPlatform extends MillimetersPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Size?> getSize() => Future.value(const Size(60, 40));

  @override
  Future<Size?> getResolution() => Future.value(const Size(600, 400));
}

void main() {
  test('getPlatformVersion', () async {
    MockMillimetersPlatform fakePlatform = MockMillimetersPlatform();
    MillimetersPlatform.instance = fakePlatform;

    expect(await fakePlatform.getPlatformVersion(), '42');
  });

  test('cropEqual', () {
    const initial = Size(100, 200);
    final cropped = initial.cropToAspectRatio(0.5);

    expect(initial, cropped);
  });

  test('cropTaller', () {
    const initial = Size(100, 200);
    final cropped = initial.cropToAspectRatio(1);

    expect(cropped, const Size(100, 100));
  });

  test('cropWider', () {
    const initial = Size(200, 100);
    final cropped = initial.cropToAspectRatio(1);

    expect(cropped, const Size(100, 100));
  });
}
