import 'package:al_raheeq_library/app/config/status.dart';
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
  try {
    onStatusChange(Status.loading);
    final dbPath = await _getDatabasePath(bookId);
    final db = await openDatabase(dbPath);

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

Future<String> _getDatabasePath(int bookId) async {
  // Getting the database path for the specified book ID
  String path = await getApplicationDocumentsDirectory().then((dir) {
    return join(dir.path, 'b$bookId.sqlite');
  });
  return path;
}
