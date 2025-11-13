import 'package:coka/api/org_request.dart';
import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JoinOrgItem extends StatefulWidget {
  final Map dataItem;
  const JoinOrgItem({
    super.key,
    required this.dataItem,
  });

  @override
  State<JoinOrgItem> createState() => _JoinOrgItemState();
}

class _JoinOrgItemState extends State<JoinOrgItem> {
  int stageBtn = 0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          widget.dataItem['avatar'] == null
              ? createCircleAvatar(name: widget.dataItem['name'], radius: 20)
              : CircleAvatar(
                  radius: 25,
                  backgroundImage: getAvatarProvider(widget.dataItem["avatar"]),
                ),
          const SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: Get.width - 210,
                child: Text(widget.dataItem["name"],
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF44474F))),
              ),
              Text(
                  widget.dataItem["subscription"] == "PERSONAL"
                      ? "Cá nhân"
                      : "Doanh nghiệp",
                  style: TextStyle(
                      fontSize: 11, color: Colors.black.withOpacity(0.7))),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              if (!widget.dataItem["isRequest"]) {
                showLoadingDialog(context);
                if (stageBtn != 1) {
                  try {
                    OrgRequestApi()
                        .postOrgRequest(widget.dataItem["organizationId"])
                        .then((res) {
                      Get.back();
                      if (isSuccessStatus(res["code"])) {
                        setState(() {
                          stageBtn = 1;
                        });
                      }
                    });
                  } catch (e) {
                    Get.back();
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
                elevation: 0,
                minimumSize: Size.zero,
                backgroundColor: stageBtn == 1 || widget.dataItem["isRequest"]
                    ? Colors.white
                    : const Color(0xFF7926F5).withOpacity(0.6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 5)),
            child: Text(
              stageBtn != 0 || widget.dataItem["isRequest"]
                  ? "Đã gửi"
                  : "Tham gia",
              style: TextStyle(
                  color: stageBtn != 0 || widget.dataItem["isRequest"]
                      ? const Color(0xFF7926F5).withOpacity(0.6)
                      : Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
