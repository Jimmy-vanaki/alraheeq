// import 'dart:async';

// import 'package:get/get.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// class SupportController extends GetxController {
//   var isLoading = true.obs;
//   var hasError = false.obs;

//   InAppWebViewController? webViewController;
//   Timer? timeoutTimer;

//   void onPageStarted() {
//     isLoading.value = true;
//     hasError.value = false;

//     timeoutTimer?.cancel();
//     timeoutTimer = Timer(const Duration(seconds: 10), () {
//       if (isLoading.value) {
//         hasError.value = true;
//         isLoading.value = false;
//       }
//     });
//   }

//   void onPageFinished() {
//     timeoutTimer?.cancel();
//     isLoading.value = false;
//     hasError.value = false;
//   }

//   void onPageError() {
//     timeoutTimer?.cancel();
//     isLoading.value = false;
//     hasError.value = true;
//   }

//   void retryLoad() {
//     hasError.value = false;
//     isLoading.value = true;
//     webViewController?.loadUrl(
//       urlRequest: URLRequest(url: WebUri("https://example.com")),
//     );
//   }

//   @override
//   void onClose() {
//     timeoutTimer?.cancel();
//     super.onClose();
//   }
// }
