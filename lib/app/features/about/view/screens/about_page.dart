import 'dart:convert';
import 'dart:io';

import 'package:al_raheeq_library/app/config/launch_url.dart';
import 'package:al_raheeq_library/app/core/common/widgets/custom_loading.dart';
import 'package:al_raheeq_library/app/features/about/view/controller/about_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:collection';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

class AboutPage extends StatelessWidget {
  const AboutPage({
    super.key,
    required this.fileName,
  });

  final String fileName;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AboutController());
// لیست لینک‌ها و آیکون‌ها برای شبکه‌های اجتماعی
// لیست شبکه‌های اجتماعی با مسیر آیکون و لینک مستقیم
    final List<_SocialItem> socialItems = [
      _SocialItem(
          'assets/svgs/youtube.svg', 'https://www.youtube.com/c/alyqoobi'),
      _SocialItem(
          'assets/svgs/twitter-alt.svg', 'https://twitter.com/NewsAlyaqoobi'),
      _SocialItem('assets/svgs/telegram.svg', 'https://yaqoobioffice.t.me'),
      _SocialItem('assets/svgs/facebook.svg',
          'https://www.facebook.com/news.alyaqoobi'),
      _SocialItem('assets/svgs/instagram.svg',
          'https://www.instagram.com/yaqoobi_com/'),
      _SocialItem('assets/svgs/whatsapp.svg',
          'https://api.whatsapp.com/send/?phone=9647519833704&text&type=phone_number&app_absent=0'),
    ];
    final path = Platform.isWindows
        ? 'data/flutter_assets/assets/web/html/$fileName'
        : 'assets/web/html/$fileName';

    final fileUrl = Uri.file(path).toString();
    return WillPopScope(
      onWillPop: () async {
        await controller.handleBack();
        return true;
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Image.asset(
                    "assets/images/bg-b.png",
                    height: Get.height,
                    width: Get.width,
                    fit: BoxFit.contain,
                    repeat: ImageRepeat.repeatX,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 90),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Obx(() => controller.showWebView.value
                          ? FutureBuilder(
                              future: copyAssetFolderToTemp(fileName),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return CustomLoading();
                                }

                                final localPath = snapshot.data as String;
                                final localUrl =
                                    WebUri(Uri.file(localPath).toString());
                                return InAppWebView(
                                  initialUrlRequest: URLRequest(url: localUrl),
                                  initialSettings: InAppWebViewSettings(
                                    transparentBackground: true,
                                    javaScriptEnabled: true,
                                    supportZoom: false,
                                    builtInZoomControls: false,
                                    displayZoomControls: false,
                                    pageZoom: 1,
                                    maximumZoomScale: 1,
                                    minimumZoomScale: 1,
                                    disableContextMenu: true,
                                  ),
                                  initialUserScripts:
                                      UnmodifiableListView<UserScript>([
                                    UserScript(
                                      source: '''
                              // Set transparent background for html and body
                              document.documentElement.style.backgroundColor = 'transparent';
                              document.body.style.backgroundColor = 'transparent';
                                                    
                              // Also force transparent background for all immediate child elements of body
                              Array.from(document.body.children).forEach(function(el) {
                                el.style.backgroundColor = 'transparent';
                              });
                                                    
                              // Hide scrollbar while keeping scroll active
                              document.body.style.overflowY = 'scroll'; // keep scroll active
                              document.body.style.msOverflowStyle = 'none'; // IE, Edge
                              document.body.style.scrollbarWidth = 'none'; // Firefox
                                                    
                              var styleEl = document.createElement('style');
                              styleEl.textContent = `
                                ::-webkit-scrollbar { 
                                  width: 0px; 
                                  background: transparent;
                                }
                              `;
                              document.head.appendChild(styleEl);
                            ''',
                                      injectionTime: UserScriptInjectionTime
                                          .AT_DOCUMENT_END,
                                      forMainFrameOnly: true,
                                    )
                                  ]),
                                  onWebViewCreated: (controller) async {},
                                  onLoadStop: (controller, url) async {},
                                );
                              })
                          : const SizedBox.shrink()),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 20,
                    width: Get.width - 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ZoomTapAnimation(
                          onTap: () async {
                            try {
                              final rawHtml = await rootBundle
                                  .loadString('assets/web/html/$fileName');

                              dom.Document document =
                                  html_parser.parse(rawHtml);
                              final plainText = document.body?.text ?? '';

                              if (Platform.isWindows) {
                                // Copy to clipboard on Windows
                                await Clipboard.setData(
                                    ClipboardData(text: plainText));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text('تم نسخ النص!'),
                                ));
                              } else {
                                // Use share_plus normally on other platforms
                                await Share.share(plainText,
                                    subject: 'Shared Content');
                              }
                            } catch (e) {
                              print('❌ Error: $e');
                            }
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
                              'assets/svgs/share.svg',
                              colorFilter: ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
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
            ),
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: socialItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ZoomTapAnimation(
                      onTap: () {
                        urlLauncher(item.url);
                      },
                      child: SvgPicture.asset(
                        item.assetPath,
                        height: 25,
                        colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.primary,
                            BlendMode.srcIn),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialItem {
  final String assetPath;
  final String url;

  const _SocialItem(this.assetPath, this.url);
}

Future<String> copyAssetFolderToTemp(String htmlFileName) async {
  final folder = 'assets/web/html/';
  final manifestContent = await rootBundle.loadString('AssetManifest.json');
  final manifestMap = json.decode(manifestContent) as Map<String, dynamic>;

  final files =
      manifestMap.keys.where((key) => key.startsWith(folder)).toList();
  final tempDir = await getTemporaryDirectory();

  for (final assetPath in files) {
    final data = await rootBundle.load(assetPath);
    final relativePath = assetPath.replaceFirst(folder, '');
    final file = File('${tempDir.path}/$relativePath');
    await file.create(recursive: true);
    await file.writeAsBytes(data.buffer.asUint8List());
  }

  // 🔁 Return the full path to the copied main HTML file (e.g., index.html)
  return '${tempDir.path}/$htmlFileName';
}
