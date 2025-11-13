import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatBotTimeTypeRadio extends StatefulWidget {
  final int? initType;
  final Function typeFunction;
  const ChatBotTimeTypeRadio(
      {super.key, required this.typeFunction, this.initType});

  @override
  State<ChatBotTimeTypeRadio> createState() => _ChatBotTimeTypeRadioState();
}

class _ChatBotTimeTypeRadioState extends State<ChatBotTimeTypeRadio> {
  int? type;

  @override
  Widget build(BuildContext context) {
    type ??= widget.initType;

    return SizedBox(
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Số lần phản hồi",
            style: TextStyle(
                color: Color(0xFF1F2329),
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: <Widget>[
                  Radio(
                    value: 2,
                    onChanged: (value) {
                      setState(() {
                        type = value;
                        widget.typeFunction(type);
                      });
                    },
                    groupValue: type,
                  ),
                  Text(
                    "Luôn luôn",
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.7), fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              Row(
                children: <Widget>[
                  Radio(
                    value: 1,
                    onChanged: (value) {
                      setState(() {
                        type = value;
                        widget.typeFunction(type);
                      });
                    },
                    groupValue: type,
                  ),
                  Text(
                    "Chỉ lần đầu",
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.7), fontSize: 14),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
