import 'dart:convert';

import 'package:coka/constants.dart';
import 'package:coka/screen/crm_omnichannel/components/page_item.dart';
import 'package:coka/screen/crm_omnichannel/crm_omnichannel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../components/elevated_btn.dart';
import 'components/category.dart';
import 'components/channel_item.dart';

final pageList = <Map<String, dynamic>>[
  {
    "name": 'Essensia Nam Sai Gon A A A A',
    "ava": base64Decode(defaultAvatar),
    "channel": "Facebook"
  },
  {
    "name": 'Essensia Nam Sai Gon',
    "ava": base64Decode(defaultAvatar),
    "channel": "Zalo OA"
  },
  {
    "name": 'Essensia Nam Sai Gon',
    "ava": base64Decode(defaultAvatar),
    "channel": "TikTok"
  }
];

class CrmOmnichannelPage extends StatelessWidget {
  const CrmOmnichannelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CrmOmnichannelController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Omnichannel',
            style: TextStyle(
                color: Color(0xFF171A1F),
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          leading: ElevatedBtn(
              onPressed: () {
                Get.back();
              },
              circular: 30,
              paddingAllValue: 15,
              child: SvgPicture.asset(
                'assets/icons/back_arrow.svg',
                height: 30,
                width: 30,
              )),
          actions: [
            ElevatedBtn(
                onPressed: () {
                  Get.bottomSheet(Wrap(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12,
                            vertical: 24),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16))),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ChannelItem(name: 'Facebook',),
                            ChannelItem(name: 'Zalo OA',),
                            ChannelItem(name: 'Tiktok',),
                          ],
                        ),
                      ),
                    ],
                  ), isScrollControlled: true,);
                },
                circular: 50,
                paddingAllValue: 14,
                child: const Icon(
                  Icons.add,
                  color: Color(0xFFf7706e),
                  size: 30,
                )),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only( right: 23, left: 23),
          child: Column(
            children: [
              SizedBox(
                height: 46,
                child: Center(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: channelList.length,
                    itemBuilder: (context, index) =>
                        BuildChannelCategory(index: index),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  itemCount: channelList.length,
                  onPageChanged: (index) {
                    controller.currentPage.value = index;
                    controller.update();
                  }, itemBuilder: (BuildContext context, int index) {
                  return ListView.builder(
                    itemCount: controller.hubGroup[channelList[index].toLowerCase().replaceFirst('tất cả', 'all')]?.length??0,
                    shrinkWrap: true,
                    itemBuilder: (context, i) {
                      return AnimationConfiguration.staggeredList(
                        position: i,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                              child: PageItem(
                                dataItem: controller.hubGroup[channelList[index].toLowerCase().replaceFirst('tất cả', 'all')][i],)),
                        ),
                      );
                    },);
                },

                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
