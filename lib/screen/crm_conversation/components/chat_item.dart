import 'package:coka/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../crm_conversation_controller.dart';

class ChatItem extends StatelessWidget {
  final Map dataItem;

  const ChatItem({super.key, required this.dataItem});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CrmConversationController>(builder: (controller) {
      return Obx(() {
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: controller.roomInfo['personId'] == dataItem['from']
                      ? CircleAvatar(
                          backgroundImage:
                              MemoryImage(controller.roomInfo['personAvatar']))
                      : Container(),
                ),
                const SizedBox(
                  width: 12,
                ),
                Container(
                  width: Get.width - 120,
                  constraints: const BoxConstraints(minHeight: 50),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: controller.roomInfo['personId'] == dataItem['from']
                          ? const Color(0xFFFEF1F0)
                          : const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      controller.roomInfo['personId'] == dataItem['from']
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: Get.width*0.5,
                                  child: Text(
                                    controller.roomInfo['personName'],
                                    style: const TextStyle(
                                        color: Color(0xFFf1548b), fontSize: 15),textAlign: TextAlign.left,overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  timeStampToHour(dataItem['timestamp']),
                                  style: const TextStyle(
                                      color: Color(0xFF565E6C), fontSize: 13),
                                )
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  timeStampToHour(dataItem['timestamp']),
                                  style: const TextStyle(
                                      color: Color(0xFF565E6C), fontSize: 13),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: Get.width*0.5,
                                  child: Text(
                                    controller.roomInfo['pageName'],
                                    style: const TextStyle(
                                        color: Color(0xFF60AEFF), fontSize: 15),textAlign: TextAlign.right,overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(
                        height: 2,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                              width: double.infinity,
                              child: SelectableLinkify(
                                text: dataItem['message'],
                                style: const TextStyle(fontSize: 15),
                                onOpen: (link) async {
                                  if (await canLaunchUrl(Uri.parse(link.url))) {
                                    await launchUrl(Uri.parse(link.url),mode: LaunchMode.externalApplication);
                                  } else {
                                    throw 'Could not launch $link';
                                  }
                                },

                              )),
                          if (dataItem['sendIndex'] != null)
                            controller.stateWidget(dataItem['sendIndex'])
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Container(
                  height: 30,
                  width: 30,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: controller.roomInfo['pageId'] == dataItem['from']
                      ? CircleAvatar(
                          backgroundImage:
                              MemoryImage(controller.roomInfo['pageAvatar']))
                      : Container(),
                ),
              ],
            ),
            const SizedBox(
              height: 18,
            )
          ],
        );
      });
    });
  }
}
