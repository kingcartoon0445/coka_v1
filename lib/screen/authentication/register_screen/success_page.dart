import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegSuccessPage extends StatelessWidget {
  const RegSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Wrap(
          children: [
            Column(
              children: [
                Image.asset("assets/images/reg_success.png"),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                    "Tạo tài khoản thành công, bạn hãy tạo tổ chức cá nhân để trải nghiệm được hết tính năng của COKA",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      backgroundColor: const Color(0xFF5c33f0)),
                  onPressed: () => Get.toNamed("/createPOrg"),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.0),
                    child: Text(
                      "Tiếp tục",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }
}
