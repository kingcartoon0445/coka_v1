import 'package:coka/screen/crm_automation/components/add_applet/add_applet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CardItem extends StatelessWidget {
  final VoidCallback onPressed;
  final String id;
  const CardItem(
      {super.key,
      required this.onPressed,
      required this.id});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: triggerUiData[id]!["id"]!,
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
              backgroundColor: triggerUiData[id]!["bgColor"] as Color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          child: Wrap(
            children: [
              Column(
                children: [
                  SvgPicture.asset(triggerUiData[id]!["iconPath"] as String, color: Colors.white, width: 70),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    triggerUiData[id]!["name"] as String,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  )
                ],
              ),
            ],
          )),
    );
  }
}
