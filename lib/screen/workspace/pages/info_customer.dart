import 'package:coka/api/customer.dart';
import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/image_viewer_page.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/workspace/components/assign_to_bottomsheet.dart';
import 'package:coka/screen/workspace/getx/customer_controller.dart';
import 'package:coka/screen/workspace/main_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart' as g;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rive/rive.dart' hide Image;
import 'package:url_launcher/url_launcher.dart';

import '../components/customer_item.dart';
import '../components/journey_layout.dart';
import 'edit_customer.dart';

// final infoIcons = {
//   "email": Icons.mail_outline,
//   "phone": Icons.phone_outlined,
//   "gender": "assets/images/gender1.png",
//   "dob": Icons.calendar_month,
//   "maritalStatus": "assets/images/marry.png",
//   "address": Icons.location_on_outlined,
// };

class InfoCustomer extends StatefulWidget {
  const InfoCustomer({super.key});

  @override
  State<InfoCustomer> createState() => _InfoCustomerState();
}

class _InfoCustomerState extends State<InfoCustomer> {
  var tagList = [];

  List subPhoneList = [];
  List subEmailList = [];
  List detailProfileList = [];
  String? fbUrl, zaloUrl;
  final _picker = ImagePicker();
  XFile? pickedImage;
  CustomerController customerController = g.Get.put(CustomerController());
  WorkspaceMainController wmController = g.Get.put(WorkspaceMainController());
  HomeController homeController = g.Get.put(HomeController());

  Future<void> _openImagePicker() async {
    pickedImage = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 300, maxHeight: 300);
    if (pickedImage?.path != null) {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          pickedImage!.path,
          filename: pickedImage!.path.split('/').last,
          contentType: MediaType("image", "jpg"),
        ),
      });

      showLoadingDialog(g.Get.context!);
      final res = await CustomerApi().updateAvatarCustomer(
          homeController.workGroupCardDataValue['id'],
          customerController.dataItem["id"],
          formData);
      if (isSuccessStatus(res["code"])) {
        g.Get.back();
        controllerRefresh();
        successAlert(
          title: "Thành công",
          desc: "Avatar đã được cập nhật",
          btnOkOnPress: () {},
        );
      } else {
        errorAlert(title: "Thất bại", desc: res["message"]);
      }
    }
  }

  void controllerRefresh() {
    wmController.onRefresh().then((value) {
      customerController.dataItem.value = wmController
          .roomList[wmController.selectedGroupIndex.value]
          .firstWhere(
              (element) => element["id"] == customerController.dataItem["id"]);
      customerController.update();
    });
  }

  SMIInput<double>? _rating;
  void _onRiveInit(Artboard artboard) {
    final cController = g.Get.put(CustomerController());
    final controller = StateMachineController.fromArtboard(
      artboard,
      'State Machine 1',
      onStateChange: (stateMachineName, stateName) {
        if (_rating?.value !=
            ((cController.dataItem["rating"] ?? 0).toDouble() ?? 0)) {
          onRatingUpdate(_rating?.value);
        }
      },
    );
    artboard.addController(controller!);
    _rating = controller.findInput<double>('rating') as SMINumber;
    _rating?.value = (cController.dataItem["rating"] ?? 0).toDouble() ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    // final List<DropdownMenuEntry<String>> tagEntries =
    // <DropdownMenuEntry<String>>[];
    // for (final tagLabel in tagMenu) {
    //   tagEntries.add(DropdownMenuEntry<String>(
    //       value: tagLabel, label: tagLabel, enabled: true));
    // }
    return g.GetBuilder<CustomerController>(builder: (controller) {
      detailProfileList.clear();
      subPhoneList.clear();
      subEmailList.clear();
      tagList = customerController.dataItem["tags"];
      if (customerController.dataItem["additional"].isNotEmpty) {
        for (var x in customerController.dataItem["additional"]) {
          if (x["key"] == "phone") {
            subPhoneList.add({"value": x["value"], "name": x["name"]});
          } else if (x["key"] == "email") {
            subEmailList.add({"value": x["value"], "name": x["name"]});
          }
        }
      }
      if (customerController.dataItem["social"]?.isNotEmpty ?? false) {
        for (var x in customerController.dataItem["social"]) {
          if (x["provider"] == "FACEBOOK") {
            fbUrl = x["profileUrl"];
          } else if (x["provider"] == "ZALO") {
            zaloUrl = x["profileUrl"];
          }
        }
      }
      detailProfileList = [
        if (customerController.dataItem["gender"] != null &&
            getValue("gender", customerController.dataItem["gender"]) != null)
          {
            "name": "Giới tính",
            "value": getValue("gender", customerController.dataItem["gender"])
          },
        if (customerController.dataItem["dob"] != null &&
            getValue("dob", customerController.dataItem["dob"]) != null)
          {
            "name": "Sinh nhật",
            "value": getValue("dob", customerController.dataItem["dob"])
          },
        if (customerController.dataItem["physicalId"] != null)
          {
            "name": "CMND/CCCD",
            "value": customerController.dataItem["physicalId"]
          },
        if (customerController.dataItem["address"] != null)
          {"name": "Nơi ở", "value": customerController.dataItem["address"]},
        if (customerController.dataItem["source"]?.isNotEmpty)
          {
            "name": "Nguồn khách hàng",
            "value": customerController.dataItem["source"]?.last["utmSource"]
          },
        if (customerController.dataItem["source"]?.isNotEmpty)
          {
            "name": "Phân loại khách hàng",
            "value": customerController.dataItem["source"]?.last["sourceName"]
          },
        ...detailProfileList,
      ];
      final mainIcons = [
        {
          "id": "phone",
          "icon": const Icon(Icons.phone, color: Color(0xFF554FE8), size: 25),
          "onTap": () async {
            callMethodBottomSheet();
          }
        },
        {
          "id": "sms",
          "icon": const Icon(Icons.chat, color: Color(0xFF554FE8), size: 25),
          "onTap": () async {
            var url = Uri.parse(
                "sms:${controller.dataItem["phone"].replaceFirst("84", "0")}");
            if (!await launchUrl(url)) {
              throw Exception('Could not launch $url');
            }
          }
        },
        {
          "id": "mail",
          "icon": controller.dataItem["email"] != null
              ? const Icon(Icons.mail, color: Color(0xFF554FE8), size: 25)
              : const Icon(Icons.mail, color: Color(0xFFF8F8F8), size: 25),
          "onTap": () async {
            if (controller.dataItem["email"] != null) {
              var url = Uri.parse("mailto:${controller.dataItem["email"]}");
              if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
              }
            }
          }
        },
        {
          "id": "facebook",
          "icon": fbUrl != null
              ? const Icon(Icons.facebook, color: Color(0xFF554FE8), size: 25)
              : const Icon(Icons.facebook, color: Color(0xFFF8F8F8), size: 25),
          "onTap": () async {
            if (fbUrl != null) {
              var url = Uri.parse(fbUrl!);
              if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
              }
            }
          }
        },
        {
          "id": "zalo",
          "icon": zaloUrl != null
              ? SvgPicture.asset(
                  "assets/icons/zalo_icon.svg",
                  width: 22,
                  height: 22,
                )
              : SvgPicture.asset(
                  "assets/icons/zalo_inactive_icon.svg",
                  width: 22,
                  height: 22,
                ),
          "onTap": () async {
            if (zaloUrl == null) return;
            var url = Uri.parse(zaloUrl!);
            if (!await launchUrl(url)) {
              throw Exception('Could not launch $url');
            }
          }
        },
      ];
      return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          appBar: buildAppBar(context, controller),
          body: SizedBox(
            height: double.infinity,
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: buildHeaderCard(controller, context, mainIcons),
                      ),
                      const Gap(18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: customContainer(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Nhãn",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap(8),
                            Wrap(
                              children: [
                                if (tagList.isEmpty)
                                  const Text("Chưa có nhãn phân loại"),
                                ...tagList.map((e) => Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Chip(
                                        label: Text(e),
                                      ),
                                    )),
                              ],
                            )
                          ],
                        )),
                      ),
                      const Gap(18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: customContainer(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 6,
                            ),
                            const Text(
                              "Số điện thoại",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2329),
                                  fontSize: 14),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            buildRowContent(
                                name: "Chính",
                                value: controller.dataItem["phone"]
                                    .replaceFirst("84", "0")),
                            ...subPhoneList.map((e) => buildRowContent(
                                name: e["name"], value: e["value"]))
                          ],
                        )),
                      ),
                      if (controller.dataItem["email"] != null &&
                          controller.dataItem["email"] != "")
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 18.0, left: 16, right: 16),
                          child: customContainer(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 6,
                              ),
                              const Text(
                                "Email",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2329),
                                    fontSize: 14),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              buildRowContent(
                                  name: "Chính",
                                  value: controller.dataItem["email"]),
                              ...subEmailList.map((e) => buildRowContent(
                                  name: e["name"], value: e["value"]))
                            ],
                          )),
                        ),
                      if (detailProfileList.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 18.0, left: 16, right: 16),
                          child: customContainer(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 6,
                              ),
                              const Text(
                                "Thông tin khách hàng",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2329),
                                    fontSize: 14),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              ...detailProfileList.asMap().entries.map((entry) {
                                final index = entry.key;
                                final element = entry.value;
                                return element["value"] == null ||
                                        element["value"] == ""
                                    ? Container()
                                    : Column(
                                        children: [
                                          buildRowContent(
                                              name: element["name"],
                                              value: element["value"] ?? ""),
                                          if (index <
                                              detailProfileList.length - 1)
                                            const Divider(
                                                color: Color(0x33000000),
                                                height: 6,
                                                thickness: 0),
                                        ],
                                      );
                              })
                            ],
                          )),
                        ),
                      const SizedBox(
                        height: 100,
                      )
                    ],
                  ),
                ),
                // Positioned(
                //   bottom: 0,
                //   left: 0,
                //   right: 0,
                //   child: Opacity(
                //     opacity:
                //         (isDropdownMenuFocused() && isKeyboardVisible) ? 1 : 0,
                //     child: SingleChildScrollView(
                //       child: Container(
                //         padding:
                //             const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                //         decoration: const BoxDecoration(
                //             color: Colors.white,
                //             borderRadius:
                //                 BorderRadius.vertical(top: Radius.circular(8))),
                //         child: Row(
                //           children: [
                //             Expanded(
                //               child: CustomChipInput(
                //                   focusNode: tagFocusNode,
                //                   itemInitValue: tagChipList,
                //                   onItemChange: (p0) {
                //                     setState(() {
                //                       tagChipList = p0;
                //                     });
                //                   },
                //                   itemsMenu: tagMenu,
                //                   hintText: "Thêm thẻ phân loại"),
                //             ),
                //             const Gap(6),
                //             IconButton(
                //                 onPressed: () {
                //                   setState(() {
                //                     tagChipList.clear();
                //                     tagFocusNode.unfocus();
                //                   });
                //                 },
                //                 icon: const Icon(Icons.send))
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        );
      });
    });
  }

  AppBar buildAppBar(BuildContext context, CustomerController controller) {
    return AppBar(
      backgroundColor: const Color(0xFFF8F8F8),
      title: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
            builder: (context) => AssignToBottomSheet(
              onSelected: (data) {
                warningAlert(
                    title: "Chuyển phụ trách?",
                    desc: homeController.workGroupCardDataValue["type"] !=
                                "OWNER" ||
                            homeController.workGroupCardDataValue["type"] !=
                                "ADMIN"
                        ? "Bạn có chắc muốn phân phối data đến người này?"
                        : "Bạn sẽ mất quyền phụ trách, khi phân phối tới người này?",
                    nameOkBtn: "Đồng ý",
                    btnOkOnPress: () {
                      assignToRequest(customerController.dataItem["id"], data,
                          isInside: true);
                    });
              },
            ),
          );
        },
        child: SizedBox(
          width: 220,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 14,
              ),
              Image.asset(
                "assets/images/group_1_icon.png",
                width: 22,
                height: 22,
              ),
              const SizedBox(
                width: 4,
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 125),
                child: Text(
                  (controller.dataItem["assignToUser"]?["fullName"] ??
                          controller.dataItem["teamResponse"]?["name"]) ??
                      "Chưa có quản lý",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2329)),
                ),
              ),
              const SizedBox(
                width: 4,
              ),
              const Icon(Icons.keyboard_arrow_down_sharp),
            ],
          ),
        ),
      ),
      centerTitle: true,
      automaticallyImplyLeading: true,
      actions: [
        MenuAnchor(
            alignmentOffset: const Offset(-160, 0),
            menuChildren: [
              MenuItemButton(
                leadingIcon: const Icon(Icons.edit, size: 25),
                onPressed: () {
                  g.Get.to(() => EditCustomerPage(
                        dataItem: controller.dataItem,
                        isInside: true,
                      ));
                },
                child: const Text(
                  "Chỉnh sửa thông tin",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
            builder: (context, controller, child) {
              return IconButton(
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  icon: const Icon(
                    Icons.more_vert,
                    size: 28,
                  ));
            })
      ],
    );
  }

  Stack buildHeaderCard(CustomerController controller, BuildContext context,
      List<Map<String, Object>> mainIcons) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: customContainer(
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Align(
                  alignment: Alignment.topCenter,
                  heightFactor: controller.dataItem['work'] != null ? 1 : 0.7,
                  child: Text(
                    controller.dataItem['fullName'],
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF171A1F)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                if (controller.dataItem['work'] != null)
                  Align(
                    alignment: Alignment.topCenter,
                    heightFactor: 0.8,
                    child: Text(
                      controller.dataItem['work'],
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: 0.35,
                    child: RiveAnimation.asset(
                        'assets/animations/rating_animation.riv',
                        onInit: _onRiveInit,
                        stateMachines: const ["State Machine 1"],
                        // animations: const ['0', '1', '2', '3', '4', '5'],
                        useArtboardSize: true),
                  ),
                ),
                // buildRatingBar(controller, context),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ...mainIcons.map((e) => buildCircleIcon(
                          icon: e["icon"] as Widget,
                          onTap: e["onTap"] as Function()))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        Center(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: controller.dataItem['avatar'] == null
                    ? createCircleAvatar(
                        name: controller.dataItem['fullName'],
                        fontSize: 30,
                        radius: 40,
                      )
                    : InkWell(
                        onTap: () {
                          print("open imgviewer");
                          g.Get.to(
                              () => ImagePageViewer(
                                  imageProvider: getAvatarProvider(
                                      controller.dataItem['avatar'] ??
                                          defaultAvatar)),
                              transition: g.Transition.noTransition);
                        },
                        child: Hero(
                          tag: "avatarImg",
                          child: CircleAvatar(
                            backgroundImage: getAvatarProvider(
                                controller.dataItem['avatar'] ?? defaultAvatar),
                            radius: 40,
                          ),
                        ),
                      ),
              ),
              Positioned(
                  right: 0,
                  bottom: 0,
                  child: InkWell(
                    onTap: () {
                      _openImagePicker();
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      padding: const EdgeInsets.all(4),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFe5f4ff),
                        border: Border.fromBorderSide(BorderSide(
                            color: Colors.white,
                            strokeAlign: BorderSide.strokeAlignInside,
                            width: 2)),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.black,
                        size: 18,
                      ),
                    ),
                  ))
            ],
          ),
        )
      ],
    );
  }

  Widget buildRowContent({required String name, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(color: Color(0xB2000000)),
          ),
          const Spacer(),
          Container(
            constraints: BoxConstraints(maxWidth: g.Get.width - 165),
            child: SelectableText(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w500),
            ),
          )
        ],
      ),
    );
  }

  void onRatingUpdate(rating) {
    CustomerApi()
        .updateRatingCustomer(homeController.workGroupCardDataValue['id'],
            customerController.dataItem["id"], rating.toInt())
        .then((res) {
      if (isSuccessStatus(res["code"])) {
        customerController.dataItem["rating"] = rating.toInt();
        wmController.roomList[wmController.selectedGroupIndex.value].firstWhere(
            (element) =>
                element["id"] ==
                customerController.dataItem["id"])["rating"] = rating.toInt();
        customerController.fetchJourney();
        wmController.update();
      } else {
        errorAlert(
            title: "Thất bại",
            desc: res["message"] ?? "Đã xảy ra lỗi xin vui lòng thử lại");
      }
    });
  }
}

Widget customContainer({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1A000000),
              spreadRadius: 0,
              blurRadius: 8,
              offset: Offset(0, 2))
        ]),
    child: child,
  );
}

Widget buildCircleIcon({
  Function()? onTap,
  required Widget icon,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(8),
      decoration:
          const BoxDecoration(color: Color(0xFFE3DFFF), shape: BoxShape.circle),
      child: icon,
    ),
  );
}

String? getValue(key, value) {
  final lowerCaseKey = key.toLowerCase();
  if (lowerCaseKey == "gender") {
    return value == 1
        ? "Nam"
        : value == 0
            ? "Nữ"
            : "Khác";
  }
  if (lowerCaseKey == "maritalstatus") {
    return value == 1
        ? "Đã kết hôn"
        : value == 0
            ? "Độc thân"
            : null;
  }
  if (lowerCaseKey == "dob") {
    if (value == null) return null;
    final inputDateTime = DateTime.parse(value);
    final outputDateFormat = DateFormat('dd/MM/yyyy', 'vi');
    final outputDateString = outputDateFormat.format(inputDateTime);
    return outputDateString;
  }
  if (lowerCaseKey == "phone") {
    return value.replaceFirst("84", "0");
  }
  return value;
}
