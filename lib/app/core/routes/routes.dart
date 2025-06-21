import 'package:al_raheeq_library/app/features/home/view/screens/home_page.dart';
import 'package:al_raheeq_library/app/features/intro/view/screens/onbording_page.dart';
import 'package:al_raheeq_library/app/features/intro/view/screens/splash_page.dart';
import 'package:al_raheeq_library/app/features/setting/view/screens/setting_page.dart';
import 'package:get/get.dart';

class Routes {
  static const String home = '/';
  static const String splash = '/splash';
  static const String onBording = '/onBording';
  static const String setting = '/setting';
  static const String subjectsPage = '/subjectsPage';

  static final List<GetPage> pages = [
    GetPage(name: splash, page: () => const SplashPage()),
    GetPage(name: home, page: () => HomePage()),
    GetPage(name: onBording, page: () => OnbordingPage()),
    GetPage(name: setting, page: () => SettingPage()),
  ];
}
