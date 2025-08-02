import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:one_ai/constants/colors.dart';
import 'package:one_ai/feature/home/controllers/home_screen_controller.dart';
import 'package:one_ai/feature/webview/controllers/web_view_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: must_be_immutable
class WebviewScreen extends StatelessWidget {
  WebviewScreen({super.key});

  void onBackPressed() async {
    if (await webViewController.canGoBack()) {
      webViewController.goBack();
    } else {
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
              Get.back();
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
                  allowFileAccessFromFileURLs: true,
                  allowUniversalAccessFromFileURLs: true,
                  userAgent:
                      "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Mobile Safari/537.36",
                ),
                onWebViewCreated: (controller) {
                  webViewController = controller;

                  // JS Handler for file inputs
                  controller.addJavaScriptHandler(
                    handlerName: 'fileInputClicked',
                    callback: (args) async {
                      await _handleFilePicker(controller);
                    },
                  );
                },
                onLoadStop: (controller, uri) async {
                  // Inject JS to handle file input
                  await controller.evaluateJavascript(
                    source: """
                    document.querySelectorAll('input[type=file]').forEach(el => {
                      el.addEventListener('click', (e) => {
                        e.preventDefault();
                        window.flutter_inappwebview.callHandler('fileInputClicked');
                      });
                    });
                  """,
                  );
                },
                onProgressChanged: (controller, progress) {
                  webViewScreenController.progress.value = progress / 100;
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  return NavigationActionPolicy.ALLOW;
                },
                onCreateWindow: (controller, request) async {
                  // You can open a dialog or new screen for popups if needed
                  return true;
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
    );
  }

  Future<void> _handleFilePicker(InAppWebViewController controller) async {
    var permissionStatus = await Permission.photos.request();
    if (permissionStatus.isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final base64 = base64Encode(result.files.single.bytes!);
        final name = result.files.single.name;

        // Optionally inject back to input (not fully functional due to browser restrictions)
        await controller.evaluateJavascript(
          source:
              '''
          const fileInput = document.querySelector('input[type=file]');
          if (fileInput) {
            const blob = new Blob([Uint8Array.from(atob("$base64"), c => c.charCodeAt(0))], {type: 'image/jpeg'});
            const file = new File([blob], "$name", {type: "image/jpeg"});
            const dataTransfer = new DataTransfer();
            dataTransfer.items.add(file);
            fileInput.files = dataTransfer.files;
            fileInput.dispatchEvent(new Event('change'));
          }
        ''',
        );
      }
    } else {
      Get.snackbar("Permission Denied", "Cannot access files.");
    }
  }
}
