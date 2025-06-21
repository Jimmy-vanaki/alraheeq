import 'package:al_raheeq_library/app/core/database/db_helper.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  // گروه‌های کتاب
  var bookGroups = <Map<String, dynamic>>[].obs;

  // زیرگروه‌ها دسته‌بندی‌شده بر اساس fatherId
  RxMap<String, List<Map<String, dynamic>>> subCategories =
      <String, List<Map<String, dynamic>>>{}.obs;

  // گروه انتخاب شده
  var selectedCategory = Rx<String?>(null);

  // بارگذاری گروه‌ها از دیتابیس
  Future<void> loadBookGroups() async {
    final groups = await DBHelper.getBookGroups();
    bookGroups.value = groups;
  }

  // بارگذاری زیرگروه‌ها بر اساس fatherId و ذخیره به صورت Map
  Future<void> loadSubCategories(String fatherId) async {
    print("Loading subcategories for fatherId: $fatherId");

    final subGroups = await DBHelper.getSubCategoriesByFatherId(fatherId);

    subCategories[fatherId] = subGroups;
    print("Loaded ${subGroups.length} subcategories for $fatherId");
  }

  // تغییر وضعیت انتخاب دسته
  void toggleCategory(String categoryName, String fatherId) {
    if (selectedCategory.value == categoryName) {
      selectedCategory.value = null;
    } else {
      selectedCategory.value = categoryName;
      loadSubCategories(fatherId);
    }
  }
}
