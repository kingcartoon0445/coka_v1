import 'package:coka/api/conversation.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/elevated_btn.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/crm_conversation/components/category.dart';
import 'package:coka/screen/crm_conversation/components/chat_item.dart';
import 'package:coka/screen/crm_conversation/crm_conversation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../crm_customer/components/customer_item.dart';
import '../crm_customer/crm_customer_controller.dart';

class CrmConversationPage extends StatefulWidget {
  const CrmConversationPage({super.key});

  @override
  State<CrmConversationPage> createState() => _CrmConversationPageState();
}

class _CrmConversationPageState extends State<CrmConversationPage> {
  var index = 0;
  TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CrmConversationController>(builder: (controller) {
      return Scaffold(body: SafeArea(
        child: Obx(() {
          return Column(
            children: [
              const SizedBox(
                height: 6,
              ),
              Row(
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
                      Get.toNamed('/contactDetail',
                          arguments: controller.roomInfo);
                    },
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: CircleAvatar(
                                backgroundImage: getAvatarProvider(
                                    controller.roomInfo['personAvatar'] ??
                                        defaultAvatar),
                                radius: 20,
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
                                    border: const Border.fromBorderSide(
                                        BorderSide(
                                            color: Colors.white,
                                            strokeAlign:
                                                BorderSide.strokeAlignCenter,
                                            width: 2)),
                                    color: getColor(
                                        (controller.roomInfo['source'].isEmpty)
                                            ? "import"
                                            : controller.roomInfo['source'][0]
                                                ['sourceName']),
                                  ),
                                  child: controller.roomInfo['source'].isEmpty
                                      ? SvgPicture.asset(
                                          getAsset((controller
                                                  .roomInfo['source'].isEmpty)
                                              ? "import"
                                              : controller.roomInfo['source'][0]
                                                  ['sourceName']),
                                          color: Colors.white,
                                        )
                                      : Container(),
                                ))
                          ],
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        SizedBox(
                          width: Get.width * .38,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.roomInfo['fullName'],
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
                              if (controller.roomInfo['pageName'] != null)
                                Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: MemoryImage(controller
                                                  .roomInfo['pageAvatar']))),
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    SizedBox(
                                        width: Get.width * .3,
                                        child: Text(
                                          controller.roomInfo['pageName'],
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        )),
                                  ],
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ElevatedBtn(
                    onPressed: () {},
                    paddingAllValue: 0,
                    circular: 6,
                    child: Container(
                      width: 45,
                      height: 45,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(6),
                          color: const Color(0xFFFEF1F0)),
                      child: SvgPicture.asset(
                        'assets/icons/call_icon.svg',
                        color: const Color(0xFFF7706E),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  ElevatedBtn(
                    onPressed: () {},
                    paddingAllValue: 0,
                    circular: 6,
                    child: Container(
                      width: 45,
                      height: 45,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(6),
                          color: const Color(0xFFFEF1F0)),
                      child: SvgPicture.asset(
                        'assets/icons/more_vertical_icon.svg',
                        color: const Color(0xFFF7706E),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                ],
              ),
              const SizedBox(
                height: 26,
              ),
              Container(
                height: 36,
                width: Get.width - 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: const Color(0xFFfef1f0),
                    borderRadius: BorderRadius.circular(20)),
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return BuildConversationCategory(index: index);
                  },
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  itemCount: categories.length,
                  onPageChanged: (index) {
                    controller.currentPage.value = index;
                    controller.update();
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return index == 1
                        ? Stack(
                            children: [
                              ListView.builder(
                                itemCount: controller.convList.length,
                                shrinkWrap: true,
                                controller: controller.sc,
                                reverse: true,
                                physics: const ClampingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return index ==
                                              controller.convList.length - 1 &&
                                          !controller.isLoadMore.value
                                      ? Column(
                                          children: [
                                            const SizedBox(
                                              height: 18,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                    child: Container(
                                                  height: 1,
                                                  color:
                                                      const Color(0xFFDEE1E6),
                                                )),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6.0),
                                                  child: Text(
                                                    'Cuộc trò chuyện bắt đầu vào ${timeStampToDate(controller.convList[index]['timestamp'])}',
                                                    style: const TextStyle(
                                                        color:
                                                            Color(0xFF9095A0),
                                                        fontSize: 13),
                                                  ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                  height: 1,
                                                  color:
                                                      const Color(0xFFDEE1E6),
                                                )),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 18,
                                            ),
                                            ChatItem(
                                                dataItem:
                                                    controller.convList[index]),
                                          ],
                                        )
                                      : (index > 0 &&
                                              timeStampToDate(
                                                      controller.convList[index]
                                                          ['timestamp']) !=
                                                  timeStampToDate(controller
                                                          .convList[index - 1]
                                                      ['timestamp']))
                                          ? Column(
                                              children: [
                                                ChatItem(
                                                    dataItem: controller
                                                        .convList[index]),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        child: Container(
                                                      height: 1,
                                                      color: const Color(
                                                          0xFFDEE1E6),
                                                    )),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 6.0),
                                                      child: Text(
                                                        timeStampToDate(
                                                            controller.convList[
                                                                    index - 1]
                                                                ['timestamp']),
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xFF9095A0),
                                                            fontSize: 13),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        child: Container(
                                                      height: 1,
                                                      color: const Color(
                                                          0xFFDEE1E6),
                                                    )),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 18,
                                                ),
                                              ],
                                            )
                                          : ChatItem(
                                              dataItem:
                                                  controller.convList[index]);
                                },
                              ),
                              controller.isLoadMore.value
                                  ? Positioned(
                                      top: 5,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                          child: SpinKitCircle(
                                        color: kPrimaryColor.withOpacity(0.4),
                                        duration:
                                            const Duration(milliseconds: 500),
                                      )))
                                  : Container()
                            ],
                          )
                        : Container();
                  },
                ),
              ),
              controller.currentPage.value != 0
                  ? Container(
                      constraints: const BoxConstraints(minHeight: 75),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 12),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              top: BorderSide(
                                  color: Color(0xFFDEE1E6),
                                  width: 1,
                                  style: BorderStyle.solid))),
                      child: Row(
                        children: [
                          !controller.onFocus.value
                              ? Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/emotion_icon.svg',
                                      color: const Color(0xFFF7706E),
                                      width: 25,
                                      height: 25,
                                    ),
                                    const SizedBox(
                                      width: 7,
                                    ),
                                    SvgPicture.asset(
                                      'assets/icons/image_icon.svg',
                                      color: const Color(0xFFF7706E),
                                      width: 25,
                                      height: 25,
                                    ),
                                    const SizedBox(
                                      width: 7,
                                    ),
                                    SvgPicture.asset(
                                      'assets/icons/attachment_icon.svg',
                                      color: const Color(0xFFF7706E),
                                      width: 25,
                                      height: 25,
                                    ),
                                  ],
                                )
                              : const Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  color: Color(0xFFF7706E),
                                  size: 25,
                                ),
                          const SizedBox(
                            width: 11,
                          ),
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Focus(
                                onFocusChange: (value) {
                                  controller.onFocus.value = value;
                                },
                                child: Form(
                                  key: controller.formKey,
                                  child: TextFormField(
                                    controller: contentController,
                                    keyboardType: controller.onFocus.value
                                        ? TextInputType.multiline
                                        : TextInputType.text,
                                    minLines: 1,
                                    //Normal textInputField will be displayed
                                    maxLines: controller.onFocus.value ? 5 : 1,
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Aa'),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ElevatedBtn(
                              circular: 6,
                              paddingAllValue: 8,
                              onPressed: () {
                                controller.formKey.currentState!.save();
                                if (contentController.text != "") {
                                  final message = contentController.text;
                                  contentController.text = "";
                                  controller.convList.insert(0, {
                                    "from": controller.roomInfo['pageId'],
                                    "message": message,
                                    "sendIndex": index,
                                    "timestamp":
                                        DateTime.now().millisecondsSinceEpoch,
                                  });
                                  index++;
                                  controller.sendMessageState.add(2);
                                  ConvApi().sendConv({
                                    "conversationId":
                                        controller.roomInfo['conversationId'],
                                    "hubId": controller.roomInfo['hubId'],
                                    "message": message,
                                    "messageId": "",
                                    "type": "message",
                                  }).then((res) {
                                    if (isSuccessStatus(res['code'])) {
                                      CrmCustomerController cCController =
                                          Get.put(CrmCustomerController());
                                      final currentIndex = cCController.roomList
                                          .indexWhere((e) =>
                                              e['conversationId'] ==
                                              controller
                                                  .roomInfo['conversationId']);
                                      controller.sendMessageState[index - 1] =
                                          1;

                                      cCController.roomList[currentIndex]
                                              ['updatedTime'] =
                                          DateTime.now().millisecondsSinceEpoch;
                                      cCController.roomList[currentIndex]
                                          ['snippet'] = message;
                                      cCController.roomList[currentIndex]
                                          ['unreadCount'] = 0;
                                      cCController.update();
                                    } else {
                                      controller.sendMessageState[index - 1] =
                                          0;
                                      errorAlert(
                                          title: 'Gửi thất bại',
                                          desc: res['message']);
                                    }
                                    controller.update();
                                  });
                                  controller.update();
                                }
                              },
                              child: SvgPicture.asset(
                                'assets/icons/send_icon.svg',
                                color: const Color(0xFFF7706E),
                                width: 25,
                                height: 25,
                              )),
                        ],
                      ))
                  : Container()
            ],
          );
        }),
      ));
    });
  }
}
