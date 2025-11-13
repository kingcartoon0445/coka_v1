import 'package:coka/api/org_request.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/auto_avatar.dart';

class ProfileInviteItem extends StatefulWidget {
  final Map dataItem;
  final Function onReload;
  const ProfileInviteItem(
      {super.key, required this.dataItem, required this.onReload});

  @override
  State<ProfileInviteItem> createState() => _ProfileInviteItemState();
}

class _ProfileInviteItemState extends State<ProfileInviteItem> {
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
            child: widget.dataItem["organization"]["avatar"] == null
                ? createCircleAvatar(
                    name: widget.dataItem["organization"]['name'], radius: 20)
                : CircleAvatar(
                    backgroundImage: getAvatarProvider(
                        widget.dataItem["organization"]["avatar"]),
                  ),
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: Get.width - 250,
                child: Text(
                  widget.dataItem["organization"]["name"],
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
                widget.dataItem["organization"]["subsciption"] == "PERSONAL"
                    ? "Riêng tư"
                    : "Công khai",
                style: TextStyle(
                    color: Colors.black.withOpacity(0.7), fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
              onPressed: () {
                showLoadingDialog(context);
                OrgRequestApi()
                    .postAcceptRequest(widget.dataItem["id"], true, "zzz")
                    .then((res) {
                  if (isSuccessStatus(res["code"])) {
                    Get.back();
                    HomeController homeController = Get.put(HomeController());
                    homeController.onRefresh();
                    successAlert(
                        title: "Thành công",
                        btnOkOnPress: () {},
                        desc:
                            "Bạn đã gia nhập tổ chức ${widget.dataItem["organization"]["name"]}");
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
                OrgRequestApi()
                    .postAcceptRequest(widget.dataItem["id"], false, "zzz");
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

class ProfileRequestItem extends StatefulWidget {
  final Map dataItem;
  final Function onReload;

  const ProfileRequestItem(
      {super.key, required this.dataItem, required this.onReload});

  @override
  State<ProfileRequestItem> createState() => _ProfileRequestItemState();
}

class _ProfileRequestItemState extends State<ProfileRequestItem> {
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
                  child: widget.dataItem["organization"]["avatar"] == null
                      ? createCircleAvatar(
                          name: widget.dataItem["organization"]["name"],
                          radius: 20)
                      : CircleAvatar(
                          backgroundImage: getAvatarProvider(
                              widget.dataItem["organization"]["avatar"]),
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
                        widget.dataItem["organization"]["name"],
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
                      widget.dataItem["organization"]["subsciption"] ==
                              "PERSONAL"
                          ? "Riêng tư"
                          : "Công khai",
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.7), fontSize: 13),
                    ),
                  ],
                ),
                const Spacer(),
                widget.dataItem["status"] == 2
                    ? GestureDetector(
                        onTap: () {
                          showLoadingDialog(context);
                          try {
                            OrgRequestApi()
                                .postCancelRequest(widget.dataItem["id"])
                                .then((res) {
                              Get.back();
                              if (isSuccessStatus(res["code"])) {
                                widget.onReload();
                              } else {
                                errorAlert(title: "Lỗi", desc: res["message"]);
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
