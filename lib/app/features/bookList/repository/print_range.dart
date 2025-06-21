import 'package:flutter/material.dart';

Future<List<int>?> showPageRangeDialog(
    BuildContext context, int totalPages) async {
  final startController = TextEditingController(text: '1');
  final endController = TextEditingController(text: totalPages.toString());

  return showDialog<List<int>>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'اختيار نطاق الصفحات',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: startController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'البدء من صفحة',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(fontSize: 13)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: endController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'الى الصفحة',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء', textDirection: TextDirection.rtl),
          ),
          ElevatedButton(
            onPressed: () {
              final start = int.tryParse(startController.text);
              final end = int.tryParse(endController.text);
              if (start != null &&
                  end != null &&
                  start >= 1 &&
                  end <= totalPages &&
                  start <= end) {
                Navigator.of(context).pop([start, end]);
              }
            },
            child: const Text('تأكيد', textDirection: TextDirection.rtl),
          ),
        ],
      );
    },
  );
}
