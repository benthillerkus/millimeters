import 'dart:async';

import 'package:flutter/widgets.dart';

import 'millimeters_platform_interface.dart';

/// [InheritedWidget] that provides the [MillimetersData] to its descendants.
///
/// Provide your App with data from the plugin by wrapping it with `Millimeters.fromView(child: ...)`.
/// Use the [Millimeters.of] static methods to access the values.
///
/// If you're simulating a device with different measurements,
/// you can wrap that subtree with a [Millimeters] Widget built with the default constructor.
class Millimeters extends InheritedWidget {
  /// Creates a [Millimeters] Widget with the given data.
  /// 
  /// If you want to use the data provided by the plugin, use [Millimeters.fromView] instead.
  const Millimeters({super.key, required this.data, required super.child});

  final MillimetersData data;

  /// Creates a [Millimeters] Widget with data provided by the plugin.
  static Widget fromView({Key? key, required Widget child}) {
    return _MillimetersFromView(key: key, child: child);
  }

  /// Returns the [MillimetersData] from the closest [Millimeters] ancestor.
  static MillimetersData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Millimeters>()?.data;
  }

  /// Returns the [MillimetersData] from the closest [Millimeters] ancestor.
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

/// Data class that holds information about a monitor.
@immutable
class MillimetersData {
  const MillimetersData({
    required this.physical,
    required this.resolution,
  });

  /// The physical size of the monitor in millimeters.
  final Size physical;
  /// The effective resolution (after scaling) of the monitor in pixels.
  final Size resolution;

  /// Converts a millimeter value into logical pixels.
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

  /// Creates a copy of this [MillimetersData] with the given fields replaced
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
  /// Converts this [Size] of the unit defined by [fn] into logical pixels.
  Size unit(double Function(double scalar) fn) => Size(fn(width), fn(height));
}

extension OffsetUnit on Offset {
  /// Converts this [Offset] of the unit defined by [fn] into logical pixels.
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
