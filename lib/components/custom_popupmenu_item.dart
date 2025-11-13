import 'package:flutter/material.dart';

class CustomPopupMenuItem<T> extends PopupMenuItem<T> {
  final double width;

  CustomPopupMenuItem({
    super.key,
    required T super.value,
    required Widget child,
    this.width = 100,
  }) : super(
    child: SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,

        ],
      ),
    ),
  );
}