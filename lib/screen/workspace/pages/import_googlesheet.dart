import 'dart:async';

import 'package:coka/api/googlesheet.dart';
import 'package:coka/components/border_textfield.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/components/url_googlesheet_field.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/workspace/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../../components/awesome_alert.dart';

// final menuItemList = [
//   {"id": "FullName", "name": "Họ và tên"},
//   {"id": "Email", "name": "Email"},
//   {"id": "Phone", "name": "Số điện thoại"},
//   {"id": "Gender", "name": "Giới tính"},
//   {"id": "Dob", "name": "Ngày sinh"},
//   {"id": "Address", "name": "Địa chỉ"},
//   {"id": "Website", "name": "Website"},
//   {"id": "UtmSource", "name": "Utm Source"},
// ];

class ImportGoogleSheet extends StatefulWidget {
  const ImportGoogleSheet({super.key});

  @override
  State<ImportGoogleSheet> createState() => _ImportGoogleSheetState();
}

class _ImportGoogleSheetState extends State<ImportGoogleSheet> {
  TextEditingController urlController = TextEditingController();
  TextEditingController headerController = TextEditingController(text: "1");

  List menuItemList = [];
  void getMenuItems() async {
    final dio = Dio();
    final response =
        await dio.get('https://automation.coka.ai/googlesheet_config.json');
    setState(() {
      menuItemList = (response.data);
      print(menuItemList);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMenuItems();
  }

  String? successMessage, errorMessage, fileName;
  int? rowCount;
  List mappingList = [
    {"googleFieldId": "", "googleFieldTitle": "", "cokaField": ""}
  ];
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F8F8),
          title: const Text("Nhập từ Google Sheet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          centerTitle: true,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showLoadingDialog(context);
              GoogleSheetApi().importData({
                "formUrl": urlController.text,
                "targetRow": headerController.text,
                "rowCount": rowCount,
                "mappingField": mappingList
              }).then((res) {
                Get.back();
                if (isSuccessStatus(res["code"])) {
                  Get.back();
                  successAlert(
                      title: "Thành công",
                      desc:
                          "Bạn đã import thành công ${res["metadata"]["totalSuccess"]}/${res["metadata"]["totalRow"]} data");
                  final workspaceMainController =
                      Get.put(WorkspaceMainController());
                  workspaceMainController.onRefresh();
                } else {
                  errorAlert(title: "Thất bại", desc: res["message"]);
                }
              });
            },
            label: const Text(
              "Hoàn tất",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            extendedPadding: const EdgeInsets.symmetric(horizontal: 100),
            backgroundColor: const Color(0xFF637EFF)),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (successMessage == null)
                  BorderTextField(
                    name: "Chọn dòng tiêu đề",
                    nameHolder: "Điền dòng tiêu đề",
                    onTooltipClick: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 16,
                              ),
                              const Center(
                                child: Text(
                                  "Dòng tiêu đề",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF1F2329)),
                                ),
                              ),
                              const SizedBox(
                                height: 22,
                              ),
                              Image.asset(
                                  "assets/images/row_header_tooltip.png"),
                              const SizedBox(
                                height: 12,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: Text("Dòng tiêu đề",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF47464F))),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: Text(
                                    "Đây là dòng đầu tiên của bản dữ liệu có chứa các nhãn hoặc tiêu đề mô tả các cột dưới đó.\n(Ở ví dụ phía trên dòng tiêu đề là 3)",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF47464F))),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    borderRadius: 4,
                    fillColor: Colors.white,
                    controller: headerController,
                    validator: (p0) {
                      if (p0 == null || p0.isEmpty) {
                        return "Vui lòng điền dòng tiêu đề";
                      }
                      if (!RegExp(r'^[0-9]+$').hasMatch(p0)) {
                        return "Dòng tiêu đề chỉ được nhập số";
                      }
                      if (int.parse(p0) <= 0) {
                        return "Dòng tiêu đề phải lớn hơn 0";
                      }
                      return null;
                    },
                    textInputType: TextInputType.number,
                  ),
                const SizedBox(
                  height: 16,
                ),
                UrlGoogleSheetField(
                  urlController: urlController,
                  onRetry: () {
                    setState(() {
                      errorMessage = null;
                    });
                  },
                  onSubmit: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();

                      GoogleSheetApi()
                          .urlCheck(urlController.text,
                              int.parse(headerController.text))
                          .then((res) {
                        if (isSuccessStatus(res["code"])) {
                          successMessage =
                              "Đã lấy được ${res["content"]["rowCount"]} dữ liệu từ file";
                          fileName = res["content"]["sheetName"];

                          Timer(const Duration(milliseconds: 100), () {
                            setState(() {
                              rowCount = res["content"]["rowCount"];
                              mappingList = res["content"]["mappingField"];
                            });
                          });
                        } else {
                          errorMessage = res["message"];
                        }
                        setState(() {});
                      });
                    } else {
                      setState(() {
                        errorMessage = "Vui lòng thử lại";
                      });
                    }
                    // Timer(const Duration(seconds: 2), () {
                    //   setState(() {
                    //     successMessage = "Data lấy được: 500";
                    //     fileName = "Tên file google sheet";
                    //   });
                    // });
                  },
                  errorMessage: errorMessage,
                  successMessage: successMessage,
                  fileName: fileName,
                ),
                if (rowCount != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Text(
                              "Cấu hình GoogleSheet",
                              style: TextStyle(
                                  color: Color(0xFF1F2329),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            Text(
                              "*",
                              style: TextStyle(
                                  color: Color(0xFFFB0038), fontSize: 20),
                            )
                          ],
                        ),
                      ),
                      buildContainer(),
                      ...mappingList.map((e0) {
                        final zaloFieldController =
                            TextEditingController(text: e0["googleFieldTitle"]);

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              SizedBox(
                                width: Get.width / 2 - 25,
                                child: TextFormField(
                                  controller: zaloFieldController,
                                  readOnly: true,
                                  onChanged: (value) =>
                                      e0["googleFieldTitle"] = value,
                                  decoration: InputDecoration(
                                    hintText: "Nội dung",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                          color: Colors.black.withOpacity(0.7)),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.black,
                                ),
                              ),
                              MenuAnchor(
                                  style: MenuStyle(
                                    minimumSize: WidgetStatePropertyAll(
                                        Size(Get.width / 2 - 25, 300)),
                                    maximumSize: WidgetStatePropertyAll(
                                        Size(Get.width / 2 - 25, 300)),
                                  ),
                                  menuChildren: [
                                    ...menuItemList.map((e1) {
                                      return MenuItemButton(
                                        child: Text(e1["name"]!),
                                        onPressed: () {
                                          setState(() {
                                            e0["cokaField"] = e1["id"];
                                          });
                                        },
                                      );
                                    })
                                  ],
                                  builder: (context, controller, child) {
                                    return InkWell(
                                      onTap: () {
                                        if (controller.isOpen) {
                                          controller.close();
                                        } else {
                                          controller.open();
                                        }
                                      },
                                      child: SizedBox(
                                        width: Get.width / 2 - 25,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 14),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                  color: Colors.black
                                                      .withOpacity(0.7))),
                                          child: Row(children: [
                                            Text(
                                                e0["cokaField"] == ""
                                                    ? "Form Field"
                                                    : menuItemList.firstWhere(
                                                                (element) =>
                                                                    element[
                                                                        "id"] ==
                                                                    e0["cokaField"])[
                                                            "name"] ??
                                                        "",
                                                style: TextStyle(
                                                    color: e0["cokaField"] == ""
                                                        ? const Color(
                                                            0xFF40484D)
                                                        : Colors.black)),
                                            const Spacer(),
                                            const Icon(
                                                Icons.arrow_drop_down_sharp,
                                                size: 30),
                                          ]),
                                        ),
                                      ),
                                    );
                                  }),
                            ],
                          ),
                        );
                      }),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container buildContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
              width: Get.width / 2 - 25,
              child: const Text(
                "Google Sheet",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              )),
          const Spacer(),
          SizedBox(
              width: Get.width / 2 - 25,
              child: const Text(
                "Coka Field",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }
}
