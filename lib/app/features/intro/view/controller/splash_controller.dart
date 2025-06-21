import 'package:al_raheeq_library/app/core/routes/routes.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  RxDouble sliderValue = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _startAutoFill();
  }

  void _startAutoFill() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    Get.offAllNamed(Routes.onBording);
  }
}
