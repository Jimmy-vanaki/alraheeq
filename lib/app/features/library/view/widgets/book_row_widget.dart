import 'dart:io';
import 'package:al_raheeq_library/app/core/common/widgets/custom_loading.dart';
import 'package:al_raheeq_library/app/features/book_content/view/screens/content_page.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:path/path.dart' as path;

class BooksRow extends StatelessWidget {
  const BooksRow({
    super.key,
    required this.books,
    required this.title,
  });

  final List<Map<String, dynamic>> books;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10).copyWith(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          Center(
            child: SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const PageScrollPhysics(),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  final bookName = book['name'] ?? 'بدون عنوان';
                  final progress = (book['progress'] ?? 0.0) as double;

                  return Container(
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 1,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          height: 160,
                          width: 130,
                          margin: const EdgeInsets.only(top: 80),
                          child: Column(
                            children: [
                              const Gap(70),
                              Text(
                                bookName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                ),
                              ),
                              const Gap(20),
                              ZoomTapAnimation(
                                onTap: () {
                                  Get.to(
                                    () => ContentPage(
                                      bookId: int.parse(book['id'].toString()),
                                      bookName: bookName,
                                      scrollPosetion: double.tryParse(
                                              book['currentPage'].toString()) ??
                                          0.0,
                                      searchWord: '',
                                    ),
                                  );
                                },
                                child: progress > 0
                                    ? Stack(
                                        children: [
                                          Container(
                                            width: 120,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              // color: Colors.grey.shade300,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary
                                                  .withAlpha(120),
                                            ),
                                          ),
                                          Container(
                                            width: 120 * progress,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                            ),
                                          ),
                                          Container(
                                            width: 120,
                                            height: 20,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(
                                                    horizontal: 5)
                                                .copyWith(bottom: 4),
                                            child: Row(
                                              mainAxisAlignment: progress > 0
                                                  ? MainAxisAlignment
                                                      .spaceBetween
                                                  : MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'مقدار التصفح',
                                                  style: TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                if (progress > 0)
                                                  Text(
                                                    '${((book['progress'] ?? 0.0) * 100).toStringAsFixed(0)}٪',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    : Container(
                                        width: 120,
                                        height: 30,
                                        alignment: Alignment.center,
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 5)
                                                .copyWith(bottom: 4),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: Text(
                                          'تصفح الكتاب',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 10,
                          child: FutureBuilder<Directory>(
                            future: Future(() async {
                              if (Platform.isWindows) {
                                // گرفتن مسیر AppData به صورت داینامیک از محیط ویندوز
                                final appData = Platform.environment[
                                    'APPDATA']; // مثل: C:\Users\mvana\AppData\Roaming
                                return Directory(path.join(
                                    appData!,
                                    'com.dijlah',
                                    'al_raheeq_library',
                                    'alraheeq'));
                              } else {
                                // برای سایر پلتفرم‌ها مسیر داکیومنت
                                return await getApplicationDocumentsDirectory();
                              }
                            }),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data == null) {
                                return const CustomLoading();
                              }

                              final directory = snapshot.data!;
                              final imagePath =
                                  File('${directory.path}/${book['id']}.jpg');

                              print(
                                  '📁 Image path: ${imagePath.path}'); // Debug log

                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: imagePath.existsSync()
                                    ? Image.file(
                                        imagePath,
                                        fit: BoxFit.cover,
                                        width: 90,
                                        height: 140,
                                      )
                                    : Image.asset(
                                        'assets/images/not.jpg',
                                        fit: BoxFit.cover,
                                        width: 90,
                                        height: 140,
                                      ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const Gap(10),
        ],
      ),
    );
  }
}
