import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class InternalPage extends StatelessWidget {
  const InternalPage({
    super.key,
    required this.child,
  });
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.onPrimary.withAlpha(50),
              BlendMode.colorBurn,
            ),
            child: Image.asset(
              "assets/images/bg-b.png",
              height: Get.height,
              width: Get.width,
              fit: BoxFit.contain,
              repeat: ImageRepeat.repeatX,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 90),
            child: child,
          ),
          Positioned(
            top: 40,
            left: 20,
            width: Get.width - 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ZoomTapAnimation(
                  onTap: () async {
                    Get.back();
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: SvgPicture.asset(
                      'assets/svgs/angle-left.svg',
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
