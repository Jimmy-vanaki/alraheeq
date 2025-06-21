import 'package:al_raheeq_library/app/core/common/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class ModalComment {
  static void show(
    BuildContext context, {
    required int idBook,
    required String bookname,
    required int idPage,
    required bool updateMode,
    required int id,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController();
        TextEditingController titleController = TextEditingController();

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "تعليقك على ص $idPage من كتاب: $bookname",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'عنوان التعليق',
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
                  ),
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 16),

                // Comment input field
                TextField(
                  controller: controller,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'التعليق',
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
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 20),

                // Action buttons (Submit & Cancel)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (controller.text.isEmpty ||
                            titleController.text.isEmpty) {
                          Get.snackbar(
                            'خطأ',
                            'يرجى ملء جميع الحقول.',
                            colorText: Colors.white,
                            backgroundColor: Colors.redAccent.withAlpha(100),
                            icon:
                                Icon(Icons.error_outline, color: Colors.white),
                            snackPosition: SnackPosition.BOTTOM,
                            duration: Duration(seconds: 3),
                            margin: EdgeInsets.all(16),
                            borderRadius: 10,
                          );
                        } else {
                          String title = titleController.text.trim();
                          String comment = controller.text.trim();
                          String allCommentsKey = 'allBookComments';

                          List<dynamic> existingComments =
                              Constants.localStorage.read(allCommentsKey) ?? [];

                          // چک کن که آیا کامنت قبلی برای همین کتاب و صفحه وجود دارد
                          int existingIndex = existingComments.indexWhere((c) =>
                              c['idBook'] == idBook && c['idPage'] == idPage);

                          if (existingIndex != -1) {
                            // حذف کامنت قبلی
                            existingComments.removeAt(existingIndex);
                          }

                          // ایجاد کامنت جدید
                          Map<String, dynamic> newComment = {
                            'id': DateTime.now().millisecondsSinceEpoch,
                            'idBook': idBook,
                            'bookName': bookname,
                            'idPage': idPage,
                            'title': title,
                            'comment': comment,
                            'createdAt': DateTime.now().toIso8601String(),
                          };

                          // اضافه کردن کامنت جدید
                          existingComments.add(newComment);

                          await Constants.localStorage
                              .write(allCommentsKey, existingComments);

                          Get.snackbar(
                            'تم الحفظ',
                            '✅ تم حفظ التعليق بنجاح',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor:
                                Colors.green.shade600.withAlpha(240),
                            colorText: Colors.white,
                            icon: Icon(Icons.check_circle_outline,
                                color: Colors.white),
                            borderRadius: 12,
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            duration: Duration(seconds: 2),
                            isDismissible: true,
                          );

                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('إرسال'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close modal without action
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.onPrimary,
                            width: 1),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ],
                ),
                const Gap(20),
              ],
            ),
          ),
        );
      },
    );
  }
}
