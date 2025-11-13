import 'package:coka/api/webform.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/workspace/getx/multi_connect_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../components/elevated_btn.dart';
import '../../crm_customer/components/code_container.dart';

void connectWebFormNext({Map? connectData}) {
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
      return ConnectWebformLayout(
        connectData: connectData,
      );
    },
  );
}

class ConnectWebformLayout extends StatefulWidget {
  final Map? connectData;

  const ConnectWebformLayout({
    super.key,
    this.connectData,
  });

  @override
  State<ConnectWebformLayout> createState() => _ConnectWebformLayoutState();
}

class _ConnectWebformLayoutState extends State<ConnectWebformLayout> {
  HomeController mainController = Get.put(HomeController());
  MultiConnectController mcController = Get.put(MultiConnectController());
  TextEditingController websiteController = TextEditingController();

  String webformId = "";

  String getScriptText(id) {
    return '''<meta name="coka-site-verification" content="$id" /><script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start': new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0], j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src= 'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f); })(window,document,'script','dataLayer','GTM-NM778J2J');</script>''';
  }

  bool isVerify = false;
  final formKey = GlobalKey<FormState>();

  void submitForm() {
    if (formKey.currentState!.validate()) {
      String url = websiteController.text.contains("http")
          ? websiteController.text
          : "https://${websiteController.text}";
      showLoadingDialog(context);

      WebformApi()
          .addWebsite(url, mainController.workGroupCardDataValue['id'])
          .then((res) {
        Get.back();
        if (isSuccessStatus(res['code'])) {
          setState(() {
            isVerify = true;
            webformId = res["content"]["id"];
          });
          mcController.onRefresh();
        } else {
          errorAlert(title: 'Lỗi', desc: res['message']);
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    webformId = widget.connectData?["id"] ?? "";
    websiteController.text = widget.connectData?["url"] ?? "";
    isVerify = widget.connectData != null ? true : false;
  }

  @override
  Widget build(BuildContext context) {
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
                  enabled: widget.connectData == null ? true : false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Hãy nhập website URL';
                    }
                    bool isValid = Uri.tryParse(value)?.hasAbsolutePath ?? false;
                    if (isValid) {
                      return 'Hãy nhập URL hợp lệ';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                            color: Color(0xFF9095A0), width: 1),
                      ),
                      hintText: 'Nhập website cần kết nối vào đây',
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
                if (isVerify)
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
                      CodeSnippetContainer(code: getScriptText(webformId)),
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
                          showLoadingDialog(context);
                          WebformApi()
                              .verifyWebsite(webformId,
                                  mainController.workGroupCardDataValue['id'])
                              .then((res) {
                            Get.back();
                            if (res["content"]) {
                              Get.back();
                              MultiConnectController mcController =
                                  Get.put(MultiConnectController());
                              mcController.isFetching.value = true;
                              mcController.update();
                              mcController.fetchWebForm().then((value) {
                                mcController.isFetching.value = false;
                                mcController.update();
                              });
                              successAlert(
                                desc: 'Website đã gắn script thành công',
                                title: "Thành công",
                                btnOkOnPress: () {},
                              );
                            } else {
                              errorAlert(
                                  title: "Thất bại",
                                  desc: "Website chưa được cấu hình đúng cách");
                            }
                          });
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
  }
}
