import 'package:al_raheeq_library/app/core/database/db_helper.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class BookListController extends GetxController {
  // List of downloaded books
  RxList<Map<String, dynamic>> downloadedBooks = <Map<String, dynamic>>[].obs;

  // List of parsed pages (used for printing or other actions)
  var pages = <Map<String, dynamic>>[].obs;

  // State variables
  var isLoading = true.obs;
  var isDownloading = false.obs;
  var downloadComplete = false.obs;
  var progress = 0.obs;

  // Search query for filtering
  RxString searchQuery = ''.obs;

  // Filtered book list based on search query (title or writer)
  List<Map<String, dynamic>> get filteredBooks {
    if (searchQuery.value.isEmpty) return downloadedBooks;
    return downloadedBooks.where((book) {
      final query = searchQuery.value.toLowerCase();
      final title = (book['title'] ?? '').toString().toLowerCase();
      final writer = (book['writer'] ?? '').toString().toLowerCase();
      return title.contains(query) || writer.contains(query);
    }).toList();
  }

  // Fetch all downloaded books from local database
  Future<void> fetchDownloadedBooks() async {
    isLoading.value = true;
    final result = await DBHelper.getDownloadedBooks();
    downloadedBooks.value = result;
    isLoading.value = false;
  }

  // Called when controller is initialized
  @override
  void onInit() {
    super.onInit();
    fetchDownloadedBooks();
  }

  // Download PDF file if it doesn't exist locally
  Future<void> downloadFile({
    required String url,
    required String fileName,
  }) async {
    Dio dio = Dio();
    Directory dir;

    // Get proper storage directory for each platform
    if (Platform.isAndroid || Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
    }

    String savePath = "${dir.path}/$fileName";

    // If file already exists, skip downloading
    if (await File(savePath).exists()) {
      print("✅ File already exists at: $savePath");
      isDownloading.value = false;
      downloadComplete.value = true;
      return;
    }

    try {
      isDownloading.value = true;
      downloadComplete.value = false;

      // Start downloading file
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            progress.value = ((received / total) * 100).toInt();
            print("⬇️ Download Progress: ${progress.value}%");
          }
        },
      );

      print("✅ Download completed at: $savePath");
      downloadComplete.value = true;
    } catch (e) {
      print("❌ Error during download: $e");
    } finally {
      isDownloading.value = false;
    }
  }
}
