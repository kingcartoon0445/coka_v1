import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';

class UpdateAlert extends StatelessWidget {
  const UpdateAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset("assets/images/update_alert.png")),
            Padding(
              padding: const EdgeInsets.only(
                  right: 16.0, left: 16.0, top: 25, bottom: 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: () {
                      Get.back();
                      InAppReview.instance.openStoreListing(
                        appStoreId: "6447948044",
                      );
                    },
                    style: ButtonStyle(
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                        padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(vertical: 10)),
                        backgroundColor:
                            const WidgetStatePropertyAll(Color(0xFF554fe8))),
                    child: const Text(
                      "Cập nhật",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
