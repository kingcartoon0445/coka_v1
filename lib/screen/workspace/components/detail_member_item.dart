import 'package:coka/constants.dart';
import 'package:flutter/material.dart';

class DetailMemberItem extends StatelessWidget {
  final Map dataItem;
  const DetailMemberItem({super.key, required this.dataItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 8, left: 16, top: 8, right: 4),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x663949AB), width: 1),
                color: Colors.white),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: getAvatarWidget(dataItem["avatar"]),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dataItem["profile"]["fullName"] ?? "",
                style: const TextStyle(
                    color: Color(0xFF1F2329),
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                getEmployee(dataItem["typeOfEmployee"]),
                style: TextStyle(
                    color: Colors.black.withOpacity(0.7), fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.more_vert,
                size: 30,
              ))
        ],
      ),
    );
  }
}
