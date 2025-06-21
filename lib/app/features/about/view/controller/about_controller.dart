import 'package:get/get.dart';

class AboutController extends GetxController {
  var showWebView = true.obs;

  Future<void> handleBack() async {
    showWebView.value = false;
    await Future.delayed(const Duration(milliseconds: 50));
    Get.back();
  }
}
