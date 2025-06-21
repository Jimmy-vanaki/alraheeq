import 'package:al_raheeq_library/app/core/common/widgets/custom_loading.dart';
import 'package:al_raheeq_library/app/core/common/widgets/empty_widget.dart';
import 'package:al_raheeq_library/app/features/book_content/view/screens/content_page.dart';
import 'package:al_raheeq_library/app/features/library/view/controller/book_controller.dart';
import 'package:al_raheeq_library/app/features/library/view/widgets/book_detail_page.dart';
import 'package:auto_height_grid_view/auto_height_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class BooksGridWidget extends StatelessWidget {
  const BooksGridWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final BookController bookController = Get.put(BookController());

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = (constraints.maxWidth / 120).floor();

        return Column(
          children: [
            Obx(
              () => DefaultTabController(
                length: bookController.bookgroups.length + 1,
                child: Column(
                  children: [
                    TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      dividerColor: Colors.transparent,
                      labelColor: Theme.of(context).colorScheme.onPrimary,
                      indicatorColor: Theme.of(context).colorScheme.onPrimary,
                      unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withAlpha(120),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                      tabs: [
                        Tab( 
                          child: Row(
                            children: [
                              Text('الکل'),
                              const Gap(5),
                              Obx(() {
                                return Container(
                                  width: 20,
                                  height: 20,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: bookController.activeTab.value == 0
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : Theme.of(context).colorScheme.onPrimary.withAlpha(120),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${bookController.books.length}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        ...bookController.bookgroups.map((group) {
                          final groupId = group['fatherId'];
                          final count = bookController.books.where((book) {
                            final bookGroupId = book['gid'];
                            return bookGroupId.toString() == groupId.toString();
                          }).length;

                          return Tab(
                            child: Row(
                              children: [
                                Text('${group['name']}'),
                                const Gap(5),
                                Obx(() {
                                  final index = bookController.bookgroups
                                          .indexWhere(
                                              (g) => g['id'] == group['id']) +
                                      1;
                                  return Container(
                                    width: 20,
                                    height: 20,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: bookController.activeTab.value ==
                                              index
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                          : Theme.of(context).colorScheme.onPrimary.withAlpha(120),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '$count',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        }),
                      ],
                      onTap: (index) {
                        print(index);
                        bookController.activeTab.value = index;

                        if (index == 0) {
                          bookController.filterBooksByGroup(-1);
                        } else {
                          final groupId =
                              bookController.bookgroups[index - 1]['fatherId'];
                          bookController.filterBooksByGroup(groupId);
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
            Obx(
              () {
                if (bookController.filteredBooks.isEmpty) {
                  return EmptyWidget(
                    title: 'لا يوجد كتاب. انتقل إلى قسم التحميل.',
                  );
                }
                return AutoHeightGridView(
                  itemCount: bookController.filteredBooks.length,
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 10,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(10),
                  shrinkWrap: true,
                  builder: (context, index) {
                    var book = bookController.filteredBooks[index];
                    return Container(
                      width: 130,
                      height: 215,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 40,
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  height: 145,
                                  width: 120,
                                  padding: EdgeInsets.all(10).copyWith(top: 80),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Gap(13),
                                      Text(
                                        (book['title'] ?? '') +
                                            (book['joz'] != 0
                                                ? ' ${book['joz']?.toString() ?? ''}'
                                                : ''),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                      const Gap(4),
                                      RatingBar.builder(
                                        initialRating: double.parse('2.5'),
                                        minRating: 1,
                                        itemSize: 14,
                                        allowHalfRating: true,
                                        itemBuilder: (context, index) => Icon(
                                          Icons.star,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                        unratedColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                            .withAlpha(120),
                                        onRatingUpdate: (rating) {},
                                      ),
                                      const Gap(10),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                    top: 2,
                                  ),
                                  width: 120,
                                  clipBehavior: Clip.antiAlias,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    // borderRadius: BorderRadius.only(
                                    //   bottomLeft: Radius.circular(10),
                                    //   bottomRight: Radius.circular(10),
                                    // ),
                                  ),
                                  child: ZoomTapAnimation(
                                    onTap: () {
                                      print('bOOKID====> ${book['id']}');
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
                                    child: Container(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        'تصفح الكتاب',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 0,
                            child: ZoomTapAnimation(
                              onTap: () {
                                Get.to(() => BookDetailPage(book: book));
                              },
                              child: Hero(
                                tag: 'book-image-${book['id']}',
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  width: 90,
                                  imageUrl: book['img'] ?? '',
                                  placeholder: (context, url) =>
                                      const CustomLoading(),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    'assets/images/not.jpg',
                                    fit: BoxFit.cover,
                                    width: 90,
                                    height: 150,
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
              },
            ),
          ],
        );
      },
    );
  }
}
