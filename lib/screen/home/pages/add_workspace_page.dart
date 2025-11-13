import 'dart:io';

import 'package:coka/api/workspace.dart';
import 'package:coka/components/border_textfield.dart';
import 'package:coka/components/radio_privacy.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/workspace/getx/dashboard_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart' as g;

import '../../../api/api_url.dart';
import '../../../components/awesome_alert.dart';
import '../../../components/loading_dialog.dart';

class AddWorkSpacePage extends StatefulWidget {
  final Map? dataItem;
  final Function? onSuccess;
  const AddWorkSpacePage({super.key, this.dataItem, this.onSuccess});

  @override
  State<AddWorkSpacePage> createState() => _AddWorkSpacePageState();
}

class _AddWorkSpacePageState extends State<AddWorkSpacePage> {
  final _picker = ImagePicker();
  TextEditingController nameController = TextEditingController();
  TextEditingController desController = TextEditingController();
  int privacy = 0;
  XFile? pickedImage;
  String? workspaceAvatar;
  Future<void> _openImagePicker() async {
    pickedImage = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 300, maxHeight: 300);
    setState(() {});
  }

  final formKey = GlobalKey<FormState>();

  Future onSubmit() async {
    FocusScope.of(context).unfocus();
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      showLoadingDialog(context);
      FormData formData = FormData.fromMap({
        if (pickedImage?.path != null)
          'Avatar': await MultipartFile.fromFile(
            pickedImage!.path,
            contentType: MediaType("image", "jpg"),
          ),
        "Name": nameController.text,
        "Description": desController.text,
        "Scope": privacy,
      });
      if (widget.dataItem != null) {
        final res = await WorkspaceApi()
            .updateWorkspace(formData, widget.dataItem?["id"]);
        if (isSuccessStatus(res["code"])) {
          g.Get.back();
          final homeController = g.Get.put(HomeController());
          final dashboardController = g.Get.put(DashboardController());
          homeController
              .onRefresh(isInside: true)
              .then((value) => dashboardController.onRefresh());
          successAlert(
            title: "Thành công",
            desc: "Đã chỉnh sửa nhóm ${nameController.text}",
            btnOkOnPress: () {
              g.Get.back();
            },
          );
        } else {
          g.Get.back();
          errorAlert(title: "Thất bại", desc: res["message"]);
        }
      } else {
        final res = await WorkspaceApi().createWorkspace(formData);
        if (isSuccessStatus(res["code"])) {
          g.Get.back();
          HomeController homeController = g.Get.put(HomeController());
          homeController.onRefresh();
          widget.onSuccess!();

          successAlert(
            title: "Thành công",
            desc: "Đã tạo nhóm ${nameController.text}",
            btnOkOnPress: () {
              g.Get.back();
            },
          );
        } else {
          g.Get.back();
          errorAlert(title: "Thất bại", desc: res["message"]);
        }
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.dataItem != null) {
      nameController.text = widget.dataItem?["name"];
      workspaceAvatar = widget.dataItem?["avatar"];
      desController.text = widget.dataItem?["description"] ?? "";
      privacy = widget.dataItem?["scope"] ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Form(
        key: formKey,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              widget.dataItem != null
                  ? "Chỉnh sửa nhóm làm việc"
                  : "Tạo nhóm làm việc",
              style: const TextStyle(
                  color: Color(0xFF1F2329),
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            automaticallyImplyLeading: true,
          ),
          body: SafeArea(
              child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _openImagePicker,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFF8F8F8),
                          radius: 45,
                          child: pickedImage != null
                              ? ClipOval(
                                  child: Image.file(File(pickedImage!.path),
                                      width: 300,
                                      height: 300,
                                      fit: BoxFit.cover))
                              : workspaceAvatar != null
                                  ? ClipOval(
                                      child: Image.network(
                                          "$apiBaseUrl$workspaceAvatar",
                                          width: 300,
                                          height: 300,
                                          fit: BoxFit.cover))
                                  : SvgPicture.asset(
                                      "assets/icons/profile_avatar.svg"),
                        ),
                        if (pickedImage == null && workspaceAvatar == null)
                          const Positioned(
                              bottom: 0,
                              right: 0,
                              child: Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.black,
                              ))
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  BorderTextField(
                      name: "Tên nhóm làm việc",
                      nameHolder: "Nhập tên nhóm",
                      controller: nameController,
                      isRequire: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Hãy điền tên nhóm làm việc';
                        }
                        return null;
                      }),
                  const SizedBox(
                    height: 20,
                  ),
                  RadioPrivacy(
                      privacyFunction: (pvc) => {privacy = pvc},
                      initPrivacy: privacy),
                  BorderTextField(
                    name: "Mô tả",
                    nameHolder: "Mô tả nhóm làm việc",
                    controller: desController,
                    maxLines: 6,
                  ),
                ],
              ),
            ),
          )),
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
                  onPressed: () async {
                    onSubmit();
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  backgroundColor: const Color(0xFF5c33f0),
                  label: const Text(
                    "                         Hoàn thành                         ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
        ),
      );
    });
  }
}
