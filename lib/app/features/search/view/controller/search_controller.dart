import 'dart:io';

import 'package:al_raheeq_library/app/core/database/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class MainSearchController extends GetxController {
  Rx<SearchMode> selectedSearchMode = SearchMode.simple.obs;
  TextEditingController searchController = TextEditingController();

  RxList<Book> downloadedBooks = <Book>[].obs;
  var searchResults = <Map<String, dynamic>>[].obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  var resultCount = 0.obs;
  RxInt selectedBook = (-1).obs;
  RxBool inText = true.obs;
  RxBool inTitle = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadDownloadedBooks();
  }

  void changeSearchMode(SearchMode mode) {
    selectedSearchMode.value = mode;
  }

  Future<void> loadDownloadedBooks() async {
    final List<Map<String, dynamic>> booksData =
        await DBHelper.getDownloadedBooks();

    if (booksData.isNotEmpty) {
      List<Book> books = booksData.map((bookData) {
        return Book.fromMap(bookData);
      }).toList();

      books.sort((a, b) => a.idShow.compareTo(b.idShow));

      downloadedBooks.value = books;
    }
  }

  Future<void> searchBooksInDb(
    String dbName,
    String searchWords,
    bool isTitleChecked,
    bool isDescriptionChecked,
    String bookName,
    int bookId,
  ) async {
    var results = await searchBooks(
      dbName,
      searchWords,
      isTitleChecked,
      isDescriptionChecked,
      bookName,
    );

    List<Map<String, dynamic>> bookResults = [];

    for (var result in results) {
      var updatedResult = Map<String, dynamic>.from(result);
      updatedResult['bookName'] = bookName;
      updatedResult['bookId'] = bookId;
      bookResults.add(updatedResult);
    }

    searchResults.addAll(bookResults);
    resultCount.value = searchResults.length;
  }
}

enum SearchMode { simple, advanced }

class Book {
  final int id;
  final String title;
  final String author;
  final int idShow;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.idShow,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: (map['title']?.toString() ?? '') + (map['joz']?.toString() ?? ''),
      author: map['writer'],
      idShow: map['id_show'] ?? 0,
    );
  }
}

Future<List<Map<String, dynamic>>> searchBooks(
  String bookId,
  String searchWords,
  bool isTitleChecked,
  bool isDescriptionChecked,
  String bookName,
) async {
  late String dbPath;
  late Database db;

  if (Platform.isWindows || Platform.isMacOS) {
    // 📂 مسیر برای دسکتاپ (میتونی داینامیک‌ترش کنی)
    final downloadsDir = await getDownloadsDirectoryPath();
    dbPath = p.join(downloadsDir, bookId);

    if (!await File(dbPath).exists()) {
      print("❌ Database file not found: $dbPath");
      return [];
    }

    // ✅ استفاده از dbFactory اختصاصی
    db = await DBHelper.dbFactory.openDatabase(dbPath);
  } else {
    // 📱 مسیر برای موبایل
    final dir = await getApplicationDocumentsDirectory();
    dbPath = "${dir.path}/$bookId";

    if (!await File(dbPath).exists()) {
      print("❌ Database file not found: $dbPath");
      return [];
    }

    db = await openDatabase(
        dbPath); // در موبایل لازم نیست از dbFactory استفاده بشه
  }

  print("📂 Opened database at: $dbPath");

  List<Map<String, dynamic>> results = [];

  // 🔍 جستجو در عنوان
  if (isTitleChecked) {
    final titleResults = await db.rawQuery(
      'SELECT * FROM bgroups WHERE title LIKE ?',
      ['%$searchWords%'],
    );
    results.addAll(titleResults);
  }

  // 🔍 جستجو در متن
  if (isDescriptionChecked) {
    final descriptionResults = await db.rawQuery(
      'SELECT * FROM bpages WHERE _text LIKE ?',
      ['%$searchWords%'],
    );
    results.addAll(descriptionResults);
  }

  await db.close(); // همیشه دیتابیس رو ببند
  return results;
}

Future<String> getDownloadsDirectoryPath() async {
  if (Platform.isWindows) {
    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile != null) {
      return p.join(userProfile, 'Downloads');
    }
  } else if (Platform.isMacOS) {
    final home = Platform.environment['HOME'];
    if (home != null) {
      return p.join(home, 'Downloads');
    }
  }

  throw UnsupportedError(
      'Downloads directory is not supported on this platform');
}
