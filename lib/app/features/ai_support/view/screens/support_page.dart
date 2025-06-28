import 'package:al_raheeq_library/app/features/ai_support/controller/support_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(SupportController());
    return Scaffold(
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri("http://ai.library.yaqoobi.net"),
            ),
            onWebViewCreated: (webViewController) {
              webViewController = webViewController;
            },
          ),
        ],
      ),
    );
  }
}
