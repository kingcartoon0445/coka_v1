import 'package:coka/screen/crm_automation/components/add_applet/add_applet_controller.dart';
import 'package:flutter/material.dart';

class DetailActionCardItem extends StatelessWidget {
  final VoidCallback onPressed;
  final String id;
  final int index;

  const DetailActionCardItem(
      {super.key,
      required this.onPressed,
      required this.id,
      required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: actionUiData[id]!["bgColor"] as Color,
            foregroundColor: Colors.white,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: Text((actionUiData[id]!["actions"] as List)[index]["title"],
            textAlign: TextAlign.left,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ),
    );
  }
}
