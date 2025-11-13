
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../constants.dart';

class OtpForm extends StatefulWidget {
  final Function onSubmit;

  const OtpForm({
    super.key,
    required this.onSubmit,
  });

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  final _formKey = GlobalKey<FormState>();
  String? errorMess;
  String? otpCode;
  String? errorMes;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: Get.height * 0.05),
          PinCodeTextField(
            length: 6,
            obscureText: false,
            keyboardType: TextInputType.number,
            animationType: AnimationType.fade,
            cursorColor: Colors.black,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              errorBorderColor: Colors.black,
              borderWidth: 1,
              borderRadius: BorderRadius.circular(8),
              fieldHeight: 50,
              fieldWidth: 50,
              activeFillColor: kSecondaryColor,
              selectedColor: Colors.black,
              activeColor: Colors.black,
              inactiveColor: Colors.black,
              selectedFillColor: kSecondaryColor,
              inactiveFillColor: kSecondaryColor,
            ),
            animationDuration: const Duration(milliseconds: 300),
            enableActiveFill: true,
            onChanged: (value) {
              if (value.length == 6) {
                widget.onSubmit(value);
              }
            },
            beforeTextPaste: (text) {
              return true;
            },
            appContext: context,
          ),
        ],
      ),
    );
  }
}
