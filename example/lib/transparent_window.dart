import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

Future<void> makeWindowTransparent() async {
  if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) return;
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  await Window.setEffect(
    effect:
        Platform.isMacOS ? WindowEffect.fullScreenUI : WindowEffect.transparent,
    dark: false,
  );
}
