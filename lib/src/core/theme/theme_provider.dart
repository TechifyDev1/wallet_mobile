import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final themeProvider = NotifierProvider<ThemeNotifier, Brightness>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<Brightness> {
  static const _storage = FlutterSecureStorage();
  static const _themeKey = 'app_brightness';

  @override
  Brightness build() {
    _loadTheme();
    return Brightness.light;
  }

  Future<void> _loadTheme() async {
    try {
      final savedTheme = await _storage.read(key: _themeKey);
      if (savedTheme != null) {
        state = savedTheme == 'dark' ? Brightness.dark : Brightness.light;
      }
    } catch (_) {
      // Fallback to light theme if storage fails
    }
  }

  Future<void> toggleTheme() async {
    state = state == Brightness.light ? Brightness.dark : Brightness.light;
    try {
      await _storage.write(
        key: _themeKey,
        value: state == Brightness.dark ? 'dark' : 'light',
      );
    } catch (_) {
      // Ignore storage failures
    }
  }

  void setBrightness(Brightness brightness) {
    state = brightness;
  }
}
