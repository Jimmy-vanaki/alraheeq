import 'dart:async';
import 'package:al_raheeq_library/app/config/status.dart';
import 'package:al_raheeq_library/app/core/common/constants/constants.dart';
import 'package:al_raheeq_library/app/core/routes/routes.dart';
import 'package:al_raheeq_library/app/features/intro/data/data_source/update_books_api_provider.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  final updateProvider = Get.find<UpdateBooksApiProvider>();

  RxBool showRetry = false.obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initApp();
  }

  Future<void> _initApp() async {
    final lastUpdate =
        Constants.localStorage.read('last_update') ?? '2023-02-15 16:39:22';

    final status =
        await updateProvider.fetchUpdatedBooks(lastUpdate: lastUpdate);

    if (status == Status.success) {
      _navigateToNext();
    } else {
      showRetry.value = true;
      isLoading.value = false;
    }
  }

  void retry() {
    showRetry.value = false;
    isLoading.value = true;
    _initApp();
  }

  void skip() {
    _navigateToNext();
  }

  void _navigateToNext() {
    final hasSeen = Constants.localStorage.read('hasSeenOnboarding') ?? false;
    if (hasSeen) {
      Get.offAllNamed(Routes.home);
    } else {
      Get.offAllNamed(Routes.onBording);
    }
  }
}
