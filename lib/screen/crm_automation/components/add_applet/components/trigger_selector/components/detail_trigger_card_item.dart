import 'package:flutter/material.dart';

import '../../../add_applet_controller.dart';

class DetailTriggerCardItem extends StatelessWidget {
  final VoidCallback onPressed;
  final String id;
  final int index;
  const DetailTriggerCardItem(
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
            backgroundColor: triggerUiData[id]!["bgColor"] as Color,
            foregroundColor: Colors.white,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: Text((triggerUiData[id]!["triggers"] as List)[index]["title"],
            textAlign: TextAlign.left,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ),
    );
  }
}
