import 'package:al_raheeq_library/app/features/download/view/controller/download_controller.dart';
import 'package:al_raheeq_library/app/features/download/view/controller/provide_books_controller.dart';
import 'package:get/get.dart';

Future<void> downloadAllBooks(
    ProvideBooksController provideBooksController) async {
  final filteredBooks = provideBooksController.books
      .where(
          (book) => book['downloaded'] == 0) // فقط کتاب‌هایی که دانلود نشده‌اند
      .toList();
  print('book');
  // مرتب‌سازی کتاب‌ها به ترتیب
  filteredBooks.sort((a, b) => a['id_show'].compareTo(b['id_show']));

  // دانلود کتاب‌ها به ترتیب
  for (int i = 0; i < filteredBooks.length; i++) {
    var book = filteredBooks[i];

    final tag = i.toString();

    final downloadController = Get.isRegistered<DownloadController>(tag: tag)
        ? Get.find<DownloadController>(tag: tag)
        : Get.put(DownloadController(), tag: tag);

    downloadController.handleDownloadTap(
      "https://library.yaqoobi.net/api/books/download/${book['id']}",
      "${book['id']}.zip",
      isDownloadAll: true,
    );

    await Future.delayed(Duration(seconds: 2));
  }
}
