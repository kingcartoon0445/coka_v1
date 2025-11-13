import 'package:coka/components/placeholders.dart';
import 'package:coka/screen/crm_customer/components/category.dart';
import 'package:coka/screen/crm_customer/components/import_contact_layout.dart';
import 'package:coka/screen/crm_customer/components/customer_item.dart';
import 'package:coka/screen/crm_customer/crm_customer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'components/add_customer/add_customer_binding.dart';
import 'components/add_customer/add_customer_page.dart';

class CrmCustomerPage extends StatelessWidget {
  const CrmCustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GetBuilder<CrmCustomerController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Khách hàng',
            style: TextStyle(
                color: Color(0xFF171A1F),
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: true,
          actions: [
            IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(
                  'assets/icons/burger.svg',
                  width: 28,
                )),
          ],
        ),
        body: controller.isRoomEmpty.value
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Image.asset('assets/images/hub_blank.png'),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  const Text(
                    'Không tìm thấy khách hàng nào',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Get.toNamed('/crmOmnichannel');
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF725fdf),
                          maximumSize: const Size(185, 65),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Tới trang kết nối',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 20,
                            color: Colors.white,
                          )
                        ],
                      )),
                  const SizedBox(
                    height: 6,
                  ),
                  OutlinedButton(
                      onPressed: () {
                        Get.to(() => const AddCustomerPage(),
                            binding: AddCustomerBinding());
                      },
                      style: OutlinedButton.styleFrom(
                          maximumSize: const Size(185, 65),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Thêm khách hàng',
                            style: TextStyle(
                                color: Color(0xFF725fdf),
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                          Spacer(),
                          Icon(
                            Icons.add,
                            size: 20,
                            color: Color(0xFF725fdf),
                          )
                        ],
                      )),
                ],
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: SizedBox(
                      height: 46,
                      child: Center(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: controller.isReadList.length,
                          itemBuilder: (context, index) =>
                              BuildCustomerCategory(index: index),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: controller.pageController,
                          itemCount: controller.isReadList.length,
                          onPageChanged: (index) {
                            controller.currentPage.value = index;
                            controller.update();
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return (index == 0 || index == 4)
                                ? controller.isLoading.value
                                    ? const ListPlaceholder(
                                        length: 10,
                                      )
                                    : RefreshIndicator(
                                        onRefresh: () async {
                                          controller.fetchCustomer();
                                        },
                                        child: ListView.builder(
                                            itemCount:
                                                controller.roomList.length,
                                            shrinkWrap: true,
                                            physics:
                                                const ClampingScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              return index ==
                                                      controller
                                                              .roomList.length -
                                                          1
                                                  ? Column(
                                                      children: [
                                                        RoomItem(
                                                          itemData: controller
                                                              .roomList[index],
                                                          index: index,
                                                        ),
                                                        const SizedBox(
                                                          height: 60,
                                                        )
                                                      ],
                                                    )
                                                  : RoomItem(
                                                      itemData: controller
                                                          .roomList[index],
                                                      index: index,
                                                    );
                                            }),
                                      )
                                : Container();
                          },
                        ),
                        if (controller.isSyncing.value)
                          Positioned(
                            bottom: 0,
                            child: Container(
                              width: Get.width,
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                    color: Colors.white.withOpacity(0.5),
                                    spreadRadius: 4,
                                    blurRadius: 5)
                              ]),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: const Row(
                                children: [
                                  Spacer(),
                                  SpinKitThreeBounce(
                                    color: Color(0xFF725fdf),
                                    size: 25,
                                    duration: Duration(milliseconds: 1000),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text('Đang đồng bộ tin nhắn',
                                      style: TextStyle(
                                          color: Color(0xFF725fdf),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  Spacer(),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
        floatingActionButton: SpeedDial(
          icon: Icons.add,
          spacing: 15,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14))),
          activeIcon: Icons.close,
          children: [
            SpeedDialChild(
              backgroundColor: theme.colorScheme.secondary,
              label: "Nhập từ danh bạ",
              child: SvgPicture.asset(
                "assets/icons/import_icon.svg",
                color: const Color(0xFFE3DFFF),
                width: 30,
                height: 30,
              ),
              onTap: () {
                importContactLayout();
              },
            ),
            SpeedDialChild(
              label: "Nhập thủ công",
              backgroundColor: theme.colorScheme.secondary,
              child: const Icon(Icons.create, color: Colors.white),
            ),
            SpeedDialChild(
              label: "Facebook Lead",
              backgroundColor: theme.colorScheme.secondary,
              child: SvgPicture.asset(
                "assets/icons/fb_icon.svg",
                color: Colors.white,
                width: 30,
                height: 30,
              ),
            ),
            SpeedDialChild(
              label: "Zalo Lead",
              backgroundColor: theme.colorScheme.secondary,
              child: SvgPicture.asset(
                "assets/icons/zalo_bw.svg",
                color: Colors.white,
                width: 30,
                height: 30,
              ),
            ),
            SpeedDialChild(
              label: "Webform",
              backgroundColor: theme.colorScheme.secondary,
              child: SvgPicture.asset(
                "assets/icons/world_icon.svg",
                color: Colors.white,
                width: 30,
                height: 30,
              ),
            ),
          ],
        ),
        // floatingActionButton: ExpandableFab(
        //   distance: 140,
        //   children: [
        //     ActionButton(
        //       onPressed: () => {},
        //       icon: SvgPicture.asset(
        //         "assets/icons/import_icon.svg",
        //         color: Colors.white,
        //         width: 30,
        //         height: 30,
        //       ),
        //     ),
        //     ActionButton(
        //       onPressed: () => {},
        //       icon: const Icon(Icons.create),
        //     ),
        //     ActionButton(
        //       onPressed: () => {},
        //       icon: SvgPicture.asset(
        //         "assets/icons/fb_icon.svg",
        //         color: Colors.white,
        //         width: 30,
        //         height: 30,
        //       ),
        //     ),
        //     ActionButton(
        //       onPressed: () => {},
        //       icon: SvgPicture.asset(
        //         "assets/icons/zalo_bw.svg",
        //         color: Colors.white,
        //         width: 30,
        //         height: 30,
        //       ),
        //     ),
        //     ActionButton(
        //       onPressed: () => {},
        //       icon: SvgPicture.asset(
        //         "assets/icons/world_icon.svg",
        //         color: Colors.white,
        //         width: 30,
        //         height: 30,
        //       ),
        //     ),
        //   ],
        // ),
      );
    });
  }
}
