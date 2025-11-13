
import 'package:get/get.dart';

import 'components/body.dart';
import 'package:flutter/material.dart';

class OtpResetPassScreen extends StatelessWidget {
  const OtpResetPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(phoneNum: Get.arguments),
    );
  }
}
