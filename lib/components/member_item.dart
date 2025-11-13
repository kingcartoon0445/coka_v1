import 'package:coka/api/organization.dart';
import 'package:coka/components/elevated_btn.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/main/pages/detail_member.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auto_avatar.dart';
import 'awesome_alert.dart';
import 'loading_dialog.dart';

class MemberItem extends StatelessWidget {
  final Map dataItem;

  const MemberItem({super.key, required this.dataItem});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (controller) {
      return MenuAnchor(
          menuChildren: dataItem["typeOfEmployee"] == "OWNER" ||
                  (controller.oData["type"] != "OWNER" &&
                      controller.oData["type"] != "ADMIN") ||
                  dataItem["status"] == 4
              ? []
              : [
                  SubmenuButton(menuChildren: [
                    if (dataItem["typeOfEmployee"] != "OWNER" &&
                        dataItem["typeOfEmployee"] != "ADMIN")
                      MenuItemButton(
                        child: const Text("Quản trị viên",
                            style: TextStyle(color: Colors.black)),
                        onPressed: () {
                          showLoadingDialog(context);
                          OrganApi()
                              .grantRoleOrganMember(
                                  dataItem["profileId"], "ADMIN")
                              .then((res) async {
                            Get.back();
                            if (isSuccessStatus(res["code"])) {
                              final homeController = Get.put(HomeController());
                              homeController.isMemberFetching.value = true;
                              homeController.update();
                              await homeController.fetchMemberList();
                              homeController.isMemberFetching.value = false;
                              homeController.update();
                              successAlert(
                                  title: "Thành công",
                                  desc:
                                      "${dataItem["fullName"]} đã trở thành quản trị viên");
                            } else {
                              errorAlert(
                                  title: "Thất bại", desc: res["message"]);
                            }
                          });
                        },
                      ),
                    if (dataItem["typeOfEmployee"] != "FULLTIME")
                      MenuItemButton(
                          child: const Text(
                            "Thành viên",
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () {
                            showLoadingDialog(context);
                            OrganApi()
                                .grantRoleOrganMember(
                                    dataItem["profileId"], "FULLTIME")
                                .then((res) async {
                              Get.back();
                              if (isSuccessStatus(res["code"])) {
                                final homeController =
                                    Get.put(HomeController());
                                homeController.isMemberFetching.value = true;
                                homeController.update();
                                await homeController.fetchMemberList();
                                homeController.isMemberFetching.value = false;
                                homeController.update();
                                successAlert(
                                    title: "Thành công",
                                    desc:
                                        "${dataItem["fullName"]} đã bị hạ cấp");
                              } else {
                                errorAlert(
                                    title: "Thất bại", desc: res["message"]);
                              }
                            });
                          }),
                  ], child: const Text("Phân quyền")),
                  MenuItemButton(
                      child: const Text(
                        "Xoá thành viên",
                        style: TextStyle(color: Color(0xFFB2261F)),
                      ),
                      onPressed: () {
                        warningAlert(
                            title: "Xoá thành viên?",
                            desc:
                                "Bạn có chắc muốn xoá ${dataItem["fullName"]} ?",
                            btnOkOnPress: () {
                              showLoadingDialog(context);
                              OrganApi()
                                  .deleteOrganMember(dataItem["profileId"])
                                  .then((res) async {
                                Get.back();
                                if (isSuccessStatus(res["code"])) {
                                  final homeController =
                                      Get.put(HomeController());
                                  homeController.isMemberFetching.value = true;
                                  homeController.update();
                                  await homeController.fetchMemberList();
                                  homeController.isMemberFetching.value = false;
                                  homeController.update();
                                  successAlert(
                                      title: "Thành công",
                                      desc:
                                          "${dataItem["fullName"]} đã bị xoá khỏi tổ chức");
                                } else {
                                  errorAlert(
                                      title: "Thất bại", desc: res["message"]);
                                }
                              });
                            });
                      }),
                ],
          builder: (context, controller, child) {
            return ElevatedBtn(
              paddingAllValue: 0,
              onPressed: () {
                Get.to(() => DetailMember(
                      dataItem: dataItem,
                      isMyProfile: false,
                    ));
              },
              onLongPressd: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              circular: 0,
              child: Container(
                padding: const EdgeInsets.only(
                    bottom: 6, left: 16, top: 6, right: 4),
                child: Row(
                  children: [
                    dataItem["avatar"] == null
                        ? createCircleAvatar(
                            name: dataItem["fullName"], radius: 20)
                        : Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0x663949AB), width: 1),
                                color: Colors.white),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: getAvatarWidget(dataItem["avatar"]),
                            ),
                          ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dataItem["fullName"] ?? "",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Row(
                          children: [
                            Text(
                              getEmployee(dataItem["typeOfEmployee"] ?? ""),
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.3),
                                  fontSize: 13),
                            ),
                            if (dataItem["status"] == 4)
                              Text(
                                " - Đã nghỉ việc",
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.3),
                                    fontSize: 13),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            );
          });
    });
  }
}
