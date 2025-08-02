import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:one_ai/constants/colors.dart';
import 'package:one_ai/feature/home/controllers/home_screen_controller.dart';
import 'package:one_ai/feature/webview/controllers/web_view_controller.dart';

class WebviewScreen extends StatelessWidget {
  WebviewScreen({super.key});

  void onBackPressed() async {
    if (await webViewController.canGoBack()) {
      // Navigate back in WebView history
      webViewController.goBack();
    } else {
      // No more history, close screen and overlays
      webViewScreenController.progress.value = 0.0;
      Get.back(closeOverlays: true);
    }
  }

  final int index = Get.arguments;
  final homeScreenController = Get.find<HomeScreenController>();

  late InAppWebViewController webViewController;
  final webViewScreenController = Get.find<WebViewScreenController>();

  @override
  Widget build(BuildContext context) {
    final item = homeScreenController.filteredList[index];
    final String url = item['url'];
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        onBackPressed();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              webViewScreenController.progress.value = 0.0;
              Get.back(closeOverlays: true);
            },
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.appDefaultColor,
            ),
          ),
          title: Text(
            item['title'],
            style: TextStyle(color: AppColors.appDefaultColor),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(url)),
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    cacheEnabled: true,
                    useShouldOverrideUrlLoading: true,
                    mediaPlaybackRequiresUserGesture: false,
                    allowsInlineMediaPlayback: true,
                    thirdPartyCookiesEnabled: true,
                    userAgent:
                        "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Mobile Safari/537.36",
                  ),
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStop: (controller, uri) async {
                    debugPrint("Loaded: $uri");
                  },
                  onProgressChanged: (controller, newProgress) {
                    webViewScreenController.progress.value = newProgress / 100;
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                        var uri = navigationAction.request.url;
                        if (uri != null) {
                          return NavigationActionPolicy.ALLOW;
                        }
                        return NavigationActionPolicy.ALLOW;
                      },
                ),

                Obx(
                  () => webViewScreenController.progress.value < 1.0
                      ? LinearProgressIndicator(
                          value: webViewScreenController.progress.value,
                          backgroundColor: Colors.transparent,
                          color: Colors.blueAccent.shade400,
                          minHeight: 3,
                        )
                      : SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
