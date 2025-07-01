import 'dart:io';
import 'package:al_raheeq_library/app/core/common/constants/confirm_action_dialog.dart';
import 'package:al_raheeq_library/app/core/database/db_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:archive/archive_io.dart'; // برای استخراج zip

class DownloadController extends GetxController {
  var isDownloading = false.obs;
  var downloadComplete = false.obs;
  var downloadProgress = 0.0.obs;

  final Dio dio = Dio();

  Future<void> startDownload(String url, String fileName) async {
    try {
      isDownloading.value = true;
      downloadComplete.value = false;
      downloadProgress.value = 0;

      Directory dir;

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

      final savePath = p.join(dir.path, fileName);

      // بررسی وجود فایل قبلی
      if (await File(savePath).exists()) {
        print("✅ File already exists at: $savePath");
        isDownloading.value = false;
        downloadComplete.value = true;
        return;
      }

      // دانلود فایل با dio
      await dio.download(url, savePath, onReceiveProgress: (received, total) {
        if (total > 0) {
          double progress = (received / total) * 100;
          downloadProgress.value = progress;
          print("📥 Download progress: ${progress.toStringAsFixed(0)}%");
        } else {
          print("📥 Downloaded $received bytes...");
        }
      });

      // استخراج فایل zip
      if (p.extension(savePath).toLowerCase() == '.zip') {
        await extractAndDeleteZip(savePath);
      }

      // استخراج شماره کتاب از نام فایل
      final bookIdStr = p.basenameWithoutExtension(fileName);
      final bookId = int.parse(bookIdStr.replaceAll(RegExp(r'[^0-9]'), ''));

      await DBHelper.markBookAsDownloaded(bookId);

      isDownloading.value = false;
      downloadComplete.value = true;
      print("✅ File downloaded and marked as downloaded: $savePath");
    } catch (e) {
      print("❌ Download failed: $e");
      isDownloading.value = false;
      downloadComplete.value = false;
    }
  }

  void handleDownloadTap(String url, String fileName,
      {bool isDownloadAll = false}) async {
    bool exists = await checkIfFileDownloaded(fileName);
    if (exists) {
      Get.closeAllSnackbars();
      Get.snackbar(
        "📚 تم التحميل",
        "سبق وتم تحميل هذا الكتاب",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade50,
        borderRadius: 12,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: EdgeInsets.all(16),
        icon: Icon(Icons.check_circle, color: Colors.green, size: 28),
        shouldIconPulse: false,
        duration: Duration(seconds: 2),
        barBlur: 5,
        isDismissible: true,
        forwardAnimationCurve: Curves.easeOutBack,
        animationDuration: Duration(milliseconds: 500),
      );
    } else {
      if (isDownloadAll) {
        startDownload(url, fileName);
      } else {
        showConfirmationDialog(
          title: "تحميل الكتاب",
          message: "هل أنت متأكد أنك تريد تحميل هذا الكتاب؟",
          onConfirm: () {
            startDownload(url, fileName);
          },
        );
      }
    }
  }
}

Future<Directory> getWindowsSaveDirectory() async {
  // Get the application support directory (typically AppData\Roaming)
  final appSupportDir = await getApplicationSupportDirectory();

  // Define a subdirectory named 'alraheeq' inside the support directory
  final alraheeqDir = Directory(p.join(appSupportDir.path, 'alraheeq'));

  // Create the directory if it doesn't exist
  if (!await alraheeqDir.exists()) {
    await alraheeqDir.create(recursive: true);
  }

  return alraheeqDir;
}

Future<bool> checkIfFileDownloaded(String fileName) async {
  Directory dir;
  if (Platform.isAndroid || Platform.isIOS) {
    dir = await getApplicationDocumentsDirectory();
  } else {
    dir = await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
  }

  final bookIdStr = p.basenameWithoutExtension(fileName);
  String dbFileName = 'b$bookIdStr.sqlite';

  String filePath = p.join(dir.path, dbFileName);
  bool exists = await File(filePath).exists();
  return exists;
}

Future<void> extractAndDeleteZip(String zipPath) async {
  final zipFile = File(zipPath);

  if (!await zipFile.exists()) {
    print("❌ Zip file does not exist at $zipPath");
    return;
  }

  try {
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final destinationDir = zipFile.parent.path;

    for (final file in archive) {
      final filename = file.name;
      final outputPath = p.join(destinationDir, filename);

      if (file.isFile) {
        final outFile = File(outputPath);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
        print("✅ Extracted file: $outputPath");
      } else {
        await Directory(outputPath).create(recursive: true);
        print("✅ Created directory: $outputPath");
      }
    }

    await zipFile.delete();
    print("✅ Zip extracted and deleted: $zipPath");
  } catch (e) {
    print("❌ Error extracting zip: $e");
  }
}
