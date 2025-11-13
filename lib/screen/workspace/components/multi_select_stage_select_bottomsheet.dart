import 'package:coka/components/elevated_btn.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/workspace/main_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MultiStageSelectBottomSheet extends StatefulWidget {
  const MultiStageSelectBottomSheet({
    super.key,
  });

  @override
  State<MultiStageSelectBottomSheet> createState() =>
      _MultiStageSelectBottomSheetState();
}

class _MultiStageSelectBottomSheetState
    extends State<MultiStageSelectBottomSheet> {
  final wmController = Get.put(WorkspaceMainController());
  var stageSelectedList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    stageSelectedList = List.from(wmController.stageFilterList.value);
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
                    "Trạng thái",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Spacer(),
                  ElevatedBtn(
                      onPressed: () {
                        wmController.stageFilterList.value = stageSelectedList;
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
            ...stageObject.entries.map((e) {
              final key = e.key;
              final value = e.value;
              return ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 20),
                title: Text(
                  value["name"].toString(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                children: [
                  ...(value["data"] as List).map((data) {
                    final isSelected =
                        stageSelectedList.any((e) => e["id"] == data["id"]);
                    return ListTile(
                        title: Text(data["name"]),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (v) {
                            if (v ?? false) {
                              stageSelectedList.add(data);
                            } else {
                              stageSelectedList
                                  .removeWhere((e) => e["id"] == data["id"]);
                            }
                            setState(() {});
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 32,
                        ));
                  })
                ],
              );
            }),
            const SizedBox(
              height: 25,
            ),
          ],
        ),
      ],
    );
  }
}
