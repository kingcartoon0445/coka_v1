import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants.dart';
import '../../../models/chip_data.dart';

class CustomerCategoryBottomsheet extends StatefulWidget {
  final List initData;
  final void Function(List)? onSubmit;
  const CustomerCategoryBottomsheet(
      {super.key, this.onSubmit, required this.initData});

  @override
  State<CustomerCategoryBottomsheet> createState() =>
      _CustomerCategoryBottomsheetState();
}

class _CustomerCategoryBottomsheetState
    extends State<CustomerCategoryBottomsheet> {
  final categoryMenu = <ChipData>[
    const ChipData('ce7f42cf-f10f-49d2-b57e-0c75f8463c82', 'Nhập vào'),
    const ChipData('3b70970b-e448-46fa-af8f-6605855a6b52', 'Form'),
    const ChipData('38b353c3-ecc8-4c62-be27-229ef47e622d', 'AIDC'),
  ];
  var selects = [true, true, true];
  var isAll = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isAll = widget.initData[0] == "Tất cả";
    if (!isAll) {
      selects = compareCategories(categoryMenu, widget.initData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          const Text(
            "Phân loại khách hàng",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 6,
          ),
          const Divider(color: Color(0x33000000)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tất cả", style: TextStyle(fontSize: 14)),
                SizedBox(
                  height: 38,
                  width: 38,
                  child: Checkbox(
                    value: isAll,
                    onChanged: (value) {
                      setState(() {
                        isAll = value!;
                      });
                      if (isAll) {
                        setState(() {
                          selects = [true, true, true];
                        });
                      } else {
                        setState(() {
                          selects = [false, false, false];
                        });
                      }
                    },
                  ),
                )
              ],
            ),
          ),
          ...categoryMenu.map((e) {
            final index = categoryMenu.indexOf(e);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.name, style: const TextStyle(fontSize: 14)),
                  SizedBox(
                    height: 38,
                    width: 38,
                    child: Checkbox(
                      value: selects[index],
                      onChanged: (value) {
                        setState(() {
                          selects[index] = value!;
                        });
                        if (selects[0] == true &&
                            selects[1] == true &&
                            selects[2] == true) {
                          setState(() {
                            isAll = true;
                          });
                        } else {
                          setState(() {
                            isAll = false;
                          });
                        }
                      },
                    ),
                  )
                ],
              ),
            );
          }),
          const Spacer(),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    var submitData = <ChipData>[];
                    for (var x in categoryMenu) {
                      final index = categoryMenu.indexOf(x);
                      if (selects[index]) {
                        submitData.add(x);
                      }
                    }
                    widget.onSubmit!(isAll ? ["Tất cả"] : submitData);
                    Get.back();
                  },
                  child: const Text(
                    "Hoàn thành",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  )))
        ],
      ),
    );
  }
}
