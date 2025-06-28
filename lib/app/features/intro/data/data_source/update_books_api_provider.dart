import 'dart:async';

import 'package:al_raheeq_library/app/config/status.dart';
import 'package:al_raheeq_library/app/core/common/constants/constants.dart';
import 'package:al_raheeq_library/app/core/database/db_helper.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class UpdateBooksApiProvider extends GetxController {
  // Reactive status to track the request state
  late Rx<Status> rxRequestStatus;
  final RxBool showRetryButton = false.obs;
  RxInt currentPage = 0.obs;
  RxList sliders = [].obs;
  @override
  void onInit() {
    super.onInit();
    rxRequestStatus = Status.init.obs;
  }

  // Function to fetch updated books
  Future<Status> fetchUpdatedBooks({required String lastUpdate}) async {
    rxRequestStatus.value = Status.loading;

    try {
      final response = await http
          .post(
        Uri.parse('${Constants.baseUrl}home'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"last_update": lastUpdate}),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          showRetryButton.value = true;
          throw TimeoutException('Request timed out');
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final books = List<Map<String, dynamic>>.from(json['books'] ?? []);
        final categories =
            List<Map<String, dynamic>>.from(json['categories'] ?? []);
        sliders
            .assignAll(List<Map<String, dynamic>>.from(json['sliders'] ?? []));

        rxRequestStatus.value = Status.success;
        await DBHelper.upsertBooksBatch(books);
        await DBHelper.upsertCategoriesBatch(categories);
        Constants.localStorage.write('last_update', json['last_update']);

        return Status.success;
      } else {
        rxRequestStatus.value = Status.error;
        return Status.error;
      }
    } catch (e) {
      rxRequestStatus.value = Status.error;
      return Status.error;
    }
  }
}
