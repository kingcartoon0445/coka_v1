import 'package:avatar_stack/avatar_stack.dart';
import 'package:coka/api/chatbot.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/workspace/pages/config_ai_chatbot.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/awesome_alert.dart';

class AiChatBotPage extends StatefulWidget {
  const AiChatBotPage({super.key});

  @override
  State<AiChatBotPage> createState() => _AiChatBotPageState();
}

class _AiChatBotPageState extends State<AiChatBotPage> {
  bool isEmpty = false;
  List scriptList = [];
  bool isFetching = false;
  final searchController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    onReload();
  }

  Future onReload() async {
    isFetching = true;
    setState(() {});
    await Future.wait([fetchScriptList()]);
    isFetching = false;
    setState(() {});
  }

  Future fetchScriptList() async {
    await ChatBotApi().getList().then((res) {
      if (isSuccessStatus(res["code"])) {
        scriptList = res["content"];
        if (scriptList.isNotEmpty) {
          isEmpty = false;
        } else {
          isEmpty = true;
        }
      } else {
        errorAlert(title: "Lỗi", desc: res["message"]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6F4),
        title: const Text(
          "AI chat bot",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2329)),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
              onPressed: () {
                Get.to(() => ConfigAiChatBotPage(isSubmit: () {
                      onReload();
                    }));
              },
              icon: const Icon(
                Icons.add,
                size: 26,
              ))
        ],
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(60.0), // Height of the search bar.
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
            child: SearchBar(
              hintText: "Tìm kiếm",
              controller: searchController,
              backgroundColor:
                  const WidgetStatePropertyAll(Color(0xFFF2F3F5)),
              leading: const Icon(Icons.search),
            ),
          ),
        ),
        bottomOpacity:
            1.0, // Ensures the search bar stays visible when scrolling.
      ),
      body: isEmpty
          ? Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 30.0, right: 30, top: 40),
                  child: Image.asset(
                    "assets/images/empty_script.png",
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  "Hiện chưa có kịch bản nào",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C33F0)),
                    onPressed: () {
                      Get.to(() => ConfigAiChatBotPage(isSubmit: () {
                            onReload();
                          }));
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Text(
                          "Thêm",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white),
                        ),
                      ],
                    ))
              ],
            )
          : isFetching
              ? const ListPlaceholder(length: 11)
              : RefreshIndicator(
                  onRefresh: onReload,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: Get.height - 100),
                    child: ListView.builder(
                      itemCount: scriptList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final data = scriptList[index];
                        final title = data["title"];
                        final status = data["status"] == 1 ? true : false;
                        List avatars = data["subscribed"];

                        return MenuAnchor(
                          builder: (context, controller, child) {
                            return ListTile(
                              title: Text(title,
                                  style: const TextStyle(fontSize: 16)),
                              subtitle: AvatarStack(
                                height: 22,
                                borderWidth: 1,
                                avatars: [
                                  ...avatars.map((e) {
                                    return getAvatarProvider(
                                        "https://dev.coka.ai${e["avatar"]}");
                                  })
                                ],
                              ),
                              leading: const Icon(Icons.description, size: 40),
                              trailing: Switch(
                                value: status,
                                activeTrackColor: const Color(0xFF5C33F0),
                                onChanged: (value) {
                                  showLoadingDialog(context);
                                  ChatBotApi()
                                      .updateStatus(value ? 1 : 0, data["id"])
                                      .then((res) {
                                    Get.back();
                                    if (!isSuccessStatus(res["code"])) {
                                      return errorAlert(
                                          title: "Lỗi", desc: res["message"]);
                                    }
                                    setState(() {
                                      scriptList[index]["status"] =
                                          value ? 1 : 0;
                                    });
                                  });
                                },
                              ),
                              onTap: () {
                                if (controller.isOpen) {
                                  controller.close();
                                } else {
                                  controller.open();
                                }
                              },
                            );
                          },
                          menuChildren: [
                            MenuItemButton(
                                leadingIcon: const Icon(Icons.edit, size: 25),
                                onPressed: () {
                                  Get.to(
                                    () => ConfigAiChatBotPage(
                                      editData: data,
                                      isSubmit: () {
                                        onReload();
                                      },
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Chỉnh sửa kịch bản",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                )),
                            MenuItemButton(
                                leadingIcon: const Icon(Icons.delete, size: 25),
                                onPressed: () {
                                  warningAlert(
                                      title: "Xoá kịch bản?",
                                      desc:
                                          "Bạn có chắc chắn muốn xoá kịch bản này?",
                                      btnOkOnPress: () {
                                        showLoadingDialog(context);
                                        ChatBotApi()
                                            .delete(
                                          data["id"],
                                        )
                                            .then((res) {
                                          Get.back();
                                          if (isSuccessStatus(res["code"])) {
                                            onReload();
                                            successAlert(
                                                title: "Thành công",
                                                desc: "Kịch bản đã bị xóa");
                                          } else {
                                            errorAlert(
                                                title: "Lỗi",
                                                desc: res["message"]);
                                          }
                                        });
                                      });
                                },
                                child: const Text(
                                  "Xóa kịch bản",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                )),
                          ],
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}
