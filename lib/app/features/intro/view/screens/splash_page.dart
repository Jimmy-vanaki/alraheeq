import 'package:al_raheeq_library/app/config/get_version.dart';
import 'package:al_raheeq_library/app/config/retry_widget.dart';
import 'package:al_raheeq_library/app/config/status.dart';
import 'package:al_raheeq_library/app/core/common/constants/constants.dart';
import 'package:al_raheeq_library/app/core/common/widgets/custom_loading.dart';
import 'package:al_raheeq_library/app/core/routes/routes.dart';
import 'package:al_raheeq_library/app/features/intro/data/data_source/update_books_api_provider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  Future<void> _fetchUpdatedBooks(UpdateBooksApiProvider updateProvider) async {
    final lastUpdate =
        Constants.localStorage.read('last_update') ?? '2023-02-15 16:39:22';
    await updateProvider.fetchUpdatedBooks(lastUpdate: lastUpdate);

    if (updateProvider.rxRequestStatus.value == Status.success) {
      final hasSeen = Constants.localStorage.read('hasSeenOnboarding') ?? false;

      if (hasSeen) {
        Get.offAllNamed(Routes.home);
      } else {
        Get.offAllNamed(Routes.onBording);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final updateProvider = Get.find<UpdateBooksApiProvider>();
    final AppVersionController appVersionController =
        Get.put(AppVersionController());
    Future.delayed(Duration.zero, () => _fetchUpdatedBooks(updateProvider));

    return Scaffold(
      body: SizedBox(
        width: Get.width,
        height: Get.height,
        child: Obx(
          () {
            return Container(
              alignment: Alignment.center,
              child: updateProvider.showRetryButton.value
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RetryWidget(
                            onTap: () {
                              updateProvider.showRetryButton.value = false;
                              _fetchUpdatedBooks(updateProvider);
                            },
                          ),
                          const Gap(20),
                          OutlinedButton(
                            onPressed: () {
                              final hasSeen = Constants.localStorage
                                      .read('hasSeenOnboarding') ??
                                  false;

                              if (hasSeen) {
                                Get.offAllNamed(Routes.home);
                              } else {
                                Get.offAllNamed(Routes.onBording);
                              }
                            },
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
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/splash.png',
                          width: Get.width * 0.6,
                          height: Get.height * 0.3,
                        ),
                        const Gap(20),
                        CustomLoading(),
                        const Gap(50),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'الاصدار: ',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: appVersionController.version.value,
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
