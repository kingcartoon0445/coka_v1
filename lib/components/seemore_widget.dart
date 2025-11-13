import 'package:flutter/material.dart';

class SeeMore extends StatelessWidget {
  final VoidCallback onTap;
  const SeeMore({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
        child: const Column(
          children: [
            Divider(
              height: 1,
              color: Color(0xFFFAF8FD),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    "Xem tất cả",
                    style: TextStyle(
                        color: Color(0xB2000000),
                        fontSize: 14),
                  ),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
