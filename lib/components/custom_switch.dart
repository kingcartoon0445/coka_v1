import 'package:flutter/material.dart';

class SwitchRow extends StatefulWidget {
  final Function(bool) onChanged;
  const SwitchRow({
    super.key,
    required this.onChanged,
  });

  @override
  State<SwitchRow> createState() => _SwitchRowState();
}

class _SwitchRowState extends State<SwitchRow> {
  bool value1 = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Switch(
          thumbIcon: const WidgetStatePropertyAll(Icon(Icons.percent)),
          activeTrackColor: const Color(0xFF483ac1),
          value: value1,
          onChanged: (value) {
            setState(() {
              value1 = value;
            });
            widget.onChanged(value1);
          },
        ),
      ],
    );
  }
}
