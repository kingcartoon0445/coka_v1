import 'package:flutter/material.dart';

import '../constants.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    super.key,
    this.text,
    required this.press, required this.isLoading,
  });
  final String? text;
  final VoidCallback press;
  final bool isLoading ;
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(width: 190, height: 56),
      child: ElevatedButton(
        style:
        ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(10)
              ),
            ),
        ),
          onPressed: press ,
          child: Center(
            child:!isLoading? Text(
              text!,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),
            ):const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
        ),
    );
  }
}
