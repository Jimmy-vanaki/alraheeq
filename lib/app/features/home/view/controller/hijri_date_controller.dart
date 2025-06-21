import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HijriDateController extends GetxController {
  var hijriDate = ''.obs;

  Future<void> fetchHijriDate() async {
    try {
      final response =
          await http.get(Uri.parse('https://yaqoobi.in/api/getdate'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        hijriDate.value = data['date'];
      } else {
        hijriDate.value = 'خطا در دریافت تاریخ';
      }
    } catch (e) {
      hijriDate.value = 'خطای شبکه';
    }
  }

  @override
  void onInit() {
    fetchHijriDate();
    super.onInit();
  }
}
