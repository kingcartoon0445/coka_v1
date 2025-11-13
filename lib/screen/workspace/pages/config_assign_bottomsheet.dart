import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/inc_dec_widget.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/home_controller.dart';
import '../getx/team_controller.dart';

class ConfigAssignBottomSheet extends StatefulWidget {
  final String? parentId;
  final List teamList, countObject;
  final Function onSwitchChange;
  final Function onRatioChange;
  final bool? isAutoAssignToNew;
  const ConfigAssignBottomSheet(
      {super.key,
      required this.onSwitchChange,
      this.isAutoAssignToNew,
      this.parentId,
      required this.onRatioChange,
      required this.teamList,
      required this.countObject});

  @override
  State<ConfigAssignBottomSheet> createState() =>
      _ConfigAssignBottomSheetState();
}

class _ConfigAssignBottomSheetState extends State<ConfigAssignBottomSheet> {
  bool? isAutoAssignToNew;
  var isTeamFetching = false;
  TextEditingController searchTeamController = TextEditingController();
  final teamController = Get.put(TeamController());
  final homeController = Get.put(HomeController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isAutoAssignToNew = widget.isAutoAssignToNew ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: Get.height - 100),
      child: Wrap(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 14.0),
                child: Center(
                  child: Text("Tuỳ chỉnh",
                      style: TextStyle(
                          color: Color(0xFF1F2329),
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 16,
                  ),
                  const Text("Phân phối tới team hoặc sale mới",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                  const Spacer(),
                  Switch(
                    value: isAutoAssignToNew!,
                    onChanged: (value) {
                      setState(() {
                        isAutoAssignToNew = value;
                      });
                      widget.onSwitchChange(value);
                    },
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                ],
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 500),
                child: isTeamFetching
                    ? const ListPlaceholder(length: 10)
                    : widget.teamList.isNotEmpty
                        ? ListView.builder(
                            itemBuilder: (context, index) {
                              final avatar = widget.teamList[index]["avatar"];
                              final name = widget.teamList[index]["name"];
                              const subtitle = "";
                              return buildListTile(
                                  index, avatar, name, subtitle,
                                  isMember: false, onChange: (value) {
                                widget.countObject.firstWhere((element) =>
                                        element["refId"] ==
                                        widget.teamList[index]["id"])["ratio"] =
                                    value;
                                widget.onRatioChange(widget.countObject);
                              });
                            },
                            itemCount: widget.teamList.length,
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                          )
                        : teamController.isFetching.value
                            ? const ListPlaceholder(length: 4)
                            : ListView.builder(
                                physics: const ClampingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final profile = teamController
                                      .memberList[index]["profile"];
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        bottom: index ==
                                                teamController
                                                        .memberList.length -
                                                    1
                                            ? 75
                                            : 0),
                                    child: ListTile(
                                        title: Text(
                                          profile["fullName"],
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF1F2329)),
                                        ),
                                        subtitle: const Text("Thành viên"),
                                        trailing: IncrementDecrementWidget(
                                            onChange: (value) {
                                              widget.countObject[index]
                                                  ["ratio"] = value;
                                              widget.onRatioChange(
                                                  widget.countObject);
                                            },
                                            initValue: widget.countObject[index]
                                                    ["ratio"] ??
                                                1),
                                        leading: profile['avatar'] == null
                                            ? createCircleAvatar(
                                                name: profile["fullName"],
                                                radius: 22)
                                            : CircleAvatar(
                                                backgroundImage:
                                                    getAvatarProvider(
                                                        profile['avatar'] ??
                                                            defaultAvatar),
                                                radius: 22,
                                              )),
                                  );
                                },
                                shrinkWrap: true,
                                itemCount: teamController.memberList.length,
                              ),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ],
      ),
    );
  }

  Container buildListTile(index, avatar, name, subtitle,
      {bool? isMember, required Function onChange}) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(index == 0 ? 12 : 0),
              bottom: Radius.circular(
                  index == widget.teamList.length - 1 ? 12 : 0))),
      child: ListTile(
        contentPadding:
            const EdgeInsets.only(left: 16, right: 10, bottom: 0, top: 0),
        leading: avatar == null
            ? createCircleAvatar(name: name, radius: 20)
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
                  child: getAvatarWidget(avatar),
                ),
              ),
        title: Text(name,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 13),
        ),
        trailing: IncrementDecrementWidget(
            onChange: (value) {
              onChange(value);
            },
            initValue: widget.countObject[index]["ratio"] ?? 1),
      ),
    );
  }
}
