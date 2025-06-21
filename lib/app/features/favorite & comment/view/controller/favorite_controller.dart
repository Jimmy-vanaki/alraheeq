import 'dart:convert';

import 'package:al_raheeq_library/app/core/common/constants/constants.dart';
import 'package:get/get.dart';

class FavoriteController extends GetxController {
  RxInt selectedTabIndex = 1.obs;
  RxList<Map<String, dynamic>> commentsList = <Map<String, dynamic>>[].obs;

  RxList<Map<String, dynamic>> bookmarksList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadBookmarks();
    loadComments();
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  void loadBookmarks() {
    String? savedBookmarksJson = Constants.localStorage.read('bookmark');
    if (savedBookmarksJson != null) {
      try {
        var decoded = jsonDecode(savedBookmarksJson);
        if (decoded is List) {
          bookmarksList.value = List<Map<String, dynamic>>.from(decoded);
        } else if (decoded is Map) {
          bookmarksList.value = [Map<String, dynamic>.from(decoded)];
        }
      } catch (e) {
        print('❌ Failed to decode bookmarks: $e');
      }
    } else {
      bookmarksList.clear();
    }
  }

  void saveBookmarks() {
    String encodedBookmarks = jsonEncode(bookmarksList.toList());
    Constants.localStorage.write('bookmark', encodedBookmarks);
  }

  void removeBookmarkAt(int bookId, int pageNumber) {
    var index = bookmarksList.indexWhere(
      (bookmark) =>
          bookmark['bookId'].toString() == bookId.toString() &&
          bookmark['pageNumber'].toString() == pageNumber.toString(),
    );
    if (index != -1) {
      bookmarksList.removeAt(index);
      saveBookmarks();
    } else {
      print(
          '❌ Bookmark not found for bookId: $bookId and pageNumber: $pageNumber');
    }
  }

  void clearAllBookmarks() {
    bookmarksList.clear();
    Constants.localStorage.remove('bookmark');
  }

  void loadComments() {
    final data = Constants.localStorage.read('allBookComments');
    if (data != null && data is List) {
      commentsList.value = List<Map<String, dynamic>>.from(data);
    } else {
      commentsList.clear();
    }
  }

  void deleteComment(int commentId) {
    commentsList.removeWhere((comment) => comment['id'] == commentId);
    Constants.localStorage.write('allBookComments', commentsList);
  }
}
