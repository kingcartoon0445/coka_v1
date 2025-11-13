import 'package:coka/components/elevated_btn.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/crm_conversation/contact_detail/contact_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

final typeIcon = {
  "phone": 'assets/icons/device-mobile.svg',
  "phone_1": "assets/icons/calculator.svg",
  "website": 'assets/icons/at.svg',
  "address": "assets/icons/map-pin.svg"
};
final socialTypeIcon = {
  "facebook": 'assets/icons/fb_2_icon.svg',
  "instagram": "assets/icons/instagram_icon.svg",
  "website": 'assets/icons/at.svg',
  "address": "assets/icons/map-pin.svg"
};

class ContactDetailPage extends StatelessWidget {
  const ContactDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ContactDetailController>(builder: (controller) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFf8f9fa),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text(
            'Contact',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            ElevatedBtn(
                onPressed: () {},
                circular: 50,
                paddingAllValue: 15,
                child: Center(
                    child: SvgPicture.asset(
                  'assets/icons/note_icon.svg',
                  width: 25,
                  height: 25,
                  color: const Color(0xFFF7706E),
                )))
          ],
          elevation: 1,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Container(
                  height: 105,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          topLeft: Radius.circular(8)),
                      color: Color(0xFFF7706E),
                      shape: BoxShape.rectangle),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 12,
                          ),
                          CircleAvatar(
                            backgroundImage: getAvatarProvider(
                                controller.dataContact['avatar']),
                            radius: 32,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Text(
                            controller.dataContact['fullName'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  height: 75,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8)),
                    color: Color(0xFFF8807E),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                            width: 50,
                          ),
                          ElevatedBtn(
                              onPressed: () {},
                              circular: 50,
                              paddingAllValue: 5,
                              child: SvgPicture.asset(
                                  'assets/icons/chat-dots.svg',
                                  width: 30,
                                  height: 30,
                                  color: Colors.white)),
                          ElevatedBtn(
                              onPressed: () {},
                              circular: 50,
                              paddingAllValue: 5,
                              child: SvgPicture.asset('assets/icons/phone.svg',
                                  width: 30, height: 30, color: Colors.white)),
                          ElevatedBtn(
                              onPressed: () {},
                              circular: 50,
                              paddingAllValue: 5,
                              child: SvgPicture.asset(
                                  'assets/icons/video-camera.svg',
                                  width: 30,
                                  height: 30,
                                  color: Colors.white)),
                          ElevatedBtn(
                              onPressed: () {},
                              circular: 50,
                              paddingAllValue: 5,
                              child: SvgPicture.asset(
                                'assets/icons/envelope.svg',
                                width: 30,
                                height: 30,
                                color: Colors.white,
                              )),
                          const SizedBox(
                            width: 50,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 60),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF171a1f).withOpacity(0.5),
                          blurRadius: 1,
                          spreadRadius: 0,
                        )
                      ]),
                  child: ListView.builder(
                    itemCount: controller.dataProfileList.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(top: 16, left: 16, right: 16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  typeIcon[controller.dataProfileList[index]
                                      ["type"]]!,
                                  color: const Color(0xFFF7706E),
                                  width: 25,
                                  height: 25,
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                SizedBox(
                                    width: 200,
                                    child: Text(
                                      controller.dataProfileList[index]
                                          ["value"],
                                      style: const TextStyle(
                                          color: Color(0xFF171A1F),
                                          fontSize: 15),
                                    ))
                              ],
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            if (index != controller.dataProfileList.length - 1)
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Container(
                                  width: Get.width - 90,
                                  height: 1,
                                  color: const Color(0xFFF3F4F6),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                controller.dataSocialList.isEmpty
                    ? Container()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Social Accounts',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(minHeight: 60),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF171a1f)
                                        .withOpacity(0.5),
                                    blurRadius: 1,
                                    spreadRadius: 0,
                                  )
                                ]),
                            child: ListView.builder(
                              itemCount: controller.dataSocialList.length,
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      top: 16, left: 16, right: 16),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            socialTypeIcon[
                                                controller.dataSocialList[index]
                                                    ["type"]]!,
                                            color: const Color(0xFFF7706E),
                                            width: 25,
                                            height: 25,
                                          ),
                                          const SizedBox(
                                            width: 12,
                                          ),
                                          SizedBox(
                                              width: 200,
                                              child: Text(
                                                controller.dataSocialList[index]
                                                    ["value"],
                                                style: const TextStyle(
                                                    color: Color(0xFF171A1F),
                                                    fontSize: 15),
                                              ))
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      if (index !=
                                          controller.dataSocialList.length - 1)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 20.0),
                                          child: Container(
                                            width: Get.width - 90,
                                            height: 1,
                                            color: const Color(0xFFF3F4F6),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
