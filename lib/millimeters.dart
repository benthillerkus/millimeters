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
    return MillimetersFromView(key: key, child: child);
  }

  /// Returns the [MillimetersData] from the closest [Millimeters] ancestor.
  static MillimetersData? maybeOf(BuildContext context) {
    final pixelRatio = MediaQuery.maybeDevicePixelRatioOf(context);
    return context
        .dependOnInheritedWidgetOfExactType<Millimeters>()
        ?.data
        .copyWith(
          devicePixelRatio: pixelRatio,
        );
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
  MillimetersData({
    required Size physical,
    required this.resolution,
    this.devicePixelRatio = 1.0,
  })  : _monitor = physical,
        physical = physical.cropToAspectRatio(resolution.aspectRatio),
        mmPerPixel = (resolution.isEmpty || physical.isEmpty)
            ? 3.78
            : (resolution.width /
                physical.cropToAspectRatio(resolution.aspectRatio).width);

  /// The physical size of the display area in millimeters.
  final Size physical;

  /// The physical size of the monitor in millimeters.
  final Size _monitor;

  /// The effective resolution (after scaling) of the monitor in pixels.
  final Size resolution;

  /// Calculated as `resolution.width / physical.cropToAspectRatio(resolution).width`.
  final double mmPerPixel;

  final double devicePixelRatio;

  /// Converts a millimeter value into logical pixels.
  double mm(double mm) => mm * mmPerPixel / devicePixelRatio;

  bool get isEmpty => physical.isEmpty || resolution.isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MillimetersData &&
          runtimeType == other.runtimeType &&
          _monitor == other._monitor &&
          resolution == other.resolution;

  @override
  int get hashCode => _monitor.hashCode ^ resolution.hashCode;

  /// Creates a copy of this [MillimetersData] with the given fields replaced
  MillimetersData copyWith({
    Size? physical,
    Size? resolution,
    double? devicePixelRatio,
  }) {
    return MillimetersData(
      physical: physical ?? _monitor,
      resolution: resolution ?? this.resolution,
      devicePixelRatio: devicePixelRatio ?? this.devicePixelRatio,
    );
  }

  @override
  String toString() {
    return '${physical.width.toStringAsFixed(1)}×${physical.height.toStringAsFixed(1)}mm@${resolution.width.round()}×${resolution.height.round()}px (pre crop size: ${physical.width.toStringAsFixed(1)}×${physical.height.toStringAsFixed(1)}mm) (pixel scale: $devicePixelRatio)';
  }
}

extension SizeUnit on Size {
  /// Converts this [Size] of the unit defined by [fn] into logical pixels.
  Size unit(double Function(double scalar) fn) => Size(fn(width), fn(height));

  Size cropToAspectRatio(double aspectRatio) {
    // ar = w / h
    // w = ar * h
    // h = w / ar
    if ((this.aspectRatio - aspectRatio).abs() < 0.01) {
      return this;
    } else if (this.aspectRatio > aspectRatio) {
      // this is wider than target, ie we need to remove width
      return Size(aspectRatio * height, height);
    } else {
      // remove height
      return Size(width, width / aspectRatio);
    }
  }
}

extension OffsetUnit on Offset {
  /// Converts this [Offset] of the unit defined by [fn] into logical pixels.
  Offset unit(double Function(double scalar) fn) => Offset(fn(dx), fn(dy));
}

/// Implementation detail of [Millimeters].
/// This Widget is used to manage the plugin subscriptions.
@protected
class MillimetersFromView extends StatefulWidget {
  const MillimetersFromView({super.key, required this.child});

  /// Child that will be mounted below a [Millimeters] Widget.
  final Widget child;

  @override
  State<MillimetersFromView> createState() => MillimetersFromViewState();
}

@protected
class MillimetersFromViewState extends State<MillimetersFromView> {
  /// The data provided by the plugin.
  /// It does not include the `devicePixelRatio`.
  /// To read the data, use the [Millimeters.of(context)] methods.
  var _data = MillimetersData(
    physical: Size.zero,
    resolution: Size.zero,
  );

  StreamSubscription<Size>? _physical;
  StreamSubscription<Size>? _resolution;

  final Completer<MillimetersData> _initialized = Completer<MillimetersData>();

  /// Wait until data from the [MillimetersPlatform] is available.
  Future<MillimetersData> get initialize => _initialized.future;
  bool get isInitialized => !_data.isEmpty;

  @override
  void initState() {
    super.initState();

    final sizeSet = MillimetersPlatform.instance.getSize().then((Size? value) {
      setState(() {
        _data = _data.copyWith(physical: value ?? Size.zero);
      });
      return null;
    });

    final resolutionSet =
        MillimetersPlatform.instance.getResolution().then((Size? value) {
      setState(() {
        _data = _data.copyWith(resolution: value ?? Size.zero);
      });
      return null;
    });

    (sizeSet, resolutionSet).wait.then((_) {
      // Should only be `false` if the widget has been disposed before the data is available
      if (!_initialized.isCompleted) {
        _initialized.complete(_data);
      }
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
      if (physical != _data._monitor) {
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
    if (!_initialized.isCompleted) {
      _initialized.completeError(StateError('MillimetersFromView disposed'));
    }
    super.dispose();
  }

  @override
  void deactivate() {
    _physical?.pause();
    _resolution?.pause();
    super.deactivate();
  }

  @override
  void didUpdateWidget(MillimetersFromView oldWidget) {
    _physical?.resume();
    _resolution?.resume();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // This isn't actually necessary if people use the Millimeters.of(context) methods.
    // But it doesn't cost anything, so why not.
    final devicePixelRatio = MediaQuery.maybeDevicePixelRatioOf(context);
    return Millimeters(
      data: _data.copyWith(devicePixelRatio: devicePixelRatio),
      child: widget.child,
    );
  }
}
