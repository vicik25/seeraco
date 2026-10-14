import 'dart:async';

import '../../navigator.dart';

class SplashCtrl {
  bool _hasStarted = false;

  void start() {
    if (_hasStarted) return;
    _hasStarted = true;
    unawaited(_navigateAfterMinimumSplash());
  }

  Future<void> _navigateAfterMinimumSplash() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    nav.to('/home');
  }
}
