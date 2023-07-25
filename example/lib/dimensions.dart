import 'dart:math';

import 'package:flutter/material.dart';
import 'package:millimeters/millimeters.dart';

import 'arrow.dart';

class DimensionsIndicator extends StatelessWidget {
  const DimensionsIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final mm = Millimeters.of(context).mm;
    return DefaultTextStyle.merge(
      style: TextStyle(
        color: Theme.of(context).colorScheme.tertiary,
        fontFamily: "monospace",
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final diagonal = sqrt(constraints.maxWidth * constraints.maxWidth +
            constraints.maxHeight * constraints.maxHeight);
        return Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: RotatedBox(
                quarterTurns: -1,
                child: Row(
                  children: [
                    const SizedBox(width: 24),
                    const Expanded(
                      child: Arrow(
                        end: HeadStyle.line,
                        start: HeadStyle.arrow,
                      ),
                    ),
                    Text(
                      "${(constraints.maxHeight / mm(1)).toStringAsFixed(1)}mm",
                    ),
                    const Expanded(child: Arrow()),
                  ],
                ),
              ),
            ),
            Center(
              child: Transform.rotate(
                angle: atan2(-constraints.maxHeight, constraints.maxWidth),
                child: OverflowBox(
                  maxWidth: diagonal - 12,
                  child: Row(
                    children: [
                      const SizedBox(width: 22.5),
                      const Expanded(
                        child: Arrow(
                          start: HeadStyle.arrow,
                          end: HeadStyle.line,
                        ),
                      ),
                      Text(
                        "${(diagonal / mm(1)).toStringAsFixed(1)}mm",
                      ),
                      const Expanded(child: Arrow()),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  const Expanded(
                    child: Arrow(
                      start: HeadStyle.arrow,
                      end: HeadStyle.line,
                    ),
                  ),
                  Text(
                    "${(constraints.maxWidth / mm(1)).toStringAsFixed(1)}mm",
                  ),
                  const Expanded(child: Arrow()),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.only(topRight: Radius.circular(128)),
                  border: Border.all(
                      color: Theme.of(context).colorScheme.tertiary,
                      width: 1.5,
                      strokeAlign: BorderSide.strokeAlignOutside),
                ),
                child: const SizedBox.square(dimension: 22),
              ),
            )
          ],
        );
      }),
    );
  }
}
