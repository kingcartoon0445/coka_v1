
import 'package:flutter/material.dart';

import '../../../components/default_button.dart';
import '../../../components/form_error.dart';
import '../../../constants.dart';

class ResetPassScreen extends StatefulWidget {
  const ResetPassScreen({super.key});

  @override
  State<ResetPassScreen> createState() => _ResetPassScreenState();
}

class _ResetPassScreenState extends State<ResetPassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formPassKey = GlobalKey<FormState>();
  final _formRepeatPassKey = GlobalKey<FormState>();
  String? email;
  String? password;
  String? confirmPassword;
  String? errorMes;
  final bool _isLoading = false;
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

  bool obscureText = true;
  bool _obscureText = true;

  void _toggle() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  void __toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
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
                    "Thiết lập mật khẩu",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                        fontSize: 24),
                  ),
                ),
                Form(key: _formPassKey, child: buildPassTextFormField()),
                Form(
                    key: _formRepeatPassKey,
                    child: buildRepeatPassTextFormField()),
                FormError(errors: errors),
                const SizedBox(height: 10),
                Hero(
                  tag: "Done regis button",
                  child: DefaultButton(
                    isLoading: _isLoading,
                    press: _isLoading
                        ? () {}
                        : () {

                          },
                    text: "Hoàn tất",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding buildRepeatPassTextFormField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextFormField(
        textInputAction: TextInputAction.done,
        obscureText: _obscureText,
        cursorColor: kPrimaryColor,
        maxLength: 40,
        onChanged: (value) {
          _formRepeatPassKey.currentState!.validate();
          confirmPassword = value;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return kRepeatPassNullError;
          } else if ((password != value)) {
            return kMatchPassError;
          }
          return null;
        },
        decoration: InputDecoration(
            counterText: "",
            errorStyle: const TextStyle(height: 0),
            filled: true,
            fillColor: kSecondaryColor,
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
            ),
            hintText: "Nhập lại mật khẩu",
            prefixIcon: const Padding(
              padding: EdgeInsets.all(20),
              child: Icon(Icons.lock),
            ),
            suffixIcon: GestureDetector(
              onTap: __toggle,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            )),
      ),
    );
  }

  TextFormField buildPassTextFormField() {
    return TextFormField(
      textInputAction: TextInputAction.done,
      obscureText: obscureText,
      cursorColor: kPrimaryColor,
      maxLength: 40,
      onChanged: (value) {
        _formPassKey.currentState!.validate();
        password = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return kPassNullError;
        } else if (!regex.hasMatch(value)) {
          return kValidPassError;
        }
        return null;
      },
      decoration: InputDecoration(
          counterText: "",
          errorStyle: const TextStyle(height: 0),
          errorMaxLines: 2,
          filled: true,
          fillColor: kSecondaryColor,
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          hintText: "Mật khẩu",
          prefixIcon: const Padding(
            padding: EdgeInsets.all(20),
            child: Icon(Icons.lock),
          ),
          suffixIcon: GestureDetector(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
              ),
            ),
          )),
    );
  }
}
