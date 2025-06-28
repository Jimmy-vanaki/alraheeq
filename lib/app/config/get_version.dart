import 'dart:io'; // برای تشخیص سیستم‌عامل

import 'package:al_raheeq_library/app/core/common/constants/constants.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionController extends GetxController {
  final version = ''.obs;
  final buildNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkVersionAndClearStorageIfNeeded();
  }

  // گرفتن نسخه اپ از package_info_plus
  Future<void> getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
    buildNumber.value = packageInfo.buildNumber;
  }

  // بررسی تغییر نسخه فقط در ویندوز
  Future<void> checkVersionAndClearStorageIfNeeded() async {
    if (!Platform.isWindows) return;

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final savedVersion = Constants.localStorage.read('app_version');
    print('savedVersion ---> $savedVersion');
    print('currentVersion ---> $currentVersion');
    if (savedVersion == null) {
      // بار اول اجراست، فقط نسخه رو ذخیره کن
      await Constants.localStorage.write('app_version', currentVersion);
    } else if (savedVersion != currentVersion) {
      // نسخه تغییر کرده، پاک کن و نسخه جدید ذخیره کن
      await Constants.localStorage.erase();
      await Constants.localStorage.write('app_version', currentVersion);
    }

    version.value = currentVersion;
  }
}
