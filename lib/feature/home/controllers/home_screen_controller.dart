import 'package:flutter/material.dart';
import 'package:get/get.dart';

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




  RxList<Map<String, dynamic>> aiList = [
    {'imagePath': 'assets/images/chatgpt.png', 'title': 'ChatGpt', 'url': 'https://chatgpt.com/'},
    {'imagePath': 'assets/images/gemini.png', 'title': 'Gemini', 'url': 'https://gemini.google.com/app'},
    {
      'imagePath': 'assets/images/perplexity.webp',
      'title': 'Perplexity',
      'url': 'https://www.perplexity.ai/',
    },
    {'imagePath': 'assets/images/grok.webp', 'title': 'Grok', 'url': 'https://grok.com/'},
  ].obs;

  @override
  void onInit() {
    filteredList.assignAll(aiList); 
    super.onInit();
  }
}
