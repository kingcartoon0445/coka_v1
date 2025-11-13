import 'package:coka/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class GptChatItem extends StatelessWidget {
  final Widget avatar;
  final bool isMe;
  final String name, message;
  final int timestamp;
  const GptChatItem(
      {super.key,
      required this.avatar,
      required this.isMe,
      required this.name,
      required this.timestamp,
      required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            !isMe
                ? avatar
                : const SizedBox(
                    width: 30,
                  ),
            const SizedBox(
              width: 12,
            ),
            Container(
              width: Get.width - 116,
              constraints: const BoxConstraints(minHeight: 50),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color:
                      !isMe ? const Color(0xFFFEF1F0) : const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  isMe
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              timeStampToHour(timestamp),
                              style: const TextStyle(
                                  color: Color(0xFF565E6C), fontSize: 13),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: Get.width * 0.5,
                              child: Text(
                                name,
                                style: const TextStyle(
                                    color: Color(0xFF6DB2FF), fontSize: 15),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: Get.width * 0.5,
                              child: Text(
                                name,
                                style: const TextStyle(
                                    color: Color(0xFFf1548b), fontSize: 15),
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              timeStampToHour(timestamp),
                              style: const TextStyle(
                                  color: Color(0xFF565E6C), fontSize: 13),
                            )
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
                            text: message,
                            style: const TextStyle(fontSize: 15),
                            onOpen: (link) async {
                              if (await canLaunchUrl(Uri.parse(link.url))) {
                                await launchUrl(Uri.parse(link.url),
                                    mode: LaunchMode.externalApplication);
                              } else {
                                throw 'Could not launch $link';
                              }
                            },
                          )),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            isMe
                ? avatar
                : const SizedBox(
                    width: 30,
                  ),
          ],
        ),
        const SizedBox(
          height: 18,
        )
      ],
    );
  }
}
