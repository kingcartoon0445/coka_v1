import 'package:coka/api/team.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/elevated_btn.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/workspace/getx/team_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auto_avatar.dart';

class MemberM2TItem extends StatefulWidget {
  final Map dataItem;
  final String teamId;
  final bool isInvited;
  const MemberM2TItem(
      {super.key,
      required this.dataItem,
      required this.teamId,
      required this.isInvited});

  @override
  State<MemberM2TItem> createState() => _MemberM2TItemState();
}

class _MemberM2TItemState extends State<MemberM2TItem> {
  HomeController homeController = Get.put(HomeController());
  TeamController teamController = Get.put(TeamController());

  bool isInvited = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isInvited = widget.isInvited;
  }

  Future onAdd() async {
    showLoadingDialog(context);
    TeamApi()
        .addMember(homeController.workGroupCardDataValue["id"], widget.teamId,
            widget.dataItem["profileId"])
        .then((res) {
      Get.back();
      if (!isSuccessStatus(res["code"])) {
        errorAlert(title: "Lỗi", desc: res["message"]);
      } else {
        teamController.fetchMemberList(widget.teamId, "");
        setState(() {
          isInvited = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 8, left: 16, top: 8, right: 4),
      child: Row(
        children: [
          widget.dataItem["avatar"] == null
              ? createCircleAvatar(
                  name: widget.dataItem["fullName"], radius: 20)
              : Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0x663949AB), width: 1),
                      color: Colors.white),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: getAvatarWidget(widget.dataItem["avatar"]),
                  ),
                ),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.dataItem["fullName"] ?? "",
                style: const TextStyle(
                    color: Color(0xFF1F2329),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 2,
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: Get.width - 155),
                child: Text(
                  widget.dataItem["email"],
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 13,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedBtn(
              circular: 14,
              paddingAllValue: 0,
              onPressed: !isInvited ? onAdd : () {},
              child: isInvited
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 9, horizontal: 9),
                      decoration: BoxDecoration(
                          color: const Color(0xfffc6d72),
                          borderRadius: BorderRadius.circular(14)),
                      child: const Text(
                        'Đã thêm',
                        style:
                            TextStyle(color: Color(0xFFfef0f1), fontSize: 13),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 9, horizontal: 9),
                      decoration: BoxDecoration(
                          color: const Color(0xFFfef0f1),
                          borderRadius: BorderRadius.circular(14)),
                      child: const Text(
                        'Thêm',
                        style:
                            TextStyle(color: Color(0xFFf22128), fontSize: 13),
                      ),
                    )),
          const SizedBox(
            width: 12,
          ),
        ],
      ),
    );
  }
}
