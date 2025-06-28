import 'package:al_raheeq_library/app/config/get_version.dart';
import 'package:al_raheeq_library/app/config/retry_widget.dart';
import 'package:al_raheeq_library/app/core/common/widgets/custom_loading.dart';
import 'package:al_raheeq_library/app/features/intro/view/controller/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SplashController());
    final appVersionController = Get.put(AppVersionController());

    return Scaffold(
      body: SizedBox(
        width: Get.width,
        height: Get.height,
        child: Obx(() {
          if (controller.showRetry.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RetryWidget(
                    onTap: controller.retry,
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: controller.skip,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'تخطي',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/splash.png',
                width: Get.width * 0.6,
                height: Get.height * 0.3,
              ),
              const SizedBox(height: 20),
              const CustomLoading(),
              // Text version if needed
              // const SizedBox(height: 50),
              // Text('الإصدار: ${appVersionController.version.value}', style: TextStyle(fontSize: 12)),
            ],
          );
        }),
      ),
    );
  }
}
