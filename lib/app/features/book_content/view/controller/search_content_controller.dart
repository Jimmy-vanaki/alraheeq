import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchContentController extends GetxController {
  final RxInt currentMatchIndex = 0.obs;
  final RxInt totalMatchCount = 0.obs;
  RxBool showSearch = false.obs;
  RxBool showSearcResult = false.obs;

  final TextEditingController searchController = TextEditingController();
  final GlobalKey<FormState> searchFormKey = GlobalKey<FormState>();
}
