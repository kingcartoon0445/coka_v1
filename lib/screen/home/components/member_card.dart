import 'package:coka/components/member_item.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/home/pages/find_member_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/placeholders.dart';
import '../../../components/seemore_widget.dart';
import 'more_member_bottomsheet.dart';

class MemberCard extends StatelessWidget {
  const MemberCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (controller) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: controller.isMemberFetching.value
            ? const MemberFetching()
            : controller.memberList.isEmpty
                ? const EmptyMember()
                : MemberList(dataList: controller.memberList),
      );
    });
  }
}

class MemberList extends StatelessWidget {
  final List dataList;
  const MemberList({super.key, required this.dataList});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: Get.width,
          child: Row(
            children: [
              const SizedBox(
                width: 14,
              ),
              const Text(
                "Nhân sự",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2329)),
              ),
              const Spacer(),
              IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                        builder: (context) => const FindMemberBottomSheet(),
                        isScrollControlled: true,
                        context: context);
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Colors.black,
                    size: 24,
                  ))
            ],
          ),
        ),
        const Divider(
          color: Color(0xFFFAF8FD),
          height: 1,
        ),
        ListView.builder(
          itemBuilder: (context, index) {
            return Column(
              children: [
                MemberItem(
                  dataItem: dataList[index],
                ),
                if (index == 3)
                  SeeMore(
                    onTap: () {
                      showMoreMember(true);
                    },
                  )
              ],
            );
          },
          itemCount: dataList.length <= 4 ? dataList.length : 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        )
      ],
    );
  }
}

class MemberFetching extends StatelessWidget {
  const MemberFetching({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: Get.width,
          child: Row(
            children: [
              const SizedBox(
                width: 14,
              ),
              const Text(
                "Nhân sự",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2329)),
              ),
              const Spacer(),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.add,
                    color: Colors.black,
                    size: 24,
                  ))
            ],
          ),
        ),
        const Divider(
          color: Color(0xFFFAF8FD),
          height: 1,
        ),
        const ListPlaceholder(
          length: 2,
          avatarSize: 40,
          contentHeight: 12,
        )
      ],
    );
  }
}

class EmptyMember extends StatelessWidget {
  const EmptyMember({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 15,
        ),
        SizedBox(
          width: Get.width,
          child: const Row(
            children: [
              SizedBox(
                width: 14,
              ),
              Text(
                "Nhân sự",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2329)),
              ),
              Spacer(),
            ],
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Image.asset("assets/images/member_empty.png"),
        const SizedBox(
          height: 10,
        ),
        const Text(
          "Hiện chưa có thành viên nào",
          style: TextStyle(fontSize: 15, color: Colors.black),
        ),
        const SizedBox(
          height: 15,
        ),
        ElevatedButton.icon(
          icon: const Icon(
            Icons.add,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (context) => const FindMemberBottomSheet(),
                isScrollControlled: true);
          },
          label: const Text(
            "Mời",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5c33f0)),
        ),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
