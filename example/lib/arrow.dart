import 'package:flutter/material.dart';

enum HeadStyle {
  none,
  arrow,
  // circle,
  // square,
  line,
}

class Arrow extends StatelessWidget {
  const Arrow({
    super.key,
    this.color,
    this.height = 8.0,
    this.start = HeadStyle.line,
    this.end = HeadStyle.arrow,
    this.margin = const EdgeInsets.all(8),
  });

  final Color? color;
  final double height;
  final HeadStyle start;
  final HeadStyle end;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxWidth: 128,
      child: Padding(
        padding: margin,
        child: CustomPaint(
          painter: _ArrowPainter(
            color: color ?? Theme.of(context).colorScheme.tertiary,
            start: start,
            end: end,
          ),
          size: Size.fromHeight(height),
        ),
      ),
    );
  }
}

@immutable
class _ArrowPainter extends CustomPainter {
  const _ArrowPainter({
    required this.color,
    required this.start,
    required this.end,
  });

  final Color color;
  final HeadStyle start;
  final HeadStyle end;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width, size.height / 2);

    switch (end) {
      case HeadStyle.none:
        break;
      case HeadStyle.arrow:
        path
          ..relativeMoveTo(-size.height, -size.height / 2)
          ..relativeLineTo(size.height, size.height / 2)
          ..relativeMoveTo(-size.height, size.height / 2)
          ..relativeLineTo(size.height, -size.height / 2);
      case HeadStyle.line:
        path
          ..relativeMoveTo(0, -size.height / 2)
          ..relativeLineTo(0, size.height);
    }

    path.moveTo(0, size.height / 2);
    switch (start) {
      case HeadStyle.none:
        break;
      case HeadStyle.arrow:
        path
          ..relativeMoveTo(size.height, -size.height / 2)
          ..relativeLineTo(-size.height, size.height / 2)
          ..relativeMoveTo(size.height, size.height / 2)
          ..relativeLineTo(-size.height, -size.height / 2);
      case HeadStyle.line:
        path
          ..relativeMoveTo(0, -size.height / 2)
          ..relativeLineTo(0, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) =>
      color != oldDelegate.color ||
      start != oldDelegate.start ||
      end != oldDelegate.end;
}
