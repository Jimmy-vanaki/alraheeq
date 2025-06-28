import 'dart:convert';

import 'package:al_raheeq_library/app/config/status.dart';
import 'package:al_raheeq_library/app/core/common/constants/constants.dart';
import 'package:al_raheeq_library/app/core/common/widgets/custom_loading.dart';
import 'package:al_raheeq_library/app/core/common/widgets/empty_widget.dart';
import 'package:al_raheeq_library/app/features/audio/view/controller/audio_controller.dart';
import 'package:al_raheeq_library/app/features/book_content/repository/content_repository.dart';
import 'package:al_raheeq_library/app/features/book_content/repository/modal_comment.dart';
import 'package:al_raheeq_library/app/features/book_content/repository/save_dialog.dart';
import 'package:al_raheeq_library/app/features/book_content/view/controller/search_content_controller.dart';
import 'package:al_raheeq_library/app/features/book_content/view/screens/subjects_page.dart';
import 'package:another_xlider/enums/tooltip_direction_enum.dart';
import 'package:another_xlider/models/handler.dart';
import 'package:another_xlider/models/tooltip/tooltip.dart';
import 'package:another_xlider/models/trackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:al_raheeq_library/app/features/book_content/view/controller/content_controller.dart';
import 'package:al_raheeq_library/app/features/setting/view/controller/settings_controller.dart';
import 'package:another_xlider/another_xlider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ContentPage extends StatelessWidget {
  final int bookId;
  final String bookName;
  final String searchWord;
  final double scrollPosetion;
  const ContentPage({
    super.key,
    required this.bookId,
    required this.bookName,
    required this.searchWord,
    required this.scrollPosetion,
  });

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.put(SettingsController());
    final SearchContentController searchContentController =
        Get.put(SearchContentController());
    final ContentController contentController = Get.put(
      ContentController(bookId.obs),
      tag: bookId.toString(),
    );
    final bool verticalScroll = settingsController.verticalScroll.value;

    AudioController audioController;

// Check if the controller is already registered
    if (Get.isRegistered<AudioController>()) {
      // If already registered, find it
      audioController = Get.find<AudioController>();
    } else {
      // If not registered, create and register it
      audioController = Get.put(AudioController());
    }

    return WillPopScope(
      onWillPop: () async {
        if (contentController.currentPage.value > 10 &&
            contentController.currentPage.value <
                contentController.pages.length) {
          showSaveBookDialog(
              context,
              bookName,
              contentController.currentPage.value.toInt(),
              bookId,
              contentController.pages.length);
        }
        await contentController.handleBack();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: null,
          automaticallyImplyLeading: false,
          actions: [
            Expanded(
              child: Row(
                children: [
                  const Gap(10),
                  ZoomTapAnimation(
                    onTap: () {
                      Get.to(() => SubjectsPage(
                            groups: contentController.groups,
                            bookName: bookName,
                            bookId: bookId.toString(),
                          ));
                    },
                    child: SvgPicture.asset(
                      'assets/svgs/index-book.svg',
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onPrimary,
                          BlendMode.srcIn),
                    ),
                  ),
                  const Gap(10),
                  Obx(
                    () => ZoomTapAnimation(
                      onTap: () {
                        if (searchContentController.showSearcResult.value &&
                            !searchContentController.showSearch.value) {
                          searchContentController.showSearch.value = false;
                          searchContentController.showSearcResult.value = false;

                          contentController.inAppWebViewController
                              .evaluateJavascript(
                            source: "clearHighlights();",
                          );

                          searchContentController.searchController.text = '';
                        } else {
                          searchContentController.showSearch.value =
                              !searchContentController.showSearch.value;
                          // searchContentController.showSearcResult.value =
                          //     !searchContentController.showSearcResult.value;
                        }
                      },
                      child: SvgPicture.asset(
                        !searchContentController.showSearcResult.value
                            ? 'assets/svgs/search.svg'
                            : 'assets/svgs/not-found-alt.svg',
                        width: 22,
                        height: 22,
                        colorFilter: ColorFilter.mode(
                            searchContentController.showSearcResult.value
                                ? Colors.red
                                : Theme.of(context).colorScheme.onPrimary,
                            BlendMode.srcIn),
                      ),
                    ),
                  ),
                  const Gap(10),
                  contentController.bookInfo.value?['sound_url'] != ''
                      ? ZoomTapAnimation(
                          onTap: () {
                            contentController.showAudio.value =
                                !contentController.showAudio.value;
                          },
                          child: SvgPicture.asset(
                            'assets/svgs/comment-alt-music.svg',
                            width: 22,
                            height: 22,
                            colorFilter: ColorFilter.mode(
                                Theme.of(context).colorScheme.onPrimary,
                                BlendMode.srcIn),
                          ),
                        )
                      : SizedBox(),
                  const Gap(10),
                  const Gap(10),
                  Expanded(
                    child: Center(
                      child: Text(
                        bookName,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ),
                  const Gap(10),
                  ZoomTapAnimation(
                    onTap: () {
                      contentController.showContentSettings.value =
                          !contentController.showContentSettings.value;
                    },
                    child: SvgPicture.asset(
                      'assets/svgs/settings.svg',
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onPrimary,
                          BlendMode.srcIn),
                    ),
                  ),
                  const Gap(10),
                  Obx(() => ZoomTapAnimation(
                        onTap: () {
                          final id = bookId.toString();

                          toggleBookmark(id, bookName);

                          final bookmarks =
                              Constants.localStorage.read('bookmarks') ?? {};
                          final isAdded = bookmarks.containsKey(id);

                          contentController.isBookmarked.value = isAdded;
                          Get.closeAllSnackbars();
                          Get.snackbar(
                            isAdded ? 'تمت الإضافة' : 'تمت الإزالة',
                            isAdded
                                ? 'تم إضافة "$bookName" إلى المفضلة'
                                : 'تمت إزالة "$bookName" من المفضلة',
                            snackPosition: SnackPosition.BOTTOM,
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.black54,
                            colorText: Colors.white,
                            margin: EdgeInsets.all(12),
                            borderRadius: 10,
                          );
                        },
                        child: SvgPicture.asset(
                          contentController.isBookmarked.value
                              ? 'assets/svgs/star-fill.svg'
                              : 'assets/svgs/star.svg',
                          width: 22,
                          height: 22,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.onPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                      )),
                  const Gap(10),
                  ZoomTapAnimation(
                    onTap: () async {
                      if (contentController.currentPage.value > 10 &&
                          contentController.currentPage.value <
                              contentController.pages.length) {
                        showSaveBookDialog(
                            context,
                            bookName,
                            contentController.currentPage.value.toInt(),
                            bookId,
                            contentController.pages.length);
                      } else {
                        Get.back();
                        await contentController.handleBack();
                      }
                    },
                    child: SvgPicture.asset(
                      'assets/svgs/angle-left.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const Gap(10),
                ],
              ),
            )
          ],
        ),
        body: Obx(() {
          if (contentController.status.value == Status.loading) {
            return const Center(child: CustomLoading());
          }

          if (contentController.pages.isEmpty) {
            return const Center(child: EmptyWidget(title: 'لا يوجد صفحة'));
          }

          if (contentController.status.value == Status.success &&
              contentController.htmlContent.value.isEmpty) {
            return const Center(child: CustomLoading());
          }
          return contentController.showWebView.value
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    Flex(
                      direction:
                          verticalScroll ? Axis.horizontal : Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      textDirection: TextDirection.ltr,
                      children: [
                        const Gap(5),
                        Expanded(
                          child: SizedBox(
                            width: verticalScroll ? Get.width - 40 : Get.width,
                            child: InAppWebView(
                              initialSettings: InAppWebViewSettings(
                                useShouldInterceptRequest: true,
                                javaScriptEnabled: true,
                                domStorageEnabled: true,
                                allowFileAccessFromFileURLs: true,
                                allowUniversalAccessFromFileURLs: true,
                                useShouldOverrideUrlLoading: true,
                                javaScriptCanOpenWindowsAutomatically: true,
                                supportZoom: false,
                                horizontalScrollBarEnabled: false,
                                verticalScrollBarEnabled: false,
                                pageZoom: 1,
                                maximumZoomScale: 1,
                                minimumZoomScale: 1,
                                useOnLoadResource: true,
                              ),
                              initialData: InAppWebViewInitialData(
                                data: contentController.htmlContent.value,
                                mimeType: "text/html",
                                encoding: "utf-8",
                              ),
                              onWebViewCreated: (controller) async {
                                contentController.inAppWebViewController =
                                    controller;

                                // await controller.evaluateJavascript(
                                //     source:
                                //         "window.flutter_inappwebview.callHandler('onSearchPositionChanged', 3);");
                              },
                              shouldInterceptRequest:
                                  (controller, request) async {
                                String url = request.url.toString();
                                print("Intercepted URL: $url");

                                if (url.startsWith("asset://")) {
                                  String assetFileName =
                                      url.replaceFirst("asset://", "");

                                  try {
                                    ByteData assetData = await rootBundle
                                        .load("assets/$assetFileName");
                                    Uint8List bytes =
                                        assetData.buffer.asUint8List();
                                    String contentType = "text/plain";

                                    if (assetFileName.endsWith(".css")) {
                                      contentType = "text/css";
                                    } else if (assetFileName.endsWith(".gif")) {
                                      contentType = "image/gif";
                                    }

                                    return WebResourceResponse(
                                      data: bytes,
                                      statusCode: 200,
                                      reasonPhrase: "OK",
                                      contentType: contentType,
                                      headers: {
                                        "Access-Control-Allow-Origin": "*"
                                      },
                                    );
                                  } catch (e) {
                                    print("Error loading asset: $e");
                                  }
                                }

                                return null;
                              },
                              onLoadStop: (controller, url) async {
                                await controller.evaluateJavascript(source: '''
                                  document.documentElement.style.scrollbarWidth = 'none';
                                  document.body.style.msOverflowStyle = 'none';
                                  document.documentElement.style.overflow = 'auto';
                                  document.body.style.overflow = 'auto';

                                  var style = document.createElement('style');
                                  style.innerHTML = '::-webkit-scrollbar { display: none; }';
                                  document.head.appendChild(style);
                                ''');

                                final bgColor =
                                    Theme.of(context).colorScheme.surface;
                                final hexColor =
                                    '#${bgColor.value.toRadixString(16).substring(2)}';

                                await controller.evaluateJavascript(
                                    source:
                                        "document.body.style.backgroundColor = '$hexColor';");
                                final jsonData = jsonEncode(
                                  contentController.pages.map((item) {
                                    final originalText = item['_text'] ?? '';
                                    var processedText =
                                        applyTextReplacements(originalText);

                                    // Highlight the searchWord if it's not empty
                                    if (searchWord.isNotEmpty) {
                                      final regex = RegExp(
                                          RegExp.escape(searchWord),
                                          caseSensitive: false);
                                      processedText = processedText
                                          .replaceAllMapped(regex, (match) {
                                        return '<span class="highlight">${match[0]}</span>';
                                      });
                                    }

                                    return processedText;
                                  }).toList(),
                                );

                                await controller.evaluateJavascript(source: '''
                                  (function() {
                                    var data = $jsonData;
                                    for (var i = 0; i < data.length; i++) {
                                      var el = document.getElementById("page___" + i);
                                      if (el) el.innerHTML = data[i];
                                    }
                                  })();
                                ''');

                                controller.addJavaScriptHandler(
                                  handlerName: 'CommentEvent',
                                  callback: (args) async {
                                    int pageNumber = args[0] + 1;

                                    ModalComment.show(
                                      context,
                                      updateMode: false,
                                      id: pageNumber,
                                      idPage: pageNumber,
                                      idBook: bookId,
                                      bookname: bookName,
                                    );
                                  },
                                );

                                controller.addJavaScriptHandler(
                                  handlerName: 'onSearchPositionChanged',
                                  callback: (args) {
                                    print("======2>>" + args.toString());
                                    if (args.length == 2) {
                                      searchContentController
                                          .currentMatchIndex.value = args[0];
                                      searchContentController
                                          .totalMatchCount.value = args[1];
                                    }
                                  },
                                );

                                controller.addJavaScriptHandler(
                                  handlerName: 'bookmarkToggled',
                                  callback: (args) async {
                                    var pageNumber = args[0];
                                    var bookmarkData = {
                                      'bookId': bookId,
                                      'pageNumber': pageNumber,
                                      'bookName': bookName,
                                    };

                                    String? savedBookmarks =
                                        Constants.localStorage.read('bookmark');
                                    List<dynamic> bookmarks = [];
                                    if (savedBookmarks != null) {
                                      var decodedData =
                                          jsonDecode(savedBookmarks);

                                      if (decodedData is List) {
                                        bookmarks = decodedData;
                                      } else if (decodedData is Map) {
                                        bookmarks = [decodedData];
                                      }
                                    }

                                    var existingBookmarkIndex =
                                        bookmarks.indexWhere((bookmark) =>
                                            bookmark['bookId'] == bookId &&
                                            bookmark['pageNumber'] ==
                                                pageNumber);

                                    if (existingBookmarkIndex != -1) {
                                      bookmarks.removeAt(existingBookmarkIndex);
                                      print('Bookmark removed');
                                    } else {
                                      bookmarks.add(bookmarkData);
                                      print('Bookmark saved: $bookmarkData');
                                    }

                                    Constants.localStorage.write(
                                        'bookmark', jsonEncode(bookmarks));
                                  },
                                );

                                // Scroll SPY
                                if (verticalScroll) {
                                  await controller
                                      .evaluateJavascript(source: '''
                                      if (${contentController.scrollPosetion.value} != 0) {
                                        var y = getOffset(document.getElementById('book-mark_${contentController.scrollPosetion.value == 0 ? contentController.scrollPosetion.value : contentController.scrollPosetion.value.floor() - 1}')).top;
                                        window.scrollTo(0, y);
                                      };
                                      ''');
                                  controller.evaluateJavascript(source: r"""
                                                $(window).on('scroll', function() {
                                            var currentTop = $(window).scrollTop();
                                            var elems = $('.BookPage-vertical');
                                            elems.each(function(index) {
                                                var elemTop = $(this).offset().top;
                                                var elemBottom = elemTop + $(this).height();
                                                if (currentTop >= elemTop && currentTop <= elemBottom) {
                                                    var page = $(this).attr('data-page');
                                                    window.flutter_inappwebview.callHandler('scrollSpy', page);
                                                }
                                            });
                                                });
                                              """);
                                  await controller
                                      .evaluateJavascript(source: '''
                          var scrollPosition = ${scrollPosetion == 0 ? 0 : scrollPosetion.floor()};
                          var element = document.getElementById('book-mark_' + scrollPosition);
                          if (element != null) {
                            var y = getOffset(element).top;
                            window.scrollTo(0, y);
                          }
                        ''');
                                } else {
                                  controller.evaluateJavascript(source: r"""
                                    $(document).ready(function () {
                                      var container = $('.book-container-horizontal');

                                      container.on('scroll', function () {
                                        var containerScrollLeft = container.scrollLeft();
                                        var containerWidth = container.width();

                                        $('.BookPage-horizontal').each(function () {
                                          var $page = $(this);
                                          var pageLeft = $page.position().left;
                                          var pageWidth = $page.outerWidth();
                                          var pageRight = pageLeft + pageWidth;

                                          // Check if page is in view
                                          if (
                                            pageLeft < containerWidth &&
                                            pageRight > 0
                                          ) {
                                            var page = $page.attr('data-page');
                                            window.flutter_inappwebview.callHandler('scrollSpy', page);
                                            return false; // break after finding the first visible page
                                          }
                                        });
                                      });
                                    });
                                                """);
                                  await controller
                                      .evaluateJavascript(source: '''
                                      var scrollPosition = ${scrollPosetion == 0 ? 0 : scrollPosetion.floor()};
                                      var element = document.getElementById('book-mark_' + scrollPosition);
                                      var container = document.querySelector('.book-container-horizontal');

                                      if (element && container) {
                                        var elementRect = element.getBoundingClientRect();
                                        var containerRect = container.getBoundingClientRect();
                                        var scrollX = elementRect.left - containerRect.left + container.scrollLeft;
                                        container.scrollTo({ left: scrollX, behavior: 'smooth' });
                                      }
                                    ''');
                                }
                                controller.addJavaScriptHandler(
                                  handlerName: 'scrollSpy',
                                  callback: (arguments) {
                                    if (arguments.isNotEmpty &&
                                        double.tryParse(arguments[0]) != null) {
                                      double page = double.parse(arguments[0]);
                                      if (contentController.currentPage.value !=
                                              page &&
                                          page > 0) {
                                        contentController.currentPage.value =
                                            double.parse(arguments[0]);
                                      }
                                      debugPrint("$arguments <<<<=======SPY");
                                    } else {
                                      debugPrint(
                                          "Invalid arguments: $arguments");
                                    }
                                  },
                                );
                                controller.evaluateJavascript(source: r'''
                              $(function () {
                                  $('[data-toggle="tooltip"]').tooltip({
                                    placement: 'bottom',
                                    html: true
                                  });
                                });
                                ''');
                              },
                              onLoadStart: (controller, url) async {},
                            ),
                          ),
                        ),
                        const Gap(5),
                        SizedBox(
                          width: verticalScroll ? 15 : Get.width,
                          height: verticalScroll ? Get.height : 15,
                          child: Obx(
                            () {
                              return FlutterSlider(
                                axis: verticalScroll
                                    ? Axis.vertical
                                    : Axis.horizontal,
                                rtl: verticalScroll ? false : true,
                                values: [contentController.currentPage.value],
                                max: contentController.pages.length.toDouble(),
                                min: 1,
                                tooltip: FlutterSliderTooltip(
                                  disabled: false,
                                  direction: verticalScroll
                                      ? FlutterSliderTooltipDirection.left
                                      : FlutterSliderTooltipDirection.top,
                                  disableAnimation: false,
                                  custom: (value) => Padding(
                                    padding: const EdgeInsets.only(right: 0),
                                    child: Card(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          bottomRight: Radius.circular(8),
                                        ),
                                      ),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          value.toStringAsFixed(0),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                trackBar: FlutterSliderTrackBar(
                                    activeTrackBar: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary)),
                                handler: FlutterSliderHandler(
                                    child: const SizedBox()),
                                onDragCompleted:
                                    (handlerIndex, lower, upper) async {
                                  final controller =
                                      contentController.inAppWebViewController;
                                  if (verticalScroll) {
                                    await controller.evaluateJavascript(
                                      source: '''
                                          window.scrollTo(0, 0);
                                          var y = getOffset( document.querySelector('[data-page="${lower.floor() - 1}"]') ).top;
                                          window.scrollTo(0, y);
                                          ''',
                                    );
                                  } else {
                                    await controller
                                        .evaluateJavascript(source: '''
                                  var x = getOffset(document.querySelector('[data-page="${lower.floor() - 1}"]')).left;
                                  horizontal_container.scrollLeft = x;
                                ''');
                                  }
                                },
                              );
                            },
                          ),
                        ),
                        const Gap(5),
                      ],
                    ),

                    //  Search Box
                    Obx(() {
                      return AnimatedPositioned(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        top: searchContentController.showSearch.value ? 0 : -70,
                        left: 0,
                        right: 0,
                        height: 70,
                        child: Container(
                          height: 70,
                          color: Theme.of(context).colorScheme.surface,
                          padding: EdgeInsets.all(10),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onPrimary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Form(
                              key: searchContentController.searchFormKey,
                              child: Row(
                                children: [
                                  // search box
                                  Expanded(
                                    child: TextFormField(
                                      controller: searchContentController
                                          .searchController,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'لا يمكن أن يكون نص البحث فارغاً';
                                        }
                                        if (value.trim().length < 3) {
                                          return 'الرجاء إدخال 3 أحرف على الأقل';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'البحث',
                                        hintStyle: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: 14,
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),

                                  ZoomTapAnimation(
                                    child: SvgPicture.asset(
                                      'assets/svgs/search.svg',
                                      colorFilter: ColorFilter.mode(
                                        Theme.of(context).colorScheme.primary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    onTap: () {
                                      if (searchContentController
                                          .searchFormKey.currentState!
                                          .validate()) {
                                        final searchText =
                                            searchContentController
                                                .searchController.text
                                                .trim();
                                        contentController.inAppWebViewController
                                            .evaluateJavascript(
                                                source:
                                                    "highlight_search('$searchText','highlight')");
                                        searchContentController
                                            .showSearcResult.value = true;
                                        searchContentController
                                            .showSearch.value = false;
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    //  buttons search
                    Obx(
                      () => AnimatedPositioned(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        bottom: searchContentController.showSearcResult.value
                            ? 0
                            : -70,
                        child: Container(
                          width: Get.width,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: Constants.containerBoxDecoration(context)
                              .copyWith(
                            borderRadius: BorderRadius.circular(0),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ZoomTapAnimation(
                                onTap: () {
                                  contentController.inAppWebViewController
                                      .evaluateJavascript(
                                    source: "goToPrevMatchPage();",
                                  );
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration:
                                      Constants.containerBoxDecoration(context),
                                  width: 35,
                                  height: 35,
                                  child: SvgPicture.asset(
                                    'assets/svgs/angle-double-right.svg',
                                    width: 12,
                                    height: 12,
                                    colorFilter: ColorFilter.mode(
                                        Colors.white, BlendMode.srcIn),
                                  ),
                                ),
                              ),
                              Obx(() => Text(
                                    '${searchContentController.currentMatchIndex} من ${searchContentController.totalMatchCount}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  )),
                              ZoomTapAnimation(
                                onTap: () {
                                  contentController.inAppWebViewController
                                      .evaluateJavascript(
                                    source: "goToNextMatchPage();",
                                  );
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration:
                                      Constants.containerBoxDecoration(context),
                                  width: 35,
                                  height: 35,
                                  child: RotatedBox(
                                    quarterTurns: 2,
                                    child: SvgPicture.asset(
                                      'assets/svgs/angle-double-right.svg',
                                      width: 12,
                                      height: 12,
                                      colorFilter: ColorFilter.mode(
                                          Colors.white, BlendMode.srcIn),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    //  Setting Container
                    Obx(
                      () {
                        return contentController.showContentSettings.value
                            ? GestureDetector(
                                onTap: () {
                                  contentController.showContentSettings.value =
                                      false;
                                },
                                child: Container(
                                  width: Get.width,
                                  height: Get.height,
                                  decoration: BoxDecoration(
                                    color: Colors.black38,
                                  ),
                                  alignment: Alignment.center,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: 400,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.all(20),
                                    margin: EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Font Size Slider
                                        Text("حجم الخط:"),
                                        SliderTheme(
                                          data:
                                              SliderTheme.of(context).copyWith(
                                            trackHeight: 2,
                                            thumbShape: RoundSliderThumbShape(
                                                enabledThumbRadius: 8),
                                            overlayShape:
                                                RoundSliderOverlayShape(
                                                    overlayRadius: 12),
                                            activeTrackColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            inactiveTrackColor:
                                                Colors.grey.shade300,
                                            thumbColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          child: Slider(
                                              value: settingsController
                                                  .fontSize.value,
                                              min: 10,
                                              max: 30,
                                              divisions: 20,
                                              label: settingsController
                                                  .fontSize.value
                                                  .round()
                                                  .toString(),
                                              onChanged: (value) {
                                                settingsController
                                                    .isApplying.value = true;
                                                settingsController
                                                    .setFontSize(value);

                                                Future.delayed(
                                                    Duration(milliseconds: 500),
                                                    () {
                                                  contentController
                                                      .inAppWebViewController
                                                      .evaluateJavascript(
                                                    source: """
                                                  document.querySelectorAll('.text_style').forEach(function(el) {
                                                    el.style.setProperty('font-size', '${value}px', 'important');
                                                    });
                                                  """,
                                                  ).whenComplete(() {
                                                    settingsController
                                                        .isApplying
                                                        .value = false;
                                                  });
                                                });
                                              }),
                                        ),

                                        const Gap(20),
                                        const Text("تباعد الأسطر:"),
                                        SliderTheme(
                                          data:
                                              SliderTheme.of(context).copyWith(
                                            trackHeight: 2,
                                            thumbShape: RoundSliderThumbShape(
                                                enabledThumbRadius: 8),
                                            overlayShape:
                                                RoundSliderOverlayShape(
                                                    overlayRadius: 12),
                                            activeTrackColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            inactiveTrackColor:
                                                Colors.grey.shade300,
                                            thumbColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          child: Slider(
                                            value: settingsController
                                                .lineHeight.value,
                                            min: 1,
                                            max: 3,
                                            divisions: 10,
                                            label: settingsController
                                                .lineHeight.value
                                                .toStringAsFixed(1),
                                            onChanged: (value) {
                                              settingsController
                                                  .isApplying.value = true;
                                              settingsController
                                                  .setLineHeight(value);
                                              Future.delayed(
                                                  Duration(milliseconds: 300),
                                                  () {
                                                contentController
                                                    .inAppWebViewController
                                                    .evaluateJavascript(
                                                  source: """
                                                document.querySelectorAll('.text_style').forEach(function(el) {
                                                  el.style.setProperty('line-height', '$value', 'important');
                                                });
                                              """,
                                                ).whenComplete(() {
                                                  settingsController
                                                      .isApplying.value = false;
                                                });
                                              });
                                            },
                                          ),
                                        ),

                                        const Gap(20),
                                        const Text("نوع الخط:"),
                                        const Gap(10),
                                        // Font Type Dropdown
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: Colors.grey.shade300,
                                                width: 1),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: settingsController
                                                  .fontFamily.value,
                                              isExpanded: true,
                                              items: const [
                                                DropdownMenuItem(
                                                    value: 'لوتوس',
                                                    child: Text("لوتوس")),
                                                DropdownMenuItem(
                                                    value: 'البهيج',
                                                    child: Text("البهيج")),
                                                DropdownMenuItem(
                                                    value: 'دجلة',
                                                    child: Text("دجلة")),
                                              ],
                                              onChanged: (value) async {
                                                settingsController
                                                    .setFontFamily(value!);
                                                settingsController
                                                    .isApplying.value = true;

                                                final css =
                                                    await contentController
                                                        .loadFont();

                                                Future.delayed(
                                                    Duration(milliseconds: 500),
                                                    () async {
                                                  await contentController
                                                      .inAppWebViewController
                                                      .evaluateJavascript(
                                                    source: """
                                                    var style = document.getElementById('customFontStyle');
                                                    if (!style) {
                                                      style = document.createElement('style');
                                                      style.id = 'customFontStyle';
                                                      document.head.appendChild(style);
                                                    }
                                                    style.innerHTML = `$css`;

                                                    document.querySelectorAll('.text_style').forEach(function(el) {
                                                      el.style.setProperty('font-family', '$value', 'important');
                                                    });
                                                  """,
                                                  );
                                                  settingsController
                                                      .isApplying.value = false;
                                                });
                                              },
                                            ),
                                          ),
                                        ),

                                        const Gap(20),

                                        // Background Color Selection
                                        const Text(
                                          "لون الخلفية:",
                                        ),
                                        const Gap(10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _buildColorCircle(
                                                Colors.white,
                                                settingsController,
                                                contentController),
                                            _buildColorCircle(
                                                Color(0xFFDAD0A7),
                                                settingsController,
                                                contentController),
                                            _buildColorCircle(
                                                Colors.grey,
                                                settingsController,
                                                contentController),
                                          ],
                                        ),
                                        const Gap(10),
                                        Obx(() => settingsController
                                                .isApplying.value
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child: CustomLoading(),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                        "جاري تطبيق التغييرات..."),
                                                  ],
                                                ),
                                              )
                                            : SizedBox.shrink())
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox.shrink();
                      },
                    ),

                    //  Comment

//            showModalBottomSheet(
//   context: context,
//   isScrollControlled: true,
//   builder: (context) {
//     return Text('Hello from Modal');
//   },
// );
// AUDIO
                    Obx(
                      () => AnimatedPositioned(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        bottom: contentController.showAudio.value ? 0 : -70,
                        child: Stack(
                          children: [
                            Container(
                              width: Get.width,
                              height: 70,
                              padding: EdgeInsets.all(5),
                              decoration:
                                  Constants.containerBoxDecoration(context)
                                      .copyWith(
                                borderRadius: BorderRadius.circular(0),
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Gap(10),
                                  Row(
                                    children: [
                                      ZoomTapAnimation(
                                        onTap: () {
                                          audioController.seekBackward();
                                        },
                                        child: SvgPicture.asset(
                                          'assets/svgs/time-forward-ten.svg',
                                          width: 20,
                                          height: 20,
                                          colorFilter: ColorFilter.mode(
                                            Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                      const Gap(15),
                                      ZoomTapAnimation(
                                        onTap: () async {
                                          final bookInfo =
                                              contentController.bookInfo.value;
                                          if (bookInfo != null) {
                                            final soundUrl =
                                                bookInfo['sound_url'];
                                            final title = bookInfo['title'];
                                            final writer = bookInfo['writer'];
                                            final img = bookInfo['img'];

                                            print("❌soundUrl ==>$soundUrl");
                                            audioController.togglePlayPause(
                                              soundUrl,
                                              title,
                                              writer,
                                              img,
                                            );
                                          } else {
                                            print("❌ Book info not found");
                                          }
                                        },
                                        child: SvgPicture.asset(
                                          audioController.isPlaying.value
                                              ? 'assets/svgs/pause-circle.svg'
                                              : 'assets/svgs/play-circle.svg',
                                          width: 24,
                                          height: 24,
                                          colorFilter: ColorFilter.mode(
                                            Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                      const Gap(15),
                                      ZoomTapAnimation(
                                        onTap: () {
                                          audioController.seekForward();
                                        },
                                        child: SvgPicture.asset(
                                          'assets/svgs/time-forward-ten2.svg',
                                          width: 20,
                                          height: 20,
                                          colorFilter: ColorFilter.mode(
                                            Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(20),
                                  Expanded(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                bookName,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(fontSize: 13),
                                              ),
                                              Text(
                                                contentController.bookInfo
                                                        .value?['writer'] ??
                                                    '',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Gap(20),
                                        Image.network(contentController
                                            .bookInfo.value?['img']),
                                        const Gap(10),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: -8,
                              left: 0,
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  // thumbShape: SliderComponentShape.noThumb,
                                  thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: 0),
                                  trackHeight: 3,
                                  trackShape: RectangularSliderTrackShape(),
                                ),
                                child: SizedBox(
                                  width: Get.width,
                                  height: 20,
                                  child: Slider(
                                    padding: EdgeInsets.zero,
                                    value: audioController
                                        .position.value.inSeconds
                                        .toDouble(),
                                    min: 0.0,
                                    max: audioController
                                        .duration.value.inSeconds
                                        .toDouble(),
                                    onChanged: (value) {
                                      audioController.seekTo(
                                          Duration(seconds: value.toInt()));
                                    },
                                    activeColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    inactiveColor: Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withAlpha(105),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : SizedBox.shrink();
        }),
      ),
    );
  }
}

Widget _buildColorCircle(Color color, SettingsController settingsController,
    ContentController contentController) {
  return GestureDetector(
    onTap: () {
      settingsController.isApplying.value = true;
      settingsController.setBackgroundColor(color);
      final hexColor = '#${color.value.toRadixString(16).substring(2)}';

      Future.delayed(Duration(milliseconds: 300), () {
        contentController.inAppWebViewController.evaluateJavascript(
          source: """
        document.querySelectorAll('.book_page').forEach(function(el) {
          el.style.setProperty('background-color', '$hexColor', 'important');
        });
      """,
        ).whenComplete(() {
          settingsController.isApplying.value = false;
        });
      });
    },
    child: Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: settingsController.backgroundColor.value == color
                  ? Colors.red
                  : Colors.grey,
              width: 1,
            ),
          ),
        ),
      ],
    ),
  );
}
