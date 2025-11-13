import 'package:coka/components/awesome_alert.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/filter_selector/components/textfield_ingredient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../../../../components/elevated_btn.dart';
import 'ingredient_dialog.dart';

class ConfigFilterPage extends StatefulWidget {
  final Map? currentCondition;
  final Map? currentAction;
  final String? filterText;
  final Function(Map) onUpdateData;
  const ConfigFilterPage(
      {super.key,
      required this.currentCondition,
      required this.currentAction,
      required this.filterText,
      required this.onUpdateData});

  @override
  State<ConfigFilterPage> createState() => _ConfigFilterPageState();
}

class _ConfigFilterPageState extends State<ConfigFilterPage> {
  TextEditingController filterController = TextEditingController();
  List conditionList = [
    {"name": "Chứa", "id": "contains"},
    {"name": "Không chứa", "id": "not_contains"},
    {"name": "Bằng", "id": "exact"},
    {"name": "Khác", "id": "not_exact"},
    {"name": "Lớn hơn", "id": "greater"},
    {"name": "Nhỏ hơn", "id": "less"},
    {"name": "Tồn tại", "id": "exist"},
    {"name": "Không tồn tại", "id": "not_exist"},
  ];
  Map? currentCondition;
  Map? currentAction;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    filterController.text = widget.filterText ?? "";
    currentAction = widget.currentAction;
    currentCondition = widget.currentCondition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Cấu hình điều kiện',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          leading: ElevatedBtn(
              onPressed: () {
                Get.back();
              },
              circular: 30,
              paddingAllValue: 15,
              child: SvgPicture.asset(
                'assets/icons/back_arrow.svg',
                color: Colors.black,
                height: 30,
                width: 30,
              ))),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: Get.width - 40,
              height: 50,
              child: OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => IngredientDialog(
                        onIngTap: (data) {
                          setState(() {
                            currentAction = data;
                          });
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black)),
                  child: Row(
                    children: [
                      if (currentAction != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: SvgPicture.asset(
                            currentAction!["action"]["iconPath"],
                            width: 30,
                            height: 30,
                          ),
                        ),
                      Text(
                        currentAction != null
                            ? currentAction!["data"]!
                            : "Chọn tham số cần so sánh",
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ],
                  )),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)),
              child: PopupMenuButton<Map>(
                  splashRadius: 0,
                  offset: const Offset(-20, 0),
                  onSelected: (Map value) {
                    setState(() {
                      currentCondition = value;
                    });
                  },
                  initialValue: currentCondition,
                  itemBuilder: (BuildContext context) {
                    return conditionList.map((item) {
                      return PopupMenuItem<Map>(
                        value: item,
                        padding: EdgeInsets.zero,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: 120,
                              child: Text(
                                item["name"],
                                style: const TextStyle(
                                    color: Color(0xFF171A1F),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList();
                  },
                  child: Wrap(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                currentCondition?["name"] ?? "Chọn điều kiện",
                                style: const TextStyle(
                                    color: Color(0xFF171A1F),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black,
                              size: 30,
                            )
                          ],
                        ),
                      ),
                    ],
                  )),
            ),
            const SizedBox(
              height: 15,
            ),
            TextFieldIngredient(controller: filterController)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (currentAction != {} &&
              currentCondition != null &&
              filterController.text != "") {
            final updatedData = ({
              "currentAction": currentAction,
              "currentCondition": currentCondition,
              "filterText": filterController.text
            });
            widget.onUpdateData(updatedData);
            Get.back();
          } else {
            errorAlert(title: "Lỗi", desc: "Bạn chưa cấu hình xong");
          }
        },
        shape: const CircleBorder(),
        child: const Icon(
          Icons.check,
        ),
      ),
    );
  }
}
