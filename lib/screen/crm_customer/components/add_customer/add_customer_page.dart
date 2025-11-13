import 'dart:convert';

import 'package:coka/api/customer.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/crm_customer/crm_customer_controller.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../components/awesome_alert.dart';
import '../../../../components/loading_dialog.dart';
import 'add_customer_controller.dart';

class AddCustomerPage extends StatefulWidget {
  const AddCustomerPage({super.key});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  String avatarFile = "";

  Future<void> _openImagePicker() async {
    final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 100, maxHeight: 100);
    if (pickedImage != null) {
      AddCustomerController addCustomerController =
          Get.put(AddCustomerController());
      avatarFile = base64Encode(await pickedImage.readAsBytes());
      addCustomerController.avatarData.value = avatarFile;
      addCustomerController.update();
    }
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  String dateString = "";
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddCustomerController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Khách hàng mới',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    HomeController mainController = Get.put(HomeController());
                    showLoadingDialog(context);
                    CustomerApi().createCustomer(
                        mainController.workGroupCardDataValue['id'], {
                      "fullName": nameController.text,
                      "phone": phoneController.text,
                      "sourceId": "ce7f42cf-f10f-49d2-b57e-0c75f8463c82",
                      "gender": genderController.text == 'Nam'
                          ? 1
                          : genderController.text == 'Nữ'
                              ? 0
                              : 2,
                      if (avatarFile != "") "avatar": avatarFile,
                      if (dateString != "") "dob": dateString,
                      if (emailController.text != "")
                        "email": emailController.text,
                    }).then((res) {
                      Get.back();
                      if (isSuccessStatus(res['code'])) {
                        Get.back();
                        CrmCustomerController crmCustomerController =
                            Get.put(CrmCustomerController());
                        crmCustomerController.fetchCustomer();
                        successAlert(
                            title: "Thành công",
                            desc: "Đã thêm khách hàng ${nameController.text}");
                      } else {
                        errorAlert(title: "Lỗi", desc: res['message']);
                      }
                    }).catchError((e) {
                      Get.back();
                      errorAlert(title: "Lỗi", desc: e.toString());
                    });
                  }
                },
                icon: const Icon(Icons.check))
          ],
        ),
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _openImagePicker();
                        },
                        child: CircleAvatar(
                          backgroundImage: MemoryImage(
                              base64Decode(controller.avatarData.value)),
                          radius: 50,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.person_outline),
                      SizedBox(
                        width: Get.width - 85,
                        child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Hãy điền tên khách hàng';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.name,
                            controller: nameController,
                            style: const TextStyle(fontSize: 16),
                            decoration: const InputDecoration(
                              hintText: 'Tên',
                              hintStyle: TextStyle(fontSize: 16),
                              border: UnderlineInputBorder(),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.phone_outlined),
                      SizedBox(
                        width: Get.width - 85,
                        child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Hãy điền số điện thoại';
                              }
                              if (!phonenumValidatorRegExp.hasMatch(value)) {
                                return 'Hãy điền số điện thoại hợp lệ';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.phone,
                            controller: phoneController,
                            style: const TextStyle(fontSize: 16),
                            decoration: const InputDecoration(
                              hintText: 'Số điện thoại',
                              hintStyle: TextStyle(fontSize: 16),
                              border: UnderlineInputBorder(),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.email_outlined),
                      SizedBox(
                        width: Get.width - 85,
                        child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            controller: emailController,
                            style: const TextStyle(fontSize: 16),
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(fontSize: 16),
                              border: UnderlineInputBorder(),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/gender.png',
                        width: 25,
                      ),
                      SizedBox(
                        width: Get.width - 85,
                        child: PopupMenuButton<String>(
                          offset: const Offset(0, 45),
                          constraints: BoxConstraints(minWidth: Get.width - 85),
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'Male',
                              child: const Text('Nam'),
                              onTap: () {
                                genderController.text = 'Nam';
                              },
                            ),
                            PopupMenuItem<String>(
                              value: 'Female',
                              child: const Text('Nữ'),
                              onTap: () {
                                genderController.text = 'Nữ';
                              },
                            ),
                          ],
                          child: AbsorbPointer(
                            absorbing: true,
                            child: TextFormField(
                                readOnly: true,
                                keyboardType: TextInputType.text,
                                controller: genderController,
                                style: const TextStyle(fontSize: 16),
                                decoration: const InputDecoration(
                                  hintText: 'Giới tính',
                                  hintStyle: TextStyle(fontSize: 16),
                                  border: UnderlineInputBorder(),
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.calendar_month),
                      GestureDetector(
                        onTap: () {
                          showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now())
                              .then((value) {
                            if (value != null) {
                              dateController.text =
                                  DateFormat.yMMMMd('vi_VN').format(value);
                              String formattedDateTime =
                                  DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
                                      .format(value.toUtc());
                              dateString = formattedDateTime;
                            }
                          });
                        },
                        child: SizedBox(
                          width: Get.width - 85,
                          child: AbsorbPointer(
                            absorbing: true,
                            child: TextFormField(
                                readOnly: true,
                                keyboardType: TextInputType.datetime,
                                controller: dateController,
                                style: const TextStyle(fontSize: 16),
                                decoration: const InputDecoration(
                                  hintText: 'Ngày sinh',
                                  hintStyle: TextStyle(fontSize: 16),
                                  border: UnderlineInputBorder(),
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
