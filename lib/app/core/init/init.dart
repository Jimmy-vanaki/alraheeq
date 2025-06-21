import 'package:al_raheeq_library/app/config/error_widget.dart';
import 'package:al_raheeq_library/app/config/get_version.dart';
import 'package:al_raheeq_library/app/core/database/db_helper.dart';
import 'package:al_raheeq_library/app/features/intro/data/data_source/update_books_api_provider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> init() async {
  // Initialize the custom error widget
  CustomErrorWidget.initialize();
  Get.put(AppVersionController());
  Get.put(UpdateBooksApiProvider());
  await GetStorage.init();
  await DBHelper.initDb();
}
