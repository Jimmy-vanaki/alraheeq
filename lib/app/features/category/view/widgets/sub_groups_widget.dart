import 'package:al_raheeq_library/app/config/get_book_storage.dart';
import 'package:al_raheeq_library/app/core/common/constants/confirm_action_dialog.dart';
import 'package:al_raheeq_library/app/core/common/widgets/custom_loading.dart';
import 'package:al_raheeq_library/app/features/audio/view/screens/audio_book.dart';
import 'package:al_raheeq_library/app/features/bookList/repository/print_book.dart';
import 'package:al_raheeq_library/app/features/bookList/repository/print_range.dart';
import 'package:al_raheeq_library/app/features/bookList/view/controller/book_controller.dart';
import 'package:al_raheeq_library/app/features/book_content/view/screens/content_page.dart';
import 'package:al_raheeq_library/app/features/download/view/controller/download_controller.dart';
import 'package:al_raheeq_library/app/features/library/view/widgets/book_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class SubGroupsWidget extends StatelessWidget {
  const SubGroupsWidget({
    super.key,
    required this.subCategories,
  });

  final List<Map<String, dynamic>> subCategories;

  @override
  Widget build(BuildContext context) {
    // final BookListController bookListController =
    //     Get.isRegistered<BookListController>()
    //         ? Get.find<BookListController>()
    //         : Get.put(BookListController());
    List<Map<String, dynamic>> sortedSubCategories = List.from(subCategories);
    sortedSubCategories.sort((a, b) {
      return (a['id_show'] as int).compareTo(b['id_show'] as int);
    });
    return ListView.builder(
      itemCount: sortedSubCategories.length,
      padding: EdgeInsets.symmetric(
        horizontal: 20,
      ).copyWith(top: 20),
      itemBuilder: (context, index) {
        final book = sortedSubCategories[index];
        final DownloadController downloadController =
            Get.put(DownloadController(), tag: index.toString());
        return Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              Container(
                // margin:
                //     EdgeInsets.symmetric(vertical: 8).copyWith(bottom: 20),
                margin: EdgeInsets.only(top: 30),
                padding: EdgeInsets.all(16).copyWith(right: 115),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(15),
                ),
                width: Get.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (book['title'] ?? '') +
                          (book['joz'] != 0
                              ? ' ${book['joz']?.toString() ?? ''}'
                              : ''),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // const Gap(5),
                    Text(
                      'المؤلف : ${book['writer']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const Gap(5),
                    Row(
                      children: [
                        _buildIconButton(
                          context: context,
                          icon: 'info.svg',
                          onTap: () {
                            Get.to(() => BookDetailPage(book: book));
                          },
                        ),
                        _buildIconButton(
                          context: context,
                          icon: 'comment-alt-music.svg',
                          isDisabled: book['sound_url'] == null ||
                              book['sound_url'].isEmpty,
                          onTap: () {
                            Get.to(() => AudioBook(book: book));
                          },
                        ),

                        // PDF
                        // _buildIconButton(
                        //   context: context,
                        //   icon: 'file-pdf.svg',
                        //   onTap: () {
                        //     showConfirmationDialog(
                        //       title: 'تأكيد تنزيل الملف',
                        //       message:
                        //           'هل أنت متأكد من أنك ترغب في تنزيل هذا الملف؟',
                        //       onConfirm: () {
                        //         bookListController.downloadFile(
                        //             fileName: '${book['id']}.pdf',
                        //             url: book['pdf']);
                        //       },
                        //     );
                        //   },
                        // ),
                        // QR CODE
                        _buildIconButton(
                          context: context,
                          icon: 'qr.svg',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CachedNetworkImage(
                                      width: Get.width / 2,
                                      height: Get.height / 3,
                                      imageUrl:
                                          'https://library.yaqoobi.net/upload_list/source/Library/QrCode/book${book['id']}.gif',
                                      placeholder: (context, url) =>
                                          CustomLoading(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                    Text(
                                      (book['title'] ?? '') +
                                          (book['joz'] != 0
                                              ? ' ${book['joz']?.toString() ?? ''}'
                                              : ''),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        // PRINT
                        // _buildIconButton(
                        //   context: context,
                        //   icon: 'print.svg',
                        //   onTap: () async {
                        //     await loadDatabase(
                        //       bookId: book['id'],
                        //       pages: bookListController.pages,
                        //       isLoading: bookListController.isLoading,
                        //     );

                        //     final totalPages = bookListController.pages.length;

                        //     final pageRange =
                        //         await showPageRangeDialog(context, totalPages);
                        //     if (pageRange == null) {
                        //       return;
                        //     }

                        //     final start = pageRange[0];
                        //     final end = pageRange[1];

                        //     final selectedPages = bookListController.pages
                        //         .sublist(start - 1, end);

                        //     String allText = '';
                        //     for (var page in selectedPages) {
                        //       allText += page['_text'] ?? '';
                        //       allText += '\n\n';
                        //     }

                        //     await printBook(allText);
                        //   },
                        // ),
                        book['downloaded'] == 1
                            ?
                            // DELETE
                            _buildIconButton(
                                context: context,
                                icon: 'delete-document.svg',
                                onTap: () {
                                  showConfirmationDialog(
                                    title: "حذف الكتاب",
                                    message:
                                        "هل أنت متأكد أنك تريد حذف هذا الكتاب؟",
                                    onConfirm: () {},
                                  );
                                },
                              )
                            : Obx(() {
                                return SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // دایره پروگرس
                                      downloadController.isDownloading.value
                                          ? CircularProgressIndicator(
                                              value: null,
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary),
                                            )
                                          : SizedBox.shrink(),
                                      ZoomTapAnimation(
                                        onTap: () {
                                          downloadController.handleDownloadTap(
                                            "https://library.yaqoobi.net/api/books/download/${book['id']}",
                                            "${book['id']}.zip",
                                          );
                                        },
                                        child: SvgPicture.asset(
                                          downloadController
                                                  .downloadComplete.value
                                              ? 'assets/svgs/down-to-line-solid.svg'
                                              : 'assets/svgs/down-to-line.svg',
                                          width: 20,
                                          height: 20,
                                          colorFilter: ColorFilter.mode(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              BlendMode.srcIn),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 15,
                child: ZoomTapAnimation(
                  onTap: () {
                    print(book['id']);
                    Get.to(
                      () => ContentPage(
                        bookId: book['id'],
                        bookName: (book['title'] ?? '') +
                            (book['joz'] != 0
                                ? ' ${book['joz']?.toString() ?? ''}'
                                : ''),
                        scrollPosetion: 0.0, searchWord: '',
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'book-image-${book['id']}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        width: 90,
                        // height: 150,
                        imageUrl: book['img'] ?? '',
                        placeholder: (context, url) => const CustomLoading(),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/not.jpg',
                          fit: BoxFit.cover,
                          width: 90,
                          // height: 150,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
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
                : Theme.of(context).colorScheme.onPrimary),
      ),
      margin: EdgeInsets.only(left: 5),
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
