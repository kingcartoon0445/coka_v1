import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/elevated_btn.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/crm/crm_controller.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/workspace/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../api/customer.dart';
import '../../../components/awesome_alert.dart';

void importContactLayout() {
  HomeController homeController = Get.put(HomeController());
  List phoneList = [];
  List phoneStringList = [];
  CrmController ct = Get.put(CrmController());

  print(phoneStringList);
  WorkspaceMainController wmc = Get.put(WorkspaceMainController());
  ct.isContactLoading.value = true;

  ct.refreshContacts().then((value) {
    for (var x in ct.contacts) {
      if (x.phones.isNotEmpty) {
        phoneStringList.add(x.phones[0].number);
      }
    }
    CustomerApi().checkPhone(homeController.workGroupCardDataValue['id'],
        {"phones": phoneStringList}).then((res) {
      if (isSuccessStatus(res['code'])) {
        var data = res['content']["phones"];
        for (var x in data) {
          phoneList
              .add(x.toString().replaceAll(' ', '').replaceFirst("84", "0"));
        }
        ct.update();
      } else {
        errorAlert(title: 'Lỗi', desc: res['message']);
      }
    });
  });
  ct.currentAlphabet.value = 'A';
  GlobalKey contactsKey = GlobalKey();

  showModalBottomSheet(
      context: Get.context!,
      builder: (context) {
        return GetBuilder<CrmController>(builder: (controller) {
          return Obx(() => controller.isContactLoading.value
              ? Container(
                  height: Get.height - 45,
                  width: Get.width,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: const Center(child: CircularProgressIndicator()))
              : Container(
                  height: Get.height - 45,
                  width: Get.width,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ElevatedBtn(
                              onPressed: () {
                                Get.back();
                              },
                              circular: 30,
                              paddingAllValue: 10,
                              child: SvgPicture.asset(
                                'assets/icons/back_arrow.svg',
                                height: 30,
                                width: 30,
                              )),
                          const Text(
                            'Nhập từ danh bạ',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ],
                      ),
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: const Color(0xFFF3F4F6),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SizedBox(
                          width: Get.width,
                          height: 50,
                          child: TextFormField(
                            maxLines: 1,
                            onChanged: (value) {
                              ct.onSearchChanged(value);
                            },
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(top: 8),
                              filled: true,
                              fillColor: Color(0xFFf3f4f6),
                              hintText: "Tìm kiếm",
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0)),
                              ),
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                          child: Stack(
                        children: [
                          ListView.builder(
                            key: contactsKey,
                            controller: ct.sc,
                            itemCount:
                                ct.itemCount.value < ct.filteredContacts.length
                                    ? ct.itemCount.value
                                    : ct.filteredContacts.length,
                            itemBuilder: (BuildContext context, int index) {
                              Contact c = ct.filteredContacts[index];
                              String firstLetter =
                                  c.displayName != "" ? c.displayName[0] : "";
                              if (firstLetter != '' && c.phones.isNotEmpty) {
                                if (firstLetter.isAlphabetOnly) {
                                  return Column(
                                    children: [
                                      index == 0
                                          ? _buildGroupHeader(
                                              firstLetter.toUpperCase())
                                          : (ct.filteredContacts[index - 1]
                                                      .displayName[0]
                                                      .toUpperCase() !=
                                                  firstLetter.toUpperCase())
                                              ? _buildGroupHeader(
                                                  firstLetter.toUpperCase())
                                              : const SizedBox.shrink(),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0, vertical: 15),
                                        child: Row(
                                          children: [
                                            createCircleAvatar(
                                                name: c.displayName),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 125,
                                                  child: Text(
                                                    c.displayName ?? "",
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        color: Colors.black),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 2,
                                                ),
                                                Text(c.phones[0].number ?? ''),
                                              ],
                                            ),
                                            const Spacer(),
                                            !phoneList.contains(
                                                    c.phones[0].number)
                                                ? buildSubmitBtn(
                                                    context,
                                                    homeController,
                                                    c,
                                                    phoneList,
                                                    ct,
                                                    wmc)
                                                : Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 9,
                                                        horizontal: 9),
                                                    decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xfffc6d72),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(14)),
                                                    child: const Text(
                                                      'Đã thêm',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFFfef0f1),
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: Get.width - 40,
                                        height: 1,
                                        color: const Color(0xFFF3F4F6),
                                      ),
                                    ],
                                  );
                                } else {
                                  return Column(
                                    children: [
                                      index == 0
                                          ? _buildGroupHeader("#")
                                          : ct.filteredContacts[index - 1]
                                                      .displayName[0] !=
                                                  firstLetter
                                              ? _buildGroupHeader("#")
                                              : const SizedBox.shrink(),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0, vertical: 15),
                                        child: Row(
                                          children: [
                                            createCircleAvatar(
                                                name: c.displayName),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 125,
                                                  child: Text(
                                                    c.displayName ?? "",
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        color: Colors.black),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 2,
                                                ),
                                                Text(c.phones.isNotEmpty
                                                    ? c.phones[0].number
                                                    : ''),
                                              ],
                                            ),
                                            const Spacer(),
                                            !phoneList.contains(
                                                    c.phones[0].number)
                                                ? buildSubmitBtn(
                                                    context,
                                                    homeController,
                                                    c,
                                                    phoneList,
                                                    ct,
                                                    wmc)
                                                : Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 9,
                                                        horizontal: 9),
                                                    decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xfffc6d72),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(14)),
                                                    child: const Text(
                                                      'Đã thêm',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFFfef0f1),
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: Get.width - 40,
                                        height: 1,
                                        color: const Color(0xFFF3F4F6),
                                      ),
                                    ],
                                  );
                                }
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ],
                      )),
                    ],
                  )));
        });
      },
      isScrollControlled: true);
}

ElevatedBtn buildSubmitBtn(
    BuildContext context,
    HomeController homeController,
    Contact c,
    List<dynamic> phoneList,
    CrmController ct,
    WorkspaceMainController wmc) {
  return ElevatedBtn(
    circular: 14,
    paddingAllValue: 0,
    onPressed: () {
      showLoadingDialog(context);
      CustomerApi()
          .importCustomer(homeController.workGroupCardDataValue['id'], [
        {
          "fullName": c.displayName,
          "phone": c.phones[0].number.replaceAll(" ", "").replaceAll("-", ""),
          "sourceId": "ce7f42cf-f10f-49d2-b57e-0c75f8463c82",
          "additional": [],
          "social": [],
        }
      ]).then((res) {
        Get.back();
        if (isSuccessStatus(res['code'])) {
          phoneList.add(c.phones[0].number);
          print(phoneList);
          ct.update();
          wmc.onRefresh();
        } else {
          errorAlert(title: "Lỗi", desc: res['message']);
        }
      }).catchError((e) {
        errorAlert(title: "Lỗi", desc: e['message']);
        Get.back();
      });
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 9),
      decoration: BoxDecoration(
          color: const Color(0xFFfef0f1),
          borderRadius: BorderRadius.circular(14)),
      child: const Text(
        'Thêm',
        style: TextStyle(color: Color(0xFFf22128), fontSize: 13),
      ),
    ),
  );
}

Widget _buildGroupHeader(String letter) {
  return Container(
    width: double.infinity,
    height: 32,
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    color: const Color(0xFFF3F4F6),
    child: Text(
      letter.toUpperCase(),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
