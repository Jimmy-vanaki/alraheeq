import 'package:al_raheeq_library/app/core/common/constants/constants.dart';
import 'package:al_raheeq_library/app/features/category/view/controller/category_controller.dart';
import 'package:al_raheeq_library/app/features/category/view/widgets/sub_groups_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoryController categoryController = Get.put(CategoryController());

    // بارگذاری اولیه
    categoryController.loadBookGroups();

    return WillPopScope(
      onWillPop: () async {
        if (categoryController.selectedCategory.value != null) {
          categoryController.selectedCategory.value = null;
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Obx(() {
          if (categoryController.bookGroups.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final selectedCategory = categoryController.selectedCategory.value;

          if (selectedCategory != null) {
            final fatherId = categoryController.bookGroups
                .firstWhere(
                    (group) => group['name'] == selectedCategory)['fatherId']
                .toString();

            final subCategories =
                categoryController.subCategories[fatherId] ?? [];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ZoomTapAnimation(
                    onTap: () {
                      if (categoryController.selectedCategory.value != null) {
                        categoryController.selectedCategory.value = null;
                        return false;
                      }
                      return true;
                    },
                    child: SvgPicture.asset(
                      'assets/svgs/angle-left.svg',
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onPrimary,
                          BlendMode.srcIn),
                    ),
                  ),
                  Expanded(
                    child: SubGroupsWidget(subCategories: subCategories),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categoryController.bookGroups.length,
            itemBuilder: (context, index) {
              final item = categoryController.bookGroups[index];
              return ZoomTapAnimation(
                child: Card(
                  color: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: SvgPicture.asset(
                      'assets/svgs/books.icon.svg',
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                    title: Text(item["name"] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: Constants.containerBoxDecoration(context),
                      child: Text(
                        item["rownum"].toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    onTap: () {
                      categoryController.toggleCategory(
                          item["name"], item["fatherId"].toString());
                    },
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
