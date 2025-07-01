import 'dart:io';

import 'package:al_raheeq_library/app/config/status.dart';
import 'package:al_raheeq_library/app/core/database/db_helper.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

Future<void> loadDatabase({
  required int bookId,
  required RxList<Map<String, dynamic>> pages,
  RxList<Map<String, dynamic>>? groups,
  required void Function(Status) onStatusChange,
}) async {
  late Database db;

  try {
    onStatusChange(Status.loading);
    final dbPath = await getDatabasePath(bookId);
    db = await DBHelper.dbFactory.openDatabase(dbPath);

    // final db = await openDatabase(dbPath);

    final loadedPages = await db.query('bpages');
    final loadedGroups = await db.query('bgroups');

    pages.assignAll(loadedPages);
    groups?.assignAll(loadedGroups);

    onStatusChange(Status.success);
  } catch (e) {
    print("❌ Error loading database: $e");
    onStatusChange(Status.error);
  }
}

/// Returns the path of the SQLite database based on book ID
Future<String> getDatabasePath(int bookId) async {
  Directory dir;

  if (Platform.isAndroid) {
    // ترجیحاً از getExternalStorageDirectory استفاده کن
    dir = await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
  } else if (Platform.isIOS) {
    dir = await getApplicationDocumentsDirectory();
  } else if (Platform.isWindows) {
    dir = await getWindowsSaveDirectory();
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

Future<Directory> getWindowsSaveDirectory() async {
  final appSupportDir = await getApplicationSupportDirectory();

  final alraheeqDir = Directory(join(appSupportDir.path, 'alraheeq'));

  if (!await alraheeqDir.exists()) {
    await alraheeqDir.create(recursive: true);
  }

  return alraheeqDir;
}
