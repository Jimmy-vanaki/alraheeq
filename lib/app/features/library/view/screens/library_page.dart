import 'package:al_raheeq_library/app/features/book_content/repository/save_dialog.dart';
import 'package:al_raheeq_library/app/features/library/repository/provide_bookmarks.dart';
import 'package:al_raheeq_library/app/features/library/view/widgets/ad_slider.dart';
import 'package:al_raheeq_library/app/features/library/view/widgets/book_row_widget.dart';
import 'package:al_raheeq_library/app/features/library/view/widgets/books_grid_widget.dart';
import 'package:al_raheeq_library/app/features/search/view/screens/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // final SliderController sliderController = Get.put(SliderController());
    final bookmarks = getBookmarks();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // search Box
          GestureDetector(
            onTap: () {
              Get.to(() => SearchPage());
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'البحث',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/svgs/search.svg',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  )
                ],
              ),
            ),
          ),
          AdSlider(),
          const Gap(10),
          FutureBuilder<List<Book>>(
            future: getBooksList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('خطأ في تحميل الكتب'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SizedBox.shrink();
              }

              final books = snapshot.data!;

              return BooksRow(
                books: books
                    .map((book) => {
                          'id': book.id,
                          'name': book.name,
                          'currentPage': book.currentPage,
                          'progress': book.totalPages > 0
                              ? book.currentPage / book.totalPages
                              : 0.0,
                        })
                    .toList(),
                title: 'اكمل التصفح',
              );
            },
          ),

          bookmarks.isNotEmpty
              ? BooksRow(
                  books: bookmarks,
                  title: 'المفضلة',
                )
              : SizedBox.shrink(),

          BooksGridWidget(),
        ],
      ),
    );
  }
}
