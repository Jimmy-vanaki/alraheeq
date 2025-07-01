import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

class DBHelper {
  static sqflite.Database? _db;
  // DatabaseFactory shared for all DB operations
  static late final sqflite.DatabaseFactory _dbFactory;

  static sqflite.DatabaseFactory get dbFactory => _dbFactory;

  static void initializeDatabaseFactory() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      _dbFactory = databaseFactoryFfi;
    } else {
      _dbFactory = sqflite.databaseFactory;
    }
  }

  /// Initialize and open the database, copy from assets if not exist
  static Future<sqflite.Database> initDb() async {
    if (_db != null) return _db!;

    // Get proper database directory path based on platform
    String dbPath;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      dbPath = await _dbFactory.getDatabasesPath();
    } else {
      dbPath = await sqflite.getDatabasesPath();
    }

    final dbDir = Directory(dbPath);
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    final path = join(dbPath, 'booklist.sqlite');

    // Copy database file from assets if it does not exist
    final exists = await File(path).exists();
    if (!exists) {
      final data = await rootBundle.load('assets/db/booklist.sqlite');
      final bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }

    // Open database
    _db = await _dbFactory.openDatabase(path);
    return _db!;
  }

  static Future<void> closeDb() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
      print('Database closed successfully.');
    } else {
      print('Database was already closed.');
    }
  }

  /// Execute a simple query on the given table
  static Future<List<Map<String, dynamic>>> query(String table) async {
    final db = await initDb();
    return db.query(table);
  }

  /// Get downloaded books with group names
  static Future<List<Map<String, dynamic>>> getDownloadedBooks() async {
    final db = await initDb();
    return await db.rawQuery('''
      SELECT books.*, bookgroups.name AS groupName
      FROM books
      LEFT JOIN bookgroups ON books.gid = bookgroups.fatherId
      WHERE books.downloaded = 1
    ''');
  }

  /// Get book groups
  static Future<List<Map<String, dynamic>>> getBookGroups() async {
    final db = await initDb();
    return await db.query('bookgroups');
  }

  /// Get not downloaded books
  static Future<List<Map<String, dynamic>>> getNotDownloadedBooks() async {
    final db = await initDb();
    return await db.query('books', where: 'downloaded = ?', whereArgs: [0]);
  }

  /// Mark a book as downloaded
  static Future<void> markBookAsDownloaded(int id) async {
    final db = await initDb();
    await db.update('books', {'downloaded': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  /// Mark a book as not downloaded
  static Future<void> markBookAsNotDownloaded(int id) async {
    final db = await initDb();
    await db.update(
      'books',
      {'downloaded': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get book info by bookId
  static Future<Map<String, dynamic>?> getBookInfo(int bookId) async {
    final db = await initDb();
    final result =
        await db.query('books', where: 'id = ?', whereArgs: [bookId]);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  /// Run raw SQL query
  static Future<List<Map<String, dynamic>>> rawQuery(String sql) async {
    final db = await initDb();
    return db.rawQuery(sql);
  }

  /// Get subcategories by fatherId
  static Future<List<Map<String, dynamic>>> getSubCategoriesByFatherId(
      String fatherId) async {
    final db = await initDb();
    return await db.query('books', where: 'gid = ?', whereArgs: [fatherId]);
  }

  /// Batch insert or update books
  static Future<void> upsertBooksBatch(List<Map<String, dynamic>> books) async {
    final db = await initDb();
    final batch = db.batch();

    for (var book in books) {
      final id = book['id'];
      final result = await db.query('books', where: 'id = ?', whereArgs: [id]);

      final data = {
        'gid': book['category_id'],
        'title': book['title'],
        'joz': book['part'],
        'pdf': book['pdf_link'],
        'img': book['photo_url'],
        'id_show': book['id_show'],
        'writer': book['writer_name'],
        'epub': book['epub'],
        'international_number': book['international_number'],
        'scholar': book['scholar'],
        'book_code': book['book_code'],
        'description': book['description'],
        'version': 2,
        'info_version': 0,
        'last_update': book['last_update'],
        'sound_dl': 0,
        'sound_url': book['sound_url'],
        'pdf_dl': 0,
        'fav': 0,
      };

      if (result.isNotEmpty) {
        batch.update('books', data, where: 'id = ?', whereArgs: [id]);
      } else {
        batch.insert('books', {
          'id': id,
          'downloaded': 0,
          ...data,
        });
      }
    }

    await batch.commit(noResult: true);
  }

  /// Batch insert or update categories
  static Future<void> upsertCategoriesBatch(
      List<Map<String, dynamic>> categories) async {
    final db = await initDb();

    for (final category in categories) {
      final id = category['id'];
      final result =
          await db.query('bookgroups', where: 'fatherId = ?', whereArgs: [id]);

      if (result.isNotEmpty) {
        await db.update(
          'bookgroups',
          {
            'name': category['title'],
            'id_show': category['id_show'],
            'rownum': category['books_count'],
          },
          where: 'fatherId = ?',
          whereArgs: [id],
        );
      } else {
        await db.insert('bookgroups', {
          'fatherId': category['id'],
          'name': category['title'],
          'id_show': category['id_show'],
          'rownum': category['books_count'],
        });
      }
    }
  }
}
