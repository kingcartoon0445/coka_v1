import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void showLoadingDialog(BuildContext context) {
  // show the loading dialog
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return const Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // The loading indicator
                  SpinKitCircle(
                    color: Colors.white,
                    duration: Duration(milliseconds: 500),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ));
      });
}
