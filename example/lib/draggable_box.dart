
import 'package:flutter/material.dart';

import 'dimensions.dart';

class DraggableBox extends StatefulWidget {
  const DraggableBox({
    super.key,
    this.size = const Size(50, 50),
    this.offset = Offset.zero,
  });

  final Size size;
  final Offset offset;

  @override
  State<DraggableBox> createState() => _DraggableBoxState();
}

class _DraggableBoxState extends State<DraggableBox> {
  Offset _offset = Offset.zero;
  Size _size = Size.zero;

  @override
  void initState() {
    super.initState();
    _offset = widget.offset;
    _size = widget.size;
  }

  @override
  void didUpdateWidget(covariant DraggableBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offset != widget.offset) {
      _offset = widget.offset;
    }
    if (oldWidget.size != widget.size) {
      _size = widget.size;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: MouseRegion(
        cursor: SystemMouseCursors.move,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _offset += details.delta;
            });
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
                border: Border.all(
                    width: 2, color: Theme.of(context).colorScheme.primary),
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.33)),
            child: SizedBox.fromSize(
              size: _size,
              child: const DimensionsIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
