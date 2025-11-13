import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:coka/components/border_textfield.dart';
import 'package:coka/main.dart';
import 'package:dio/dio.dart';
import 'package:coka/api/auth.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/default_button.dart';
import 'package:coka/models/auto_login_model.dart';
import 'package:coka/screen/authentication/otp_screen/otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' as g;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../api/user.dart';
import '../../../../components/elevated_btn.dart';
import '../../../../components/form_error.dart';
import '../../../../components/loading_dialog.dart';
import '../../../../components/social_button.dart';
import '../../../../constants.dart';
import '../../password_screen/forgot_pass_screen.dart';
import '../../register_screen/success_page.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool obscureText = true;
  final userNameController = TextEditingController();
  bool isSocialLoading = true;
  bool _isLoading = false;
  late String accessToken, providerId;
  final FirebaseAuth auth = FirebaseAuth.instance;
  var googleAccount = g.Rx<GoogleSignInAccount?>(null);
  final GoogleSignIn googleSignIn = GoogleSignIn();
  late Map result;

  final List<String?> errors = [];
  final _formKey = GlobalKey<FormState>();
  final _formAccountKey = GlobalKey<FormState>();

  String? _refreshToken;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          buildWelcomeText(),
          const SizedBox(height: 30),
          const Text(
            "Đăng nhập vào ứng dụng Coka",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xff52616b)),
          ),
          const SizedBox(height: 10),

          Form(key: _formAccountKey, child: buildUserNameTextFormField()),
          // Form(key: _formPassKey, child: buildPassTextFormField()),
          // buildForgotPassText(context),
          FormError(errors: errors),
          const SizedBox(height: 20),

          buildLoginBtn(context),
          const Padding(
            padding: EdgeInsets.only(bottom: 12.0, top: 40),
            child: Text(
              "Đăng nhập với",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xff52616b)),
            ),
          ),
          buildSocialBtn(),

          // const SizedBox(height: 20),
          // AlreadyHaveAnAccountCheck(
          //   press: () {
          //     Get.toNamed('/signUp');
          //   },
          // ),
        ],
      ),
    );
  }

  Hero buildLoginBtn(BuildContext context) {
    return Hero(
      tag: "login_btn",
      child: DefaultButton(
        isLoading: _isLoading,
        press: !_isLoading
            ? () {
                if (_formKey.currentState!.validate() &&
                    _formAccountKey.currentState!.validate()) {
                  _formKey.currentState!.validate();
                  _formKey.currentState!.save();

                  errors.clear();
                  if (phonenumValidatorRegExp
                      .hasMatch(userNameController.text)) {
                    g.Get.to(() => const OtpScreen(),
                        arguments: AutoLoginModel(userNameController.text, ""));
                    return;
                  }
                  setState(() {
                    _isLoading = true;
                  });
                  AuthApi()
                      .userNameLogin(userNameController.text)
                      .then((value) {
                    setState(() {
                      _isLoading = false;
                    });
                    if (isSuccessStatus(value['code'])) {
                      g.Get.to(() => const OtpScreen(),
                          arguments: AutoLoginModel(userNameController.text,
                              value['content']['otpId']));
                    } else {
                      errorAlert(title: 'Lỗi', desc: value['message']);
                    }
                  });
                }
              }
            : () {},
        text: "Đăng nhập",
      ),
    );
  }

  Row buildForgotPassText(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const ForgotPassScreen();
                  },
                ),
              );
            },
            child: const Text(
              "Quên mật khẩu ?",
              style: TextStyle(color: kPrimaryColor),
            )),
      ],
    );
  }

  Padding buildPassTextFormField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextFormField(
        textInputAction: TextInputAction.done,
        obscureText: obscureText,
        cursorColor: kPrimaryColor,
        maxLength: 40,
        onChanged: (value) {
          return;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return kPassNullError;
          }
          return null;
        },
        decoration: InputDecoration(
          errorStyle: const TextStyle(height: 0),
          counterText: "",
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
                obscureText ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSocialBtn() {
    return Row(
      mainAxisAlignment: Platform.isIOS
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedBtn(
          onPressed: isSocialLoading
              ? () {
                  setState(() {
                    isSocialLoading = false;
                  });
                  fbSignUp().then((value) => setState(() {
                        isSocialLoading = true;
                      }));
                }
              : () {},
          paddingAllValue: 0,
          circular: 10,
          child: SocialButton(
              img: "assets/images/FB.png", width: Platform.isIOS ? 110 : 135),
        ),
        ElevatedBtn(
            onPressed: isSocialLoading
                ? () {
                    setState(() {
                      isSocialLoading = false;
                    });

                    ggSignUp().then((value) => setState(() {
                          isSocialLoading = true;
                        }));
                  }
                : () {},
            paddingAllValue: 0,
            circular: 10,
            child: SocialButton(
              img: "assets/images/GG.png",
              width: Platform.isIOS ? 110 : 135,
            )),
        if (Platform.isIOS)
          ElevatedBtn(
              onPressed: isSocialLoading
                  ? () {
                      setState(() {
                        isSocialLoading = false;
                      });

                      appleSignUp().then((value) => setState(() {
                            isSocialLoading = true;
                          }));
                    }
                  : () {},
              paddingAllValue: 0,
              circular: 10,
              child: const SocialButton(
                img: "assets/images/apple_logo.png",
                width: 110,
                iconSize: 18,
              )),
      ],
    );
  }

  Padding buildWelcomeText() {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 20),
      child: SvgPicture.asset("assets/icons/logo.svg"),
    );
  }

  Widget buildUserNameTextFormField() {
    return BorderTextField(
      name: "",
      nameHolder: "Email",
      validator: (value) {
        if (value!.isEmpty) {
          return "Vui lòng nhập email";
        }
        return null;
      },
      fillColor: kSecondaryColor,
      controller: userNameController,
      preIcon:
          const Padding(padding: EdgeInsets.all(15), child: Icon(Icons.person)),
    );
  }

  Future appleSignUp() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      if (credential.identityToken != null) {
        Future.delayed(const Duration(milliseconds: 50),
            () => showLoadingDialog(g.Get.context!));

        AuthApi()
            .socialLogin(credential.identityToken, 'apple')
            .then((res) async {
          if (credential.familyName != null) {
            final prefs = await SharedPreferences.getInstance();

            prefs.setString('accessToken', res['content']['accessToken']);

            FormData formData = FormData.fromMap({
              "FullName": "${credential.familyName} ${credential.givenName}",
              if (credential.email != null) "Email": "${credential.email}",
            });
            UserApi().updateProfile(formData);
          }
          await _login(res, isApple: true);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future fbSignUp() async {
    final result = await FacebookAuth.i.login(
        permissions: ["public_profile", "email"],
        loginBehavior: LoginBehavior.katanaOnly);

    if (result.status == LoginStatus.success) {
      final userData = await FacebookAuth.i.getUserData(
        fields: "email,name,id,picture.width(200)",
      );
      accessToken = result.accessToken!.token;
      Future.delayed(const Duration(milliseconds: 50),
          () => showLoadingDialog(g.Get.context!));
      AuthApi().socialLogin(accessToken, 'facebook').then((res) async {
        await _login(res);
        FacebookAuth.i.logOut();
      });
    }
  }

  Future ggSignUp() async {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      Future.delayed(const Duration(milliseconds: 50),
          () => showLoadingDialog(g.Get.context!));
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      log(googleSignInAuthentication.accessToken!);
      AuthApi()
          .socialLogin(googleSignInAuthentication.accessToken, 'google')
          .then((res) async {
        await _login(res);
        googleSignIn.signOut();
      });
    }
  }

  Future<void> _login(res, {bool? isApple}) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      if (res['code'] == 0) {
        prefs.setString('accessToken', res['content']['accessToken']);
        prefs.setString('refreshToken', res['content']['refreshToken']);
        var response = await UserApi().getProfile();
        g.Get.back();
        if (isSuccessStatus(response['code'])) {
          sendToken();
          final organList = await fetchOrganList();
          if (organList.length == 0) {
            return g.Get.to(() => const RegSuccessPage());
          }
          prefs.setString('oData', jsonEncode(organList[0]));
        }
        g.Get.offNamed('/main');
      } else {
        errorAlert(title: 'Thất bại', desc: res['message']);
      }
    } catch (e) {
      g.Get.back();
      errorAlert(title: "Lỗi", desc: "Đã có lỗi xảy ra xin vui lòng thử lại");
    }
  }

  void _toggle() {
    setState(() {
      obscureText = !obscureText;
    });
  }

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
}
