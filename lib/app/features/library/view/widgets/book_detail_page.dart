import 'package:al_raheeq_library/app/core/common/widgets/custom_loading.dart';
import 'package:al_raheeq_library/app/features/book_content/view/screens/content_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:share_plus/share_plus.dart';

class BookDetailPage extends StatelessWidget {
  final Map book;

  const BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/images/bg-b.png",
            height: Get.height,
            width: Get.width,
            fit: BoxFit.contain,
            repeat: ImageRepeat.repeatX,
          ),
          Padding(
            padding: const EdgeInsets.only(
                right: 15.0, left: 15, top: 30, bottom: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'book-image-${book['id']}',
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    width: 200,
                    height: 300,
                    imageUrl: book['img'] ?? '',
                    placeholder: (context, url) => const CustomLoading(),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/not.jpg',
                      fit: BoxFit.cover,
                      width: 200,
                      height: 300,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      book['description'],
                      style: TextStyle(
                        height: 2,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
                const Gap(10),
                ElevatedButton(
                  onPressed: () {
                    Get.to(
                      () => ContentPage(
                        bookId: book['id'],
                        bookName: (book['title'] ?? '') +
                            (book['joz'] != 0
                                ? ' ${book['joz']?.toString() ?? ''}'
                                : ''),
                        scrollPosetion: 0.0,
                        searchWord: '',
                      ),
                    );
                  },
                  child: Text('تصفح الكتاب'),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            width: Get.width - 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ZoomTapAnimation(
                  onTap: () async {
                    final textToShare = '''
${book['description']}
----------------------
أدعوك للاطلاع على تطبيق (مكتبة الرحيق المختوم) وذلك عبر الرابط التالي:

https://play.google.com/store/apps/details?id=com.dijlah.Sealedectar
                    ''';

                    await Share.share(textToShare);
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: SvgPicture.asset(
                      'assets/svgs/share-square.svg',
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                ZoomTapAnimation(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: SvgPicture.asset(
                      'assets/svgs/angle-left.svg',
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
