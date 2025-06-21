import 'dart:io';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart' hide Key;
import 'package:flutter/services.dart';

Widget loadImageCrossPlatform(String path, double width, double height) {
  if (Platform.isWindows) {
    final encryptedPath = path.replaceAll('.png', '.enc');
    return FutureBuilder<Uint8List>(
      future: loadEncryptedAsset(encryptedPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            width: width,
            height: height,
            fit: BoxFit.contain,
          );
        } else {
          return SizedBox(
            width: width,
            height: height,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  } else {
    // برای اندروید و iOS
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}


Future<Uint8List> loadEncryptedAsset(String assetPath) async {
  // Load encrypted bytes from asset
  final encryptedData = await rootBundle.load(assetPath);
  final bytes = encryptedData.buffer.asUint8List();

  // AES key باید دقیقاً 32 کاراکتر باشه برای AES-256
  final key = Key.fromUtf8('my32lengthsupersecretnooneknows1'); // کلید خودت رو اینجا بذار
  final iv = IV.fromLength(16); // مقدار IV ثابت یا دلخواه

  final encrypter = Encrypter(AES(key));

  // رمزگشایی داده‌ها
  final decrypted = encrypter.decryptBytes(Encrypted(bytes), iv: iv);

  return Uint8List.fromList(decrypted);
}