import 'package:coka/api/fb.dart';
import 'package:coka/components/elevated_btn.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../../../api/api_url.dart';
import '../../../components/loading_dialog.dart';

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  final Function? onWebClosed;

  MyChromeSafariBrowser({this.onWebClosed});

  @override
  void onOpened() {}

  @override
  void onClosed() {
    if (onWebClosed != null) {
      onWebClosed!();
    }
  }
}

class ChannelItem extends StatelessWidget {
  final String name;

  const ChannelItem({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return ElevatedBtn(
        paddingAllValue: 8,
        onPressed: () async {
          if (name == 'Facebook') {
            final result = await FacebookAuth.i.login(permissions: [
              "public_profile",
              "email",
              "openid",
              "pages_show_list",
              "pages_messaging",
              "instagram_basic",
              "instagram_manage_messages",
              "pages_read_engagement",
              "pages_manage_metadata",
              "pages_read_user_content",
              "pages_manage_engagement"
            ]);
            FbApi()
                .fbGetLongAccessToken(result.accessToken!.token)
                .then((value) {
              Future.delayed(const Duration(milliseconds: 50),
                  () => showLoadingDialog(Get.context!));
            });
          } else if (name == 'Zalo OA') {
            HomeController homeController = Get.put(HomeController());
            final webController = MyChromeSafariBrowser();
            // webController.open(
            //   url: WebUri.uri(Uri.parse(
            //     '${apiBaseUrl}api/v1/auth/zalo/message?accessToken=${await getAccessToken()}&projectId=${homeController.workGroupCardDataValue['id']}&redirectUrl=aHR0cHM6Ly9jaGF0LmF6dmlkaS52bi9yZXN1bHQ=',
            //   )),
            // );
          }
        },
        circular: 5,
        child: Row(
          children: [
            const Icon(
              Icons.add,
              size: 30,
              color: Color(0xFF565E6C),
            ),
            const SizedBox(
              width: 6,
            ),
            Text(
              name,
              style: const TextStyle(fontSize: 16, color: Color(0xFF565E6C)),
            )
          ],
        ));
  }
}
