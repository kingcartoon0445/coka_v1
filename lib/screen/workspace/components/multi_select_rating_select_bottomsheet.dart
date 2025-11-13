import 'package:coka/components/elevated_btn.dart';
import 'package:coka/screen/workspace/main_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MultiRatingSelectBottomSheet extends StatefulWidget {
  const MultiRatingSelectBottomSheet({
    super.key,
  });

  @override
  State<MultiRatingSelectBottomSheet> createState() =>
      _MultiRatingSelectBottomSheetState();
}

final ratingObject = {
  "Chưa đánh giá": 0,
  "1 sao": 1,
  "2 sao": 2,
  "3 sao": 3,
  "4 sao": 4,
  "5 sao": 5
};

class _MultiRatingSelectBottomSheetState
    extends State<MultiRatingSelectBottomSheet> {
  final wmController = Get.put(WorkspaceMainController());
  var ratingSelectedList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ratingSelectedList = List.from(wmController.ratingFilterList.value);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text(
                    "Đánh giá",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Spacer(),
                  ElevatedBtn(
                      onPressed: () {
                        wmController.ratingFilterList.value =
                            ratingSelectedList;
                        wmController.update();
                        Get.back();
                      },
                      circular: 50,
                      paddingAllValue: 2,
                      child: const Icon(
                        CupertinoIcons.checkmark_alt,
                        color: Color(0xFF5C33F0),
                        size: 32,
                      ))
                ],
              ),
            ),
            const Divider(height: 1),
            ...ratingObject.entries.map((e) {
              final key = e.key;
              final value = e.value;
              final isSelected = ratingSelectedList
                  .any((element) => element["value"] == value);
              return ListTile(
                  title: Text(key),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (v) {
                      if (v ?? false) {
                        ratingSelectedList.add({"name": key, "value": value});
                      } else {
                        ratingSelectedList.removeWhere(
                            (element) => element["value"] == value);
                      }
                      setState(() {});
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ));
            }),
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      ],
    );
  }
}
