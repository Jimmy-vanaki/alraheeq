import 'package:al_raheeq_library/app/core/common/constants/constants.dart';

List<Map<String, dynamic>> getBookmarks() {
  final bookmarks = Constants.localStorage.read('bookmarks') ?? {};
  return (bookmarks as Map).entries.map((e) {
    return {
      'id': e.key,
      'name': e.value,
    };
  }).toList();
}


