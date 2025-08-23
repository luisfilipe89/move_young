import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  // Ensure mouse/touch/trackpad all can drag lists
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        // Keep the native bounce (default behavior)
        return super.buildOverscrollIndicator(context, child, details);

      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        // Use subtle stretch instead of blue glow
        return StretchingOverscrollIndicator(
          axisDirection: details.direction,
          child: child,
        );
    }
  }
}
