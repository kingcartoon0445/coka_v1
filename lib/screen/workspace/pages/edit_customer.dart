import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:coka/api/customer.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/awesome_textfield.dart';
import 'package:coka/components/border_textfield.dart';
import 'package:coka/components/custom_chip_input.dart';
import 'package:coka/components/radio_gender.dart';
import 'package:coka/constants.dart';
import 'package:coka/models/chip_data.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/workspace/getx/customer_controller.dart';
import 'package:coka/screen/workspace/main_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' as g;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../components/loading_dialog.dart';
import 'add_customer.dart';

class EditCustomerPage extends StatefulWidget {
  final Map dataItem;
  final bool? isInside;
  const EditCustomerPage({super.key, required this.dataItem, this.isInside});

  @override
  State<EditCustomerPage> createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends State<EditCustomerPage> {
  HomeController homeController = g.Get.put(HomeController());
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
  final tagController = TextEditingController();
  List tagList = [];
  var tagChipList = <ChipData>[];
  List<ChipData> bonusTags = <ChipData>[];
  List bonusSources = [];

  bool isTagLoaded = false;
  bool isLoaded = false;
  String dateString = "";
  List subPhoneList = [];
  List subEmailList = [];
  List<Map> jsonSocialList = [];
  List<Map> jsonAdditionalList = [];
  int? gender;
  final _picker = ImagePicker();
  XFile? pickedImage;
  String? customerAvatar;

  Future<void> _openImagePicker() async {
    pickedImage = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 300, maxHeight: 300);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Timer(const Duration(milliseconds: 100), () {
    //   showLoadingDialog(context);
    // });
    CustomerApi()
        .getTagList(homeController.workGroupCardDataValue["id"])
        .then((value) {
      setState(() {
        bonusTags =
            (value["content"] as List).map((e) => ChipData(e, e)).toList();
        isTagLoaded = true;
      });
    });
    CustomerApi()
        .getSourceList(homeController.workGroupCardDataValue["id"])
        .then((value) {
      setState(() {
        bonusSources = value["content"];
      });
    });
    CustomerApi()
        .getDetailCustomer(
            homeController.workGroupCardDataValue["id"], widget.dataItem["id"])
        .then((value) {
      // g.Get.back();
      if (isSuccessStatus(value["code"])) {
        final dataItem = value["content"];
        nameController.text = dataItem["fullName"];
        customerAvatar = dataItem["avatar"];
        emailController.text = dataItem["email"] ?? "";
        phoneController.text = dataItem["phone"].replaceFirst("84", "0") ?? "";
        if (dataItem["dob"] != null) {
          dobController.text = DateFormat("dd/MM/yyyy").format(
              DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(dataItem["dob"]));

          dateString = dataItem["dob"];
        }
        workController.text = dataItem["work"] ?? "";
        addressController.text = dataItem["address"] ?? "";
        physicalIdController.text = dataItem["physicalId"] ?? "";
        customerSourceController.text =
            dataItem?["source"]?.last["utmSource"] ?? "";

        gender = dataItem["gender"];
        tagList = dataItem["tags"] ?? [];
        setState(() {
          tagChipList = tagList.map((e) => ChipData(e, e)).toList();
          print(tagChipList);
        });
        isLoaded = true;
        if (dataItem["additional"] != null) {
          for (var x in dataItem["additional"]) {
            if (x["key"] == "phone") {
              final controller = TextEditingController(text: x["value"]);
              subPhoneList.add({
                "controller": controller,
                "category": x["name"],
                "id": x["id"]
              });
            } else if (x["key"] == "email") {
              final controller = TextEditingController(text: x["value"]);
              subEmailList.add({
                "controller": controller,
                "category": x["name"],
                "id": x["id"],
              });
            }
          }
        }
        if (dataItem["social"] != null) {
          for (var x in dataItem["social"]) {
            if (x["provider"] == "FACEBOOK") {
              fbController.text = x["profileUrl"];
            } else if (x["provider"] == "ZALO") {
              zaloController.text = x["profileUrl"];
            }
          }
        }
        setState(() {});
      } else {
        // g.Get.back();
        errorAlert(title: "Lỗi", desc: value["message"]);
      }
    });
  }

  final formKey = GlobalKey<FormState>();
  Future onSubmit() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      showLoadingDialog(context);
      String subJsonAddString = "";
      String subJsonSocialString = "";

      if (subEmailList.isNotEmpty || subPhoneList.isNotEmpty) {
        print(subPhoneList);
        jsonAdditionalList.clear();
        for (var x = 0; x < subPhoneList.length; x++) {
          jsonAdditionalList.add({
            "id": subPhoneList[x]["id"],
            "key": "phone",
            "name": subPhoneList[x]["category"],
            "value": (subPhoneList[x]["isDelete"] ?? false)
                ? ""
                : subPhoneList[x]["controller"].text
          });
        }
        for (var x = 0; x < subEmailList.length; x++) {
          jsonAdditionalList.add({
            "id": subEmailList[x]["id"],
            "key": "email",
            "name": subEmailList[x]["category"],
            "value": (subEmailList[x]["isDelete"] ?? false)
                ? ""
                : subEmailList[x]["controller"].text
          });
        }
        subJsonAddString = jsonEncode(jsonAdditionalList);
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
      final res = await CustomerApi().updateCustomer(
        homeController.workGroupCardDataValue['id'],
        widget.dataItem["id"],
        formData,
      );
      if (isSuccessStatus(res["code"])) {
        g.Get.back();
        g.Get.back();
        successAlert(
          title: "Thành công",
          desc: "Cập nhật khách hàng thành công",
          btnOkOnPress: () {},
        );
        if (widget.isInside ?? false) {
          final customerController = g.Get.put(CustomerController());
          customerController.fetchJourney();
          customerController.fetchDetailCustomer();
          customerController.update();
        }
        WorkspaceMainController wmController =
            g.Get.put(WorkspaceMainController());
        wmController.onRefresh();
      } else {
        g.Get.back();
        errorAlert(title: "Thất bại", desc: res["message"]);
      }
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
            title: const Text(
              "Chỉnh sửa khách hàng",
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
                                : customerAvatar != null
                                    ? CircleAvatar(
                                        backgroundImage:
                                            getAvatarProvider(customerAvatar),
                                        radius: 45,
                                      )
                                    : SvgPicture.asset(
                                        "assets/icons/profile_avatar.svg"),
                          ),
                          if (pickedImage == null && customerAvatar == null)
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
                          subPhoneList.firstWhere(
                              (element) => element == e)["isDelete"] = true;
                        });
                      },
                      buttonName: "Thêm số điện thoại"),
                  const SizedBox(
                    height: 15,
                  ),
                  BorderTextField(
                      controller: emailController,
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
                          subEmailList.firstWhere(
                              (element) => element == e)["isDelete"] = true;
                        });
                      },
                      buttonName: "Thêm email"),
                  const SizedBox(
                    height: 15,
                  ),
                  RadioGender(
                      genderFunction: (g) => {gender = g}, initGender: gender),
                  const SizedBox(
                    height: 6,
                  ),
                  const Text(
                    "Nhãn",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  if ((tagChipList.isNotEmpty || isLoaded) && isTagLoaded)
                    CustomChipInput(
                        itemInitValue: tagChipList,
                        onItemChange: (p0) {
                          setState(() {
                            tagChipList = p0;
                          });
                          tagList = p0.map((e) => e.id).toList();
                        },
                        itemsMenu: <ChipData>{...tagMenu, ...bonusTags}
                            .toSet()
                            .toList(),
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
                                DateFormat("dd/MM/yyyy").format(value.toUtc());
                          });

                          String formattedDateTime =
                              DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
                                  .format(value.toUtc());
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
                            Padding(
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
                                  ...<dynamic>{
                                    ...customerSourceList,
                                    ...bonusSources
                                  }.toList().map((e) => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextButton(
                                              style: TextButton.styleFrom(
                                                  minimumSize: const Size(
                                                      double.infinity, 30),
                                                  alignment:
                                                      Alignment.centerLeft),
                                              onPressed: () {
                                                g.Get.back();
                                                customerSourceController.text =
                                                    e;
                                              },
                                              child: Text(
                                                e,
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                    color: Colors.black),
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
                    "                          Hoàn thành                          ",
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
