import 'package:al_raheeq_library/app/core/database/db_helper.dart';
import 'package:get/get.dart';

class BookGroupController extends GetxController {
  var bookGroups = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadBookGroups();
  }

  void loadBookGroups() async {
    final data = await DBHelper.getBookGroups();
    bookGroups.value = data;
  }
}
