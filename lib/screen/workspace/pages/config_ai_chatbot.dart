import 'package:coka/api/chatbot.dart';
import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/border_textfield.dart';
import 'package:coka/components/chatbot_time_type_radio.dart';
import 'package:coka/components/chatbot_type_ratio.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../components/add_page2chatbot_bottomsheet.dart';

class ConfigAiChatBotPage extends StatefulWidget {
  final Map? editData;
  final Function isSubmit;
  const ConfigAiChatBotPage({super.key, this.editData, required this.isSubmit});

  @override
  State<ConfigAiChatBotPage> createState() => _ConfigAiChatBotPageState();
}

class _ConfigAiChatBotPageState extends State<ConfigAiChatBotPage> {
  final scriptNameController = TextEditingController();
  final promptController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String typeChatBot = "AI";
  int typeTimeChatBot = 2;

  var selectedFbChannelList = [];
  Map selectedFbList = {};
  var selectedZlChannelList = [];
  Map selectedZlList = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.editData != null) {
      typeChatBot = widget.editData?["typeResponse"];
      typeTimeChatBot = widget.editData?["response"];
      scriptNameController.text = widget.editData?["title"];
      promptController.text = widget.editData?["promptSystem"];
      for (var x in widget.editData?["subscribed"]) {
        if (x["provider"] == "FACEBOOK") {
          selectedFbChannelList.add(x);
          selectedFbList[x["id"]] = true;
        } else if (x["provider"] == "ZALO") {
          selectedZlChannelList.add(x);
          selectedZlList[x["id"]] = true;
        }
      }

      setState(() {});
    }
  }

  Future onSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.validate();
      _formKey.currentState!.save();
      showLoadingDialog(context);
      FocusManager.instance.primaryFocus?.unfocus();
      List idList = selectedFbChannelList.map((map) => map['id']).toList();
      idList.addAll(selectedZlChannelList.map((map) => map['id']).toList());
      print(idList);
      if (widget.editData == null) {
        ChatBotApi().create({
          "subscribedIds": idList,
          "title": scriptNameController.text,
          "description": "",
          "promptSystem": promptController.text,
          "promptUser": "",
          "numLog": 2,
          "response": typeTimeChatBot,
          "typeResponse": typeChatBot
        }).then((res) {
          Get.back();
          if (isSuccessStatus(res["code"])) {
            widget.isSubmit();
            Get.back();

            successAlert(
              title: "Thành công",
              desc: "Kịch bản của bạn đã được khởi chạy",
            );
          } else {
            errorAlert(title: "Lỗi", desc: res["message"]);
          }
        });
      } else {
        ChatBotApi().update({
          "subscribedIds": idList,
          "title": scriptNameController.text,
          "description": "",
          "promptSystem": promptController.text,
          "promptUser": "",
          "numLog": 2,
          "response": typeTimeChatBot,
          "typeResponse": typeChatBot
        }, widget.editData?["id"]).then((res) {
          Get.back();
          if (isSuccessStatus(res["code"])) {
            widget.isSubmit();
            successAlert(
              title: "Thành công",
              desc: "Kịch bản của bạn đã được khởi chạy",
              btnOkOnPress: () {
                Get.back();
              },
            );
          } else {
            errorAlert(title: "Lỗi", desc: res["message"]);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Form(
        key: _formKey,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              widget.editData != null ? "Chỉnh sửa kịch bản" : "Tạo kịch bản",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2329)),
            ),
            centerTitle: true,
            automaticallyImplyLeading: true,
            // Ensures the search bar stays visible when scrolling.
          ),
          floatingActionButtonLocation: isKeyboardVisible
              ? FloatingActionButtonLocation.endFloat
              : FloatingActionButtonLocation.centerFloat,
          floatingActionButton: isKeyboardVisible
              ? FloatingActionButton(
                  onPressed: onSubmit,
                  shape: const CircleBorder(),
                  backgroundColor: const Color(0xFF5C33F0),
                  child: const Icon(Icons.check, color: Colors.white),
                )
              : FloatingActionButton.extended(
                  onPressed: onSubmit,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  backgroundColor: const Color(0xFF5C33F0),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50.0),
                    child: Text(
                      "Hoàn thành",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BorderTextField(
                    name: "Tên kịch bản",
                    nameHolder: "Tên kịch bản",
                    controller: scriptNameController,
                    isRequire: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Hãy điền tên kịch bản';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Chọn kênh kết nối",
                    style: TextStyle(
                        color: Color(0xFF1F2329),
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  buildConnectCard(
                    iconPath: "assets/images/fb_messenger_icon.png",
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    name: "Facebook Messenger",
                    onPressed: () {
                      buildShowFbModalBottomSheet();
                    },
                    selectedPageList: selectedFbChannelList,
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  buildConnectCard(
                    iconPath: "assets/images/zalo_icon.png",
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12)),
                    name: "Zalo Oa",
                    onPressed: () {
                      buildShowZlModalBottomSheet();
                    },
                    selectedPageList: selectedZlChannelList,
                  ),
                  const Gap(8),
                  ChatBotTimeTypeRadio(
                      typeFunction: (t) {
                        setState(() {
                          typeTimeChatBot = t;
                        });
                      },
                      initType: typeTimeChatBot),
                  ChatBotTypeRadio(
                      typeFunction: (t) {
                        setState(() {
                          typeChatBot = t;
                        });
                      },
                      initType: typeChatBot),
                  const SizedBox(
                    height: 10,
                  ),
                  typeChatBot == "QA"
                      ? const Text(
                          "Kịch bản",
                          style: TextStyle(
                              color: Color(0xFF1F2329),
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        )
                      : const Tooltip(
                          message:
                              "Prompt là nơi để bạn truyền thông tin hoặc hỏi câu hỏi cụ thể cho hệ thống trí tuệ nhân tạo và phản hồi dựa trên thông tin mà bạn đã cung cấp.",
                          triggerMode: TooltipTriggerMode.tap,
                          margin: EdgeInsets.symmetric(horizontal: 40),
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          showDuration: Duration(seconds: 10),
                          child: Row(
                            children: [
                              Text(
                                "Prompt",
                                style: TextStyle(
                                    color: Color(0xFF1F2329),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Icon(
                                Icons.help_outline,
                                size: 16,
                              )
                            ],
                          ),
                        ),
                  const SizedBox(
                    height: 4,
                  ),
                  TextFormField(
                    controller: promptController,
                    cursorColor: Colors.black,
                    maxLines: 16,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 16),
                        hintText: typeChatBot == "QA"
                            ? "Q: Nội dung câu hỏi A\nA: Câu trả lời A\nQ: Nội dung câu hỏi B\nA: Câu trả lời B"
                            : "Hãy trở thành một nhà tư vấn bất động sản đầy kinh nghiệm...",
                        filled: true,
                        fillColor: const Color(0xFFF8F8F8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none)),
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Future<dynamic> buildShowFbModalBottomSheet() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (context) => AddPage2ChatBotBottomSheet(
        provider: "FACEBOOK",
        onSubmit: (members, selects) {
          setState(() {
            selectedFbChannelList = members;
            selectedFbList = selects;
          });
        },
        selectedData: selectedFbList,
      ),
    );
  }

  Future<dynamic> buildShowZlModalBottomSheet() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (context) => AddPage2ChatBotBottomSheet(
        provider: "ZALO",
        onSubmit: (members, selects) {
          setState(() {
            selectedZlChannelList = members;
            selectedZlList = selects;
          });
        },
        selectedData: selectedFbList,
      ),
    );
  }

  Widget buildConnectCard(
      {required BorderRadius borderRadius,
      required List selectedPageList,
      required String name,
      required String iconPath,
      required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8), borderRadius: borderRadius),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  iconPath,
                  height: 40,
                  width: 40,
                ),
                const SizedBox(
                  width: 16,
                ),
                Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Colors.black,
                  size: 14,
                )
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Wrap(
              spacing: 3.0, // gap between adjacent chips
              children: [
                ...selectedPageList.map((e) {
                  final name = e["name"];
                  final avatar = e["avatar"];
                  return Chip(
                    avatar: avatar == null
                        ? createCircleAvatar(name: name, radius: 8)
                        : Container(
                            height: 16,
                            width: 16,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0x663949AB), width: 1),
                                color: Colors.white),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: getAvatarWidget(avatar),
                            ),
                          ),
                    label: Text(name),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      if (e["provider"] == "ZALO") {
                        selectedZlChannelList.remove(e);
                        selectedZlList.remove(e["id"]);
                      } else {
                        selectedFbChannelList.remove(e);
                        selectedFbList.remove(e["id"]);
                      }
                      setState(() {});
                    },
                  );
                }),
              ],
            )
          ],
        ),
      ),
    );
  }
}
