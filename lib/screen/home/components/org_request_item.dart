import 'package:coka/api/invite.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/auto_avatar.dart';

class OrgRequestItem extends StatefulWidget {
  final Map dataItem;
  final Function onReload;
  const OrgRequestItem(
      {super.key, required this.dataItem, required this.onReload});

  @override
  State<OrgRequestItem> createState() => _OrgRequestItemState();
}

class _OrgRequestItemState extends State<OrgRequestItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 16, left: 16, top: 16, right: 4),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x663949AB), width: 1),
                color: Colors.white),
            child: widget.dataItem["profile"]["avatar"] == null
                ? createCircleAvatar(
                    name: widget.dataItem["profile"]['fullName'], radius: 20)
                : CircleAvatar(
                    backgroundImage:
                        getAvatarProvider(widget.dataItem["profile"]["avatar"]),
                  ),
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: Get.width - 240,
                child: Text(
                  widget.dataItem["profile"]['fullName'],
                  style: const TextStyle(
                      color: Color(0xFF1F2329),
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                widget.dataItem["profile"]["gender"] == 2
                    ? ""
                    : widget.dataItem["profile"]["gender"] == 1
                        ? "Nam"
                        : "Nữ",
                style: TextStyle(
                    color: Colors.black.withOpacity(0.7), fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
              onPressed: () {
                showLoadingDialog(context);
                InviteApi()
                    .postAcceptInvite(widget.dataItem["id"], true)
                    .then((res) {
                  if (isSuccessStatus(res["code"])) {
                    Get.back();
                    HomeController homeController = Get.put(HomeController());
                    homeController.onRefresh();
                    successAlert(
                        title: "Thành công",
                        btnOkOnPress: () {},
                        desc:
                            "Đã chấp thuận thành viên ${widget.dataItem["profile"]['fullName']} vào nhóm");
                    widget.onReload();
                  } else {
                    Get.back();
                    errorAlert(title: "Thất bại", desc: res["message"]);
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  backgroundColor: const Color(0xFF0F5AC0)),
              child: const Text(
                "Xác nhận",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              )),
          const SizedBox(
            width: 5,
          ),
          ElevatedButton(
              onPressed: () {
                InviteApi().postAcceptInvite(widget.dataItem["id"], false);
                widget.onReload();
              },
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  backgroundColor: const Color(0xFFDADADB)),
              child: const Text(
                "Xóa",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              )),
          const SizedBox(
            width: 10,
          )
        ],
      ),
    );
  }
}

class OrgInviteItem extends StatefulWidget {
  final Map dataItem;
  final Function onReload;
  const OrgInviteItem(
      {super.key, required this.dataItem, required this.onReload});

  @override
  State<OrgInviteItem> createState() => _OrgInviteItemState();
}

class _OrgInviteItemState extends State<OrgInviteItem> {
  bool isClick = false;
  @override
  Widget build(BuildContext context) {
    return isClick
        ? Container()
        : Container(
            color: Colors.white,
            padding:
                const EdgeInsets.only(bottom: 16, left: 16, top: 16, right: 4),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0x663949AB), width: 1),
                      color: Colors.white),
                  child: widget.dataItem["profile"]["avatar"] == null
                      ? createCircleAvatar(
                          name: widget.dataItem["profile"]['fullName'],
                          radius: 20)
                      : CircleAvatar(
                          backgroundImage: getAvatarProvider(
                              widget.dataItem["profile"]["avatar"]),
                        ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: Get.width - 190,
                      child: Text(
                        widget.dataItem["profile"]['fullName'],
                        style: const TextStyle(
                            color: Color(0xFF1F2329),
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      widget.dataItem["profile"]["gender"] == 2
                          ? ""
                          : widget.dataItem["profile"]["gender"] == 1
                              ? "Nam"
                              : "Nữ",
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.7), fontSize: 13),
                    ),
                  ],
                ),
                const Spacer(),
                widget.dataItem["status"] == 2
                    ? GestureDetector(
                        onTap: () {
                          try {
                            showLoadingDialog(context);
                            InviteApi()
                                .postRefuseInvite(widget.dataItem["id"])
                                .then((res) {
                              Get.back();
                              if (isSuccessStatus(res["code"])) {
                                widget.onReload();
                              }
                            });
                          } catch (e) {
                            Get.back();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color(0xFFd8dadf),
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          child: const Text("Hủy",
                              style: TextStyle(color: Colors.black)),
                        ),
                      )
                    : widget.dataItem["status"] == 3
                        ? Container(
                            decoration: BoxDecoration(
                                color: const Color(0xFFCCACCC),
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.all(8),
                            child: const Text("Đã từ chối",
                                style: TextStyle(color: Colors.white)))
                        : Container(),
                const SizedBox(
                  width: 10,
                )
              ],
            ),
          );
  }
}
