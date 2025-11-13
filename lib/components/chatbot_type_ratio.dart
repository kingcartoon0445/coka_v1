import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatBotTypeRadio extends StatefulWidget {
  final String? initType;
  final Function typeFunction;
  const ChatBotTypeRadio({super.key, required this.typeFunction, this.initType});

  @override
  State<ChatBotTypeRadio> createState() => _ChatBotTypeRadioState();
}

class _ChatBotTypeRadioState extends State<ChatBotTypeRadio> {
  String? type;

  @override
  Widget build(BuildContext context) {
    type ??= widget.initType;

    return SizedBox(
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Loại chatbot",
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
                    value: "AI",
                    onChanged: (value) {
                      setState(() {
                        type = value;
                        widget.typeFunction(type);
                      });
                    },
                    groupValue: type,
                  ),
                  Text(
                    "AI",
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
                    value: "QA",
                    onChanged: (value) {
                      setState(() {
                        type = value;
                        widget.typeFunction(type);
                      });
                    },
                    groupValue: type,
                  ),
                  Text(
                    "Q&A",
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
