import 'package:coka/constants.dart';
import 'package:flutter/material.dart';

class StickAdd extends StatelessWidget {
  final bool? isEnd;
  final VoidCallback onPressed;

  const StickAdd({super.key, this.isEnd = false, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 1,
          height: 16,
          color: kTextSmallColor,
        ),
        ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(40, 40),
                maximumSize: const Size(60, 60),
                foregroundColor: Colors.black,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const CircleBorder(
                    side: BorderSide(color: kTextSmallColor, width: 1)),
                elevation: 0,
                padding: EdgeInsets.zero),
            child: const Icon(
              Icons.add,
              color: Colors.black,
            )),
        if (!isEnd!)
          Container(
            width: 1,
            height: 16,
            color: kTextSmallColor,
          ),
      ],
    );
  }
}
