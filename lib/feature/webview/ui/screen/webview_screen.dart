import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:one_ai/feature/home/controllers/home_screen_controller.dart';

class WebviewScreen extends StatelessWidget {
  WebviewScreen({super.key});

  final int index = Get.arguments;
  final homeScreenController = Get.find<HomeScreenController>();

  @override
  Widget build(BuildContext context) {
    final item = homeScreenController.filteredList[index];
    return Scaffold(
      appBar: AppBar(
        title: Text(item['title']),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
        ),
      ),
    );
  }
}
