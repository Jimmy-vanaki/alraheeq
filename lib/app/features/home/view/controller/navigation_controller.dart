import 'package:al_raheeq_library/app/features/bookList/view/controller/book_controller.dart';
import 'package:al_raheeq_library/app/features/favorite%20&%20comment/view/controller/favorite_controller.dart';
import 'package:al_raheeq_library/app/features/library/view/controller/book_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottmNavigationController extends GetxController {
  Rx<PageController> pageController = PageController().obs;

  // Variable for changing index of Bottom Appbar
  RxInt currentPage = 0.obs;

  void goToPage(int page) {
    currentPage.value = page;
    pageController.value.jumpToPage(page);
    print(page);
    updatePageContent(page);
  }

  void animatedToPage(int page) {
    currentPage.value = page;
    pageController.value.animateToPage(currentPage.value,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
    updatePageContent(page);
  }

  @override
  void onInit() {
    pageController.value = PageController(initialPage: currentPage.value);
    super.onInit();
  }

  @override
  void onClose() {
    pageController.value.dispose();
    super.onClose();
  }

  void updatePageContent(int index) {
    switch (index) {
      case 0:
        // Get.lazyPut(() => SliderController());
        final BookController bookController = Get.find<BookController>();
        bookController.fetchAllData();
        break;
      case 1:
        break;
      case 2:
        break;
      case 3:
        BookListController bookListController;
        if (Get.isRegistered<BookListController>()) {
          bookListController = Get.find<BookListController>();
        } else {
          bookListController = Get.put(BookListController());
        }
        bookListController.fetchDownloadedBooks();
        break;
      case 4:
        FavoriteController favoriteController;
        if (Get.isRegistered<FavoriteController>()) {
          favoriteController = Get.find<FavoriteController>();
        } else {
          favoriteController = Get.put(FavoriteController());
        }

        favoriteController.loadBookmarks();
        favoriteController.loadComments();
        break;
    }
  }
}
