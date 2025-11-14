import 'package:coka/components/elevated_btn.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MultiWorkSpaceSelectBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> dataFilterList;
  final Function(List<Map<String, dynamic>>) onSelected;
  final List<Map<String, dynamic>> selectedList;
  const MultiWorkSpaceSelectBottomSheet({
    super.key,
    required this.dataFilterList,
    required this.onSelected,
    required this.selectedList,
  });

  @override
  State<MultiWorkSpaceSelectBottomSheet> createState() =>
      _MultiRatingSelectBottomSheetState();
}

// final ratingObject = {
//   "Chưa đánh giá": 0,
//   "1 sao": 1,
//   "2 sao": 2,
//   "3 sao": 3,
//   "4 sao": 4,
//   "5 sao": 5
// };

class _MultiRatingSelectBottomSheetState
    extends State<MultiWorkSpaceSelectBottomSheet> {
  // final wmController = Get.put(WorkspaceMainController());
  var workSpaceSelectedList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    workSpaceSelectedList = List.from(widget.selectedList);
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
                    "Chọn không gian làm việc",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Spacer(),
                  ElevatedBtn(
                      onPressed: () {
                        // wmController.ratingFilterList.value =
                        //     ratingSelectedList;
                        // wmController.update();
                        widget.onSelected(
                            workSpaceSelectedList.cast<Map<String, dynamic>>());
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
            ...widget.dataFilterList.map((e) {
              final isSelected = workSpaceSelectedList
                  .any((element) => element["id"] == e["id"]);
              return InkWell(
                onTap: () {
                  if (isSelected) {
                    workSpaceSelectedList
                        .removeWhere((element) => element["id"] == e["id"]);
                  } else {
                    workSpaceSelectedList
                        .add({"id": e["id"], "name": e["name"]});
                  }
                  setState(() {});
                },
                child: ListTile(
                    title: Text(e["name"]),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (v) {
                        if (v ?? false) {
                          workSpaceSelectedList
                              .add({"id": e["id"], "name": e["name"]});
                        } else {
                          workSpaceSelectedList.removeWhere(
                              (element) => element["id"] == e["id"]);
                        }
                        setState(() {});
                      },
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    )),
              );
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
