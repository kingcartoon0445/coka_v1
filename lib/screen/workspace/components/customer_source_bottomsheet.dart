import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants.dart';
import '../../../models/chip_data.dart';

class CustomerSourceBottomsheet extends StatefulWidget {
  final List initData;

  final void Function(List)? onSubmit;
  const CustomerSourceBottomsheet(
      {super.key, this.onSubmit, required this.initData});

  @override
  State<CustomerSourceBottomsheet> createState() =>
      _CustomerSourceBottomsheetState();
}

class _CustomerSourceBottomsheetState extends State<CustomerSourceBottomsheet> {
  final sourceMenu = <ChipData>[
    const ChipData('Khách cũ', 'Khách cũ'),
    const ChipData('Được giới thiệu', 'Được giới thiệu'),
    const ChipData('Trực tiếp', 'Trực tiếp'),
    const ChipData('Hotline', 'Hotline'),
    const ChipData('Google', 'Google'),
    const ChipData('Facebook', 'Facebook'),
    const ChipData('Zalo', 'Zalo'),
    const ChipData('Tiktok', 'Tiktok'),
    const ChipData('Khác', 'Khác'),
  ];
  var selects = [true, true, true, true, true, true, true, true, true];
  var isAll = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isAll = widget.initData[0] == "Tất cả";
    if (!isAll) {
      selects = compareCategories(sourceMenu, widget.initData);
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
                          selects = [
                            true,
                            true,
                            true,
                            true,
                            true,
                            true,
                            true,
                            true,
                            true
                          ];
                        });
                      } else {
                        setState(() {
                          selects = [
                            false,
                            false,
                            false,
                            false,
                            false,
                            false,
                            false,
                            false,
                            false
                          ];
                        });
                      }
                    },
                  ),
                )
              ],
            ),
          ),
          ...sourceMenu.map((e) {
            final index = sourceMenu.indexOf(e);
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
                        if (selects.every((element) => element == true)) {
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
                    for (var x in sourceMenu) {
                      final index = sourceMenu.indexOf(x);
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
