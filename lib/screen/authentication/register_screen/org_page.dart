import 'dart:convert';
import 'dart:io';

import 'package:coka/api/organization.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/border_textfield.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/main/main_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' as g;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

import '../../../api/api_url.dart';

class RegisterOrgPage extends StatefulWidget {
  final bool isPersonal;
  final bool? isEdit;

  const RegisterOrgPage({super.key, required this.isPersonal, this.isEdit});

  @override
  State<RegisterOrgPage> createState() => _RegisterOrgPageState();
}

class _RegisterOrgPageState extends State<RegisterOrgPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController desController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController ownerNameController = TextEditingController();
  TextEditingController taxController = TextEditingController();
  TextEditingController licenseController = TextEditingController();
  TextEditingController fieldActiveController = TextEditingController();
  TextEditingController hotlineController = TextEditingController();
  final _picker = ImagePicker();
  XFile? pickedImage;
  String? orgAvatar;
  Future<void> _openImagePicker() async {
    pickedImage = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 300, maxHeight: 300);
    setState(() {});
  }

  Future onSubmit() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      showLoadingDialog(context);
      print(pickedImage?.path);
      FormData formData = FormData.fromMap({
        if (pickedImage?.path != null)
          'Avatar': await MultipartFile.fromFile(
            pickedImage!.path,
            filename: pickedImage!.path.split('/').last,
            contentType: MediaType("image", "jpg"),
          ),
        "Name": nameController.text,
        "Description": desController.text,
        "Address": addressController.text,
        "Representative": "",
        "TaxId": taxController.text,
        "BusinessLicense": licenseController.text,
        "FieldOfActivity": fieldActiveController.text,
        "Hotline": hotlineController.text,
        "Email": "",
        "Website": websiteController.text,
      });
      if (widget.isEdit ?? false) {
        final res = await OrganApi().updateOrgan(formData);
        g.Get.back();

        if (isSuccessStatus(res["code"])) {
          HomeController homeController = g.Get.put(HomeController());
          MainController mainController = g.Get.put(MainController());

          mainController.onRefresh();
          homeController.onRefresh();
          successAlert(
            title: "Thành công",
            desc: "Cập nhật thành công",
            btnOkOnPress: () async {
              g.Get.offNamed("/main");
            },
          );
        } else {
          errorAlert(title: "Thất bại", desc: res["message"]);
        }
      } else {
        final res = await OrganApi().createOrgan(formData);
        g.Get.back();
        if (isSuccessStatus(res["code"])) {
          final prefs = await SharedPreferences.getInstance();

          if (!widget.isPersonal) {
            HomeController homeController = g.Get.put(HomeController());
            MainController mainController = g.Get.put(MainController());
            prefs.setString('oData', jsonEncode(res["content"]));
            mainController.onRefresh();
            homeController.onRefresh();
            successAlert(
              title: "Thành công",
              desc: "Đã tạo thành công tổ chức doanh nghiệp",
              btnOkOnPress: () async {
                g.Get.offNamed("/main");
              },
            );
          } else {
            prefs.setString('oData', jsonEncode(res["content"]));
            successAlert(
              title: "Thành công",
              desc: "Đã tạo thành công tổ chức cá nhân",
              btnOkOnPress: () async {
                g.Get.offNamed("/main");
              },
            );
          }
        } else {
          errorAlert(title: "Thất bại", desc: res["message"]);
        }
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isEdit ?? false) {
      final homeController = g.Get.put(HomeController());
      print(homeController.oData);
      orgAvatar = homeController.oData["avatar"];
      nameController.text = homeController.oData["name"];
      desController.text = homeController.oData["description"] ?? "";
      addressController.text = homeController.oData["address"] ?? "";
      taxController.text = homeController.oData["taxId"] ?? "";
      licenseController.text = homeController.oData["businessLicense"] ?? "";
      fieldActiveController.text =
          homeController.oData["fieldOfActivity"] ?? "";
      hotlineController.text = homeController.oData["hotline"] ?? "";
      websiteController.text = homeController.oData["website"] ?? "";
    }
  }

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Form(
        key: formKey,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: true,
            backgroundColor: Colors.white,
            title: Text(
              (widget.isEdit ?? false)
                  ? "Cập nhật tổ chức"
                  : widget.isPersonal
                      ? "Tạo tổ chức cá nhân"
                      : "Tạo tổ chức",
              style: const TextStyle(
                  color: Color(0xFF1F2329),
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
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
                              : orgAvatar != null
                                  ? ClipOval(
                                      child: Image.network(
                                          "$apiBaseUrl$orgAvatar",
                                          width: 300,
                                          height: 300,
                                          fit: BoxFit.cover))
                                  : SvgPicture.asset(
                                      "assets/icons/profile_avatar.svg"),
                        ),
                        if (pickedImage == null && orgAvatar == null)
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
                    controller: nameController,
                    name: "Tên",
                    isRequire: true,
                    nameHolder: "Tên của tổ chức",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Hãy điền tên tổ chức';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  BorderTextField(
                    controller: desController,
                    name: "Mô tả",
                    nameHolder: "Mô tả tổ chức của bạn",
                    maxLines: 5,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  BorderTextField(
                    controller: addressController,
                    name: "Địa chỉ",
                    nameHolder: "Địa chỉ tổ chức",
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  BorderTextField(
                    controller: websiteController,
                    name: "Website",
                    nameHolder: "Website tổ chức",
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  BorderTextField(
                    controller: ownerNameController,
                    name: "Người đại diện",
                    nameHolder: "Tên người đại diện",
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  BorderTextField(
                    controller: taxController,
                    name: "Mã số thuế",
                    nameHolder: "Nhập mã số thuế",
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  BorderTextField(
                    controller: licenseController,
                    name: "Giấy phép kinh doanh",
                    nameHolder: "Giấy phép tổ chức",
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  BorderTextField(
                    controller: fieldActiveController,
                    name: "Lĩnh vực hoạt động",
                    nameHolder: "Lĩnh vực của công ty",
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  BorderTextField(
                    controller: hotlineController,
                    name: "Hotline",
                    nameHolder: "Hotline",
                  ),
                  const SizedBox(
                    height: 100,
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
                  label: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.0),
                    child: Text(
                      "Hoàn thành",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
        ),
      );
    });
  }
}
