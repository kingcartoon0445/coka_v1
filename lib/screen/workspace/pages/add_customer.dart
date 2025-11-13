import 'dart:convert';
import 'dart:io';

import 'package:coka/api/customer.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/awesome_textfield.dart';
import 'package:coka/components/border_textfield.dart';
import 'package:coka/components/radio_gender.dart';
import 'package:coka/constants.dart';
import 'package:coka/models/chip_data.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/workspace/main_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart' as g;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../components/custom_chip_input.dart';
import '../../../components/loading_dialog.dart';

final customerSourceList = [
  "Khách cũ",
  "Được giới thiệu",
  "Trực tiếp",
  "Hotline",
  "Google",
  "Facebook",
  "Zalo",
  "Tiktok",
  "Khác"
];
final tagMenu = <ChipData>[
  const ChipData(
    'Mua để ở',
    'Mua để ở',
  ),
  const ChipData(
    'Mua đầu tư',
    'Mua đầu tư',
  ),
  const ChipData(
    'Cho thuê',
    'Cho thuê',
  ),
  const ChipData(
    'Cần thuê',
    'Cần thuê',
  ),
  const ChipData(
    'Cần bán',
    'Cần bán',
  ),
  const ChipData(
    'Chuyển nhượng',
    'Chuyển nhượng',
  ),
];

class AddCustomerPage extends StatefulWidget {
  const AddCustomerPage({super.key});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController workController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController physicalIdController = TextEditingController();
  TextEditingController customerSourceController = TextEditingController();
  TextEditingController fbController = TextEditingController();
  TextEditingController zaloController = TextEditingController();
  List tagList = [];
  var tagChipList = <ChipData>[];
  List bonusSources = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final homeController = g.Get.put(HomeController());
    CustomerApi()
        .getSourceList(homeController.workGroupCardDataValue["id"])
        .then((value) {
      setState(() {
        bonusSources = value["content"];
      });
    });
  }

  List subPhoneList = [];
  List subEmailList = [];
  List<Map> jsonAdditionalList = [];
  List<Map> jsonSocialList = [];
  String dateString = "";
  int? gender;
  final _picker = ImagePicker();
  XFile? pickedImage;

  Future<void> _openImagePicker() async {
    pickedImage = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 300, maxHeight: 300);
    setState(() {});
  }

  final formKey = GlobalKey<FormState>();
  Future onSubmit() async {
    try {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        showLoadingDialog(context);
        String subJsonAddString = "";
        String subJsonSocialString = "";
        if (subEmailList.isNotEmpty || subPhoneList.isNotEmpty) {
          jsonAdditionalList.clear();
          for (var x = 0; x < subPhoneList.length; x++) {
            jsonAdditionalList.add({
              "key": "phone",
              "name": subPhoneList[x]["category"],
              "value": subPhoneList[x]["controller"].text
            });
          }
          for (var x = 0; x < subEmailList.length; x++) {
            jsonAdditionalList.add({
              "key": "email",
              "name": subEmailList[x]["category"],
              "value": subEmailList[x]["controller"].text
            });
          }
        }

        if (fbController.text.isNotEmpty) {
          jsonSocialList.add({
            "Provider": "FACEBOOK",
            "ProfileUrl": fbController.text,
            "Phone": phoneController.text,
            "FullName": nameController.text
          });
        }
        if (zaloController.text.isNotEmpty) {
          jsonSocialList.add({
            "Provider": "ZALO",
            "ProfileUrl": zaloController.text,
            "Phone": phoneController.text,
            "FullName": nameController.text
          });
        }
        subJsonAddString = jsonEncode(jsonAdditionalList);
        subJsonSocialString = jsonEncode(jsonSocialList);
        FormData formData = FormData.fromMap({
          if (pickedImage?.path != null)
            'Avatar': await MultipartFile.fromFile(
              pickedImage!.path,
              filename: pickedImage!.path.split('/').last,
              contentType: MediaType("image", "jpg"),
            ),
          "FullName": nameController.text,
          "Phone": phoneController.text,
          "SourceId": "ce7f42cf-f10f-49d2-b57e-0c75f8463c82",
          if (physicalIdController.text != "")
            "PhysicalId": physicalIdController.text,
          if (customerSourceController.text != "")
            "UtmSource": customerSourceController.text,
          if (emailController.text != "") "Email": emailController.text,
          if (dateString != "") "Dob": dateString,
          if (gender != null) "Gender": gender,
          if (addressController.text != "") "Address": addressController.text,
          if (workController.text != "") "Work": workController.text,
          if (jsonAdditionalList.isNotEmpty) "JsonAdditional": subJsonAddString,
          if (jsonSocialList.isNotEmpty) "JsonSocial": subJsonSocialString,
          if (tagList.isNotEmpty) "JsonTags": jsonEncode(tagList)
        });
        HomeController homeController = g.Get.put(HomeController());
        final res = await CustomerApi().createCustomer(
            homeController.workGroupCardDataValue['id'], formData);
        if (isSuccessStatus(res["code"])) {
          WorkspaceMainController wmController =
              g.Get.put(WorkspaceMainController());
          wmController.onRefresh();
          g.Get.back();
          g.Get.back();

          successAlert(
            title: "Thành công",
            desc: "Đã tạo khách hàng thành công",
            btnOkOnPress: () {},
          );
        } else {
          g.Get.back();
          errorAlert(title: "Thất bại", desc: res["message"]);
        }
      }
    } catch (e) {}
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
            title: const Text(
              "Thêm khách hàng",
              style: TextStyle(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
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
                                : SvgPicture.asset(
                                    "assets/icons/profile_avatar.svg"),
                          ),
                          if (pickedImage == null)
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
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  BorderTextField(
                    controller: nameController,
                    name: "Họ và tên",
                    isRequire: true,
                    nameHolder: "Họ và tên khách hàng",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Hãy điền tên khách hàng';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  BorderTextField(
                    controller: phoneController,
                    textInputType: TextInputType.phone,
                    preIcon: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Liên hệ chính",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1A1C1E))),
                          const SizedBox(
                            width: 8,
                          ),
                          Container(
                            height: 20,
                            width: 1,
                            color: const Color(0x00000000).withOpacity(0.12),
                          )
                        ],
                      ),
                    ),
                    name: "Số điện thoại",
                    nameHolder: "Số điện thoại",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Hãy điền số điện thoại khách hàng';
                      }
                      if (!phonenumValidatorRegExp.hasMatch(value)) {
                        return 'Hãy điền số điện thoại hợp lệ';
                      }
                      return null;
                    },
                    isRequire: true,
                  ),
                  AwesomeTextField(
                      dataList: subPhoneList,
                      holderName: "Số điện thoại",
                      textInputType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Hãy điền số điện thoại khách hàng';
                        }
                        if (!phonenumValidatorRegExp.hasMatch(value)) {
                          return 'Hãy điền số điện thoại hợp lệ';
                        }
                        return null;
                      },
                      onAdded: () {
                        final controller = TextEditingController();
                        setState(() {
                          subPhoneList.add({
                            "controller": controller,
                            "category": "Công việc"
                          });
                        });
                      },
                      onCategoryChanged: (e1, value) {
                        setState(() {
                          subPhoneList
                              .firstWhere((e2) => e2 == e1)["category"] = value;
                        });
                      },
                      onDeleted: (e) {
                        setState(() {
                          subPhoneList.remove(e);
                        });
                      },
                      buttonName: "Thêm số điện thoại"),
                  const SizedBox(
                    height: 15,
                  ),
                  BorderTextField(
                      controller: emailController,
                      textInputType: TextInputType.emailAddress,
                      name: "Email",
                      preIcon: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Email chính",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1A1C1E))),
                            const SizedBox(
                              width: 8,
                            ),
                            Container(
                              height: 20,
                              width: 1,
                              color: const Color(0x00000000).withOpacity(0.12),
                            )
                          ],
                        ),
                      ),
                      nameHolder: "Điền email",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null;
                        }
                        if (!emailValidatorRegExp.hasMatch(value)) {
                          return 'Hãy điền email hợp lệ';
                        }
                        return null;
                      }),
                  AwesomeTextField(
                      dataList: subEmailList,
                      textInputType: TextInputType.emailAddress,
                      holderName: "Điền email",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null;
                        }
                        if (!emailValidatorRegExp.hasMatch(value)) {
                          return 'Hãy điền email hợp lệ';
                        }
                        return null;
                      },
                      onAdded: () {
                        final controller = TextEditingController();
                        setState(() {
                          subEmailList.add({
                            "controller": controller,
                            "category": "Công việc"
                          });
                        });
                      },
                      onCategoryChanged: (e1, value) {
                        setState(() {
                          subEmailList
                              .firstWhere((e2) => e2 == e1)["category"] = value;
                        });
                      },
                      onDeleted: (e) {
                        setState(() {
                          subEmailList.remove(e);
                        });
                      },
                      buttonName: "Thêm email"),
                  const SizedBox(
                    height: 15,
                  ),
                  RadioGender(genderFunction: (g) => {gender = g}),
                  const SizedBox(
                    height: 6,
                  ),
                  const Row(
                    children: [
                      Text(
                        "Nhãn",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Gap(4),
                      Tooltip(
                          message: "Các nhãn ngăn cách nhau bởi dấu phẩy \",\"",
                          triggerMode: TooltipTriggerMode.tap,
                          showDuration: Duration(seconds: 5),
                          child: Icon(
                            Icons.help_outline,
                            size: 20,
                          ))
                    ],
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  CustomChipInput(
                      itemInitValue: tagChipList,
                      onItemChange: (p0) {
                        setState(() {
                          tagChipList = p0;
                        });
                        tagList = p0.map((e) => e.id).toList();
                      },
                      itemsMenu: tagMenu,
                      hintText: "Hãy thêm nhãn"),
                  const SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
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
                  BorderTextField(
                    controller: workController,
                    name: "Nghề nghiệp",
                    nameHolder: "Nghề nghiệp của khách hàng",
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  BorderTextField(
                    controller: addressController,
                    name: "Nơi ở",
                    nameHolder: "Nhập nơi ở khách hàng",
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  BorderTextField(
                    controller: physicalIdController,
                    name: "CMND/CCCD",
                    nameHolder: "Nhập CMND/CCCD",
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => Wrap(
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 700),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Center(
                                        child: Text(
                                      "Nguồn khách hàng",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                          fontSize: 16),
                                    )),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ...<dynamic>{
                                              ...customerSourceList,
                                              ...bonusSources
                                            }
                                                .toList()
                                                .map((e) => Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextButton(
                                                            style: TextButton.styleFrom(
                                                                minimumSize:
                                                                    const Size(
                                                                        double
                                                                            .infinity,
                                                                        30),
                                                                alignment: Alignment
                                                                    .centerLeft),
                                                            onPressed: () {
                                                              g.Get.back();
                                                              customerSourceController
                                                                  .text = e;
                                                            },
                                                            child: Text(
                                                              e,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                            )),
                                                        const Divider(
                                                          height: 4,
                                                          thickness: 0,
                                                        )
                                                      ],
                                                    ))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: BorderTextField(
                      controller: customerSourceController,
                      name: "Nguồn khách hàng",
                      nameHolder: "Chọn nguồn",
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                      isEditAble: false,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  BorderTextField(
                    controller: fbController,
                    name: "Mạng xã hội",
                    validator: (value) {
                      bool isValid =
                          Uri.tryParse(value!)?.hasAbsolutePath ?? false;
                      if ((!isValid ||
                              (!value.contains("fb") &&
                                  !value.contains("facebook"))) &&
                          value.isNotEmpty) {
                        return 'Hãy nhập URL hợp lệ';
                      }
                      return null;
                    },
                    preIcon: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Facebook",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1A1C1E))),
                          const SizedBox(
                            width: 8,
                          ),
                          Container(
                            height: 20,
                            width: 1,
                            color: const Color(0x00000000).withOpacity(0.12),
                          )
                        ],
                      ),
                    ),
                    nameHolder: "Nhập đường dẫn",
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  BorderTextField(
                    controller: zaloController,
                    name: "",
                    validator: (value) {
                      bool isValid =
                          Uri.tryParse(value!)?.hasAbsolutePath ?? false;
                      if (!isValid && value.isNotEmpty) {
                        return 'Hãy nhập URL hợp lệ';
                      }
                      return null;
                    },
                    preIcon: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Zalo",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1A1C1E))),
                          const SizedBox(
                            width: 40,
                          ),
                          Container(
                            height: 20,
                            width: 1,
                            color: const Color(0x00000000).withOpacity(0.12),
                          )
                        ],
                      ),
                    ),
                    nameHolder: "Nhập đường dẫn",
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
                  label: const Text(
                    "                          Tiếp tục                          ",
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
