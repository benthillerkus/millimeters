import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:millimeters/millimeters.dart';
import 'package:millimeters/millimeters_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMillimetersPlatform extends MillimetersPlatform
    with MockPlatformInterfaceMixin {
  MockMillimetersPlatform({
    Size size = const Size(60, 40),
    Size resolution = const Size(600, 400),
  })  : _size = size,
        _resolution = resolution;

  final Size _size;
  final Size _resolution;

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Size?> getSize() => Future.value(_size);

  @override
  Future<Size?> getResolution() => Future.value(_resolution);
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

  testWidgets('widgetWide', (tester) async {
    const size = Size(60, 40);
    const resolution = Size(600, 400);
    MockMillimetersPlatform fakePlatform =
        MockMillimetersPlatform(size: size, resolution: resolution);
    MillimetersPlatform.instance = fakePlatform;

    MillimetersData? data;

    final key = GlobalKey<MillimetersFromViewState>();

    await tester.pumpWidget(
      MillimetersFromView(
        key: key,
        child: Builder(
          builder: (context) {
            data = Millimeters.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(data, isNotNull);

    data = await key.currentState!.initialize;
    expect(data!.physical, size);
    expect(data!.resolution, resolution);
  });

  testWidgets('widgetTall', (tester) async {
    const size = Size(27.692, 60);
    const resolution = Size(1080, 2340);
    MockMillimetersPlatform fakePlatform =
        MockMillimetersPlatform(size: size, resolution: resolution);
    MillimetersPlatform.instance = fakePlatform;

    MillimetersData? data;

    final key = GlobalKey<MillimetersFromViewState>();

    await tester.pumpWidget(
      MillimetersFromView(
        key: key,
        child: Builder(
          builder: (context) {
            data = Millimeters.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(data, isNotNull);

    data = await key.currentState!.initialize;
    expect(data!.physical, size);
    expect(data!.resolution, resolution);
  });
}
