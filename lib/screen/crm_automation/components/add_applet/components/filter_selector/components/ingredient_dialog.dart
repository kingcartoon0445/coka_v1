import 'package:coka/components/elevated_btn.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/crm_automation/components/add_applet/add_applet_controller.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/trigger_selector/trigger_selector_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class IngredientDialog extends StatefulWidget {
  final Function onIngTap;
  const IngredientDialog({super.key, required this.onIngTap});

  @override
  State<IngredientDialog> createState() => _IngredientDialogState();
}

class _IngredientDialogState extends State<IngredientDialog> {
  List<Map> actionList = [];
  List<Map> dataList = [];
  Map currentAction = {};
  AddAppletController addAppletController = Get.put(AddAppletController());
  TriggerSelectorController selectorController =
      Get.put(TriggerSelectorController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final Map triggerObject = addAppletController.triggerData;
    final Map triggerData = selectorController.testData;
    selectorController.testRun();

    if (triggerUiData[triggerObject["type"]]?["triggers"] != null) {
      actionList.removeWhere((e) => e["name"] == currentAction["name"]);
      currentAction = {
        "id": (triggerUiData[triggerObject["type"]]?["triggers"]
            as List)[triggerObject["index"]]?["id"],
        "name": (triggerUiData[triggerObject["type"]]?["triggers"]
            as List)[triggerObject["index"]]?["title"],
        "iconPath": triggerUiData[triggerObject["type"]]?["iconPath"],
      };
      for (var x in triggerData.entries) {
        dataList.add({"key": x.key, "value": x.value});
      }

      actionList.add(currentAction);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Nguyên liệu",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      content: Wrap(
        children: [
          Column(
            children: [
              Container(
                width: Get.width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
                child: PopupMenuButton<Map>(
                    splashRadius: 0,
                    offset: const Offset(0, 30),
                    onSelected: (Map value) {
                      setState(() {
                        currentAction = value;
                      });
                    },
                    initialValue: currentAction,
                    itemBuilder: (BuildContext context) {
                      return actionList.map((Map item) {
                        print(item);
                        return PopupMenuItem<Map>(
                          value: item,
                          padding: EdgeInsets.zero,
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              SvgPicture.asset(
                                currentAction["iconPath"],
                                width: 30,
                                height: 30,
                              ),
                              Container(
                                  width: Get.width - 140,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    item['name'],
                                    style: const TextStyle(
                                        color: Color(0xFF171A1F),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (currentAction["iconPath"] != null)
                          SvgPicture.asset(
                            currentAction["iconPath"],
                            width: 30,
                            height: 30,
                          ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: Get.width - 180,
                          child: Text(
                            currentAction['name'] ?? "Chưa có dữ liệu",
                            style: const TextStyle(
                                color: Color(0xFF171A1F),
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.black,
                          size: 30,
                        )
                      ],
                    )),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  height: 200,
                  width: double.maxFinite,
                  child: ListView.builder(
                    physics: const ClampingScrollPhysics(),
                    itemCount: dataList.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      return selectorController
                                  .formatData[dataList[index]["key"]] ==
                              null
                          ? Container()
                          : ElevatedBtn(
                              circular: 0,
                              onPressed: () {
                                widget.onIngTap({
                                  "action": currentAction,
                                  "data": selectorController
                                      .formatData[dataList[index]["key"]]
                                      .toString()
                                });
                                Get.back();
                              },
                              paddingAllValue: 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 15),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                "${selectorController.formatData[dataList[index]["key"]]}: ",
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          TextSpan(
                                            text: dataList[index]["value"]
                                                .toString(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (selectorController.testData.keys
                                          .lastWhere((element) =>
                                              selectorController
                                                  .formatData[element] !=
                                              null) !=
                                      dataList[index]["key"])
                                    Container(
                                      width: double.infinity,
                                      height: 1,
                                      color: kTextSmallColor,
                                    )
                                ],
                              ),
                            );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
