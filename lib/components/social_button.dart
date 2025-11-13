
import 'package:flutter/material.dart';


class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    this.img, required this.width, this.iconSize,


  });
  final String? img;
  final double? iconSize;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            spreadRadius: 3,
            blurRadius: 8,
            offset: const Offset(0, 4), // changes position of shadow
          ),
        ],
      ),
        child: Center(
          child:
              Image.asset(
                img!,
                height: iconSize??22,
              ),
          ),
        );
  }
}
