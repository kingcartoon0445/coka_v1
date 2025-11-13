
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/default_button.dart';
import '../../../components/form_error.dart';
import '../../../constants.dart';

class ForgotPassScreen extends StatefulWidget {
  const ForgotPassScreen({super.key});

  @override
  State<ForgotPassScreen> createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
  String? _phone, _error;
  final _formKey = GlobalKey<FormState>();
  final List<String?> errors = [];
  bool isLoading = false;
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 130, bottom: 60),
                  child: Text(
                    "Quên mật khẩu",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                        fontSize: 24),
                  ),
                ),
                buildForgotPhoneText(),
                FormError(errors: errors),
                const SizedBox(height: 10),
                buildNextBtn(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Hero buildNextBtn(BuildContext context) {
    return Hero(
      tag: "Done regis button",
      child: DefaultButton(
        isLoading: isLoading,
        press: isLoading
            ? () {}
            : () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    isLoading = true;
                  });
                  errors.clear();
                  _formKey.currentState!.validate();
                  hideKeyboard(context);
                  Get.toNamed('/otpResetPassScreen',arguments: _phone);

                }
              },
        text: "Tiếp theo",
      ),
    );
  }

  Padding buildForgotPhoneText() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        cursorColor: kPrimaryColor,
        maxLength: 10,
        onChanged: (value) {
          _formKey.currentState!.validate();
          _phone = value;
          return;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return kPhoneNumberNullError;
          }
          return null;
        },
        decoration: const InputDecoration(
          counterText: "",
          filled: true,
          fillColor: kSecondaryColor,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          hintText: "Số điện thoại",
          prefixIcon: Padding(
            padding: EdgeInsets.all(20),
            child: Icon(Icons.people),
          ),
        ),
      ),
    );
  }
}
