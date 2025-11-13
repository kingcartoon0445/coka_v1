import 'dart:async';

import 'package:coka/api/support.dart';
import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/elevated_btn.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/main/components/chat_fetching.dart';
import 'package:coka/screen/main/components/chat_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  final homeController = Get.put(HomeController());
  var isFetching = false;
  var sampleChats = [];

  void addMessage(isMe, message) {
    sampleChats.insert(
        0,
        GptChatItem(
            avatar: isMe
                ? homeController.userData["avatar"] == ""
                    ? createCircleAvatar(
                        name: homeController.userData["fullName"], radius: 15)
                    : CircleAvatar(
                        backgroundImage: getAvatarProvider(
                          homeController.userData["avatar"],
                        ),
                        radius: 15,
                      )
                : Image.asset(
                    "assets/images/bot_icon.png",
                    width: 30,
                    height: 30,
                  ),
            isMe: isMe,
            name: isMe ? homeController.userData["fullName"] : "Coka-Bot",
            timestamp: DateTime.now().millisecondsSinceEpoch,
            message: message));
    setState(() {});
  }

  final sampleCard = [
    {
      "text": "Giới thiệu tính năng & hướng dẫn sử dụng",
    },
    {
      "text": "Khuyến mãi, tin tức, sự kiện",
    },
    {
      "text": "Phản hồi, góp ý",
    },
    {
      "text": "Chăm sóc khách hàng",
    },
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addMessage(false,
        "Chào mừng bạn đến với Coka. Tôi là Coka-Bot, tôi có thể giúp gì cho bạn ?");
  }

  final chatController = TextEditingController();

  Future fetchChat(message) async {
    setState(() {
      isFetching = true;
    });
    AutomationApi().createChat(message).then((res) {
      setState(() {
        isFetching = false;
      });
      if (res["reply"] != null) {
        addMessage(false, res["reply"]);
      } else {
        errorAlert(title: 'Lỗi', desc: res["message"]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Hỗ trợ",
          style: TextStyle(
              color: Color(0xFF1F2329),
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
            itemBuilder: (context, index) {
              return sampleChats.length == 1
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sampleChats[index],
                        ...sampleCard.map((e) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildSampleCard(e["text"], () {
                                addMessage(true, e["text"]);
                                fetchChat(e["text"]);
                              }),
                              const SizedBox(
                                height: 8,
                              ),
                            ],
                          );
                        }),
                        const SizedBox(
                          height: 60,
                        )
                      ],
                    )
                  : sampleChats[index];
            },
            shrinkWrap: true,
            reverse: true,
            itemCount: sampleChats.length,
          )),
          if (isFetching) const ChatFetching(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 16, bottom: 12, right: 8),
            child: buildChatField(),
          )
        ],
      ),
    );
  }

  Widget buildSampleCard(text, onPressed) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(8),
        child: ElevatedBtn(
          paddingAllValue: 0,
          circular: 8,
          onPressed: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(text, style: const TextStyle(color: Color(0xFF00B0FF))),
          ),
        ),
      ),
    );
  }

  Row buildChatField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            cursorColor: Colors.black,
            controller: chatController,
            maxLines: 5,
            minLines: 1,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: const Color(0x66F3EEEE),
                hintText: "Nhập nội dung cần tư vấn"),
          ),
        ),
        IconButton(
            onPressed: () {
              addMessage(true, chatController.text);
              fetchChat(chatController.text);
              chatController.clear();
            },
            icon: SvgPicture.asset("assets/icons/send_1_icon.svg"))
      ],
    );
  }
}
