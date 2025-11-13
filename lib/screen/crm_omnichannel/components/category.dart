import 'package:coka/screen/crm_omnichannel/crm_omnichannel_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/elevated_btn.dart';

final channelList = ['Tất cả','Facebook','Zalo','Tiktok'];

class BuildChannelCategory extends StatelessWidget {
  final int index;
  const BuildChannelCategory({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CrmOmnichannelController>(
      builder: (controller) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  controller.currentPage.value == index
                      ? Container(
                    height: 4,
                    width: 64,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF7706E),
                        borderRadius: BorderRadius.circular(5)),
                  )
                      : Container(height: 4,),
                  ElevatedBtn(
                    paddingAllValue: 3,
                    circular: 2,
                    onPressed: () {
                      controller.currentPage.value = index;
                      controller.pageController.jumpToPage(index);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 64,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: SizedBox(
                              child: Text(
                              channelList[index],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: controller.currentPage.value == index
                                      ? const Color(0xFFF7706E)
                                      : const Color(0xFF828282),
                                ),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

  }
}

