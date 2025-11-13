import 'package:coka/api/ifttt.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/border_textfield.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

class EmailConfigScreen extends StatefulWidget {
  final Function(Map) onSubmit;
  final Map initData;
  const EmailConfigScreen(
      {super.key, required this.onSubmit, required this.initData});

  @override
  State<EmailConfigScreen> createState() => _EmailConfigScreenState();
}

class _EmailConfigScreenState extends State<EmailConfigScreen> {
  final formKey = GlobalKey<FormState>();
  final displayNameController = TextEditingController();
  final serverNameController = TextEditingController();
  final portController = TextEditingController();
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

  Future onSubmit() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      showLoadingDialog(context);
      final res = await IftttApi().testSendmail(
          displayNameController.text,
          userNameController.text,
          passwordController.text,
          portController.text,
          serverNameController.text);
      Get.back();
      if (res["content"]) {
        widget.onSubmit({
          "displayName": displayNameController.text,
          "serverName": serverNameController.text,
          "port": portController.text,
          "userName": userNameController.text,
          "password": passwordController.text
        });
        Get.back();
      } else {
        errorAlert(
            title: "Xác thực thất bại",
            desc: "Thông tin cấu hình chưa đúng, vui lòng thử lại.");
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.initData["name"] != "Chưa có kết nối nào") {
      displayNameController.text = widget.initData["data"]["displayName"];
      serverNameController.text = widget.initData["data"]["serverName"];
      portController.text = widget.initData["data"]["port"];
      userNameController.text = widget.initData["data"]["userName"];
      passwordController.text = widget.initData["data"]["password"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.white,
          title: const Text(
            "Thêm cấu hình Email",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        floatingActionButtonLocation: isKeyboardVisible
            ? FloatingActionButtonLocation.endFloat
            : FloatingActionButtonLocation.centerFloat,
        floatingActionButton: isKeyboardVisible
            ? FloatingActionButton(
                onPressed: () {
                  onSubmit();
                },
                shape: const CircleBorder(),
                backgroundColor: const Color(0xFF5c33f0),
                child: const Icon(Icons.check, color: Colors.white),
              )
            : FloatingActionButton.extended(
                onPressed: () {
                  onSubmit();
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                backgroundColor: const Color(0xFF5c33f0),
                label: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    "Hoàn thành",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  BorderTextField(
                      name: "Tên hiển thị",
                      nameHolder: "CoKa CRM",
                      controller: displayNameController,
                      isRequire: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Hãy điền tên hiển th';
                        }
                        return null;
                      }),
                  BorderTextField(
                      name: "Server name",
                      nameHolder: "stmp.gmail.com",
                      controller: serverNameController,
                      isRequire: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Hãy điền Server Name';
                        }
                        return null;
                      }),
                  BorderTextField(
                    name: "Port",
                    textInputType: TextInputType.number,
                    nameHolder: "587/465/25",
                    controller: portController,
                    isRequire: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Hãy điền số port';
                      }
                      return null;
                    },
                  ),
                  BorderTextField(
                      name: "Username",
                      nameHolder: "coka@gmail.com",
                      textInputType: TextInputType.emailAddress,
                      controller: userNameController,
                      isRequire: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Hãy điền username';
                        }
                        return null;
                      }),
                  BorderTextField(
                      name: "Password",
                      nameHolder: "Password",
                      controller: passwordController,
                      isRequire: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Hãy điền password';
                        }
                        return null;
                      }),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
