import 'package:get/get.dart';
import 'package:one_ai/feature/home/ui/screen/home_screen.dart';
import 'package:one_ai/feature/webview/ui/screen/webview_screen.dart';

class AppRoute {
  static String homeScreen = '/homeScreen';
  static String webViewScreen = '/webViewScreen';

  static String get getHomeScreen => homeScreen;
  static String get getWebViewScreen => webViewScreen;

  static List<GetPage> routes = [
    GetPage(name: homeScreen, page: () => HomeScreen()),
    GetPage(name: webViewScreen, page: () => WebviewScreen())
  ];
}
