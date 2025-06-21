import 'package:al_raheeq_library/app/features/setting/view/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyThemes {
  static final SettingsController settingsController = Get.find();

  static ThemeData get lightTheme {
    final scheme = settingsController.selectedColorScheme.value;

    return ThemeData(
      brightness: Brightness.light,
      fontFamily: 'SegoeUI',
      useMaterial3: true,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.onPrimary.withAlpha(50),
      ),
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: Colors.white,
        onPrimary: scheme.onPrimary,
        surface: scheme.surface,
        onSurface: const Color.fromARGB(255, 14, 14, 14),
        secondary: const Color.fromARGB(255, 240, 205, 140),
        onSecondary: const Color(0xff22323f),
        error: const Color.fromARGB(255, 249, 52, 62),
        onError: const Color(0xffffb4ab),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      fontFamily: 'dijlah',
      useMaterial3: true,
      dividerTheme:
          const DividerThemeData(color: Color.fromARGB(50, 210, 210, 210)),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 55, 55, 55),
          backgroundColor: const Color.fromARGB(255, 194, 194, 194),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color.fromARGB(255, 194, 194, 194),
        onPrimary: Color.fromARGB(255, 55, 55, 55),
        surface: Color.fromARGB(255, 55, 55, 55),
        onSurface: Color.fromARGB(255, 194, 194, 194),
        secondary: Color.fromARGB(255, 81, 0, 244),
        onSecondary: Color.fromARGB(255, 63, 34, 34),
        error: Color.fromARGB(255, 249, 52, 62),
        onError: Color(0xffffb4ab),
      ),
    );
  }
}
