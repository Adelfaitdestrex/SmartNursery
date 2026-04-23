import 'package:flutter/material.dart';

class ThemeProvider extends InheritedWidget {
  final ThemeNotifier notifier;

  const ThemeProvider({
    required this.notifier,
    required super.child,
    super.key,
  });

  static ThemeNotifier of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ThemeProvider>()!
        .notifier;
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return notifier.isDarkMode != oldWidget.notifier.isDarkMode;
  }
}

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }
}
