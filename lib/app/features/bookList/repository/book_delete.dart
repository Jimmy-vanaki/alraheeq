import 'dart:io';

import 'package:al_raheeq_library/app/config/get_book_storage.dart';
import 'package:al_raheeq_library/app/core/database/db_helper.dart';
import 'package:path_provider/path_provider.dart';

Future<void> deleteBookFiles(String bookId) async {
  Directory dir;
  await DBHelper.closeDb(); // close db first

  if (Platform.isAndroid) {
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

  List<String> fileNames = [
    '$bookId.jpg',
    'b$bookId.sqlite',
  ];

  for (var name in fileNames) {
    final path = '${dir.path}/$name';
    final file = File(path);

    if (await file.exists()) {
      try {
        await tryDeleteFile(file);
        print("🗑️ Deleted: $path");
      } catch (e) {
        print("❌ Failed to delete file after retries: $path\nError: $e");
      }
    } else {
      print("⚠️ Not found: $path");
    }
  }
}

Future<void> tryDeleteFile(File file, {int retries = 5}) async {
  for (int attempt = 0; attempt < retries; attempt++) {
    try {
      if (await file.exists()) {
        await file.delete();
        print("🗑️ Deleted: ${file.path}");
        return;
      } else {
        print("⚠️ Not found: ${file.path}");
        return;
      }
    } catch (e) {
      print("❌ Delete attempt ${attempt + 1} failed for ${file.path}: $e");
      if (attempt == retries - 1) {
        rethrow;
      }
    }
  }
}
