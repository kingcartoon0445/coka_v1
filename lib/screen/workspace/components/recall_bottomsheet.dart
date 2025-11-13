import 'package:coka/constants.dart';
import 'package:coka/screen/workspace/components/customer_category_bottomsheet.dart';
import 'package:coka/screen/workspace/components/recall_target_bottomsheet.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'customer_source_bottomsheet.dart';

class RecallBottomsheet extends StatefulWidget {
  final Map initConfig;
  final bool isRaw;
  final void Function(Map) onSubmit;
  const RecallBottomsheet(
      {super.key,
      required this.onSubmit,
      required this.initConfig,
      required this.isRaw});

  @override
  State<RecallBottomsheet> createState() => _RecallBottomsheetState();
}

class _RecallBottomsheetState extends State<RecallBottomsheet> {
  Map configData = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    configData = widget.initConfig;
    print(configData);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          SizedBox(
            width: double.infinity,
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    height: 1.5,
                    fontSize: 20,
                    color: Color(0xB2000000),
                    fontWeight: FontWeight.bold),
                text: 'Nếu người phụ trách\nnhận khách hàng\nthuộc phân loại ',
                children: <TextSpan>[
                  TextSpan(
                      text: configData["category"].join(", "),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          showModalBottomSheet(
                            context: Get.context!,
                            backgroundColor: Colors.white,
                            isScrollControlled: true,
                            constraints:
                                BoxConstraints(maxHeight: Get.height * .4),
                            shape: const RoundedRectangleBorder(
                              // <-- SEE HERE
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(14.0),
                              ),
                            ),
                            builder: (BuildContext context) {
                              return CustomerCategoryBottomsheet(
                                onSubmit: (List p0) {
                                  setState(() {
                                    configData["category"] = p0;
                                  });
                                },
                                initData: configData["category"],
                              );
                            },
                          );
                        },
                      style: const TextStyle(color: Color(0xFF554FE8))),
                  const TextSpan(text: '\nvà nguồn '),
                  TextSpan(
                      text: configData["source"].join(", "),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          showModalBottomSheet(
                            context: Get.context!,
                            backgroundColor: Colors.white,
                            isScrollControlled: true,
                            constraints:
                                BoxConstraints(maxHeight: Get.height * .7),
                            shape: const RoundedRectangleBorder(
                              // <-- SEE HERE
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(14.0),
                              ),
                            ),
                            builder: (BuildContext context) {
                              return CustomerSourceBottomsheet(
                                onSubmit: (List p0) {
                                  setState(() {
                                    configData["source"] = p0;
                                  });
                                },
                                initData: configData["source"],
                              );
                            },
                          );
                        },
                      style: const TextStyle(color: Color(0xFF554FE8))),
                  const TextSpan(text: '\nsau '),
                  TextSpan(
                      text:
                          '${configData["time"].hour} giờ ${configData["time"].minute} phút',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          final TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: configData["time"],
                              initialEntryMode: TimePickerEntryMode.input);
                          if (time != null) {
                            setState(() {
                              configData["time"] = time;
                            });
                          }
                        },
                      style: const TextStyle(color: Color(0xFF554FE8))),
                  const TextSpan(
                    text: '\nKhông cập nhật ',
                    // style: TextStyle(color: Color(0xFF554FE8))
                  ),
                  const TextSpan(text: 'tình trạng chăm sóc'),
                  const TextSpan(text: '\nthu hồi về\n'),
                  TextSpan(
                      text: configData["target"]["type"] == 1
                          ? 'Đội sale ${configData["target"]["teamData"]["name"]}'
                          : configData["target"]["name"],
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          showModalBottomSheet(
                            context: Get.context!,
                            backgroundColor: Colors.white,
                            isScrollControlled: true,
                            constraints:
                                BoxConstraints(maxHeight: Get.height * .55),
                            shape: const RoundedRectangleBorder(
                              // <-- SEE HERE
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(14.0),
                              ),
                            ),
                            builder: (BuildContext context) {
                              return RecallTargetBottomsheet(
                                initData: configData["target"],
                                onSubmit: (p0) {
                                  setState(() {
                                    configData["target"] = p0;
                                  });
                                  print(configData);
                                },
                              );
                            },
                          );
                        },
                      style: const TextStyle(color: Color(0xFF554FE8))),
                ],
              ),
            ),
          ),
          const Spacer(),
          if (widget.isRaw)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 25,
                    width: 25,
                    child: Checkbox(
                      value: configData["isForce"],
                      onChanged: (value) {
                        setState(() {
                          configData["isForce"] = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  const Text("Áp dụng cho tất cả đội Sale phía dưới")
                ],
              ),
            ),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    widget.onSubmit(configData);
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
