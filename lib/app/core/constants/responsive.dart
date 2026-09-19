import 'package:flutter/material.dart';

class Responsive {
  static bool get useNavRail =>
      WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width /
              WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio >
          700;
}
