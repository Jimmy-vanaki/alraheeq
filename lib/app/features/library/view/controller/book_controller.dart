import 'package:al_raheeq_library/app/core/database/db_helper.dart';
import 'package:get/get.dart';

class BookController extends GetxController {
  var books = <Map<String, dynamic>>[].obs;
  var filteredBooks = <Map<String, dynamic>>[].obs;
  var bookgroups = <Map<String, dynamic>>[].obs;
  var activeTab = 0.obs;
  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    // Get all books and groups from the database
    bookgroups.value = await DBHelper.query('bookgroups');
    books.value = await DBHelper.getDownloadedBooks();

    filteredBooks.value = books;
  }

  // Filter books by group ID
  void filterBooksByGroup(int groupId) {
    if (groupId == -1) {
      // If the "الکل" tab is selected, show all books
      filteredBooks.value = books;
    } else {
      // Otherwise filter books by group_id
      filteredBooks.value = books
          .where((book) => book['gid'] == groupId) // Filter by groupId
          .toList(); // Convert to list

// Sort filtered books by 'id_show' in ascending order
      filteredBooks.sort((a, b) => a['id_show'].compareTo(b['id_show']));
    }
  }
}
