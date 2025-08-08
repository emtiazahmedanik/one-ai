import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:one_ai/feature/home/controllers/home_screen_controller.dart';
import 'package:one_ai/feature/home/ui/widgets/search_bar.dart';
import 'package:one_ai/route/app_route.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeScreenController = Get.find<HomeScreenController>();
    return Scaffold(
      appBar: AppBar(title: SearchBarMain(), backgroundColor: Colors.black),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16.0),
          child: Column(
            spacing: 10,
            children: [
              SizedBox(
                height: 30,
                child: buildTagListObx(homeScreenController),
              ),
              Expanded(
                child: Obx(
                  () => GridView.builder(
                    itemCount: homeScreenController.filteredList.length,
                    itemBuilder: (context, index) {
                      final item = homeScreenController.filteredList[index];
                      return InkWell(
                        onTap: () {
                          Get.toNamed(
                            AppRoute.getWebViewScreen,
                            arguments: index,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  item['imagePath'],
                                  height: 60,
                                  width: 60,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  item['title'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Obx buildTagListObx(HomeScreenController homeScreenController) {
    return Obx(
      () => ListView(
        scrollDirection: Axis.horizontal,
        children: List.generate(homeScreenController.tagList.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: InkWell(
              onTap: () {
                homeScreenController.selectedTagIndex.value = index;
                homeScreenController.filterSearchResultsWithTag();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                    color: homeScreenController.selectedTagIndex.value == index
                        ? Colors.blue
                        : Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  homeScreenController.tagList[index],
                  style: TextStyle(
                    color: homeScreenController.selectedTagIndex.value == index
                        ? Colors.blue
                        : Colors.white,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
