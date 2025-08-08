import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:one_ai/constants/colors.dart';
import 'package:one_ai/feature/home/controllers/home_screen_controller.dart';
import 'package:one_ai/feature/webview/controllers/web_view_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: must_be_immutable
class WebviewScreen extends StatefulWidget {
  WebviewScreen({super.key});

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  @override
  void initState() {
    super.initState();
    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            settings: pullToRefreshSettings,
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                webViewController?.loadUrl(
                  urlRequest: URLRequest(
                    url: await webViewController?.getUrl(),
                  ),
                );
              }
            },
          );
  }

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

  PullToRefreshController? pullToRefreshController;

  PullToRefreshSettings pullToRefreshSettings = PullToRefreshSettings(
    color: Colors.blue,
  );

  bool pullToRefreshEnabled = true;

  bool _isFilePickerActive = false;

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
                pullToRefreshController: pullToRefreshController,
                initialSettings: InAppWebViewSettings(
                  supportMultipleWindows: true,
                  javaScriptCanOpenWindowsAutomatically: true,
                  databaseEnabled: true,
                  allowFileAccess: true,
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
                onPermissionRequest: (controller, request) async {
                  return PermissionResponse(
                    resources: request.resources,
                    action: PermissionResponseAction.GRANT,
                  );
                },
                onReceivedError: (controller, request, error) {
                  pullToRefreshController?.endRefreshing();
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
    if (_isFilePickerActive) return; // Don't open another picker

    _isFilePickerActive = true;

    try {
      var permissionStatus = await Permission.photos.request();
      if (permissionStatus.isGranted) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          withData: true,
        );

        if (result != null && result.files.single.bytes != null) {
          final base64 = base64Encode(result.files.single.bytes!);
          final name = result.files.single.name;

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
    } catch (e) {
      debugPrint("File picker error: $e");
    } finally {
      _isFilePickerActive = false;
    }
  }
  // Future<void> _handleFilePicker(InAppWebViewController controller) async {
  //   var permissionStatus = await Permission.photos.request();
  //   if (permissionStatus.isGranted) {
  //     FilePickerResult? result = await FilePicker.platform.pickFiles(
  //       type: FileType.any, // Support all file types for ChatGPT
  //       withData: true,
  //     );
  //
  //     if (result != null && result.files.single.bytes != null) {
  //       final base64 = base64Encode(result.files.single.bytes!);
  //       final name = result.files.single.name;
  //       final mimeType = _getMimeType(result.files.single.extension);
  //
  //       await controller.evaluateJavascript(
  //         source: '''
  //         console.log('Injecting file: $name, type: $mimeType');
  //         const fileInput = document.querySelector('input[type=file]');
  //         if (fileInput) {
  //           const blob = new Blob([Uint8Array.from(atob("$base64"), c => c.charCodeAt(0))], {type: "$mimeType"});
  //           const file = new File([blob], "$name", {type: "$mimeType"});
  //           const dataTransfer = new DataTransfer();
  //           dataTransfer.items.add(file);
  //           fileInput.files = dataTransfer.files;
  //           fileInput.dispatchEvent(new Event('input', { bubbles: true }));
  //           fileInput.dispatchEvent(new Event('change', { bubbles: true }));
  //         } else {
  //           console.log('No file input found');
  //         }
  //       ''',
  //       );
  //     } else {
  //       debugPrint('File picker returned no file or bytes');
  //     }
  //   } else {
  //     Get.snackbar("Permission Denied", "Cannot access files.");
  //   }
  // }

  String _getMimeType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
}
