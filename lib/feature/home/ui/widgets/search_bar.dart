import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:one_ai/feature/home/controllers/home_screen_controller.dart';
import 'package:one_ai/feature/home/ui/widgets/textformfield_border.dart';

class SearchBarMain extends StatelessWidget {
  SearchBarMain({super.key});

  final homeScreenController = Get.find<HomeScreenController>();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: homeScreenController.searchController,
            cursorColor: Colors.grey,
            decoration: InputDecoration(
              hintText: 'Search...',
              contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
              // Default border
              border: textFormFieldBorder(),
              // When not focused
              enabledBorder: textFormFieldBorder(),
              // When focused
              focusedBorder: textFormFieldBorder(),
              filled: true,
              fillColor: Colors.transparent,
              hintStyle: TextStyle(color: Colors.grey),
            ),
            style: TextStyle(color: Colors.white),
            onChanged: (value) => homeScreenController.filterSearchResults(value),
          ),
        ),
      ],
    );
  }
}
