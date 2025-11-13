import 'package:coka/api/ifttt.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/screen/crm_automation/crm_auto_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'add_applet/add_applet_binding.dart';
import 'add_applet/add_applet_page.dart';

class AppletItem extends StatefulWidget {
  final Map dataItem;

  const AppletItem({super.key, required this.dataItem});

  @override
  State<AppletItem> createState() => _AppletItemState();
}

class _AppletItemState extends State<AppletItem> {
  var isActive = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isActive = widget.dataItem["isActive"];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: MenuAnchor(
          menuChildren: [
            MenuItemButton(
                leadingIcon: const Icon(Icons.delete, size: 25),
                onPressed: () {
                  warningAlert(
                      title: "Xoá kịch bản?",
                      desc: "Bạn có chắc chắn muốn xoá kịch bản này?",
                      btnOkOnPress: () {
                        showLoadingDialog(context);
                        IftttApi()
                            .deleteCampaign(widget.dataItem["id"])
                            .then((res) {
                          Get.back();
                          if (res) {
                            final crmAutoController =
                                Get.put(CrmAutoController());
                            crmAutoController.fetchCamList();
                            successAlert(
                                title: "Thành công",
                                desc: "Kịch bản đã bị xóa");
                          } else {
                            errorAlert(
                                title: "Lỗi",
                                desc: "Đã có lỗi xảy ra xin vui lòng thử lại");
                          }
                        });
                      });
                },
                child: const Text(
                  "Xóa kịch bản",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                )),
          ],
          builder: (context, controller, child) {
            return InkWell(
              onLongPress: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              onTap: () {
                Get.to(
                    () => AddAppletPage(
                        isEdit: true, appletId: widget.dataItem["id"]),
                    arguments: widget.dataItem["uiData"],
                    binding: AddAppletBinding());
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: isActive == 0
                        ? const Color(0xff676767)
                        : const Color(0xffed6002),
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 10, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ...widget.dataItem["icons"].map((e) {
                          return Row(
                            children: [
                              SvgPicture.asset(e,
                                  width: 25, height: 25, color: Colors.white),
                              const SizedBox(
                                width: 10,
                              ),
                            ],
                          );
                        }),
                        const Spacer(),
                        Switch(
                          activeTrackColor: const Color(0xff7a3000),
                          inactiveTrackColor: const Color(0xFF3D3D3D),
                          trackOutlineColor:
                              const WidgetStatePropertyAll(Colors.white),
                          value: isActive == 0 ? false : true,
                          onChanged: (value) {
                            showLoadingDialog(context);
                            IftttApi()
                                .updateCampaignStage(
                                    widget.dataItem["id"], value ? 1 : 0)
                                .then((res) {
                              Get.back();
                              if (res["error"] == null) {
                                setState(() {
                                  isActive = value ? 1 : 0;
                                });
                              } else {
                                errorAlert(
                                    title: "Thất bại",
                                    desc: "Có lỗi xảy ra vui lòng thử lại");
                              }
                            });
                          },
                          overlayColor:
                              const WidgetStatePropertyAll(Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      widget.dataItem["title"],
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1.4,
                          fontSize: 18),
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
