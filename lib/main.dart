import 'dart:io';

import 'package:al_raheeq_library/app/config/connectivity_controller.dart';
import 'package:al_raheeq_library/app/config/theme.dart';
import 'package:al_raheeq_library/app/core/common/constants/constants.dart';
import 'package:al_raheeq_library/app/core/database/db_helper.dart';
import 'package:al_raheeq_library/app/core/init/init.dart';
import 'package:al_raheeq_library/app/core/routes/routes.dart';
import 'package:al_raheeq_library/app/features/audio/view/controller/audio_service_controller.dart';
import 'package:al_raheeq_library/app/features/home/view/controller/navigation_controller.dart';
import 'package:al_raheeq_library/app/features/setting/view/controller/settings_controller.dart';
import 'package:al_raheeq_library/app/notif/firebase_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:google_api_availability/google_api_availability.dart';
// import 'package:just_audio_background/just_audio_background.dart';
import 'package:al_raheeq_library/app/features/audio/repository/audio_handler.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DBHelper.initializeDatabaseFactory();
  await init();
  Get.put(BottmNavigationController(), permanent: true);
  if (Platform.isAndroid) {
    try {
      await checkGooglePlayServices().timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint(
          'Timeout: Google Play Services check took too long, skipping.');
    }
  }

  // WidgetsBinding.instance.addPostFrameCallback((_) async {
  //   await Permission.microphone.request();
  // });
  Get.put(AudioServiceController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SettingsController());
    Get.put(ConnectivityController());
    final settingsController = Get.find<SettingsController>();
    return Obx(() {
      return MediaQuery(
        data:
            MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          locale: const Locale('ar'),
          title: Constants.appTitle,
          themeMode: ThemeMode.light,
          theme: MyThemes.lightTheme,
          darkTheme: MyThemes.darkTheme,
          initialRoute: Routes.splash,
          getPages: Routes.pages,
        ),
      );
    });
  }
}

Future<void> checkGooglePlayServices() async {
  GooglePlayServicesAvailability availability = await GoogleApiAvailability
      .instance
      .checkGooglePlayServicesAvailability();

  if (availability != GooglePlayServicesAvailability.success) {
    debugPrint('Google Play Services not available: $availability');

    showGooglePlayServicesError(availability);
  } else {
    debugPrint('Google Play Services is available.');

    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(handleFirebaseBackgroundMessage);

    await FirebaseNotificationService().initializeNotifications();
  }
}

void showGooglePlayServicesError(GooglePlayServicesAvailability availability) {
  debugPrint(
      'Google Play Services is not available: ${availability.toString()}');
}
