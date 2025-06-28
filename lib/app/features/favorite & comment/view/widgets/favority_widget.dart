import 'package:al_raheeq_library/app/core/common/constants/confirm_action_dialog.dart';
import 'package:al_raheeq_library/app/core/common/constants/constants.dart';
import 'package:al_raheeq_library/app/features/book_content/view/screens/content_page.dart';
import 'package:al_raheeq_library/app/features/favorite%20&%20comment/view/controller/favorite_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class FavorityContainer extends StatelessWidget {
  final String bookName;
  final int bookId;
  final String pageNumber;
  final int index;

  const FavorityContainer({
    super.key,
    required this.bookName,
    required this.bookId,
    required this.pageNumber,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteController = Get.find<FavoriteController>();

    return ZoomTapAnimation(
      onTap: () {
        Get.to(() => ContentPage(
              bookId: bookId,
              bookName: bookName,
              scrollPosetion: double.parse(pageNumber) - 1,
              searchWord: '',
            ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: Constants.containerBoxDecoration(context).copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/svgs/books.icon.svg',
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onPrimary,
                BlendMode.srcIn,
              ),
            ),
            const Gap(10),
            Expanded(
              child: Text(
                bookName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Text(
                pageNumber,
              ),
            ),
            ZoomTapAnimation(
              onTap: () {
                showConfirmationDialog(
                  title: 'حذف الكتاب',
                  message: 'هل انت متأكد من حذف الاشارة المرجعية؟',
                  onConfirm: () {
                    favoriteController.removeBookmarkAt(
                        bookId, int.parse(pageNumber) - 1);
                  },
                );
              },
              child: SvgPicture.asset(
                'assets/svgs/trash-empty.svg',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onPrimary,
                  BlendMode.srcIn,
                ),
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
