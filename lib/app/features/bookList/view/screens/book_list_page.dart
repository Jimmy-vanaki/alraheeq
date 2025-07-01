import 'dart:io';

import 'package:al_raheeq_library/app/config/functions.dart';
import 'package:al_raheeq_library/app/config/get_book_storage.dart';
import 'package:al_raheeq_library/app/core/database/db_helper.dart';
import 'package:al_raheeq_library/app/features/audio/view/controller/audio_controller.dart';
import 'package:al_raheeq_library/app/features/bookList/repository/book_delete.dart';
import 'package:al_raheeq_library/app/features/bookList/repository/print_book.dart';
import 'package:al_raheeq_library/app/core/common/constants/confirm_action_dialog.dart';
import 'package:al_raheeq_library/app/core/common/widgets/custom_loading.dart';
import 'package:al_raheeq_library/app/core/common/widgets/empty_widget.dart';
import 'package:al_raheeq_library/app/features/audio/view/screens/audio_book.dart';
import 'package:al_raheeq_library/app/features/bookList/repository/print_range.dart';
import 'package:al_raheeq_library/app/features/bookList/view/controller/book_controller.dart';
import 'package:al_raheeq_library/app/features/book_content/view/screens/content_page.dart';
import 'package:al_raheeq_library/app/features/library/view/widgets/book_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:open_file/open_file.dart';

class BookListPage extends StatelessWidget {
  const BookListPage({super.key});

  @override
  Widget build(BuildContext context) {
    BookListController bookListController;
    if (Get.isRegistered<BookListController>()) {
      bookListController = Get.find<BookListController>();
    } else {
      bookListController = Get.put(BookListController(), permanent: false);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bookListController.fetchDownloadedBooks();
    });
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              onChanged: (value) {
                // Update search query in controller
                bookListController.searchQuery.value = value;
              },
              decoration: InputDecoration(
                labelText: 'البحث في الكتب',
                labelStyle:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimary,
                    width: 2,
                  ),
                ),
                prefixIcon: Icon(Icons.search,
                    color: Theme.of(context).colorScheme.onPrimary),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Obx(
              () {
                if (bookListController.downloadedBooks.isEmpty &&
                    !bookListController.isLoading.value) {
                  bookListController.fetchDownloadedBooks();
                }
                final search = bookListController.searchQuery.value;
                final books = search.isEmpty
                    ? bookListController.downloadedBooks
                    : bookListController.downloadedBooks.where((book) {
                        final title = (book['title'] ?? '').toString();
                        final writer = (book['writer'] ?? '').toString();
                        return title.contains(search) ||
                            writer.contains(search);
                      }).toList();
                return LayoutBuilder(builder: (context, constraints) {
                  final double width = constraints.maxWidth;

                  final int columns = width >= 900
                      ? 3
                      : width >= 600
                          ? 2
                          : 1;

                  final double itemWidth =
                      (width - 20 * (columns + 1)) / columns;

                  if (books.isEmpty) {
                    return SingleChildScrollView(
                      child: Center(
                        child: EmptyWidget(
                          title: 'لا يوجد كتاب. انتقل إلى قسم التحميل.',
                        ),
                      ),
                    );
                  }
                  final sortedBooks = [...books]..sort((a, b) {
                      return (a['id_show'] ?? 0).compareTo(b['id_show'] ?? 0);
                    });

                  final Map<String, List<Map<String, dynamic>>> groupedBooks =
                      {};
                  for (final book in sortedBooks) {
                    final groupName = book['groupName'] ?? 'غير معروف';

                    if (!groupedBooks.containsKey(groupName)) {
                      groupedBooks[groupName] = [];
                    }

                    groupedBooks[groupName]!.add(book);
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: groupedBooks.entries.map((entry) {
                        final groupName = entry.key;
                        final groupBooks = entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display group name
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary.withAlpha(50),
                                      thickness: 1,
                                      endIndent: 8,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      groupName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary.withAlpha(50),
                                      thickness: 1,
                                      indent: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Display books inside the group
                            Wrap(
                              spacing: 20,
                              runSpacing: 20,
                              children: groupBooks.map((book) {
                                return Container(
                                  width: itemWidth,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Stack(
                                    clipBehavior: Clip.antiAlias,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 30),
                                        padding: const EdgeInsets.all(16)
                                            .copyWith(right: 115),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Book title
                                            ZoomTapAnimation(
                                              onTap: () {
                                                Get.to(() => ContentPage(
                                                      bookId: book['id'],
                                                      bookName: (book[
                                                                  'title'] ??
                                                              '') +
                                                          (book['joz'] != 0
                                                              ? ' ${book['joz']?.toString() ?? ''}'
                                                              : ''),
                                                      scrollPosetion: 0.0,
                                                      searchWord: '',
                                                    ));
                                              },
                                              child: Text(
                                                (book['title'] ?? '') +
                                                    (book['joz'] != 0
                                                        ? ' ${book['joz']?.toString() ?? ''}'
                                                        : ''),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            const Gap(5),
                                            // Writer
                                            Text(
                                              'المؤلف : ${book['writer']}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 5),

                                            // Action buttons row
                                            Row(
                                              children: [
                                                _buildIconButton(
                                                  context: context,
                                                  icon: 'info.svg',
                                                  onTap: () {
                                                    Get.to(() => BookDetailPage(
                                                        book: book));
                                                  },
                                                ),
                                                _buildIconButton(
                                                  context: context,
                                                  icon: 'comment-alt-music.svg',
                                                  isDisabled:
                                                      book['sound_url'] ==
                                                              null ||
                                                          book['sound_url']
                                                              .isEmpty,
                                                  onTap: () {
                                                    Get.to(() =>
                                                        AudioBook(book: book));
                                                  },
                                                ),
                                                _buildIconButton(
                                                  context: context,
                                                  icon: 'file-pdf.svg',
                                                  isDisabled:
                                                      book['pdf'] == null ||
                                                          book['pdf'].isEmpty,
                                                  onTap: () async {
                                                    String fileName =
                                                        '${book['id']}.pdf';
                                                    String url = book['pdf'];

                                                    Directory dir;
                                                    if (Platform.isAndroid ||
                                                        Platform.isIOS) {
                                                      dir =
                                                          await getApplicationDocumentsDirectory();
                                                    } else {
                                                      dir = await getDownloadsDirectory() ??
                                                          await getApplicationDocumentsDirectory();
                                                    }

                                                    String filePath =
                                                        '${dir.path}/$fileName';
                                                    final file = File(filePath);
                                                    if (await file.exists()) {
                                                      OpenFile.open(filePath);
                                                    } else {
                                                      showConfirmationDialog(
                                                        title:
                                                            'تأكيد تنزيل الملف',
                                                        message:
                                                            'هل أنت متأكد من أنك ترغب في تنزيل هذا الملف؟',
                                                        onConfirm: () async {
                                                          await bookListController
                                                              .downloadFile(
                                                            fileName: fileName,
                                                            url: url,
                                                          );
                                                          OpenFile.open(
                                                              filePath);
                                                        },
                                                      );
                                                    }
                                                  },
                                                ),
                                                _buildIconButton(
                                                  context: context,
                                                  icon: 'qr.svg',
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            CachedNetworkImage(
                                                              width:
                                                                  Get.width / 2,
                                                              height:
                                                                  Get.height /
                                                                      3,
                                                              imageUrl:
                                                                  'https://library.yaqoobi.net/upload_list/source/Library/QrCode/book${book['id']}.gif',
                                                              placeholder: (context,
                                                                      url) =>
                                                                  const CustomLoading(),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  const Icon(Icons
                                                                      .error),
                                                            ),
                                                            Text(
                                                              (book['title'] ??
                                                                      '') +
                                                                  (book['joz'] !=
                                                                          0
                                                                      ? ' ${book['joz']?.toString() ?? ''}'
                                                                      : ''),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                _buildIconButton(
                                                  context: context,
                                                  icon: 'print.svg',
                                                  onTap: () async {
                                                    await loadDatabase(
                                                      bookId: book['id'],
                                                      pages: bookListController
                                                          .pages,
                                                      onStatusChange:
                                                          (status) {},
                                                    );
                                                    final totalPages =
                                                        bookListController
                                                            .pages.length;
                                                    final pageRange =
                                                        await showPageRangeDialog(
                                                            context,
                                                            totalPages);
                                                    if (pageRange == null)
                                                      return;

                                                    final selectedPages =
                                                        bookListController.pages
                                                            .sublist(
                                                                pageRange[0] -
                                                                    1,
                                                                pageRange[1]);
                                                    String allText = '';
                                                    for (var page
                                                        in selectedPages) {
                                                      allText +=
                                                          page['_text'] ?? '';
                                                      allText += '\n\n';
                                                    }
                                                    await printBook(allText);
                                                  },
                                                ),
                                                _buildIconButton(
                                                  context: context,
                                                  icon: 'delete-document.svg',
                                                  onTap: () {
                                                    showConfirmationDialog(
                                                        title: "حذف الكتاب",
                                                        message:
                                                            "هل أنت متأكد من رغبتك في حذف هذا الكتاب؟",
                                                        onConfirm: () async {
                                                          print(book['id']);

                                                          await deleteBookFiles(
                                                              '${book['id']}');
                                                          await DBHelper
                                                              .markBookAsNotDownloaded(
                                                                  book['id']);

                                                          Get.snackbar(
                                                            'تمت العملية',
                                                            'تم حذف الكتاب بنجاح',
                                                            snackPosition:
                                                                SnackPosition
                                                                    .BOTTOM,
                                                            backgroundColor:
                                                                Colors.green
                                                                    .shade600,
                                                            colorText:
                                                                Colors.white,
                                                            duration: Duration(
                                                                seconds: 2),
                                                          );
                                                          bookListController
                                                              .fetchDownloadedBooks();
                                                        });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Book image (top-right)
                                      Positioned(
                                        top: 0,
                                        right: 15,
                                        child: ZoomTapAnimation(
                                          onTap: () {
                                            Get.to(() => ContentPage(
                                                  bookId: book['id'],
                                                  bookName: (book['title'] ??
                                                          '') +
                                                      (book['joz'] != 0
                                                          ? ' ${book['joz']?.toString() ?? ''}'
                                                          : ''),
                                                  scrollPosetion: 0.0,
                                                  searchWord: '',
                                                ));
                                          },
                                          child: Hero(
                                            tag: 'book-image-${book['id']}',
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                width: 90,
                                                imageUrl: book['img'] ?? '',
                                                placeholder: (context, url) =>
                                                    const CustomLoading(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  'assets/images/not.jpg',
                                                  fit: BoxFit.cover,
                                                  width: 90,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required BuildContext context,
    required String icon,
    required Function()? onTap,
    bool isDisabled = false,
  }) {
    return ZoomTapAnimation(
      onTap: isDisabled ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isDisabled
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        margin: const EdgeInsets.only(left: 5),
        padding: const EdgeInsets.all(5),
        child: SvgPicture.asset(
          'assets/svgs/$icon',
          colorFilter: ColorFilter.mode(
            isDisabled
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.onPrimary,
            BlendMode.srcIn,
          ),
          width: 18,
          height: 18,
        ),
      ),
    );
  }
}
