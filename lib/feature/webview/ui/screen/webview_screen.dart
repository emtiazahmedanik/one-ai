import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:one_ai/feature/home/controllers/home_screen_controller.dart';
import 'package:one_ai/feature/webview/controllers/web_view_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
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
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.blue),
          ),
          title: Text(
            item['title'],
            style: TextStyle(color: Colors.blue),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.blue),
              onPressed: () {
                webViewController?.reload();
              },
            ),
          ],
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
                  pullToRefreshController?.endRefreshing();
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
                onDownloadStartRequest: (controller, request) async {
                  final url = request.url.toString();

                  if (url.startsWith("blob:")) {
                    debugPrint("Blob URL detected. Fetching via JS...");

                    // Run JS inside WebView to convert blob to Base64
                    final base64Data = await controller.evaluateJavascript(
                      source:
                      """
                      (async function() {
                        const blobUrl = "$url";
                        const response = await fetch(blobUrl);
                        const blob = await response.blob();
                        return new Promise((resolve, reject) => {
                          const reader = new FileReader();
                          reader.onloadend = () => resolve(reader.result.split(",")[1]); 
                          reader.onerror = reject;
                          reader.readAsDataURL(blob);
                        });
                      })();
                    """,
                    );

                    if (base64Data != null) {
                      await _saveBase64File(base64Data, "download.bin");
                      Get.snackbar(
                        "Download Complete",
                        "File saved successfully",
                      );
                    } else {
                      Get.snackbar("Error", "Failed to download blob file.");
                    }
                  } else {
                    debugPrint("Normal file URL: $url");
                    await _downloadFileHttp(url);
                  }
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

  Future<void> _saveBase64File(String base64Data, String fileName) async {
    final bytes = base64Decode(base64Data);
    final dir = await getExternalStorageDirectory();
    final filePath = "${dir!.path}/$fileName";
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    debugPrint("File saved to $filePath");
  }
  Future<void> _downloadFileHttp(String url) async {
    if (await Permission.storage.request().isGranted) {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = await getExternalStorageDirectory();
        final fileName = url.split('/').last;
        final filePath = "${dir!.path}/$fileName";
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        debugPrint("File saved to: $filePath");
      }
    }
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
  

}
