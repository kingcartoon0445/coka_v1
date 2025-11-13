import 'package:coka/screen/crm_automation/components/add_applet/components/action_selector/action_selector_binding.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/action_selector/action_selector_page.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/filter_selector/filter_selector_binding.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/filter_selector/filter_selector_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../add_applet_controller.dart';

void showPressedBottomSheet(
    {bool isLast = false, required int index, bool isPath = false}) {
  Get.bottomSheet(Container(
    constraints: const BoxConstraints(minHeight: 90),
    padding: const EdgeInsets.only(bottom: 10),
    width: double.infinity,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), color: Colors.white),
    child: Wrap(
      children: [
        Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 4,
              width: 28,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(3)),
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            GestureDetector(
              onTap: () {
                Get.back();

                Get.to(
                    () => ActionSelectorPage(
                          isPath: isPath,
                        ),
                    binding: ActionSelectorBinding());
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black54, width: 1)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.amp_stories,
                        color: Colors.deepOrangeAccent,
                        size: 30,
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Hành động",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: Get.width - 110,
                            child: const Text(
                              "Chọn một hành động để thực thi",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isLast && !isPath)
              Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      AddAppletController appletController =
                          Get.put(AddAppletController());
                      appletController.actionDataList[index] = {
                        "type": "path",
                        "pathList": [[], []]
                      };
                      appletController.addOnePath(index, 0);
                      appletController.addOnePath(index, 1);

                      appletController.update();
                      Get.back();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.black54, width: 1)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.account_tree_sharp,
                              color: Colors.deepOrangeAccent,
                              size: 30,
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Rẻ nhánh",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: Get.width - 110,
                                  child: const Text(
                                    "Xây dựng các bước khác nhau với các điều kiện khác nhau",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                Get.back();

                Get.to(() => FilterSelectorPage(isPath: isPath),
                    binding: FilterSelectorBinding());
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black54, width: 1)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.filter_alt,
                        color: Colors.deepOrangeAccent,
                        size: 30,
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Bộ lọc",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: Get.width - 110,
                            child: const Text(
                              "Chỉ tiếp tục các bước tiếp theo khi thỏa mãn bộ lọc",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ],
    ),
  ));
}
