import 'package:coka/components/elevated_btn.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/workspace/pages/ai_chatbot.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MultiChannel extends StatefulWidget {
  const MultiChannel({super.key});

  @override
  State<MultiChannel> createState() => _MultiChannelState();
}

class _MultiChannelState extends State<MultiChannel> {
  HomeController homeController = Get.put(HomeController());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dataMenuObject = {
      "chat": {
        "name": "Chat",
        "onClick": () {
          Get.toNamed("/chat");
        },
        "icon": Image.asset(
          "assets/images/messenger_icon.png",
          height: 40,
          width: 40,
        )
      },
      "automation": {
        "name": "Automation",
        "onClick": () {
          Get.toNamed("/crmAuto");
        },
        "icon": Image.asset(
          "assets/images/automation_icon.png",
          height: 40,
          width: 40,
        )
      },
      "chatBot": {
        "name": "AI chatbot",
        "onClick": () {
          Get.to(() => const AiChatBotPage());
        },
        "icon": Image.asset(
          "assets/images/bot_2_icon.png",
          height: 40,
          width: 40,
        )
      },
    };
    GridView buildMenuGridview() {
      return GridView.count(
        shrinkWrap: true,
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 16,
        children: [
          ...dataMenuObject.entries.map(
            (e) => Column(
              children: [
                ElevatedBtn(
                  circular: 12,
                  paddingAllValue: 0,
                  onPressed: e.value["onClick"] as VoidCallback,
                  child: Container(
                    width: Get.width / 4 - 32,
                    height: Get.width / 4 - 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3DFFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: e.value["icon"] as Widget,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  e.value["name"] as String,
                  style: const TextStyle(fontSize: 12),
                )
              ],
            ),
          )
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FD),
        title: const Text(
          "Đa kênh",
          style: TextStyle(
              color: Color(0xFF1F2329),
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16, top: 16),
        child: Column(
          children: [
            SizedBox(
              width: Get.width,
              child: const SearchBar(
                leading: Icon(Icons.search),
                backgroundColor: WidgetStatePropertyAll(Color(0xFFF2F3F5)),
                hintText: "Tìm kiếm",
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            buildMenuGridview(),
          ],
        ),
      ),
    );
  }
}
