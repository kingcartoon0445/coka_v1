import 'dart:convert';
import 'dart:io';

import 'package:coka/api/api_url.dart';
import 'package:coka/api/lead.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/border_textfield.dart';
import 'package:coka/components/elevated_btn.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/crm_omnichannel/components/channel_item.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/workspace/getx/multi_connect_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

final menuItemList = [
  "FullName",
  "Email",
  "Phone",
  "Gender",
  "Dob",
  "MaritalStatus",
  "PhysicalId",
  "DateOfIssue",
  "PlaceOfIssue",
  "Address",
  "Rating",
  "Work",
  "Avatar",
  "AssignTo",
  "Note"
];

class ZaloformConfigPage extends StatefulWidget {
  const ZaloformConfigPage({super.key});

  @override
  State<ZaloformConfigPage> createState() => _ZaloformConfigPageState();
}

class _ZaloformConfigPageState extends State<ZaloformConfigPage> {
  final homeController = Get.put(HomeController());
  final formUrlController = TextEditingController();
  final expController = TextEditingController();
  var accountList = <Map>[];
  Map currentAccount = {"name": "Chưa có tài khoản nào"};
  List mappingList = [
    {"formId": "", "zaloFieldId": "", "zaloFieldTitle": "", "cokaField": ""}
  ];
  String title = "";
  String description = "";
  String zaloFormId = "";
  String dateString = "";
  DateTime expDate = DateTime.now();
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAccountList();
  }

  Future fetchAccountList() async {
    LeadApi()
        .getFbLeadList(homeController.workGroupCardDataValue["id"],
            provider: "ZALO")
        .then((res) {
      if (isSuccessStatus(res["code"])) {
        setState(() {
          accountList = List<Map>.from(res["content"]);
          if (accountList.isNotEmpty) {
            currentAccount["name"] = "Chọn tài khoản OA";
          }
        });
      } else {
        errorAlert(title: "Lỗi", desc: res["message"]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Cấu hình Zalo Form",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2329)),
          ),
          centerTitle: true,
          automaticallyImplyLeading: true,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                showLoadingDialog(context);
                LeadApi().zaloFormConnect(
                    homeController.workGroupCardDataValue["id"], {
                  "title": title,
                  "description": description,
                  "zaloFormId": zaloFormId,
                  "id": currentAccount["id"],
                  "expiryDate": dateString,
                  "mappingField": mappingList
                }).then((res) {
                  Get.back();
                  if (isSuccessStatus(res?["code"] ?? 400)) {
                    Get.back();
                    MultiConnectController multiConnectController =
                        Get.put(MultiConnectController());
                    multiConnectController.onRefresh();
                    successAlert(
                        title: "Thành công",
                        desc: "Kết nối thành công với Zaloform");
                  } else {
                    errorAlert(
                        title: "Thất bại",
                        desc: res?["message"] ?? "Vui lòng chọn tài khoản OA");
                  }
                });
              }
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
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 16, bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tài khoản OA",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 16),
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: Get.width - 32, // đặt chiều rộng tối đa
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(8)),
                  child: PopupMenuButton<Map>(
                      splashRadius: 0,
                      offset: const Offset(0, 30),
                      onSelected: (Map value) {
                        setState(() {
                          currentAccount = value;
                        });
                      },
                      initialValue: currentAccount,
                      itemBuilder: (BuildContext context) {
                        return accountList.map((Map item) {
                          return PopupMenuItem<Map>(
                            value: item,
                            padding: EdgeInsets.zero,
                            child: Container(
                                width: Get.width,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  item['name'],
                                  style: const TextStyle(
                                      color: Color(0xFF171A1F),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                )),
                          );
                        }).toList();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: Get.width - 150,
                            child: Text(
                              currentAccount['name'],
                              style: const TextStyle(
                                  color: Color(0xFF171A1F),
                                  fontSize: 15,
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
                  height: 8,
                ),
                SizedBox(
                  width: Get.width - 32,
                  child: Row(
                    mainAxisSize: MainAxisSize
                        .min, // Set mainAxisSize to MainAxisSize.min
                    children: [
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          if (Platform.isIOS) {
                            return errorAlert(
                                title: "Rất tiếc!",
                                desc:
                                    "Tính năng này chưa được phát triển ở nền tảng iOS");
                          }
                          HomeController homeController =
                              Get.put(HomeController());
                          final webController =
                              MyChromeSafariBrowser(onWebClosed: () {
                            fetchAccountList();
                          });
                          print(
                              '${apiBaseUrl}api/v1/auth/zalo/lead?accessToken=${await getAccessToken()}&workspaceId=${homeController.workGroupCardDataValue['id']}&organizationId=${jsonDecode(await getOData())["id"]}');
                          webController.open(
                            url: WebUri(
                              '$apiBaseUrl/api/v1/auth/zalo/lead?accessToken=${await getAccessToken()}&workspaceId=${homeController.workGroupCardDataValue['id']}&organizationId=${jsonDecode(await getOData())["id"]}',
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            backgroundColor: const Color(0xFFF8F8F8)),
                        child: const Row(
                          children: [
                            Icon(Icons.add),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              "Thêm tài khoản",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: BorderTextField(
                      name: "Form Url",
                      isRequire: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Hãy điền Form url';
                        }
                        return null;
                      },
                      suffixIcon: TextButton(
                          onPressed: () {
                            final homeController = Get.put(HomeController());
                            showLoadingDialog(context);
                            LeadApi()
                                .zaloAutoMapping(
                                    homeController.workGroupCardDataValue["id"],
                                    formUrlController.text)
                                .then((res) {
                              Get.back();
                              if (isSuccessStatus(res["code"])) {
                                successAlert(
                                    title: "Thành công", desc: "Url hợp lệ");
                                setState(() {
                                  mappingList = res["content"]["mappingField"];
                                });
                                print(mappingList);
                                zaloFormId = res["content"]["zaloFormId"];
                                title = res["content"]["title"];
                                description = res["content"]["description"];
                              } else {
                                errorAlert(title: "Lỗi", desc: res["message"]);
                              }
                            });
                          },
                          child: const Text(
                            "Kiểm tra",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      nameHolder: "Điền form url",
                      controller: formUrlController),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      const sDateFormate = "dd/MM/yyyy";
                      showDatePicker(
                              context: context,
                              initialDate: expDate,
                              fieldHintText: sDateFormate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2040))
                          .then((value) {
                        if (value != null) {
                          setState(() {
                            expController.text =
                                DateFormat("dd/MM/yyyy").format(value);
                          });

                          dateString =
                              DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
                                  .format(value);
                        }
                      });
                    },
                    child: BorderTextField(
                      controller: expController,
                      isRequire: true,
                      isEditAble: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Hãy chọn ngày';
                        }
                        return null;
                      },
                      name: "Ngày hết hạn",
                      nameHolder: "Chọn ngày",
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Text(
                        "Cấu hình ZaloForm",
                        style: TextStyle(
                            color: Color(0xFF1F2329),
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      Text(
                        "*",
                        style:
                            TextStyle(color: Color(0xFFFB0038), fontSize: 20),
                      )
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildContainer(),
                    ...mappingList.map((e0) {
                      final zaloFieldController =
                          TextEditingController(text: e0["zaloFieldTitle"]);

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: Get.width / 2 - 25,
                              child: TextFormField(
                                controller: zaloFieldController,
                                onChanged: (value) =>
                                    e0["zaloFieldTitle"] = value,
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
                                      child: Text(e1),
                                      onPressed: () {
                                        setState(() {
                                          e0["cokaField"] = e1;
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
                                        height: 65,
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
                                                  : e0["cokaField"] ?? "",
                                              style: TextStyle(
                                                  color: e0["cokaField"] == ""
                                                      ? const Color(0xFF40484D)
                                                      : Colors.black)),
                                          const Spacer(),
                                          e0["cokaField"] != ""
                                              ? GestureDetector(
                                                  onTap: () {
                                                    e0["cokaField"] = "";
                                                    setState(() {});
                                                  },
                                                  child: const Icon(Icons.close,
                                                      size: 20),
                                                )
                                              : const Icon(
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
                    ElevatedBtn(
                      onPressed: () {
                        setState(() {
                          mappingList.add({
                            "formId": "",
                            "zaloFieldId": "",
                            "zaloFieldTitle": "",
                            "cokaField": ""
                          });
                        });
                      },
                      paddingAllValue: 0,
                      circular: 10,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add),
                            Text(
                              "Thêm trường",
                              style: TextStyle(color: Color(0xFF1F2329)),
                            )
                          ],
                        ),
                      ),
                    )
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
                "Zalo Field",
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
