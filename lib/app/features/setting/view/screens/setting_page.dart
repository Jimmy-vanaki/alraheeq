// lib/pages/settings_page.dart
import 'package:al_raheeq_library/app/core/common/widgets/internal_page.dart';
import 'package:al_raheeq_library/app/features/setting/view/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class SettingPage extends StatelessWidget {
  final SettingsController controller = Get.put(SettingsController());

  SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: controller.backgroundColor.value,
          body: InternalPage(
              child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 🅰️ سایز فونت
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.onPrimary.withAlpha(50),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "حجم الخط :",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        // Decrease font size button
                        ZoomTapAnimation(
                          onTap: () {
                            if (controller.fontSize.value > 12) {
                              controller.fontSize.value -= 1;
                            }
                          },
                          child: Image.asset(
                            'assets/images/co-st01.png',
                            width: 30,
                            height: 30,
                          ),
                        ),

                        // Slider widget
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8),
                              overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 12),
                              activeTrackColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              inactiveTrackColor: Colors.grey.withAlpha(100),
                              thumbColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: Slider(
                              value: controller.fontSize.value,
                              min: 12,
                              max: 36,
                              divisions: 24,
                              label:
                                  controller.fontSize.value.toInt().toString(),
                              // Update fontSize value on slider change
                              onChanged: (value) =>
                                  controller.fontSize.value = value,
                            ),
                          ),
                        ),
                        // Increase font size button
                        ZoomTapAnimation(
                          onTap: () {
                            if (controller.fontSize.value < 36) {
                              controller.fontSize.value += 1;
                            }
                          },
                          child: Image.asset(
                            'assets/images/co-st02.png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 🅱️ فاصله بین خطوط
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.onPrimary.withAlpha(50),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "تباعد الأسطر :",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        // Decrease line height button
                        ZoomTapAnimation(
                          onTap: () {
                            if (controller.lineHeight.value > 1.0) {
                              controller.lineHeight.value =
                                  (controller.lineHeight.value - 0.1)
                                      .clamp(1.0, 3.0);
                            }
                          },
                          child: Image.asset(
                            'assets/images/co-st04.png',
                            width: 30,
                            height: 30,
                          ),
                        ),

                        // Slider widget
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8),
                              overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 12),
                              activeTrackColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              inactiveTrackColor: Colors.grey.withAlpha(100),
                              thumbColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: Slider(
                              value: controller.lineHeight.value,
                              min: 1.0,
                              max: 3.0,
                              divisions: 20, // each step is 0.1
                              label: controller.lineHeight.value
                                  .toStringAsFixed(1),
                              onChanged: (value) =>
                                  controller.lineHeight.value = value,
                            ),
                          ),
                        ),
                        // Increase line height button

                        ZoomTapAnimation(
                          onTap: () {
                            if (controller.lineHeight.value < 3.0) {
                              controller.lineHeight.value =
                                  (controller.lineHeight.value + 0.1)
                                      .clamp(1.0, 3.0);
                            }
                          },
                          child: Image.asset(
                            'assets/images/co-st03.png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 🟡 انتخاب رنگ متن
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.onPrimary.withAlpha(50),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "الوان المظهر :",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: controller.themeColorSchemes.map((scheme) {
                        return GestureDetector(
                          onTap: () {
                            controller.isDarkMode.value = false;
                            controller.setTheme(scheme, isDarkMode: false);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 12),
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: controller.selectedColorScheme.value
                                            .primary ==
                                        scheme.primary
                                    ? Colors.red
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // 🔤 فونت
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.onPrimary.withAlpha(50),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "نوع الخط :",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(10),
                    DropdownButton<String>(
                      value: controller.fontFamily.value,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'لوتوس', child: Text("لوتوس")),
                        DropdownMenuItem(
                            value: 'البهيج', child: Text("البهيج")),
                        DropdownMenuItem(value: 'دجلة', child: Text("دجلة")),
                      ],
                      onChanged: (value) =>
                          controller.fontFamily.value = value!,
                    ),
                  ],
                ),
              ),

              // 🎨 رنگ پس‌زمینه
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.onPrimary.withAlpha(50),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "لون الخلفية :",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildBgColorOption(Colors.white),
                        _buildBgColorOption(const Color(0xFFDAD0A7)),
                        _buildBgColorOption(Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),

              // ↔️ جهت پیمایش
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.onPrimary.withAlpha(50),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "عرض الصفحة :",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(10),
                    Obx(() {
                      return Container(
                        // اضافه کردن بوردر دور دکمه‌ها
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withAlpha(80),
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            // گزینه افقی
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    controller.setVerticalScroll(false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: !controller.verticalScroll.value
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                            .withAlpha(50)
                                        : Colors.transparent,
                                    borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.swap_horiz, size: 20),
                                      Gap(4),
                                      Text("افقی",
                                          style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // گزینه عمودی
                            Expanded(
                              child: GestureDetector(
                                onTap: () => controller.setVerticalScroll(true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: controller.verticalScroll.value
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                            .withAlpha(50)
                                        : Colors.transparent,
                                    borderRadius: const BorderRadius.horizontal(
                                      right: Radius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.swap_vert, size: 20),
                                      Gap(4),
                                      Text("عمودی",
                                          style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // 📝 پیش‌نمایش
              // Container(
              //   margin: const EdgeInsets.symmetric(vertical: 12),
              //   padding: const EdgeInsets.all(12),
              //   decoration: BoxDecoration(
              //     color: controller.selectedTheme.value.withOpacity(0.1),
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   child: Text(
              //     "بسم الله الرحمن الرحيم\nالحمد لله رب العالمين والصلاة والسلام على سيدنا محمد وعلى آله الطيبين الطاهرين",
              //     textAlign: TextAlign.center,
              //     style: TextStyle(
              //       fontSize: controller.fontSize.value,
              //       fontFamily: controller.fontFamily.value,
              //       height: controller.lineHeight.value,
              //       color: controller.backgroundColor.value == Colors.black
              //           ? Colors.white
              //           : Colors.black,
              //     ),
              //   ),
              // ),
            ],
          )),
        ));
  }

  // Background color option as widget
  Widget _buildBgColorOption(Color color) {
    final controller = Get.find<SettingsController>();
    return Obx(() => GestureDetector(
          onTap: () => controller.backgroundColor.value = color,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: controller.backgroundColor.value == color
                    ? controller.selectedTheme.value
                    : Colors.grey,
                width: 2,
              ),
            ),
          ),
        ));
  }
}
