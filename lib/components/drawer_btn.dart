import 'package:flutter/material.dart';

class DrawerBtn extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;
  const DrawerBtn(
      {super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 14, 16, 14),
        child: Row(
          children: [
            icon,
            const SizedBox(
              width: 10,
            ),
            Text(
              label,
              style: const TextStyle(
                  color: Color(0xFF44474F),
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}
