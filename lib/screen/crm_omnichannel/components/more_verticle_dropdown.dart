

import 'package:coka/screen/crm_omnichannel/components/update_feed_mess_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class MoreVerticalDropdown extends StatefulWidget {
  final Map dataItem;

  const MoreVerticalDropdown({super.key, required this.dataItem});

  @override
  State<MoreVerticalDropdown> createState() => _MoreVerticalDropdownState();
}

class _MoreVerticalDropdownState extends State<MoreVerticalDropdown> {

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 30),
      onSelected: (value) {
        if (value == 'Status') {
          setState(() {
            showModalBottomSheet(builder:(context) => UpdateFeedMessBottomSheet(dataItem: widget.dataItem),isScrollControlled: true, context: context,backgroundColor: Colors.white,
              constraints: BoxConstraints(maxHeight: Get.height - 45),
              shape: const RoundedRectangleBorder( // <-- SEE HERE
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20.0),
                ),
              ),);
          });

        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'Status',
          child: Row(
            children: [
              Icon(Icons.dataset_linked),
              SizedBox(width: 8.0),
              Text('Trạng thái kết nối'),
            ],
          ),
        ),

      ],
      child: const Icon(Icons.more_vert),
    );
  }
}
