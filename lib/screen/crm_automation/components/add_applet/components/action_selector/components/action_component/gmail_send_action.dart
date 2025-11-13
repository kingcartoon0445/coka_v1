
import 'package:coka/screen/crm_automation/components/add_applet/add_applet_controller.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/action_selector/action_selector_controller.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/action_selector/components/action_component/email_config_screen.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/action_selector/components/action_component/textfield_ingredient.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/path/path_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GmailAction extends StatefulWidget {
  final String id;
  final int index;
  final bool isPath;

  const GmailAction(
      {super.key, required this.id, required this.index, required this.isPath});

  @override
  State<GmailAction> createState() => _GmailActionState();
}

class _GmailActionState extends State<GmailAction> {
  List<Map> accountList = [];
  Map currentAccount = {"name": "Chưa có kết nối nào"};
  TextEditingController toGmailController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/gmail.send'],
  );

  Future<void> _loginWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      final GoogleSignInAuthentication authentication =
          await account!.authentication;

      final accessToken = authentication.accessToken;

      setState(() {
        accountList.removeWhere((e) => e["name"] == account.email);
        final data = {
          "name": account.email,
          "data": {"accessToken": accessToken}
        };
        accountList.add(data);
        currentAccount = data;
      });
      print('Access Token: $accessToken');
    } catch (error) {
      print('Google Sign-In Error: $error');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isPath) {
      PathController pathController = Get.put(PathController());
      final index = pathController.currentIndex.value;

      if (pathController.actionDataList[index]["stepsData"] != null) {
        final gmailData = {
          "name": pathController.actionDataList[index]["stepsData"]["params"]
              ["from"],
          "data": pathController.actionDataList[index]["stepsData"]["params"]
              ["data"]
        };
        accountList.add(gmailData);
        currentAccount = gmailData;
        toGmailController.text =
            pathController.actionDataList[index]["stepsData"]["params"]["to"];
        subjectController.text = pathController.actionDataList[index]
            ["stepsData"]["params"]["subject"];
        bodyController.text = pathController.actionDataList[index]["stepsData"]
            ["params"]["content"];
      }
    } else {
      AddAppletController appletController = Get.put(AddAppletController());
      final index = appletController.currentIndex.value;

      if (appletController.actionDataList[index]["stepsData"] != null) {
        final emailData = {
          "name": appletController.actionDataList[index]["stepsData"]["params"]
              ["from"],
          "data": appletController.actionDataList[index]["stepsData"]["params"]
              ["data"]
        };
        accountList.add(emailData);
        currentAccount = emailData;
        toGmailController.text =
            appletController.actionDataList[index]["stepsData"]["params"]["to"];
        subjectController.text = appletController.actionDataList[index]
            ["stepsData"]["params"]["subject"];
        bodyController.text = appletController.actionDataList[index]
            ["stepsData"]["params"]["content"];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ActionSelectorController>(builder: (controller) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tài khoản Email",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
                fontSize: 18),
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
            constraints: BoxConstraints(
              maxWidth: Get.width - 40, // đặt chiều rộng tối đa
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: PopupMenuButton<Map>(
                splashRadius: 0,
                offset: const Offset(0, 30),
                onSelected: (Map value) {
                  setState(() {
                    currentAccount = value;
                  });
                },
                initialValue: currentAccount,
                itemBuilder: (BuildContext context) {
                  return accountList.map((Map item) {
                    return PopupMenuItem<Map>(
                      value: item,
                      padding: EdgeInsets.zero,
                      child: Container(
                          width: Get.width,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
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
                    SizedBox(
                      width: Get.width - 150,
                      child: Text(
                        currentAccount['name'],
                        style: const TextStyle(
                            color: Color(0xFF171A1F),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black,
                      size: 30,
                    )
                  ],
                )),
          ),
          const SizedBox(
            height: 8,
          ),
          SizedBox(
            width: Get.width - 40,
            child: Row(
              mainAxisSize:
                  MainAxisSize.min, // Set mainAxisSize to MainAxisSize.min
              children: [
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _loginWithGoogle();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        foregroundColor: Colors.black,
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset("assets/icons/google_icon.svg"),
                          const SizedBox(
                            width: 4,
                          ),
                          const Text(
                            "Kết nối với Google",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.to(() => EmailConfigScreen(
                              onSubmit: (Map data) {
                                final getData = data;
                                setState(() {
                                  accountList.removeWhere(
                                      (e) => e["name"] == getData["userName"]);
                                  final data = {
                                    "name": getData["userName"],
                                    "data": getData
                                  };
                                  accountList.add(data);
                                  currentAccount = data;
                                });
                              },
                              initData: currentAccount,
                            ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        foregroundColor: Colors.black,
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset("assets/icons/gmail.svg",
                              height: 25),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            currentAccount["name"] != "Chưa có kết nối nào"
                                ? "Sửa cấu hình email"
                                : "Cấu hình email",
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextFieldIngredient(
            maxLine: 1,
            label: "Tới",
            controller: toGmailController,
          ),
          const SizedBox(
            height: 20,
          ),
          TextFieldIngredient(
            maxLine: 2,
            label: "Chủ đề",
            controller: subjectController,
          ),
          const SizedBox(
            height: 20,
          ),
          TextFieldIngredient(
            maxLine: 7,
            label: "Nội dung",
            controller: bodyController,
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: Get.width - 40,
            height: 50,
            child: ElevatedButton(
                onPressed: () {
                  if (widget.isPath) {
                    PathController pathController = Get.put(PathController());
                    final index = pathController.currentIndex.value;
                    final isEdit = pathController.actionDataList[index]
                            ["stepsData"] ==
                        null;
                    final stepsData = {
                      "app": "email",
                      "type": "write",
                      "action": "email_send",
                      "params": {
                        "from": currentAccount["name"],
                        "data": currentAccount["data"],
                        "to": toGmailController.text,
                        "subject": subjectController.text,
                        "content": bodyController.text
                      }
                    };

                    pathController.actionDataList[index] = {
                      "type": "email",
                      "stepsData": stepsData,
                      "index": widget.index
                    };
                    print(pathController.actionDataList[index]);
                    pathController.update();
                    if (isEdit) {
                      Get.back();
                      Get.back();
                    }
                  } else {
                    AddAppletController appletController =
                        Get.put(AddAppletController());
                    final index = appletController.currentIndex.value;
                    final isEdit = appletController.actionDataList[index]
                            ["stepsData"] ==
                        null;
                    print(appletController.currentIndex);
                    final stepsData = {
                      "app": "email",
                      "type": "write",
                      "action": "email_send",
                      "params": {
                        "from": currentAccount["name"],
                        "data": currentAccount["data"],
                        "to": toGmailController.text,
                        "subject": subjectController.text,
                        "content": bodyController.text
                      }
                    };
                    appletController.actionDataList[index] = {
                      "type": "email",
                      "stepsData": stepsData,
                      "index": widget.index
                    };
                    print(appletController.actionDataList[index]);
                    appletController.update();
                    if (isEdit) {
                      Get.back();
                      Get.back();
                    }
                  }

                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white),
                child: const Text(
                  "Tiếp tục",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                )),
          )
        ],
      );
    });
  }
}
