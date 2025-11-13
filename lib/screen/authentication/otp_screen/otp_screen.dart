import 'package:coka/models/auto_login_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'components/body.dart';

class OtpScreen extends StatelessWidget {

  const OtpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    AutoLoginModel autoLoginModel = Get.arguments;
    String phone = autoLoginModel.phone;
    String otpId = autoLoginModel.otpId;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Body(phone: phone,otpId: otpId),
      ),
    );
  }
}
