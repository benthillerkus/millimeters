// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart' hide GridPaper;

class _GridPaperPainter extends CustomPainter {
  const _GridPaperPainter({
    required this.color,
    required this.interval,
    required this.divisions,
    required this.subdivisions,
  });

  final Color color;
  final double interval;
  final int divisions;
  final int subdivisions;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint cell = Paint()
      ..color = color
      ..strokeWidth = 1.0;
    final Paint division = Paint()
      ..color = color
      ..strokeWidth = 0.5;
    final Paint subdivision = Paint()
      ..color = color
      ..strokeWidth = 0.125;

    for (double i = 0; i < size.width; i += interval) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        cell,
      );
      for (int d = 0; d < divisions; d++) {
        canvas.drawLine(
          Offset(interval / divisions * d + i, 0),
          Offset(interval / divisions * d + i, size.height),
          division,
        );
        for (int s = 1; s < subdivisions; s++) {
          canvas.drawLine(
            Offset(
              interval / divisions * d +
                  i +
                  interval / (divisions * subdivisions) * s,
              0,
            ),
            Offset(
              interval / divisions * d +
                  i +
                  interval / (divisions * subdivisions) * s,
              size.height,
            ),
            subdivision,
          );
        }
      }
    }

    for (double i = 0; i < size.height; i += interval) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        cell,
      );
      for (int d = 0; d < divisions; d++) {
        canvas.drawLine(
          Offset(0, interval / divisions * d + i),
          Offset(size.width, interval / divisions * d + i),
          division,
        );
        for (int s = 1; s < subdivisions; s++) {
          canvas.drawLine(
            Offset(
              0,
              interval / divisions * d +
                  i +
                  interval / (divisions * subdivisions) * s,
            ),
            Offset(
              size.width,
              interval / divisions * d +
                  i +
                  interval / (divisions * subdivisions) * s,
            ),
            subdivision,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_GridPaperPainter oldPainter) {
    return oldPainter.color != color ||
        oldPainter.interval != interval ||
        oldPainter.divisions != divisions ||
        oldPainter.subdivisions != subdivisions;
  }

  @override
  bool hitTest(Offset position) => false;
}

/// A widget that draws a rectilinear grid of lines one pixel wide.
///
/// Useful with a [Stack] for visualizing your layout along a grid.
///
/// The grid's origin (where the first primary horizontal line and the first
/// primary vertical line intersect) is at the top left of the widget.
///
/// The grid is drawn over the [child] widget.
class GridPaper extends StatelessWidget {
  /// Creates a widget that draws a rectilinear grid of 1-pixel-wide lines.
  const GridPaper({
    super.key,
    this.color = const Color(0x7FC3E8F3),
    this.interval = 100.0,
    this.divisions = 2,
    this.subdivisions = 5,
    this.child,
  })  : assert(divisions > 0,
            'The "divisions" property must be greater than zero. If there were no divisions, the grid paper would not paint anything.'),
        assert(subdivisions > 0,
            'The "subdivisions" property must be greater than zero. If there were no subdivisions, the grid paper would not paint anything.');

  /// The color to draw the lines in the grid.
  ///
  /// Defaults to a light blue commonly seen on traditional grid paper.
  final Color color;

  /// The distance between the primary lines in the grid, in logical pixels.
  ///
  /// Each primary line is one logical pixel wide.
  final double interval;

  /// The number of major divisions within each primary grid cell.
  ///
  /// This is the number of major divisions per [interval], including the
  /// primary grid's line.
  ///
  /// The lines after the first are half a logical pixel wide.
  ///
  /// If this is set to 2 (the default), then for each [interval] there will be
  /// a 1-pixel line on the left, a half-pixel line in the middle, and a 1-pixel
  /// line on the right (the latter being the 1-pixel line on the left of the
  /// next [interval]).
  final int divisions;

  /// The number of minor divisions within each major division, including the
  /// major division itself.
  ///
  /// If [subdivisions] is 5 (the default), it means that there will be four
  /// lines between each major ([divisions]) line.
  ///
  /// The subdivision lines after the first are a quarter of a logical pixel wide.
  final int subdivisions;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _GridPaperPainter(
        color: color,
        interval: interval,
        divisions: divisions,
        subdivisions: subdivisions,
      ),
      child: child,
    );
  }
}
