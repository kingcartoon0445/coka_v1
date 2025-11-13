import 'package:coka/api/callcenter.dart';
import 'package:coka/api/customer.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/workspace/components/journey_item.dart';
import 'package:coka/screen/workspace/components/stage_select_bottomsheet.dart';
import 'package:coka/screen/workspace/getx/customer_controller.dart';
import 'package:coka/screen/workspace/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' as g;
import 'package:url_launcher/url_launcher.dart';

class JourneyLayout extends StatefulWidget {
  const JourneyLayout({super.key});

  @override
  State<JourneyLayout> createState() => _JourneyLayoutState();
}

class _JourneyLayoutState extends State<JourneyLayout> {
  final chatController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return g.GetBuilder<CustomerController>(builder: (controller) {
        return RefreshIndicator(
          onRefresh: () async {
            controller.fetchJourney();
          },
          child: Container(
            color: const Color(0xFFF8F8F8),
            child: SafeArea(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50.0),
                    child: SizedBox(
                      height: double.infinity,
                      child: controller.isLoading.value
                          ? const ListJourneyPlaceholder(length: 10)
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    if (index !=
                                        controller.journeyList.length - 1)
                                      Positioned(
                                        top: index == 0 ? 20 : 0,
                                        left: 39,
                                        bottom: 0,
                                        child: Container(
                                            width: 1,
                                            color: const Color(0x66000000)),
                                      ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          bottom: index ==
                                                  controller
                                                          .journeyList.length -
                                                      1
                                              ? 80.0
                                              : 0,
                                          top: index == 0 ? 20 : 0),
                                      child: JourneyItem(
                                          dataItem:
                                              controller.journeyList[index]),
                                    ),
                                  ],
                                );
                              },
                              shrinkWrap: true,
                              itemCount: controller.journeyList.length),
                    ),
                  ),
                  Positioned(
                    bottom: 0, // Đặt vị trí dưới cùng
                    left: 0, // Đặt vị trí bên trái
                    right: 0, // Đặt vị trí bên phải
                    child: buildChatField(isKeyboardVisible),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    });
  }

  Widget buildChatField(isKeyboardVisible) {
    final controller = g.Get.put(CustomerController());

    return Column(
      children: [
        if (isKeyboardVisible)
          StageSelect(
            defaultStage: controller.stageId.value,
            // defaultStage: "",
            selectedStage: (stage) async {
              controller.stageId.value = stage;
            },
          ),
        Divider(
          height: 1,
          color: Colors.black.withOpacity(0.1),
        ),
        buildStageBottom(controller, () {}, isKeyboardVisible),
        // const BottomMenuPicker()
      ],
    );
  }

  Container buildStageBottom(
      CustomerController controller, Function onPress, isKeyboardVisible) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Row(
        children: [
          // IconButton(
          //     onPressed: () {
          //       onPress();
          //     },
          //     icon: const Icon(
          //       Icons.add,
          //       color: Color(0xFF5C33F0),
          //     )),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: TextFormField(
              cursorColor: Colors.black,
              controller: chatController,
              maxLines: 5,
              minLines: 1,
              autofocus: false,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: const Color(0x66F3EEEE),
                  hintText: "Nhập nội dung ghi chú"),
            ),
          ),
          IconButton(
              onPressed: () async {
                if (controller.stageId.value == "" && isKeyboardVisible) {
                  return errorAlert(
                      title: "Thất bại",
                      desc: "Vui lòng chọn trạng thái của khách hàng");
                }
                if (!isKeyboardVisible) {
                  callMethodBottomSheet();
                } else {
                  HomeController homeController = g.Get.put(HomeController());
                  CustomerController customerController =
                      g.Get.put(CustomerController());
                  WorkspaceMainController wmController =
                      g.Get.put(WorkspaceMainController());
                  showLoadingDialog(context);
                  final res = await CustomerApi().updateJourney(
                      homeController.workGroupCardDataValue['id'],
                      customerController.dataItem["id"], {
                    "stageId": controller.stageId.value,
                    "note": chatController.text
                  });
                  g.Get.back();
                  if (isSuccessStatus(res["code"])) {
                    chatController.clear();
                    FocusManager.instance.primaryFocus?.unfocus();
                    customerController.fetchJourney();
                    wmController.onRefresh();
                    successAlert(
                      title: "Thành công",
                      desc: "Đã cập nhật trạng thái khách hàng",
                      btnOkOnPress: () {},
                    );
                  } else {
                    errorAlert(title: "Thất bại", desc: res["message"]);
                  }
                }
              },
              icon: !isKeyboardVisible
                  ? const Icon(
                      Icons.phone_outlined,
                      color: Color(0xFF5C33F0),
                      size: 24,
                    )
                  : SvgPicture.asset(
                      "assets/icons/send_1_icon.svg",
                      color: const Color(0xFF5C33F0),
                    ))
        ],
      ),
    );
  }
}

void callMethodBottomSheet() {
  final controller = g.Get.put(CustomerController());
  showModalBottomSheet(
    isScrollControlled: true,
    context: g.Get.context!,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                  child: Text(
                "Phương thức gọi",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              )),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      var url = Uri.parse(
                          "tel:${controller.dataItem["phone"].replaceFirst("84", "0")}");
                      if (!await launchUrl(url)) {
                        throw Exception('Could not launch $url');
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                              color: const Color(0xFF43B41F),
                              borderRadius: BorderRadius.circular(14)),
                          child: const Center(
                            child:
                                Icon(Icons.call, color: Colors.white, size: 30),
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        const Text("Mặc định"),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: () async {
                      final wmController = g.Get.put(WorkspaceMainController());
                      final homeController = g.Get.put(HomeController());

                      if (homeController.isCallAble.value) {
                        wmController.handleCall(controller.dataItem["phone"]);
                        CallCenterApi().callTracking({
                          "contactId": controller.dataItem["id"],
                          "phone": controller.dataItem["phone"],
                          "extention": homeController.callData["name"]
                        });
                      } else {
                        errorAlert(
                            title: "Chưa có sẵn",
                            desc: "Bạn chưa mua gói tổng đài");
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 55,
                          height: 55,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: const Color(0xFFF1EEFF),
                              borderRadius: BorderRadius.circular(14)),
                          child: Center(
                            child: SvgPicture.asset("assets/icons/logo.svg"),
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        const Text("Tổng đài"),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ],
      ),
    ),
  );
}
