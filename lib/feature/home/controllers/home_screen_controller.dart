import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:one_ai/constants/ai_list.dart';

class HomeScreenController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  RxList<Map<String, dynamic>> filteredList = <Map<String, dynamic>>[].obs;

  void filterSearchResults(String query) {
    if (query.isEmpty) {
      filteredList.assignAll(aiList);
    } else {
      final results = aiList
          .where(
            (element) => element['title'].toString().toLowerCase().contains(
              query.toLowerCase(),
            ),
          )
          .toList();
      filteredList.assignAll(results);
    }
  }

  void filterSearchResultsWithTag() {
    final String selectedTag = tagList[selectedTagIndex.value];
    final actualTag = AiList.tagMap[selectedTag] ?? 'All';

    // Start with the full list
    List<Map<String, dynamic>> results = aiList;

    // If a specific tag is selected (not "All"), filter by tag
    if (selectedTag == 'All') {
      filteredList.assignAll(aiList);
    }else{
      debugPrint('Inside else: $actualTag');
      results = results
          .where((element) =>
      element['tag']?.toString().toLowerCase() == actualTag.toLowerCase())
          .toList();
      filteredList.assignAll(results);
      debugPrint('List:$results');
    }

  }


  RxInt selectedTagIndex = 0.obs;

  List<String> get tagList => AiList.tagMap.keys.toList();

  RxList<Map<String, dynamic>> aiList = AiList.aiList.obs;



  @override
  void onInit() {
    filteredList.assignAll(aiList);
    super.onInit();
  }
}
