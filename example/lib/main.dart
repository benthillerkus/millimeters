import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide GridPaper;

import 'package:millimeters/millimeters.dart';
import 'package:millimeters_example/dimensions.dart';
import 'package:millimeters_example/transparent_window.dart'
    if (dart.library.html) 'package:millimeters_example/transparent_window_fallback.dart';

import 'grid.dart';

Future<void> main() async {
  await makeWindowTransparent();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Millimeters.fromView(
      child: MaterialApp(
        theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 61, 200, 89),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 59, 158, 73),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Demo(),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}

class Demo extends StatelessWidget {
  const Demo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final physicalities = Millimeters.of(context);
    final mm = physicalities.mm;
    return Stack(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Monitor size: $physicalities"),
            ),
          ),
        ),
        Positioned.fill(
          child: GridPaper(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.66),
            interval: mm(50),
            divisions: 5,
            subdivisions: 10,
          ),
        ),
        const DimensionsIndicator(),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(mm(23.25)),
                child: switch ((
                  kDebugMode,
                  Image.asset(
                    "assets/euro.webp",
                    width: mm(23.25),
                    height: mm(23.25),
                    semanticLabel: "1 Euro coin",
                  )
                )) {
                  (true, Widget coin) => Banner(
                      message: "DEBUG",
                      location: BannerLocation.topEnd,
                      child: coin,
                    ),
                  (false, Widget coin) => coin,
                }),
          ),
        ),
        DraggableBox(
          size: const Size(50, 50).unit(mm),
          offset: const Offset(10, 10).unit(mm),
        ),
      ],
    );
  }
}

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
