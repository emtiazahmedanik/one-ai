import 'package:get/get.dart';
import 'package:one_ai/feature/home/controllers/home_screen_controller.dart';
import 'package:one_ai/feature/webview/controllers/web_view_controller.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeScreenController());
    Get.put(WebViewScreenController());
  }
}
