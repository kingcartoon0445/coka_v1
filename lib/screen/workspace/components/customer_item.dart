import 'package:coka/api/customer.dart';
import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/custom_snackbar.dart';
import 'package:coka/components/elevated_btn.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/workspace/getx/customer_binding.dart';
import 'package:coka/screen/workspace/getx/customer_controller.dart';
import 'package:coka/screen/workspace/pages/customer.dart';
import 'package:coka/screen/workspace/pages/edit_customer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

import '../main_controller.dart';
import 'assign_to_bottomsheet.dart';

String getAsset(String type) {
  switch (type.toLowerCase()) {
    case 'facebook':
      return 'assets/icons/fb_2_icon.svg';
    case 'zalo':
      return 'assets/icons/zalo_icon.svg';
    case 'instagram':
      return 'assets/icons/instagram_icon.svg';
    case 'import':
      return 'assets/icons/contact_icon.svg';
    case 'nhập vào':
      return 'assets/icons/contact_icon.svg';
    case 'form':
      return "assets/icons/form_icon.svg";
    case 'aidc':
      return 'assets/icons/aidc_icon.svg';
  }
  return '';
}

Color getColor(String type) {
  switch (type.toLowerCase()) {
    case 'facebook':
      return const Color(0xFF1687ff);
    case 'zalo':
      return Colors.white;
    case 'instagram':
      return const Color(0xFFB625BB);
    case 'import':
      return const Color(0xFF1dd75b);
    case 'nhập vào':
      return const Color(0xFF1dd75b);
    case 'form':
      return const Color(0xff1d20d7);
    case 'aidc':
      return const Color(0xff28eedc);
  }
  return const Color(0xFF1dd75b);
}

class RoomItem extends StatefulWidget {
  final Map itemData;
  final int index;

  const RoomItem({super.key, required this.itemData, required this.index});

  @override
  State<RoomItem> createState() => _RoomItemState();
}

final homeController = Get.put(HomeController());

Future assignToRequest(id, data, {bool? isInside = false}) async {
  showLoadingDialog(Get.context!);

  await CustomerApi()
      .assignToCustomer(homeController.workGroupCardDataValue["id"], id, data)
      .then((res) {
    Get.back();
    if (!isSuccessStatus(res["code"])) {
      return errorAlert(title: "Lỗi", desc: res["message"]);
    }
    Get.back();
    if (isInside!) {
      final cController = Get.put(CustomerController());
      cController.fetchJourney();
      cController.fetchDetailCustomer();
    }
    final wmController = Get.put(WorkspaceMainController());
    wmController.onRefresh();
    successAlert(title: "Thành công", desc: "Đã chuyển người phụ trách");
  });
}

class _RoomItemState extends State<RoomItem> {
  @override
  Widget build(BuildContext context) {
    String snipTime =
        diffFunc(DateTime.parse(widget.itemData['lastModifiedDate']));

    return MenuAnchor(
        alignmentOffset: const Offset(20, 0),
        menuChildren: [
          MenuItemButton(
            leadingIcon: Image.asset(
              "assets/images/assign_to_icon.png",
              width: 25,
              height: 25,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12))),
                builder: (context) => AssignToBottomSheet(
                  onSelected: (data) {
                    warningAlert(
                        title: "Chuyển phụ trách?",
                        desc: homeController.workGroupCardDataValue["type"] !=
                                    "OWNER" ||
                                homeController.workGroupCardDataValue["type"] !=
                                    "ADMIN"
                            ? "Bạn có chắc muốn phân phối data đến người này?"
                            : "Bạn sẽ mất quyền phụ trách, khi phân phối tới người này?",
                        nameOkBtn: "Đồng ý",
                        btnOkOnPress: () {
                          assignToRequest(widget.itemData["id"], data);
                        });
                  },
                ),
              );
            },
            child: const Text(
              "Chuyển phụ trách",
              style: TextStyle(color: Colors.black),
            ),
          ),
          MenuItemButton(
            leadingIcon: const Icon(Icons.edit, size: 25),
            onPressed: () {
              Get.to(() => EditCustomerPage(dataItem: widget.itemData));
            },
            child: const Text(
              "Chỉnh sửa thông tin",
              style: TextStyle(color: Colors.black),
            ),
          ),
          MenuItemButton(
            leadingIcon: const Icon(Icons.delete, size: 25),
            onPressed: () {
              warningAlert(
                  title: "Xoá khách hàng?",
                  desc: "Bạn có chắc chắn muốn xoá khách hàng này?",
                  btnOkOnPress: () {
                    final homeController = Get.put(HomeController());
                    showLoadingDialog(context);
                    CustomerApi()
                        .deleteCustomer(
                            homeController.workGroupCardDataValue["id"],
                            widget.itemData["id"])
                        .then((res) {
                      Get.back();
                      if (isSuccessStatus(res["code"])) {
                        final wmController = Get.put(WorkspaceMainController());

                        wmController
                            .roomList[wmController.selectedGroupIndex.value]
                            .removeWhere(
                                (e) => e["id"] == widget.itemData["id"]);

                        wmController.update();

                        successSnackbar(
                            text:
                                "Đã xóa khách hàng ${widget.itemData["fullName"]}",
                            context: context);
                      } else {
                        errorAlert(title: "Lỗi", desc: res["message"]);
                      }
                    });
                  });
            },
            child: const Text(
              "Xoá khách hàng",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
        builder: (context, controller, child) {
          return ElevatedBtn(
            circular: 0,
            paddingAllValue: 0,
            onLongPressd: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              }
              var data = Map<String, dynamic>.from(
                  widget.itemData.cast<String, dynamic>());
              data.addAll({"index": widget.index});
              Get.to(() => const CustomerPage(),
                  arguments: data, binding: CustomerBinding());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      widget.itemData['avatar'] == null
                          ? createCircleAvatar(
                              name: widget.itemData['fullName'], radius: 26)
                          : CircleAvatar(
                              backgroundImage:
                                  getAvatarProvider(widget.itemData['avatar']),
                              radius: 26,
                            ),
                      // Positioned(
                      //   bottom: 2,
                      //   right: 0,
                      //   child: Container(
                      //     height: 13,
                      //     width: 20,
                      //     decoration: BoxDecoration(
                      //         borderRadius: BorderRadius.circular(6),
                      //         border: Border.all(
                      //             color: Colors.white,
                      //             width: 1,
                      //             strokeAlign: BorderSide.strokeAlignOutside),
                      //         color: const Color(0xFF5c33f0)),
                      //     child: Row(
                      //       children: [
                      //         const Spacer(),
                      //         Text(
                      //           (widget.itemData["rating"] ?? 0).toString(),
                      //           style: const TextStyle(
                      //               color: Colors.white, fontSize: 10),
                      //         ),
                      //         const Icon(
                      //           Icons.star,
                      //           color: Colors.white,
                      //           size: 8,
                      //         ),
                      //         const Spacer(),
                      //       ],
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                  const SizedBox(
                    width: 14,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: Get.width - 140,
                        child: Row(
                          children: [
                            Container(
                              constraints:
                                  BoxConstraints(maxWidth: Get.width - 190),
                              child: Text(
                                widget.itemData['fullName'],
                                style: TextStyle(
                                  color: const Color(0xFF201A18),
                                  fontWeight: widget.itemData
                                          .containsKey("stage")
                                      ? FontWeight.w400
                                      : widget.itemData.containsKey('stage') &&
                                              widget.itemData['stage']
                                                      ['name'] ==
                                                  "Mới"
                                          ? FontWeight.w800
                                          : FontWeight.w400,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            RatingBar.builder(
                              initialRating: double.parse(
                                  (widget.itemData["rating"] ?? 0).toString()),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Color(0xFFF27B21),
                              ),
                              itemSize: 8,
                              onRatingUpdate: (value) {},
                              ignoreGestures: true,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      SizedBox(
                        width: Get.width - 140,
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 7,
                              color: getTabBadgeColor(
                                  widget.itemData.containsKey("stage")
                                      ? widget.itemData['stage']["stageGroup"]
                                          ['name']
                                      : ""),
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            ConstrainedBox(
                              constraints:
                                  BoxConstraints(maxWidth: Get.width - 205),
                              child: Text(
                                widget.itemData.containsKey('stage')
                                    ? widget.itemData['stage']['name']
                                    : "",
                                style: TextStyle(
                                  color: const Color(0xFF1F2329),
                                  fontWeight:
                                      !widget.itemData.containsKey("stage")
                                          ? FontWeight.w400
                                          : widget.itemData['stage']['name'] ==
                                                  "Mới"
                                              ? FontWeight.w400
                                              : FontWeight.w400 == "Mới"
                                                  ? FontWeight.w800
                                                  : FontWeight.w400,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.itemData['journey']?["data"]?["title"] !=
                                null)
                              const Padding(
                                padding: EdgeInsets.all(3.0),
                                child: Icon(Icons.circle, size: 4),
                              ),
                            Flexible(
                              child: Text(
                                widget.itemData['journey']?["data"]?["title"] ??
                                    "",
                                style: const TextStyle(
                                    color: Color(0xB2000000),
                                    fontSize: 12,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      if (widget.itemData["assignToUser"] != null ||
                          widget.itemData["teamResponse"] != null)
                        SizedOverflowBox(
                          size: Size(Get.width - 140, 16),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              // ...widget.itemData["tags"].map((e) => Container(
                              //       margin: const EdgeInsets.only(left: 4),
                              //       decoration: BoxDecoration(
                              //           color: const Color(0xFFe9e1ff),
                              //           borderRadius:
                              //               BorderRadius.circular(16)),
                              //       padding: const EdgeInsets.symmetric(
                              //           horizontal: 6, vertical: 1),
                              //       child: Text(
                              //         e,
                              //         style: const TextStyle(fontSize: 10),
                              //       ),
                              //     )),
                              if (widget.itemData["assignToUser"] != null ||
                                  widget.itemData["teamResponse"] != null)
                                Row(
                                  children: [
                                    (widget.itemData["assignToUser"]
                                                ?["avatar"] !=
                                            null)
                                        ? CircleAvatar(
                                            backgroundImage: getAvatarProvider(
                                                widget.itemData["assignToUser"]
                                                    ?["avatar"]),
                                            radius: 8,
                                          )
                                        : createCircleAvatar(
                                            name: widget.itemData[
                                                        "assignToUser"]
                                                    ?["fullName"] ??
                                                widget.itemData["teamResponse"]
                                                    ["name"],
                                            radius: 8,
                                            fontSize: 6),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    Text(
                                      widget.itemData["assignToUser"]
                                              ?["fullName"] ??
                                          widget.itemData["teamResponse"]
                                              ["name"],
                                      style: TextStyle(
                                        color: widget.itemData['stage']
                                                    ['name'] ==
                                                "Mới"
                                            ? Colors.black
                                            : Colors.black.withOpacity(0.5),
                                        fontWeight: widget.itemData['stage']
                                                    ['name'] ==
                                                "Mới"
                                            ? FontWeight.w800
                                            : FontWeight.w400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                )
                            ],
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snipTime,
                        style: TextStyle(
                            color: !widget.itemData.containsKey('stage')
                                ? const Color(0xFF171A1F).withOpacity(0.3)
                                : widget.itemData['stage']['name'] == "Mới"
                                    ? Colors.black
                                    : const Color(0xFF171A1F).withOpacity(0.3),
                            fontSize: 11),
                      ),
                      const SizedBox(
                        height: 30,
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}
