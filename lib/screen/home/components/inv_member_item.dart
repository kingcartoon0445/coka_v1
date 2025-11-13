import 'package:coka/api/invite.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/auto_avatar.dart';

class InvMemberItem extends StatefulWidget {
  final Map dataItem;
  const InvMemberItem({super.key, required this.dataItem});

  @override
  State<InvMemberItem> createState() => _InvMemberItemState();
}

class _InvMemberItemState extends State<InvMemberItem> {
  int stageBtn = 0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          widget.dataItem['avatar'] == null
              ? createCircleAvatar(
                  name: widget.dataItem['fullName'], radius: 25)
              : CircleAvatar(
                  radius: 25,
                  backgroundImage: getAvatarProvider(widget.dataItem["avatar"]),
                ),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: Get.width - 160,
                child: Text(widget.dataItem["fullName"],
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF44474F))),
              ),
              Text(widget.dataItem["email"] ?? widget.dataItem["phone"] ?? "",
                  style: TextStyle(
                      fontSize: 11, color: Colors.black.withOpacity(0.7))),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              showLoadingDialog(context);
              InviteApi()
                  .postOrgInvite(widget.dataItem["profileId"])
                  .then((res) {
                Get.back();
                if (isSuccessStatus(res["code"])) {
                  setState(() {
                    stageBtn = 1;
                  });
                } else {
                  errorAlert(title: "Thất bại", desc: res["message"]);
                }
              });
            },
            style: ElevatedButton.styleFrom(
                elevation: 0,
                minimumSize: Size.zero,
                backgroundColor: stageBtn == 1 || widget.dataItem["isInvite"]
                    ? Colors.white
                    : const Color(0xFF7926F5).withOpacity(0.6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5)),
            child: Text(
              stageBtn != 0 || widget.dataItem["isInvite"] ? "Đã gửi" : "Mời",
              style: TextStyle(
                  color: stageBtn != 0 || widget.dataItem["isInvite"]
                      ? const Color(0xFF7926F5).withOpacity(0.6)
                      : Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
