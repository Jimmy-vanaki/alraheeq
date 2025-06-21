import 'package:al_raheeq_library/app/core/common/constants/confirm_action_dialog.dart';
import 'package:al_raheeq_library/app/core/common/constants/constants.dart';
import 'package:al_raheeq_library/app/features/book_content/repository/modal_comment.dart';
import 'package:al_raheeq_library/app/features/favorite%20&%20comment/view/controller/favorite_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:intl/intl.dart';

class CommentContainer extends StatelessWidget {
  const CommentContainer({
    super.key,
    required this.comment,
  });

  final Map<String, dynamic> comment;

  @override
  Widget build(BuildContext context) {
    DateTime createdAt = DateTime.parse(comment['createdAt']);
    String formattedDate = DateFormat('dd/MM/yyyy').format(createdAt);
    final FavoriteController favoriteController =
        Get.find<FavoriteController>();
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(10),
      decoration: Constants.containerBoxDecoration(context)
          .copyWith(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  comment['bookName'] ?? 'نام کتاب',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                decoration: Constants.containerBoxDecoration(context),
                width: 30,
                height: 30,
                alignment: Alignment.center,
                child: Text(
                  comment['idPage'].toString(),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
          Container(
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(100),
              borderRadius: BorderRadius.circular(10),
            ),
            width: Get.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'العنوان: ${comment['title'] ?? ''}',
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.justify,
                    maxLines: 100,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'النص: ${comment['comment'] ?? ''}',
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.justify,
                    maxLines: 100,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(formattedDate),
              ),
              ZoomTapAnimation(
                onTap: () {
                  showConfirmationDialog(
                    title: 'حذف التعليق',
                    message: 'هل أنت متأكد من أنك تريد حذف هذا التعليق؟',
                    onConfirm: () {
                      favoriteController.deleteComment(comment['id']);
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
              const Gap(10),
              ZoomTapAnimation(
                onTap: () {
                  ModalComment.show(
                    context,
                    updateMode: false,
                    id: DateTime.now().millisecondsSinceEpoch,
                    idPage: comment['idPage'],
                    idBook: comment['idBook'],
                    bookname: comment['bookName'],
                  );
                  favoriteController.loadComments();
                },
                child: SvgPicture.asset(
                  'assets/svgs/file-edit.svg',
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onPrimary,
                    BlendMode.srcIn,
                  ),
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
