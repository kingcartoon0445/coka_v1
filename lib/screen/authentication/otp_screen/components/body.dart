import 'dart:async';
import 'dart:convert';

import 'package:coka/api/auth.dart';
import 'package:coka/api/user.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/main.dart';
import 'package:coka/screen/authentication/register_screen/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../components/loading_dialog.dart';
import '../../../../constants.dart';
import '../../register_screen/org_page.dart';
import 'otp_form.dart';

class Body extends StatefulWidget {
  final String phone;
  final String otpId;

  const Body({super.key, required this.phone, required this.otpId});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String? otpCode;
  int secondsRemaining = 45;
  bool enableResend = false;
  Timer? timer;
  String vId = "";

  @override
  initState() {
    super.initState();
    otpCode = widget.otpId;
    if (phonenumValidatorRegExp.hasMatch(widget.phone)) {
      verifyPhoneNumber(widget.phone);
    }
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

  Future verifyPhoneNumber(phone) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      phoneNumber: '+84$phone',
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        print("Lỗi: ${e.message!}");
      },
      codeSent: (String verificationId, int? resendToken) async {
        vId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 130, bottom: 60),
                child: Text(
                  "Đăng nhập nhanh chóng",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                      fontSize: 24),
                ),
              ),
              Text(
                "Mã OTP đã được gửi đến số điện thoại hoặc email\n${widget.phone.replaceRange(3, 7, "*****")}",
                textAlign: TextAlign.center,
              ),
              OtpForm(onSubmit: (value) async {
                if (phonenumValidatorRegExp.hasMatch(widget.phone)) {
                  print("đang xác minh OTP bằng sdt");
                  showLoadingDialog(context);
                  PhoneAuthCredential credential = PhoneAuthProvider.credential(
                      verificationId: vId, smsCode: value);

                  // Sign the user in (or link) with the credential
                  await FirebaseAuth.instance
                      .signInWithCredential(credential)
                      .then((value) async {
                    final accessToken =
                        await FirebaseAuth.instance.currentUser!.getIdToken();
                    AuthApi()
                        .socialLogin(accessToken, 'firebase')
                        .then((res) async {
                      Get.back();
                      final prefs = await SharedPreferences.getInstance();
                      try {
                        if (res['code'] == 0) {
                          prefs.setString(
                              'accessToken', res['content']['accessToken']);
                          prefs.setString(
                              'refreshToken', res['content']['refreshToken']);
                          var response = await UserApi().getProfile();
                          if (isSuccessStatus(response['code'])) {
                            sendToken();
                            final organList = await fetchOrganList();

                            if (response["content"]["fullName"] ==
                                response["content"]["phone"]) {
                              return Get.to(() => const RegisterProfilePage(
                                    isUpdateProfile: false,
                                  ));
                            } else if (organList.length == 0) {
                              return Get.to(() => const RegisterOrgPage(
                                    isPersonal: true,
                                  ));
                            }
                            prefs.setString('oData', jsonEncode(organList[0]));
                          }
                          Get.offNamed('/main');
                        } else {
                          errorAlert(title: 'Thất bại', desc: res['message']);
                        }
                      } catch (e) {
                        Get.back();
                        errorAlert(
                            title: "Lỗi",
                            desc: "Đã có lỗi xảy ra xin vui lòng thử lại");
                      }
                    });
                  }).catchError((e) {
                    Get.back();
                    errorAlert(title: "Lỗi", desc: "Mã OTP không đúng");
                  });
                } else {
                  loginWithMail(context, value);
                }
              }),
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
                      style: const TextStyle(color: Colors.black, fontSize: 10),
                    )
                  : const SizedBox(),
              SizedBox(
                height: Get.height * 0.25,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loginWithMail(BuildContext context, value) {
    showLoadingDialog(context);
    AuthApi().verifyOtp(widget.otpId, value).then((res) async {
      Get.back();
      if (isSuccessStatus(res['code'])) {
        final prefs = await SharedPreferences.getInstance();

        prefs.setString('accessToken', res['metadata']['accessToken']);
        prefs.setString('refreshToken', res['metadata']['refreshToken']);

        var response = await UserApi().getProfile();
        if (isSuccessStatus(response['code'])) {
          sendToken();
          prefs.setString('uid', response['content']['id']);
          prefs.setString('userData', jsonEncode(response['content']));
          if (response['content']["fullName"] == response['content']["email"] ||
              response['content']["fullName"] == response['content']["phone"]) {
            return Get.toNamed("/register");
          }
          final organList = await fetchOrganList();
          if (organList.length == 0) {
            return Get.to(() => const RegisterOrgPage(
                  isPersonal: true,
                ));
          }
          prefs.setString('oData', jsonEncode(organList[0]));
        }
        Get.offAllNamed('/main');
      } else {
        errorAlert(title: 'Lỗi', desc: res['message']);
      }
    });
  }

  Future<void> _resendCode() async {
    if (enableResend) {
      if (phonenumValidatorRegExp.hasMatch(widget.phone)) {
        verifyPhoneNumber(widget.phone);
      } else {
        final res = await AuthApi().resendOtp(otpCode!);
        if (isSuccessStatus(res["code"])) {
          otpCode = res["content"]["otpId"];
        } else {
          errorAlert(title: "Thất bại", desc: res["message"]);
        }
      }
    }

    setState(() {
      secondsRemaining = 60;
      enableResend = false;
    });
  }

  @override
  dispose() {
    timer!.cancel();
    super.dispose();
  }
}
