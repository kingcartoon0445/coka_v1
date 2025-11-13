import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/elevated_btn.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/workspace/components/assign_to_bottomsheet.dart';
import 'package:coka/screen/workspace/components/journey_layout.dart';
import 'package:coka/screen/workspace/getx/customer_controller.dart';
import 'package:coka/screen/workspace/pages/info_customer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../components/awesome_alert.dart';
import '../components/customer_item.dart';
import 'edit_customer.dart';

final categories = [
  "Hành trình",
  "Bán hàng",
];

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerController>(builder: (controller) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            bottom: PreferredSize(
              preferredSize:
                  const Size.fromHeight(0.0), // Height of the search bar.
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedBtn(
                      paddingAllValue: 10,
                      circular: 50,
                      onPressed: () {
                        Get.back();
                      },
                      child: SvgPicture.asset(
                        'assets/icons/back_arrow.svg',
                        width: 30,
                      )),
                  ElevatedBtn(
                    circular: 8,
                    paddingAllValue: 0,
                    onPressed: () {
                      Get.to(() => const InfoCustomer());
                    },
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: controller.dataItem['avatar'] == null
                                  ? createCircleAvatar(
                                      name: controller.dataItem['fullName'],
                                      radius: 20)
                                  : CircleAvatar(
                                      backgroundImage: getAvatarProvider(
                                          controller.dataItem['avatar'] ??
                                              defaultAvatar),
                                      radius: 20,
                                    ),
                            ),
                            // Positioned(
                            //   bottom: 2,
                            //   right: 0,
                            //   child: Container(
                            //     height: 13,
                            //     width: 20,
                            //     decoration: BoxDecoration(
                            //         borderRadius: BorderRadius.circular(6),
                            //         border: Border.all(
                            //             color: Colors.white,
                            //             width: 1,
                            //             strokeAlign:
                            //                 BorderSide.strokeAlignOutside),
                            //         color: const Color(0xff5C33F0)),
                            //     child: Row(
                            //       children: [
                            //         const Spacer(),
                            //         Text(
                            //           (controller.dataItem["rating"] ?? 0)
                            //               .toString(),
                            //           style: const TextStyle(
                            //               color: Colors.white, fontSize: 10),
                            //         ),
                            //         const Icon(
                            //           Icons.star,
                            //           color: Colors.white,
                            //           size: 8,
                            //         ),
                            //         const Spacer(),
                            //       ],
                            //     ),
                            //   ),
                            // )
                          ],
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        SizedBox(
                          width: Get.width - 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.dataItem['fullName'],
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF171A1F)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              if (controller.dataItem["gender"] != null &&
                                  controller.dataItem["dob"] != null)
                                Text(getGenderName(
                                        controller.dataItem["gender"]) +
                                    (controller.dataItem["dob"] != null
                                        ? ", ${calculateAge(controller.dataItem["dob"])} Tuổi"
                                        : "")),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  MenuAnchor(
                      alignmentOffset: const Offset(-160, 0),
                      menuChildren: [
                        MenuItemButton(
                          leadingIcon: Image.asset(
                            "assets/images/assign_to_icon.png",
                            width: 25,
                            height: 25,
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12))),
                              builder: (context) => AssignToBottomSheet(
                                onSelected: (data) {
                                  warningAlert(
                                      title: "Chuyển phụ trách?",
                                      desc: homeController.workGroupCardDataValue[
                                                      "type"] !=
                                                  "OWNER" ||
                                              homeController
                                                          .workGroupCardDataValue[
                                                      "type"] !=
                                                  "ADMIN"
                                          ? "Bạn có chắc muốn phân phối data đến người này?"
                                          : "Bạn sẽ mất quyền phụ trách, khi phân phối tới người này?",
                                      nameOkBtn: "Đồng ý",
                                      btnOkOnPress: () {
                                        assignToRequest(
                                            controller.dataItem["id"], data,
                                            isInside: true);
                                      });
                                },
                              ),
                            );
                          },
                          child: const Text(
                            "Chuyển phụ trách",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        MenuItemButton(
                          leadingIcon: const Icon(Icons.edit, size: 25),
                          onPressed: () {
                            Get.to(() => EditCustomerPage(
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
              ),
            ),
            bottomOpacity: 1.0,
          ),
          body: Material(
            color: Colors.white,
            child: SizedBox(
              height: double.infinity,
              child: Column(
                children: [
                  TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      ...categories.map(
                        (e) => Tab(
                          child: Text(e,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        const JourneyLayout(),
                        Center(
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 50,
                              ),
                              Image.asset(
                                "assets/images/comming_soon.png",
                              ),
                              const Text(
                                "Tính năng đang được phát triển\nHãy quay lại sau bạn nhé!",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     Get.bottomSheet(
          //       Wrap(
          //         children: [
          //           JourneyForm(
          //               defaultStageId: controller.dataItem["stage"]["id"]),
          //         ],
          //       ),
          //       backgroundColor: Colors.white,
          //       shape: const RoundedRectangleBorder(
          //         // <-- SEE HERE
          //         borderRadius: BorderRadius.vertical(
          //           top: Radius.circular(14.0),
          //         ),
          //       ),
          //     );
          //   },
          //   backgroundColor: const Color(0xFF5C33F0),
          //   child: const Icon(
          //     Icons.add,
          //     size: 25,
          //     color: Colors.white,
          //   ),
          // ),
        ),
      );
    });
  }
}
