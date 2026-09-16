import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  static const _boxName = 'app_settings';
  static const _themeKey = 'theme_mode';

  late final Box _box;

  @override
  ThemeMode build() {
    _box = Hive.box(_boxName);

    final savedTheme = _box.get(_themeKey);

    if (savedTheme == 'dark') {
      return ThemeMode.dark;
    }

    return ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final newTheme = state == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    state = newTheme;

    await _box.put(
      _themeKey,
      newTheme == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}

final themeProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);