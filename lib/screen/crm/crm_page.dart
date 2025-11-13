import 'package:coka/components/elevated_btn.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

final List<Map> searchCustomerList = [
  {"name": "Import", "url": "assets/icons/import_icon.svg"},
  {"name": "Web form", "url": "assets/icons/world_icon.svg"},
  {"name": "Zalo Lead", "url": "assets/icons/note_icon.svg"},
  {"name": "Fb Lead", "url": "assets/icons/fb_icon.svg"},
  {"name": "AIDC", "url": "assets/icons/user_plus_icon.svg"},
  {"name": "Ads +", "url": "assets/icons/ads_icon.svg"},
];
final List<Map> tcCustomerList = [
  {"name": "Khách hàng", "url": "assets/icons/customer_icon.svg"},
  {"name": "Omnichannel", "url": "assets/icons/omnichannel_icon.svg"},
  {"name": "AI Chatbot", "url": "assets/icons/message_icon.svg"},
  {"name": "Call Center", "url": "assets/icons/call_center_icon.svg"},
  {"name": "Data enrichment", "url": "assets/icons/database_icon.svg"},
  {"name": "Automation", "url": "assets/icons/automate_icon.svg"},
];

// DropdownButtonHideUnderline(
// child: DropdownButton<Map>(
// value: controller.workGroupCardDataValue.value,
// menuMaxHeight: 120,
//
// elevation: 1,
// onChanged: (value) {
// controller.workGroupCardDataValue.value = value!;
// },
// iconSize: 35,
// items: controller.workGroupCardDataList.map((Map item) {
// return DropdownMenuItem<Map>(
// key: ValueKey(item['id']),
// value: item,
// child: Text(item['name'],style: TextStyle(color: Color(0xFF171A1F),fontSize: 18,fontWeight: FontWeight.bold),),
// );
// }).toList(),
// ),
// ),
class CrmPage extends StatelessWidget {
  const CrmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (controller) {
      return Obx(() => controller.workGroupCardDataList.isNotEmpty
          ? Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 200, // đặt chiều rộng tối đa
                  ),
                  child: PopupMenuButton<Map>(
                      splashRadius: 0,
                      onSelected: (Map value) {
                        controller.workGroupCardDataValue.value = value;
                      },
                      initialValue: controller.workGroupCardDataValue.value,
                      itemBuilder: (BuildContext context) {
                        return controller.workGroupCardDataList.map((Map item) {
                          return PopupMenuItem<Map>(
                            value: item,
                            padding: EdgeInsets.zero,
                            child: Container(
                                width: 200,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  item['name'],
                                  style: const TextStyle(
                                      color: Color(0xFF171A1F),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                )),
                          );
                        }).toList();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              controller.workGroupCardDataValue['name'],
                              style: const TextStyle(
                                  color: Color(0xFF171A1F),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          SvgPicture.asset(
                            'assets/icons/arrow_down_1.svg',
                            width: 27,
                            height: 27,
                          )
                        ],
                      )),
                ),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'Tìm kiếm khách hàng',
                        style: TextStyle(
                            color: Color(0xFF323842),
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      children: List.generate(6, (index) {
                        return Column(
                          children: [
                            ElevatedBtn(
                                circular: 6,
                                onPressed: () {
                                  if (index == 0) {
                                    _askPermissions(false).then((value) => {
                                          Get.back(closeOverlays: true),
                                          _askPermissions(true)
                                        });
                                  } else if (index == 1) {}
                                },
                                paddingAllValue: 2,
                                child: SvgPicture.asset(
                                  searchCustomerList[index]['url'],
                                  color: const Color(0xFF60AEFF),
                                  width: 40,
                                )),
                            Text(
                              searchCustomerList[index]['name'],
                              style: const TextStyle(
                                  color: Color(0xFF565E6C), fontSize: 14),
                            )
                          ],
                        );
                      }),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'Chăm sóc khách hàng',
                        style: TextStyle(
                            color: Color(0xFF323842),
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      children: List.generate(6, (index) {
                        return Column(
                          children: [
                            ElevatedBtn(
                                circular: 6,
                                onPressed: () {
                                  if (index == 0) {
                                    Get.toNamed('/crmCustomer');
                                  } else if (index == 1) {
                                    Get.toNamed('/crmOmnichannel');
                                  } else if (index == 5) {
                                    Get.toNamed('/crmAuto');
                                  }
                                },
                                paddingAllValue: 2,
                                child: SvgPicture.asset(
                                  tcCustomerList[index]['url'],
                                  width: 40,
                                )),
                            Text(
                              tcCustomerList[index]['name'],
                              style: const TextStyle(
                                color: Color(0xFF565E6C),
                                fontSize: 12,
                              ),
                            )
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            )
          : Scaffold(
              body: Center(
                child: Column(
                  children: [
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Image.asset('assets/images/hub_blank.png'),
                    ),
                    const Text(
                      'Không tìm thấy nhóm làm việc nào',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          // controller.selectedIndex.value = 0;
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF725fdf),
                            maximumSize: const Size(190, 65),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Quay lại trang chủ',
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
                    const Spacer(),
                  ],
                ),
              ),
            ));
    });
  }
}

Future<void> _askPermissions(bool check) async {
  PermissionStatus permissionStatus = await Permission.contacts.request();
  if (permissionStatus == PermissionStatus.granted) {
    if (check) {}
  } else {
    _handleInvalidPermissions(permissionStatus);
  }
}

void _handleInvalidPermissions(PermissionStatus permissionStatus) {
  if (permissionStatus == PermissionStatus.permanentlyDenied) {
    const snackBar =
        SnackBar(content: Text('Quyền truy cập vào danh bạ bị từ chối'));
    ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
    openAppSettings();
  }
}
