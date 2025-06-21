import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubjectController extends GetxController {
  TextEditingController searchController = TextEditingController();
  RxList<Map<String, dynamic>> filteredGroups = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> allGroups = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_filterGroups);
  }

  void setGroups(List groups) {
    allGroups.value = List<Map<String, dynamic>>.from(groups);
    filteredGroups.value = List<Map<String, dynamic>>.from(groups);
  }

  void _filterGroups() {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      filteredGroups.value = allGroups;
    } else {
      filteredGroups.value = allGroups
          .where((e) =>
              (e['title'] ?? '').toString().toLowerCase().contains(query))
          .toList();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
