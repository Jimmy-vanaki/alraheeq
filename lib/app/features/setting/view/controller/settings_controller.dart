import 'package:al_raheeq_library/app/core/common/constants/constants.dart';
import 'package:al_raheeq_library/app/features/home/view/controller/navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  var selectedTheme = const Color(0xFF4B6969).obs;
  var fontSize = 16.0.obs;
  var lineHeight = 1.8.obs;
  var fontFamily = 'دجلة'.obs;
  var verticalScroll = true.obs;
  var isApplying = false.obs;
  var isDarkMode = false.obs;
  var themeIndex = 0.obs;
  final BottmNavigationController navigationController =
      Get.find<BottmNavigationController>();
  var backgroundColor = Colors.white.obs;
  var selectedColorScheme = ThemeColorScheme(
    primary: const Color.fromARGB(255, 148, 179, 161),
    onPrimary: const Color(0xFF4B6969),
    surface: const Color.fromARGB(255, 242, 245, 238),
    index: 0,
  ).obs;
  var showAllPages = true.obs;
  final ThemeColorScheme darkColorScheme = ThemeColorScheme(
    primary: Color(0xFF383838),
    onPrimary: Color(0xFFACACAC),
    surface: Color(0xFF1A1717),
    index: 10,
  );

  final List<ThemeColorScheme> themeColorSchemes = [
    ThemeColorScheme(
      primary: const Color.fromARGB(255, 148, 179, 161),
      onPrimary: const Color(0xFF4B6969),
      surface: const Color.fromARGB(255, 242, 245, 238),
      index: 0,
    ),
    ThemeColorScheme(
      primary: Color.fromARGB(255, 175, 236, 250),
      onPrimary: Color.fromARGB(255, 17, 171, 205),
      surface: Color.fromARGB(255, 225, 245, 254),
      index: 1,
    ),
    ThemeColorScheme(
      primary: Color.fromARGB(255, 169, 144, 100),
      onPrimary: Color.fromARGB(255, 103, 75, 25),
      surface: Color.fromARGB(255, 255, 251, 245),
      index: 2,
    ),
    ThemeColorScheme(
      primary: Color.fromARGB(255, 141, 148, 176),
      onPrimary: Color.fromARGB(255, 76, 82, 104),
      surface: Color.fromARGB(255, 213, 216, 228),
      index: 3,
    ),
    ThemeColorScheme(
      primary: Color.fromARGB(255, 45, 105, 151),
      onPrimary: Color.fromARGB(255, 0, 57, 102),
      surface: Color.fromARGB(255, 217, 235, 250),
      index: 4,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = Constants.localStorage.read('isDarkMode') ?? false;
    themeIndex.value = Constants.localStorage.read('themeIndex') ?? 0;
    print('isDarkMode==========================>$isDarkMode');
    if (isDarkMode.value) {
      // اگر حالت تاریک هست، از darkColorScheme استفاده کن
      selectedColorScheme.value = darkColorScheme;
    } else {
      // حالت روشن: رنگ‌ها رو از لوکال استوریج بخون و ست کن
      final primary = Constants.localStorage.read('theme_primary');
      final onPrimary = Constants.localStorage.read('theme_onPrimary');
      final surface = Constants.localStorage.read('theme_surface');

      if (primary != null && onPrimary != null && surface != null) {
        selectedColorScheme.value = ThemeColorScheme(
          primary: Color(primary),
          onPrimary: Color(onPrimary),
          surface: Color(surface),
          index: themeIndex.value,
        );
      }
    }

    setTheme(selectedColorScheme.value,
        isDarkMode: isDarkMode.value, themeindex: themeIndex.value);

    fontSize.value = Constants.localStorage.read('fontSize') ?? 16.0;
    lineHeight.value = Constants.localStorage.read('lineHeight') ?? 1.8;
    fontFamily.value = Constants.localStorage.read('fontFamily') ?? 'دجلة';
    verticalScroll.value =
        Constants.localStorage.read('verticalScroll') ?? true;

    final int? colorValue = Constants.localStorage.read('backgroundColor');
    if (colorValue != null) {
      backgroundColor.value = Color(colorValue);
    }
  }

  void setTheme(ThemeColorScheme scheme,
      {bool isDarkMode = false, required int themeindex}) {
    selectedColorScheme.value = scheme;

    // ذخیره رنگ‌ها
    if (!isDarkMode) {
      Constants.localStorage.write('theme_primary', scheme.primary.value);
      Constants.localStorage.write('theme_onPrimary', scheme.onPrimary.value);
      Constants.localStorage.write('theme_surface', scheme.surface.value);
    }
    Constants.localStorage.write('themeIndex', themeindex);

    print('111==========================$isDarkMode');
    print('111========================== theme_primary${scheme.primary.value}');
    print(
        '111========================== theme_onPrimary${scheme.onPrimary.value}');
    print(
        '111========================== theme_surface ${scheme.surface.value}');

    // ساخت تم با توجه به حالت تاریک یا روشن
    final ThemeData newTheme = ThemeData(
      dividerTheme: DividerThemeData(color: scheme.onPrimary.withAlpha(50)),
      elevatedButtonTheme: isDarkMode
          ? darkElevatedButtonTheme()
          : lightElevatedButtonTheme(scheme),
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      fontFamily: 'SegoeUI',
      useMaterial3: true,
      colorScheme: isDarkMode
          ? ColorScheme.dark(
              primary: const Color.fromARGB(255, 56, 56, 56),
              onPrimary: const Color.fromARGB(255, 172, 172, 172),
              surface: const Color.fromARGB(255, 26, 23, 23),
              onSurface: Colors.white,
              secondary: Colors.grey,
              onSecondary: Colors.white,
              error: Colors.red,
              onError: Colors.white,
            )
          : ColorScheme.light(
              primary: Colors.white,
              onPrimary: scheme.onPrimary,
              surface: scheme.surface,
              onSurface: Colors.black,
              secondary: Colors.grey,
              onSecondary: Colors.black,
              error: Colors.red,
              onError: Colors.white,
            ),
    );

    final current = navigationController.currentPage.value;

    final newController = PageController(initialPage: current);

    navigationController.pageController.value.dispose();

    navigationController.pageController.value = newController;

    // تغییر تم فعلی اپ
    Get.changeTheme(newTheme);

    // تغییر حالت تم (تم تاریک یا روشن)
    Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }

// Light theme for ElevatedButton
  ElevatedButtonThemeData lightElevatedButtonTheme(ThemeColorScheme scheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

// Dark theme for ElevatedButton
  ElevatedButtonThemeData darkElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: const Color.fromARGB(255, 172, 172, 172),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  void setFontSize(double size) {
    fontSize.value = size;
    Constants.localStorage.write('fontSize', size);
  }

  void setLineHeight(double height) {
    lineHeight.value = height;
    Constants.localStorage.write('lineHeight', height);
  }

  void setFontFamily(String family) {
    fontFamily.value = family;
    Constants.localStorage.write('fontFamily', family);
  }

  void setBackgroundColor(Color color) {
    backgroundColor.value = color;
    Constants.localStorage.write('backgroundColor', color.value);
  }

  void setVerticalScroll(bool isVertical) {
    verticalScroll.value = isVertical;
    Constants.localStorage.write('verticalScroll', isVertical);
  }
}

class ThemeColorScheme {
  final Color primary;
  final Color onPrimary;
  final Color surface;
  final int index;

  ThemeColorScheme({
    required this.primary,
    required this.onPrimary,
    required this.surface,
    required this.index,
  });
}
