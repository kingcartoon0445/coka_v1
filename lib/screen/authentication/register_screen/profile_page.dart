import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:coka/api/organization.dart';
import 'package:coka/api/user.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/border_textfield.dart';
import 'package:coka/components/radio_gender.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' as g;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/api_url.dart';
import '../../../components/loading_dialog.dart';
import '../../main/main_controller.dart';

class RegisterProfilePage extends StatefulWidget {
  final bool isUpdateProfile;
  const RegisterProfilePage({super.key, required this.isUpdateProfile});

  @override
  State<RegisterProfilePage> createState() => _RegisterProfilePageState();
}

class _RegisterProfilePageState extends State<RegisterProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  String dateString = "";
  DateTime dateTime = DateTime.now();
  int? gender;
  final _picker = ImagePicker();
  XFile? pickedImage;
  String? userAvatar;
  bool isVerifyPhone = false;
  bool isVerifyEmail = false;

  Future<void> _openImagePicker() async {
    pickedImage = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 300, maxHeight: 300);
    setState(() {});
  }

  final formKey = GlobalKey<FormState>();
  Future onSubmit() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      showLoadingDialog(context);
      FormData formData = FormData.fromMap({
        if (pickedImage?.path != null)
          'Avatar': await MultipartFile.fromFile(
            pickedImage!.path,
            filename: pickedImage!.path.split('/').last,
            contentType: MediaType("image", "jpg"),
          ),
        "FullName": nameController.text,
        "Phone": phoneController.text,
        "Email": emailController.text,
        "Dob": dateString,
        "Gender": gender,
        "About": "",
        "Address": addressController.text,
        "Position": "",
        "Website": "",
      });
      final res = await UserApi().updateProfile(formData);
      g.Get.back();
      if (isSuccessStatus(res["code"])) {
        if (widget.isUpdateProfile) {
          HomeController homeController = g.Get.put(HomeController());
          homeController
              .fetchUserData()
              .then((value) => homeController.update());
          successAlert(
            title: "Thành công",
            desc: "Thông tin đã được cập nhật",
            btnOkOnPress: () {
              return g.Get.back();
            },
          );
        } else {
          final prefs = await SharedPreferences.getInstance();
          final organList = await fetchOrganList();
          if (organList.length == 0) {
            final res = await OrganApi().createOrgan(FormData.fromMap({
              "Name": nameController.text,
            }));
            HomeController homeController = g.Get.put(HomeController());
            MainController mainController = g.Get.put(MainController());
            prefs.setString('oData', jsonEncode(res["content"]));
            mainController.onRefresh();
            homeController.onRefresh();
            g.Get.offNamed("/main");
          }
          prefs.setString('oData', jsonEncode(organList[0]));
          g.Get.offNamed("/main");
        }
      } else {
        errorAlert(title: "Thất bại", desc: res["message"]);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getUserData().then((res) {
      if (!isSuccessStatus(res["code"])) {
        return errorAlert(title: "Lỗi", desc: res["message"]);
      }
      userAvatar = res["content"]["avatar"];
      nameController.text =
          res["content"]["email"] == res["content"]["fullName"] ||
                  res["content"]["phone"] == res["content"]["fullName"]
              ? ""
              : (res["content"]["fullName"] ?? "");
      emailController.text = res["content"]["email"] ?? "";
      phoneController.text = res["content"]["phone"] ?? "";
      addressController.text = res["content"]["address"] ?? "";
      if (res["content"]["dob"] != null) {
        dobController.text = DateFormat("dd/MM/yyyy").format(
            DateFormat("yyyy-MM-dd'T'HH:mm:ss")
                .parse(res["content"]["dob"])
                .toUtc());
      }

      setState(() {
        isVerifyEmail = res["content"]["isVerifyEmail"];
        isVerifyPhone = res["content"]["isVerifyPhone"];
        gender = res["content"]["gender"];
        dateString = res["content"]["dob"] ?? "";
      });
    });
  }

  Future getUserData() async {
    final res = await UserApi().getProfile();
    return res;
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
              widget.isUpdateProfile
                  ? "Chỉnh sửa tài khoản"
                  : "Thông tin cá nhân",
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
                              : userAvatar != null
                                  ? ClipOval(
                                      child: Image.network(
                                          "$apiBaseUrl$userAvatar",
                                          width: 300,
                                          height: 300,
                                          fit: BoxFit.cover))
                                  : SvgPicture.asset(
                                      "assets/icons/profile_avatar.svg"),
                        ),
                        if (pickedImage == null && userAvatar == null)
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
                    nameHolder: "Tên của bạn",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Hãy điền tên tài khoản';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  BorderTextField(
                      controller: emailController,
                      name: "Email",
                      nameHolder: "Email của bạn",
                      enable: !isVerifyEmail,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null;
                        }
                        if (!emailValidatorRegExp.hasMatch(value)) {
                          return 'Hãy điền email hợp lệ';
                        }
                        return null;
                      }),
                  const SizedBox(
                    height: 15,
                  ),
                  BorderTextField(
                    controller: phoneController,
                    name: "Số điện thoại",
                    nameHolder: "Nhập số điện thoại",
                    enable: !isVerifyPhone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null;
                      }
                      if (!phonenumValidatorRegExp.hasMatch(value)) {
                        return 'Hãy điền số điện thoại hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      showDatePicker(
                              context: context,
                              initialDate: dateTime,
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now())
                          .then((value) {
                        if (value != null) {
                          setState(() {
                            dobController.text =
                                DateFormat("dd/MM/yyyy").format(value);
                          });

                          String formattedDateTime =
                              DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
                                  .format(value);
                          dateString = formattedDateTime;
                        }
                      });
                    },
                    child: BorderTextField(
                      controller: dobController,
                      isEditAble: false,
                      name: "Ngày Sinh",
                      nameHolder: "DD/MM/YYYY",
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  RadioGender(
                      genderFunction: (g) => {gender = g}, initGender: gender),
                  const SizedBox(
                    height: 15,
                  ),
                  BorderTextField(
                    controller: addressController,
                    name: "Nơi làm việc",
                    nameHolder: "Địa chỉ của bạn",
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
                  onPressed: () {
                    onSubmit();
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  backgroundColor: const Color(0xFF5c33f0),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Text(
                      widget.isUpdateProfile ? "Hoàn thành" : "Tiếp tục",
                      style: const TextStyle(
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
