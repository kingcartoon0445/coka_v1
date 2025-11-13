import 'package:coka/api/webform.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/crm/crm_controller.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../components/custom_snackbar.dart';
import '../../../components/elevated_btn.dart';
import '../../crm_customer/components/code_container.dart';

void connectWebFormNext() {
  CrmController ct = Get.put(CrmController());
  ct.isWebsiteLegit.value = false;
  HomeController mainController = Get.put(HomeController());
  TextEditingController websiteController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  void submitForm() {
    if (formKey.currentState!.validate()) {
      // Do something with the valid URL
      WebformApi()
          .addWebsite(websiteController.text,
              mainController.workGroupCardDataValue['id'])
          .then((res) {
        if (isSuccessStatus(res['code'])) {
          ct.websiteList.add(res['content']);
        } else {
          errorAlert(title: 'Lỗi', desc: res['message']);
        }
      });
      ct.isWebsiteLegit.value = true;
    }
  }

  showModalBottomSheet(
    context: Get.context!,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    constraints: BoxConstraints(maxHeight: Get.height - 45),
    shape: const RoundedRectangleBorder(
      // <-- SEE HERE
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20.0),
      ),
    ),
    builder: (BuildContext context) {
      return Obx(() {
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ElevatedBtn(
                      onPressed: () {
                        Get.back();
                      },
                      circular: 30,
                      paddingAllValue: 10,
                      child: SvgPicture.asset(
                        'assets/icons/back_arrow.svg',
                        height: 30,
                        width: 30,
                      )),
                  const Text(
                    'Kết nối Web form',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ],
              ),
              Container(
                height: 1,
                width: double.infinity,
                color: const Color(0xFFF3F4F6),
              ),
              const SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: websiteController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Hãy nhập website URL';
                        }
                        Uri? uri = Uri.tryParse(value);
                        if (uri == null) {
                          return 'Hãy nhập website URL hợp lệ';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(
                                color: Color(0xFF9095A0), width: 1),
                          ),
                          hintText: 'Nhập website vào đây',
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10)),
                    ),
                    const SizedBox(
                      height: 13,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF7706E),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6))),
                      onPressed: () {
                        submitForm();
                      },
                      child: const Text('Tiếp theo',
                          style: TextStyle(color: Colors.white)),
                    ),
                    if (ct.isWebsiteLegit.value)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 13,
                          ),
                          const Text(
                              'Copy đoạn Script bên dưới và dàn vào giữa <head>... </head> của phần source web site, sau đó bấm xác minh để kiểm tra'),
                          const SizedBox(
                            height: 13,
                          ),
                          const CodeSnippetContainer(
                              code:
                                  '<script>var game = new OmegaGame(288, 512);</script>'),
                          const SizedBox(
                            height: 25,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF7706E),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6))),
                            onPressed: () {
                              Get.back();
                              successSnackbar(
                                  text: 'Kết nối web form thành công!',
                                  context: Get.context!);
                            },
                            child: const Text('Xác minh',
                                style: TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      });
    },
  );
}
