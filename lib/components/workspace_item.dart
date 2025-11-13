import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/elevated_btn.dart';
import 'package:coka/constants.dart';
import 'package:flutter/material.dart';

class WorkspaceItem extends StatelessWidget {
  final Map dataItem;
  final bool? isShort;
  final VoidCallback onTap;

  const WorkspaceItem(
      {super.key, required this.dataItem, required this.onTap, this.isShort});

  @override
  Widget build(BuildContext context) {
    return ElevatedBtn(
      onPressed: onTap,
      circular: 0,
      paddingAllValue: 0,
      child: Container(
        padding:
            const EdgeInsets.only(bottom: 10, left: 16, top: 10, right: 16),
        child: Column(
          children: [
            Row(
              children: [
                dataItem["avatar"] == null
                    ? createCircleAvatar(name: dataItem["name"], radius: 20)
                    : Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0x663949AB), width: 1),
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
                      dataItem["name"],
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      dataItem["scope"] == 0 ? "Riêng tư" : "Công khai",
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.3), fontSize: 13),
                    ),
                  ],
                ),
                const Spacer(),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
            if (!(isShort ?? false))
              const SizedBox(
                height: 15,
              ),
            if (!(isShort ?? false))
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        "${dataItem["totalContact"] ?? 0}",
                        style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Khách hàng",
                        style:
                            TextStyle(color: Color(0x99646A73), fontSize: 12),
                      )
                    ],
                  ),
                  const Column(
                    children: [
                      Text(
                        "0",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Nhu cầu",
                        style:
                            TextStyle(color: Color(0x99646A73), fontSize: 12),
                      )
                    ],
                  ),
                  const Column(
                    children: [
                      Text(
                        "0",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Sản phẩm",
                        style:
                            TextStyle(color: Color(0x99646A73), fontSize: 12),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "${dataItem["totalMember"] ?? 0}",
                        style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Thành viên",
                        style:
                            TextStyle(color: Color(0x99646A73), fontSize: 12),
                      )
                    ],
                  ),
                ],
              ),
            if (!(isShort ?? false))
              const SizedBox(
                height: 10,
              ),
          ],
        ),
      ),
    );
  }
}
