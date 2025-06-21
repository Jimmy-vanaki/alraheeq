import 'package:al_raheeq_library/app/core/common/constants/constants.dart';
import 'package:al_raheeq_library/app/core/common/widgets/empty_widget.dart';
import 'package:al_raheeq_library/app/core/common/widgets/internal_page.dart';
import 'package:al_raheeq_library/app/features/search/view/controller/search_controller.dart';
import 'package:al_raheeq_library/app/features/search/view/widgets/dropdown.dart';
import 'package:al_raheeq_library/app/features/search/view/widgets/search_item.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});
  @override
  Widget build(BuildContext context) {
    final mainSearchController = Get.put(MainSearchController());
    double containerWidth = MediaQuery.of(context).size.width - 40;
    double itemWidth = (containerWidth / 2) - 5;
    return Scaffold(
      body: InternalPage(
        child: Column(
          children: [
            //tabs
            Container(
              width: containerWidth,
              height: 50,
              margin: EdgeInsets.all(20).copyWith(top: 5),
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black.withAlpha(30)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Obx(
                () => Stack(
                  children: [
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: (mainSearchController.selectedSearchMode.value ==
                                  SearchMode.simple
                              ? 1
                              : 0) *
                          itemWidth,
                      top: 0,
                      child: Container(
                        width: itemWidth,
                        height: 40,
                        decoration:
                            Constants.containerBoxDecoration(context).copyWith(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ZoomTapAnimation(
                            onTap: () {
                              mainSearchController
                                  .changeSearchMode(SearchMode.simple);
                            },
                            child: Center(
                              child: Text(
                                'بحث بسيط',
                                style: TextStyle(
                                  color: (mainSearchController
                                              .selectedSearchMode.value ==
                                          SearchMode.simple)
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ZoomTapAnimation(
                            onTap: () {
                              mainSearchController
                                  .changeSearchMode(SearchMode.advanced);
                            },
                            child: Center(
                              child: Text(
                                'بحث متقدم',
                                style: TextStyle(
                                  color: (mainSearchController
                                              .selectedSearchMode.value ==
                                          SearchMode.simple)
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            // Input
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: mainSearchController.formKey,
                child: TextFormField(
                  controller: mainSearchController.searchController,
                  decoration: InputDecoration(
                    hintText: 'بحث...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).hintColor.withAlpha(200),
                      fontFamily: 'dijlah',
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor.withAlpha(70),
                      ),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        // اعتبارسنجی فرم
                        if (mainSearchController.formKey.currentState
                                ?.validate() ??
                            false) {
                          searchInSelectedBooks(mainSearchController
                              .searchController.text
                              .trim());
                        }
                      },
                      icon: Icon(
                        Icons.search,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: 'dijlah',
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  cursorColor: Theme.of(context).colorScheme.primary,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 3) {
                      return 'يتطلب البحث إدخال 3 أحرف أو أكثر';
                    }
                    return null;
                  },
                ),
              ),
            ),
            //advance
            Obx(
              () => Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: mainSearchController.selectedSearchMode.value ==
                        SearchMode.simple
                    ? SizedBox.shrink()
                    : Column(
                        children: [
                          Row(
                            children: [
                              Obx(() => Expanded(
                                    child: CheckboxListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('النص'),
                                      value: mainSearchController.inText.value,
                                      onChanged: (bool? value) {
                                        mainSearchController.inText.value =
                                            value!;
                                      },
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    ),
                                  )),
                              Obx(() => Expanded(
                                    child: CheckboxListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('العنوان'),
                                      value: mainSearchController.inTitle.value,
                                      onChanged: (bool? value) {
                                        mainSearchController.inTitle.value =
                                            value!;
                                      },
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    ),
                                  )),
                            ],
                          ),
                          BookDropdownSearch(),
                        ],
                      ),
              ),
            ),

            const Gap(10),
            Obx(() {
              if (mainSearchController.resultCount.value != 0) {
                return Text(
                  'عدد النتائج: ${mainSearchController.resultCount.value}',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                );
              } else {
                return SizedBox.shrink();
              }
            }),
            Obx(() {
              // بررسی اگر متغیر جستجو تغییر کرده باشد
              bool hasSearchText =
                  mainSearchController.searchController.text.isNotEmpty;
              bool hasResults = mainSearchController.searchResults.isNotEmpty;

              return Expanded(
                child: hasSearchText
                    ? hasResults
                        ? ListView.builder(
                            itemCount:
                                mainSearchController.searchResults.length,
                            itemBuilder: (context, index) {
                              var book =
                                  mainSearchController.searchResults[index];
                              String bookName =
                                  book['bookName'] ?? 'نام کتاب در دسترس نیست';

                              return SearchItem(
                                title: book['title'] ??
                                    book['_text'] ??
                                    'عنوان پیش‌فرض',
                                page: book['page'] ?? '0',
                                bookName: bookName,
                                searchWords: mainSearchController
                                    .searchController.text
                                    .trim(),
                                bookId: book['bookId'].toString(),
                              );
                            },
                          )
                        : Center(
                            child: SingleChildScrollView(
                                child: EmptyWidget(
                                    title: 'لم يتم العثور على نتيجة')),
                          )
                    : SizedBox(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

void searchInSelectedBooks(String searchWords) {
  // Getting the controller instance
  final mainSearchController = Get.find<MainSearchController>();
  mainSearchController.searchResults.clear();
  print(
      'mainSearchController.selectedBook: ${mainSearchController.selectedBook}'); // Debug print

  if (mainSearchController.selectedBook.value == -1) {
    // User selected "All Books"
    for (var book in mainSearchController.downloadedBooks) {
      int bookId = book.id;
      print('Searching in: ${book.title}'); // Debug print

      mainSearchController.searchBooksInDb(
        'b$bookId.sqlite',
        searchWords,
        mainSearchController.inTitle.value,
        mainSearchController.inText.value,
        book.title,
        bookId,
      );
    }
  } else {
    // User selected a specific book
    final selectedBook = mainSearchController.downloadedBooks.firstWhere(
      (book) => book.id == mainSearchController.selectedBook.value,
      orElse: () => throw Exception('Selected book not found!'),
    );

    print('Searching in: ${selectedBook.title}');
    int bookId = selectedBook.id;

    mainSearchController.searchBooksInDb(
      'b${selectedBook.id}.sqlite',
      searchWords,
      mainSearchController.inTitle.value,
      mainSearchController.inText.value,
      selectedBook.title,
      bookId,
    );
  }
}
