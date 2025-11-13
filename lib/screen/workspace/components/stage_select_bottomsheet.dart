import 'package:coka/components/elevated_btn.dart';
import 'package:coka/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StageSelect extends StatelessWidget {
  final String defaultStage;
  final Function selectedStage;

  const StageSelect(
      {super.key, required this.defaultStage, required this.selectedStage});

  @override
  Widget build(BuildContext context) {
    return ElevatedBtn(
      circular: 6,
      paddingAllValue: 0,
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          isScrollControlled: true,
          builder: (context) =>
              StageSelectBottomSheet(selectedStage: selectedStage),
        );
      },
      child: Container(
        width: double.infinity,
        color: Colors.white,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/images/select_stage_icon.png",
              height: 25,
              width: 25,
            ),
            const SizedBox(
              width: 6,
            ),
            Text(
                defaultStage == ""
                    ? "Chọn trạng thái"
                    : stageList
                            .firstWhere((e) => e["id"] == defaultStage)["name"]
                            ?.toString() ??
                        "Chọn trạng thái",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(
              width: 4,
            ),
            const Icon(
              Icons.arrow_drop_down,
              size: 20,
            )
          ],
        ),
      ),
    );
  }
}

class StageSelectBottomSheet extends StatefulWidget {
  final Function selectedStage;

  const StageSelectBottomSheet({super.key, required this.selectedStage});

  @override
  State<StageSelectBottomSheet> createState() => _StageSelectBottomSheetState();
}

class _StageSelectBottomSheetState extends State<StageSelectBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            const Text(
              "Trạng thái",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(
              height: 15,
            ),
            ...stageObject.entries.map((e) {
              final key = e.key;
              final value = e.value;
              return ExpansionTile(
                title: Text(
                  value["name"].toString(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                children: [
                  ...(value["data"] as List).map((data) {
                    return ListTile(
                        title: Text(data["name"]),
                        onTap: () {
                          widget.selectedStage(data["id"]);
                          Get.back();
                        },
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
