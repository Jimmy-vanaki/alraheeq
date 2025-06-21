import 'package:al_raheeq_library/app/core/common/constants/constants.dart';
import 'package:al_raheeq_library/app/core/common/widgets/custom_loading.dart';
import 'package:al_raheeq_library/app/features/intro/data/data_source/update_books_api_provider.dart';
import 'package:al_raheeq_library/app/features/library/view/controller/ad_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class AdSlider extends StatelessWidget {
  const AdSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final updateProvider = Get.find<UpdateBooksApiProvider>();
    final currentIndex = 0.obs;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        final int itemsPerPage = width >= 900
            ? 3
            : width >= 600
                ? 2
                : 1;

        return Obx(() {
          final sliders = updateProvider.sliders;
          final int pageCount = (sliders.length / itemsPerPage).ceil();

          return Column(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: sliders.isNotEmpty ? 180.0 : 0,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  viewportFraction: 1,
                  onPageChanged: (index, reason) {
                    currentIndex.value = index;
                  },
                ),
                items: List.generate(pageCount, (pageIndex) {
                  final items = sliders
                      .skip(pageIndex * itemsPerPage)
                      .take(itemsPerPage)
                      .toList();

                  return Row(
                    children: items.map((slider) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ZoomTapAnimation(
                            onTap: () {},
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: CachedNetworkImage(
                                fit: BoxFit.fill,
                                imageUrl: slider['photo_url'] ?? '',
                                placeholder: (context, url) =>
                                    const CustomLoading(),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  'assets/images/not.jpg',
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ),
              const SizedBox(height: 12),
              Obx(() {
                final sliders = updateProvider.sliders;
                final int pageCount = (sliders.length / itemsPerPage).ceil();

                return AnimatedSmoothIndicator(
                  activeIndex: currentIndex.value,
                  count: pageCount,
                  effect: WormEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: Theme.of(context).colorScheme.onPrimary,
                    dotColor:
                        Theme.of(context).colorScheme.onPrimary.withAlpha(120),
                  ),
                );
              }),
            ],
          );
        });
      },
    );
  }
}
