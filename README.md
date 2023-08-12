[![GitHub](https://img.shields.io/github/license/benthillerkus/millimeters)](https://github.com/benthillerkus/millimeters#MIT-1)
[![Pub Points](https://img.shields.io/pub/points/millimeters)](https://pub.dev/packages/millimeters/score)


A Flutter plugin for determining the physical device screen size in millimeters.

https://github.com/benthillerkus/millimeters/assets/29630575/51bc68cf-f0bb-4032-8ec9-ab8d4be9a98b

## Functionality

This package depends on native APIs to provide correct values. Typically on Apple platforms (iOS, macOS) these will be correct (aslong as you aren't mirroring your screen), but on other platforms the results can be totally off. This plugins tries its best in delivering correct results, but on some platforms (e.g. Web, Android) results may never be correct.

There are probably seldom cases where you actually want physically consistent sizing anyways, drawing device frames in something like WidgetBook comes to mind, maybe for manuals referencing physical things (print in general), perhaps for QR codes.<br>
**You don't want your regular UI that users click on and interact with to use physically consistent sizes, as the typical viewing distance can be quite different between platforms.**

## Supported Features

|                       | Windows | Linux | macOS | Web | Android | iOS |
|-----------------------|:-------:|:-----:|:-----:|:---:|:-------:|:---:|
| Resolution            | ✔️ || ✔️ | ✔️ | ✔️ ||
| Physical Size         | ✔️ || ✔️ | ✔️[^1] | ✔️ ||
| Multi Window          |||||||
| Multi Monitor         | ✔️ ||||||
| Handle Screen Scaling | ✔️ || ✔️ ||||

[^1]: Will be just a static fallback value, as most browsers implement define 1mm as 96px/25.4

## Usage

```dart
// import the package
import 'package:millimeters/millimeters.dart';

void main() {
  runApp(
    // insert the `InheritedWidget` on top of your `Widget` tree
    Millimeters.fromView(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // depend on the `InheritedWidget` inside `build`
    final mm = Millimeters.of(context).mm;

    return Center(
      child: ColoredBox(
        color: Color.fromARGB(255, 0, 255, 255),
        child: SizedBox.fromSize(
          // use the mm function to convert millimeters into logical pixels
          size: Size(mm(50), mm(50)), // <- this box should have 5cm long edges.
        ),
      ),
    );
  }
}
```

## Getting Started

This project is a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

The plugin project was generated without specifying the `--platforms` flag.
To add platforms, run `flutter create -t plugin --platforms <platforms> .` in this directory.
You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.
