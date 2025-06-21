import 'package:al_raheeq_library/app/core/common/constants/constants.dart';
import 'package:al_raheeq_library/app/core/routes/routes.dart';
import 'package:al_raheeq_library/app/features/intro/view/controller/onboarding_controller.dart';
import 'package:al_raheeq_library/app/features/intro/view/widgets/onborading_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnbordingPage extends StatelessWidget {
  const OnbordingPage({super.key});

  @override
  Widget build(BuildContext context) {
    OnboardingController onBoardingController = Get.put(OnboardingController());
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: onBoardingController.pageController,
            onPageChanged: onBoardingController.animatedToPage,
            children: const [
              OnBoradingItem(
                image: 'cn1',
                title: 'عرض مرن ومتعدد للكتب',
                description:
                    'استعرض الكتب بطرق متعددة، مع تصنيف حسب الموضوع أو المؤلف أو العنوان، ودعم للوضعين العمودي والأفقي.',
              ),
              OnBoradingItem(
                image: 'cn2',
                title: 'خدمات بحث متقدمة',
                description:
                    'بحث عام وتفصيلي بكلمات ملوّنة ونتائج مصنّفة، مع إشارات مرجعية، وارتباط بين الكتب، وفهرسة تفاعلية.',
              ),
              OnBoradingItem(
                image: 'cn3',
                title: 'تجربة قراءة مخصصة',
                description:
                    'تحكم في نوع الخط وحجمه، ألوان الخلفية (ليلي/نهاري)، نسخ النص، مشاركة الروابط، عرض منسّق للنصوص والفهرست والهوامش.',
              ),
            ],
          ),
          Container(
            alignment: const Alignment(-0.78, -0.83),
            child: ZoomTapAnimation(
              onTap: () {
                onBoardingController.goToPage(2);
              },
              child: const Text('تخطي'),
            ),
          ),
          Obx(
            () => Container(
              alignment: const Alignment(0, 0.85),
              child: onBoardingController.page.value != 2
                  ? SmoothPageIndicator(
                      controller: onBoardingController.pageController,
                      count: 3,
                      effect: ExpandingDotsEffect(
                        spacing: 8,
                        radius: 10,
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: Theme.of(context).colorScheme.onPrimary,
                        dotColor: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withAlpha(100),
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      width: (double.infinity),
                      child: ElevatedButton(
                        onPressed: () {
                          Get.offAllNamed(Routes.home);
                          Constants.localStorage
                              .write('hasSeenOnboarding', true);
                        },
                        child: const Text('ابدأ'),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
