import 'dart:async';


import 'package:flutter/material.dart';

import '../../../../../constants.dart';
import 'otp_form.dart';

class Body extends StatefulWidget {
  final String phoneNum;

  const Body({super.key, required this.phoneNum});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int secondsRemaining = 45;
  bool enableResend = false;
  Timer? timer;
  @override
  initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsRemaining != 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        setState(() {
          enableResend = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 130, bottom: 60),
              child: Text(
                "OTP",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                    fontSize: 24),
              ),
            ),
            Text(
              "Mã OTP đã được gửi đến số điện thoại\n${widget.phoneNum.replaceRange(3, 8, "*****")}",
              textAlign: TextAlign.center,
            ),
            const OtpForm(),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                enableResend ? _resendCode() : null;
              },
              child: Text(
                "Gửi lại mã",
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: enableResend
                        ? kPrimaryColor
                        : kPrimaryColor.withOpacity(0.3)),
              ),
            ),
            !enableResend
                ? Text(
                    'Sau $secondsRemaining giây',
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  void _resendCode() {

    setState(() {
      secondsRemaining = 45;
      enableResend = false;
    });
  }

  @override
  dispose() {
    timer!.cancel();
    super.dispose();
  }
}
