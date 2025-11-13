import 'package:flutter/material.dart';

class MoreDropdown extends StatefulWidget {
  final int index;
  final Function onDeleteClick;

  const MoreDropdown(
      {super.key, required this.index, required this.onDeleteClick});

  @override
  State<MoreDropdown> createState() => _MoreDropdownState();
}

class _MoreDropdownState extends State<MoreDropdown> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 30),
      onSelected: (value) {
        if (value == 'Delete') {
          widget.onDeleteClick();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
         const PopupMenuItem<String>(
          value: 'Delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.black),
              SizedBox(width: 8.0),
              Text('Xoá'),
            ],
          ),
        ),
      ],
      child: const Icon(Icons.more_vert, color: Colors.black),
    );
  }
}
