
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../../components/default_button.dart';
import '../../../../../components/form_error.dart';
import '../../../../../constants.dart';

class OtpForm extends StatefulWidget {
  const OtpForm({
    super.key,
  });

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  String? errorMes;
  final _formKey = GlobalKey<FormState>();
  String? otpCode = "";
  bool _isLoading = false;

  final List<String?> errors = [];

  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                borderWidth: 1,
                errorBorderColor: Colors.black,
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
                otpCode = value;
              },
              beforeTextPaste: (text) {
                return true;
              },
              appContext: context,
            ),
            const SizedBox(
              height: 10,
            ),
            FormError(errors: errors),
            SizedBox(height: Get.height * 0.05),
            DefaultButton(
              isLoading: _isLoading,
              text: "Tiếp theo",
              press: _isLoading
                  ? () {}
                  : () {
                      if (otpCode?.length != 6) {
                        addError(error: kOtpNumberNullError);
                        _formKey.currentState!.validate();
                      } else {
                        setState(() {
                          _isLoading = true;
                        });
                        errors.clear();
                        _formKey.currentState!.validate();
                        hideKeyboard(context);
                        Get.offNamed('resetPass');
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
