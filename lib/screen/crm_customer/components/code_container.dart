import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../components/custom_snackbar.dart';

class CodeSnippetContainer extends StatelessWidget {
  final String code;

  const CodeSnippetContainer({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            code,
            style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 16.0,
            ),
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            maxLines: 10,
          ),
          const SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              successSnackbar(text: 'Đoạn code đã được sao chép',context: Get.context!);

            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEF1F0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              elevation: 0
            ),
            child: const Text('Sao chép',style: TextStyle(color: Color(0xFFF7706E),fontWeight: FontWeight.bold),),
          ),
        ],
      ),
    );
  }
}
