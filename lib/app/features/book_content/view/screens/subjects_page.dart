import 'package:al_raheeq_library/app/core/common/constants/constants.dart';
import 'package:al_raheeq_library/app/features/book_content/view/controller/content_controller.dart';
import 'package:al_raheeq_library/app/features/book_content/view/controller/subject_controller.dart';
import 'package:al_raheeq_library/app/features/setting/view/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class SubjectsPage extends StatelessWidget {
  final List groups;
  final String bookName;
  final String bookId;
  const SubjectsPage({
    super.key,
    required this.groups,
    required this.bookName,
    required this.bookId,
  });

  @override
  Widget build(BuildContext context) {
    final ContentController contentController =
        Get.find<ContentController>(tag: bookId);
    final SubjectController subjectController = Get.put(SubjectController());
    SettingsController settingsController = Get.find<SettingsController>();

    subjectController.setGroups(groups);
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        actions: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                ),
                const Gap(10),
                Expanded(
                  child: Center(
                    child: Text(
                      bookName,
                    ),
                  ),
                ),
                const Gap(10),
                ZoomTapAnimation(
                  onTap: () {
                    Get.back();
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
                const Gap(10),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // search Box
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                // search box
                Expanded(
                  child: TextFormField(
                    controller: subjectController.searchController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'البحث',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
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
                )
              ],
            ),
          ),
          // list view
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: subjectController.filteredGroups.length,
                  itemBuilder: (context, index) {
                    final item = subjectController.filteredGroups[index];
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
                          title: Text(item["title"] ?? '',
                              style: const TextStyle(fontSize: 12)),
                          trailing: Container(
                            padding: EdgeInsets.all(10),
                            decoration:
                                Constants.containerBoxDecoration(context),
                            child: Text(
                              item["page"].toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          onTap: () async {
                            final bool verticalScroll =
                                settingsController.verticalScroll.value;
                            int page =
                                int.tryParse(item["page"].toString()) ?? 0;
                            if (verticalScroll) {
                              await contentController.inAppWebViewController
                                  .evaluateJavascript(source: '''
                              if ($page != 0) {
                                var y = getOffset(document.getElementById('book-mark_${page == 0 ? page : page.floor() - 1}')).top;
                                window.scrollTo(0, y);
                              };
                              ''');
                            } else {
                              print('object<<<<<<<<<<<<<<<<');
                              await contentController.inAppWebViewController
                                  .evaluateJavascript(source: '''
                                if ($page != 0) {
                                  var element = document.getElementById('book-mark_' + ($page == 0 ? $page : ${page.floor()} - 1));
                                  
                                  if (element) {
                                    var container = document.querySelector('.book-container-horizontal');
                                    
                                    if (container) {
                                      var elementRect = element.getBoundingClientRect();
                                      var containerRect = container.getBoundingClientRect();

                                      var x = elementRect.left - containerRect.left + container.scrollLeft;
                                      
                                      container.scrollTo({ left: x, behavior: 'smooth' });
                                    } else {
                                      console.log('Container not found!');
                                    }
                                  } else {
                                    console.log('Element not found!');
                                  }
                                }
                              ''');
                            }
                            Get.back();
                          },
                        ),
                      ),
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }
}
