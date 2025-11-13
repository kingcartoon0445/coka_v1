import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChatFetching extends StatelessWidget {
  const ChatFetching({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18),
      child: Row(
        children: [
          Image.asset(
            "assets/images/bot_icon.png",
            width: 30,
            height: 30,
          ),
          const SizedBox(
            width: 12,
          ),
          SpinKitThreeBounce(
            color: const Color(0xFF5C33F0).withOpacity(0.3),
            duration: const Duration(seconds: 1),
            size: 25,
          )
        ],
      ),
    );
  }
}
