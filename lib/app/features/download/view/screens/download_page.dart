import 'package:al_raheeq_library/app/core/common/constants/confirm_action_dialog.dart';
import 'package:al_raheeq_library/app/core/common/widgets/custom_loading.dart';
import 'package:al_raheeq_library/app/features/download/repository/download_all.dart';
import 'package:al_raheeq_library/app/features/download/view/controller/download_controller.dart';
import 'package:al_raheeq_library/app/features/download/view/controller/provide_books_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class DownloadPage extends StatelessWidget {
  const DownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProvideBooksController provideBooksController =
        Get.put(ProvideBooksController());

    return Obx(
      () {
        final filteredBooks = provideBooksController.filteredBooks;
        filteredBooks.sort((a, b) => a['id_show'].compareTo(b['id_show']));


        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        provideBooksController.searchQuery.value = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'البحث عن كتاب',
                        labelStyle: TextStyle(color: Colors.black45),
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
                        prefixIcon: Icon(Icons.search, color: Colors.black45),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                  const Gap(16),
                  ElevatedButton(
                    onPressed: () {
                      showConfirmationDialog(
                        title: "تحميل الكتاب",
                        message: "هل أنت متأكد أنك تريد تحميل كل الكتب؟",
                        onConfirm: () {
                          downloadAllBooks(provideBooksController);
                        },
                      );
                    },
                    child: const Text('تحميل الكل'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth;

                  final int columns = width >= 900
                      ? 3
                      : width >= 600
                          ? 2
                          : 1;

                  final double itemWidth =
                      (width - 20 * (columns + 1)) / columns;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: filteredBooks.map((book) {
                        final int index = filteredBooks.indexOf(book);
                        final DownloadController downloadController = Get.put(
                            DownloadController(),
                            tag: index.toString());

                        return SizedBox(
                          width: itemWidth,
                          child: Stack(
                            clipBehavior: Clip.antiAlias,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 30),
                                padding: const EdgeInsets.all(16)
                                    .copyWith(right: 115),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (book['title'] ?? '') +
                                          (book['joz'] != 0
                                              ? ' ${book['joz']?.toString() ?? ''}'
                                              : ''),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'المؤلف : ${book['writer']}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withAlpha(50),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        book['groupName'] ?? 'غير معروف',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        RatingBar.builder(
                                          initialRating: 2.5,
                                          minRating: 1,
                                          itemSize: 20,
                                          itemCount: 5,
                                          allowHalfRating: true,
                                          unratedColor: Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                              .withAlpha(120),
                                          itemBuilder: (context, index) => Icon(
                                            Icons.star,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                          onRatingUpdate: (rating) {},
                                        ),
                                        Obx(() {
                                          return SizedBox(
                                            width: 50,
                                            height: 50,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                if (downloadController
                                                    .isDownloading.value)
                                                  CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary,
                                                    ),
                                                  ),
                                                ZoomTapAnimation(
                                                  onTap: () {
                                                    downloadController
                                                        .handleDownloadTap(
                                                      "https://library.yaqoobi.net/api/books/download/${book['id']}",
                                                      "${book['id']}.zip",
                                                    );
                                                  },
                                                  child: SvgPicture.asset(
                                                    downloadController
                                                            .downloadComplete
                                                            .value
                                                        ? 'assets/svgs/down-to-line-solid.svg'
                                                        : 'assets/svgs/down-to-line.svg',
                                                    width: 20,
                                                    height: 20,
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary,
                                                      BlendMode.srcIn,
                                                    ),
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    width: 120,
                                    imageUrl: book['img'] ?? '',
                                    placeholder: (context, url) =>
                                        const CustomLoading(),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      'assets/images/not.jpg',
                                      fit: BoxFit.cover,
                                      width: 120,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
