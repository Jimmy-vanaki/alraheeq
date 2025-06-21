import 'package:al_raheeq_library/app/features/search/view/controller/search_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class BookDropdownSearch extends StatelessWidget {
  const BookDropdownSearch({super.key});

  @override
  Widget build(BuildContext context) {
    // Getting the controller instance
    final mainSearchController = Get.find<MainSearchController>();

    return Obx(() {
      return DropdownMenu(
        enableFilter: true,
        requestFocusOnTap: true,
        hintText: 'اختيار',
        trailingIcon: SvgPicture.asset(
          'assets/svgs/angle-small-down.svg',
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.onPrimary,
            BlendMode.srcIn,
          ),
        ),
        selectedTrailingIcon: SvgPicture.asset(
          'assets/svgs/angle-small-up.svg',
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.onPrimary,
            BlendMode.srcIn,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          contentPadding: const EdgeInsets.all(5.0),
          fillColor: Colors.white,
          border: const UnderlineInputBorder(borderSide: BorderSide.none),
        ),
        searchCallback: (entries, query) {
          final filteredEntries = entries.where((entry) {
            return entry.label.toLowerCase().contains(query.toLowerCase());
          }).toList();
          return filteredEntries.length;
        },
        onSelected: (id) {
          // Handle selection (id contains the selected Book's ID)
          print('Selected Book ID: $id');
          mainSearchController.selectedBook.value = id as int;
        },
        dropdownMenuEntries: [
          const DropdownMenuEntry<Object?>(
            label: 'الكل', // "All books" option
            value: -1, // You can define a custom value like "all"
          ),
          ...mainSearchController.downloadedBooks.map((book) {
            return DropdownMenuEntry<Object?>(
              label: book.title,
              value: book.id,
            );
          }),
        ],
      );
    });
  }
}
