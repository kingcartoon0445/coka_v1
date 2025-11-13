import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RadioPrivacy extends StatefulWidget {
  final Function privacyFunction;
  final int? initPrivacy;
  const RadioPrivacy(
      {super.key, required this.privacyFunction, this.initPrivacy});

  @override
  State<RadioPrivacy> createState() => _RadioPrivacyState();
}

class _RadioPrivacyState extends State<RadioPrivacy> {
  int? privacy;
  @override
  Widget build(BuildContext context) {
    privacy ??= widget.initPrivacy;
    return SizedBox(
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Chế độ",
            style: TextStyle(
                color: Color(0xFF1F2329),
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          Row(
            children: [
              Row(
                children: <Widget>[
                  Text(
                    "Riêng tư",
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.7), fontSize: 14),
                  ),
                  Radio(
                    value: 0,
                    onChanged: (value) {
                      setState(() {
                        privacy = value;
                        widget.privacyFunction(privacy);
                      });
                    },
                    groupValue: privacy,
                  ),
                ],
              ),
              const SizedBox(
                width: 30,
              ),
              Row(
                children: <Widget>[
                  Text(
                    "Công khai",
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.7), fontSize: 14),
                  ),
                  Radio(
                    value: 1,
                    onChanged: (value) {
                      setState(() {
                        privacy = value;
                        widget.privacyFunction(privacy);
                      });
                    },
                    groupValue: privacy,
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
