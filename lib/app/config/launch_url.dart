import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> urlLauncher(String url) async {
  try {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  } catch (e) {
    Get.closeAllSnackbars();
    Get.snackbar('Error', 'Error: $e');
  }
}
