import 'dart:convert';

import 'package:coka/api/ifttt.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/elevated_btn.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/action_item.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/stick_add_widget.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/trigger_btn_widget.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/trigger_selector/trigger_selector_page.dart';
import 'package:coka/screen/crm_automation/crm_auto_controller.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../components/border_textfield.dart';
import '../../../home/components/more_workspace_bottomsheet.dart';
import 'add_applet_controller.dart';
import 'components/trigger_selector/trigger_selector_binding.dart';

class AddAppletPage extends StatefulWidget {
  final bool isEdit;
  final String? appletId;

  const AddAppletPage({super.key, required this.isEdit, this.appletId});

  @override
  State<AddAppletPage> createState() => _AddAppletPageState();
}

class _AddAppletPageState extends State<AddAppletPage> {
  final workspaceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddAppletController>(builder: (controller) {
      return Obx(() {
        return Form(
          key: _formKey,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text(
                widget.isEdit ? "Chỉnh sửa kịch bản" : 'Tạo kịch bản',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              leading: ElevatedBtn(
                  onPressed: () {
                    Get.back();
                  },
                  circular: 30,
                  paddingAllValue: 15,
                  child: SvgPicture.asset(
                    'assets/icons/back_arrow.svg',
                    height: 30,
                    width: 30,
                  )),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: Get.context!,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          constraints:
                              BoxConstraints(maxHeight: Get.height - 45),
                          shape: const RoundedRectangleBorder(
                            // <-- SEE HERE
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(14.0),
                            ),
                          ),
                          builder: (BuildContext context) {
                            return MoreWorkspaceBottomSheet(
                              isHome: false,
                              funcAutomation: (data) {
                                controller.currentWorkspace.value = data;
                                workspaceController.text = data["name"];
                                Get.back();
                              },
                            );
                          },
                        );
                      },
                      child: BorderTextField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Hãy chọn nhóm làm việc';
                          }
                          return null;
                        },
                        controller: workspaceController,
                        name: "Nhóm làm việc",
                        nameHolder: "Chọn nhóm làm việc",
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                        isEditAble: false,
                      ),
                    ),
                  ),
                  TriggerBtn(
                    triggerObject: controller.triggerData.value,
                    onPressed: () {
                      Get.to(() => const TriggerSelectorPage(),
                          binding: TriggerSelectorBinding());
                    },
                  ),
                  StickAdd(
                    onPressed: () {
                      controller.actionList.insert(0, 0);
                    },
                  ),
                  AnimatedList(
                    key: controller.listKey,
                    initialItemCount: controller.actionList.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index, animation) =>
                        ActionItem(animation: animation, index: index),
                  ),
                  const SizedBox(
                    height: 80,
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: const Color(0xFF5C33F0),
              onPressed: () async {
                if (_formKey.currentState!.validate() &&
                    _formKey.currentState!.validate()) {
                  _formKey.currentState!.validate();
                  _formKey.currentState!.save();
                  final homeController = Get.put(HomeController());
                  var listAction = [];
                  var scriptData = "";

                  for (var x in controller.actionDataList) {
                    if (x["type"] == "path") {
                      Map pathList = {
                        "app": "EngineAPI",
                        "type": "run",
                        "action": "paths",
                        "steps": []
                      };
                      for (var y in x["pathList"]) {
                        Map pathData = {
                          "app": "EngineAPI",
                          "type": "run",
                          "action": "ifttt",
                          "steps": []
                        };
                        for (var z in y) {
                          if (z["stepsData"] == null) {
                            errorAlert(
                                title: "Lỗi",
                                desc: "Không được để trống hành động");
                            return;
                          }
                          pathData["steps"].add(z["stepsData"]);
                        }

                        pathList["steps"].add(pathData);
                      }
                      listAction.add(pathList);
                    } else {
                      if (x["stepsData"] == null) {
                        errorAlert(
                            title: "Lỗi",
                            desc: "Không được để trống hành động");
                        return;
                      }
                      listAction.add(x["stepsData"]);
                    }
                  }
                  if (controller.triggerData["stepsData"] == null) {
                    errorAlert(
                        title: "Lỗi", desc: "Không được để trống hành động");
                    return;
                  }
                  scriptData = jsonEncode({
                    "trigger": controller.triggerData["stepsData"],
                    "organizationId": homeController.oData["id"],
                    "workspaceId": controller.currentWorkspace["id"],
                    "workspaceName": controller.currentWorkspace["name"],
                    "title": "Script",
                    "steps": listAction,
                    "uiData": {
                      "triggerData": controller.triggerData,
                      "actionDataList": controller.actionDataList
                    }
                  });
                  showLoadingDialog(context);
                  if (!widget.isEdit) {
                    var response = await IftttApi().createCam(scriptData);
                    Get.back();
                    Get.back();
                    if (isSuccessStatus(response["code"])) {
                      final crmAutoController = Get.put(CrmAutoController());
                      crmAutoController.fetchCamList();
                      successAlert(
                          title: "Thành công",
                          desc: "Kịch bản đã được khởi chạy");
                    } else {
                      errorAlert(title: "Thất bại", desc: "Đã có lỗi xảy ra");
                    }
                  } else {
                    var response =
                        await IftttApi().updateCampaign(widget.appletId!, {
                      "steps": listAction,
                      "trigger": controller.triggerData["stepsData"],
                      "uiData": {
                        "triggerData": controller.triggerData,
                        "actionDataList": controller.actionDataList
                      }
                    });
                    Get.back();

                    if (response["error"] == null) {
                      Get.back();
                      final crmAutoController = Get.put(CrmAutoController());
                      crmAutoController.fetchCamList();
                      successAlert(
                          title: "Thành công",
                          desc: "Kịch bản đã được chỉnh sửa.");
                    } else {
                      errorAlert(title: "Thất bại", desc: "Đã có lỗi xảy ra");
                    }
                  }
                }
              },
              label: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 60.0),
                child: Text(
                  "Hoàn thành",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        );
      });
    });
  }
}
