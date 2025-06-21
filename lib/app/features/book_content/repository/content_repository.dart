import 'dart:io';

import 'package:al_raheeq_library/app/core/common/constants/constants.dart';
import 'package:al_raheeq_library/app/core/database/db_helper.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

class ContentRepository {
  // late final dynamic _dbFactory = _initDbFactory();

  // dynamic _initDbFactory() {
  //   if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  //     sqfliteFfiInit();
  //     return databaseFactoryFfi;
  //   } else {
  //     return sqflite.databaseFactory;
  //   }
  // }

  /// Returns the path of the SQLite database based on book ID
  Future<String> getDatabasePath(int bookId) async {
    Directory dir;
    if (Platform.isAndroid || Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
    }

    final dbName = 'b$bookId.sqlite';
    final dbPath = join(dir.path, dbName);

    final file = File(dbPath);
    if (!await file.exists()) {
      throw Exception('فایل دیتابیس $dbName پیدا نشد، لطفا ابتدا دانلود کنید.');
    }

    return dbPath;
  }

  /// Loads the pages table from the SQLite database
  Future<List<Map<String, dynamic>>> getPages(String dbPath) async {
    final db = await DBHelper.dbFactory.openDatabase(dbPath);
    return await db.query('bpages');
  }

  /// Loads the groups table from the SQLite database
  Future<List<Map<String, dynamic>>> getGroups(String dbPath) async {
    final db = await DBHelper.dbFactory.openDatabase(dbPath);
    return await db.query('bgroups');
  }
}

void toggleBookmark(dynamic bookId, String bookTitle) {
  final id = bookId.toString();

  final bookmarks = Map<String, String>.from(
    Constants.localStorage.read('bookmarks') ?? {},
  );

  if (bookmarks.containsKey(id)) {
    bookmarks.remove(id);
  } else {
    bookmarks[id] = bookTitle;
  }

  Constants.localStorage.write('bookmarks', bookmarks);
}
