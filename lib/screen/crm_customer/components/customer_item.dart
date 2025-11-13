
import 'package:coka/components/elevated_btn.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/crm_customer/crm_customer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

String getAsset(String type) {
  switch (type.toLowerCase()) {
    case 'facebook':
      return 'assets/icons/fb_2_icon.svg';
    case 'zalo':
      return 'assets/icons/zalo_icon.svg';
    case 'instagram':
      return 'assets/icons/instagram_icon.svg';
    case 'import':
      return 'assets/icons/contact_icon.svg';
    case 'nhập vào':
      return 'assets/icons/contact_icon.svg';
    case 'form':
      return "assets/icons/form_icon.svg";
    case 'aidc':
      return 'assets/icons/aidc_icon.svg';
  }
  return '';
}

Color getColor(String type) {
  switch (type.toLowerCase()) {
    case 'facebook':
      return const Color(0xFF1687ff);
    case 'zalo':
      return Colors.white;
    case 'instagram':
      return const Color(0xFFB625BB);
    case 'import':
      return const Color(0xFF1dd75b);
    case 'nhập vào':
      return const Color(0xFF1dd75b);
    case 'form':
      return const Color(0xff1d20d7);
    case 'aidc':
      return const Color(0xff28eedc);
  }
  return const Color(0xFF1dd75b);
}

class RoomItem extends StatelessWidget {
  final Map itemData;
  final int index;

  const RoomItem({super.key, required this.itemData, required this.index});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CrmCustomerController>(builder: (controller) {
      String snipTime = diffFunc(DateTime.parse(itemData['lastModifiedDate']));
      return ElevatedBtn(
        circular: 0,
        paddingAllValue: 0,
        onPressed: () {
          var data =
              Map<String, dynamic>.from(itemData.cast<String, dynamic>());
          data.addAll({"index": index});
          Get.toNamed('/crmConversation', arguments: data);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: (itemData['unreadCount'] ?? 0) > 0
              ? const Color(0xFFFEF1F0)
              : Colors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: CircleAvatar(
                      backgroundImage:
                          getAvatarProvider(itemData['personAvatar']),
                      radius: 22,
                    ),
                  ),
                  Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 20,
                        width: 20,
                        padding: const EdgeInsets.all(4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: const Border.fromBorderSide(BorderSide(
                              color: Colors.white,
                              strokeAlign: BorderSide.strokeAlignCenter,
                              width: 2)),
                          color: getColor((itemData['source'].isEmpty)
                              ? "import"
                              : itemData['source'][0]['sourceName']),
                        ),
                        child: SvgPicture.asset(
                          getAsset((itemData['source'].isEmpty)
                              ? "import"
                              : itemData['source'][0]['sourceName']),
                          color: Colors.white,
                        ),
                      ))
                ],
              ),
              const SizedBox(
                width: 16,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (itemData['pageName'] != null)
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: MemoryImage(itemData['pageAvatar']))),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        SizedBox(
                            width: Get.width - 200,
                            child: Text(
                              itemData['pageName'],
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )),
                      ],
                    ),
                  SizedBox(
                    width: Get.width - 190,
                    child: Text(
                      itemData['personName'] ?? itemData['fullName'],
                      style: const TextStyle(
                          color: Color(0xFF171A1F),
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  SizedBox(
                    width: Get.width - 190,
                    child: Text(
                      itemData['snippet'] ?? itemData['stage']['name'],
                      style: const TextStyle(
                          color: Color(0xFF171A1F), fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  (itemData['unreadCount'] ?? 0) != 0
                      ? Container(
                          height: 16,
                          width: 16,
                          decoration: const BoxDecoration(
                              color: Color(0xFFF7706E), shape: BoxShape.circle),
                          child: Center(
                              child: Text(
                            itemData['unreadCount'].toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10),
                          )),
                        )
                      : const SizedBox(
                          height: 16,
                        ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    snipTime,
                    style:
                        const TextStyle(color: Color(0xFF171A1F), fontSize: 15),
                  )
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}
