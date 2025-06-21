import 'package:al_raheeq_library/app/core/database/db_helper.dart';
import 'package:get/get.dart';

class ProvideBooksController extends GetxController {
  var books = <Map<String, dynamic>>[].obs; // لیست کامل کتاب‌ها
  var searchQuery = ''.obs; // مقدار سرچ فعلی
  var filteredBooks = <Map<String, dynamic>>[].obs; // لیست فیلترشده نهایی

  @override
  void onInit() {
    super.onInit();
    fetchAllData(); // دریافت داده‌ها هنگام اجرای اولیه

    // هنگام تغییر searchQuery، لیست filteredBooks رو به‌روز کن
    ever(searchQuery, (_) => applyFilter());
  }

  /// گرفتن تمام داده‌ها از دیتابیس
  Future<void> fetchAllData() async {
    final result = await DBHelper.rawQuery('''
      SELECT books.*, bookgroups.name AS groupName
      FROM books
      LEFT JOIN bookgroups ON books.gid = bookgroups.fatherId
    ''');

    books.value = result;
    applyFilter(); // بعد از دریافت، فیلتر هم اعمال بشه
  }

  /// فیلتر کردن کتاب‌ها بر اساس مقدار سرچ
  void applyFilter() {
    final query = searchQuery.value.toLowerCase();

    filteredBooks.value = books.where((book) {
      final downloaded = book['downloaded'] == 0;
      final title = (book['title'] ?? '').toString().toLowerCase();
      final writer = (book['writer'] ?? '').toString().toLowerCase();
      return downloaded && (title.contains(query) || writer.contains(query));
    }).toList();
  }
}
