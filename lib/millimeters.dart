// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'millimeters_platform_interface.dart';

class Millimeters extends InheritedWidget {
  const Millimeters({super.key, required this.data, required super.child});

  final MillimetersData data;

  static Widget fromView({Key? key, required Widget child}) {
    return _MillimetersFromView(key: key, child: child);
  }

  static MillimetersData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Millimeters>()?.data;
  }

  static MillimetersData of(BuildContext context) {
    final data = maybeOf(context);
    assert(data != null, 'No Millimeters Widget found in context');
    return data!;
  }

  @override
  bool updateShouldNotify(covariant Millimeters oldWidget) {
    return data != oldWidget.data;
  }
}

@immutable
class MillimetersData {
  const MillimetersData({
    required this.physical,
    required this.resolution,
  });

  final Size physical;
  final Size resolution;

  double mm(double px) {
    if (resolution.isEmpty || physical.isEmpty) return px * 3.78;
    final ratio = resolution.width / physical.width;
    assert((ratio - (resolution.height / physical.height)).abs() < 1);
    return px * ratio;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MillimetersData &&
          runtimeType == other.runtimeType &&
          physical == other.physical &&
          resolution == other.resolution;

  @override
  int get hashCode => physical.hashCode ^ resolution.hashCode;

  MillimetersData copyWith({
    Size? physical,
    Size? resolution,
  }) {
    return MillimetersData(
      physical: physical ?? this.physical,
      resolution: resolution ?? this.resolution,
    );
  }

  @override
  String toString() {
    return '${physical.width.toStringAsFixed(1)}×${physical.height.toStringAsFixed(1)}mm@${resolution.width.round()}×${resolution.height.round()}px';
  }
}

extension SizeUnit on Size {
  Size unit(double Function(double scalar) fn) => Size(fn(width), fn(height));
}

extension OffsetUnit on Offset {
  Offset unit(double Function(double scalar) fn) => Offset(fn(dx), fn(dy));
}

class _MillimetersFromView extends StatefulWidget {
  const _MillimetersFromView({super.key, required this.child});

  final Widget child;

  @override
  State<_MillimetersFromView> createState() => _MillimetersFromViewState();
}

class _MillimetersFromViewState extends State<_MillimetersFromView> {
  MillimetersData _data = const MillimetersData(
    physical: Size.zero,
    resolution: Size.zero,
  );

  StreamSubscription<Size>? _physical;
  StreamSubscription<Size>? _resolution;

  @override
  void initState() {
    super.initState();

    MillimetersPlatform.instance.getSize().then((Size? value) {
      setState(() {
        _data = _data.copyWith(physical: value ?? Size.zero);
      });
      return null;
    });

    MillimetersPlatform.instance.getResolution().then((Size? value) {
      setState(() {
        _data = _data.copyWith(resolution: value ?? Size.zero);
      });
      return null;
    });

    _resolution?.cancel();
    _resolution = MillimetersPlatform.instance.resolution.listen((resolution) {
      if (resolution != _data.resolution) {
        setState(() {
          _data = _data.copyWith(resolution: resolution);
        });
      }
    });

    _physical?.cancel();
    _physical = MillimetersPlatform.instance.size.listen((physical) {
      if (physical != _data.physical) {
        setState(() {
          _data = _data.copyWith(physical: physical);
        });
      }
    });
  }

  @override
  void dispose() {
    _physical?.cancel();
    _resolution?.cancel();
    super.dispose();
  }

  @override
  void deactivate() {
    _physical?.pause();
    _resolution?.pause();
    super.deactivate();
  }

  @override
  void didUpdateWidget(_MillimetersFromView oldWidget) {
    _physical?.resume();
    _resolution?.resume();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Millimeters(data: _data, child: widget.child);
  }
}
