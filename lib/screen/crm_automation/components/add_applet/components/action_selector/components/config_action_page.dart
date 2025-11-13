import 'package:coka/components/elevated_btn.dart';
import 'package:coka/screen/crm_automation/components/add_applet/add_applet_controller.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/action_selector/components/action_component/assign_team_action.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/action_selector/components/action_component/assign_user_action.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/action_selector/components/action_component/gmail_send_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../action_selector_controller.dart';
import 'action_component/notify_send_action.dart';

class ConfigActionPage extends StatefulWidget {
  final String id;
  final int index;
  final bool isPath;

  const ConfigActionPage(
      {super.key, required this.id, required this.index, required this.isPath});

  @override
  State<ConfigActionPage> createState() => _ConfigActionPageState();
}

class _ConfigActionPageState extends State<ConfigActionPage> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    final controller = Get.put(ActionSelectorController());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ActionSelectorController>(builder: (controller) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            title: const Text(
              'Cấu hình',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            backgroundColor: actionUiData[widget.id]!["bgColor"] as Color,
            leading: ElevatedBtn(
                onPressed: () {
                  Get.back();
                },
                circular: 30,
                paddingAllValue: 15,
                child: SvgPicture.asset(
                  'assets/icons/back_arrow.svg',
                  color: Colors.white,
                  height: 30,
                  width: 30,
                ))),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            constraints: BoxConstraints(minHeight: Get.height),
            color: actionUiData[widget.id]!["bgColor"] as Color,
            child: Column(
              children: [
                SvgPicture.asset(actionUiData[widget.id]!["iconPath"] as String,
                    color: Colors.white, width: 100),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  actionUiData[widget.id]!["name"] as String,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 22),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  (actionUiData[widget.id]!["actions"] as List)[widget.index]
                      ["title"],
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(
                  height: 20,
                ),
                getActionWidget(
                    (actionUiData[widget.id]!["actions"] as List)[widget.index]
                        ["id"],
                    widget.index,
                    widget.isPath),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

Widget getActionWidget(id, index, isPath) {
  if (id == "email_send") {
    return GmailAction(
      id: id,
      index: index,
      isPath: isPath,
    );
  }
  if (id == "notify_send") {
    return NotifyAction(
      id: id,
      index: index,
      isPath: isPath,
    );
  }
  if (id == "assign_user") {
    return AssignUserAction(
      id: id,
      index: index,
      isPath: isPath,
    );
  }
  if (id == "assign_team") {
    return AssignTeamAction(
      id: id,
      index: index,
      isPath: isPath,
    );
  }
  return Container();
}
