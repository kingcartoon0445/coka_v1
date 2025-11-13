import 'package:coka/screen/crm_conversation/crm_conversation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../components/elevated_btn.dart';

final categories = [
  ['Hành trình', 'assets/icons/flag.svg'],
  ['Inbox', 'assets/icons/inbox_icon.svg'],
  ['Bình luận', 'assets/icons/arrow_down.svg']
];

class BuildConversationCategory extends StatelessWidget {
  final int index;

  const BuildConversationCategory({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CrmConversationController>(
      builder: (controller) {
        return ElevatedBtn(
          paddingAllValue: 0,
          circular: 20,
          onPressed: () {
            controller.currentPage.value = index;
            controller.pageController.jumpToPage(index);
          },
          child: Container(
            width: (Get.width - 40) / 3,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: controller.currentPage.value == index
                  ? const Color(0xFFF7706E)
                  : Colors.transparent,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  categories[index][1],
                  color: controller.currentPage.value == index
                      ? Colors.white
                      : const Color(0xFFF7706E),
                  width: 15,
                  height: 15,
                ),
                const SizedBox(
                  width: 2,
                ),
                Text(
                  categories[index][0],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: controller.currentPage.value == index
                        ? Colors.white
                        : const Color(0xFFF7706E),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
