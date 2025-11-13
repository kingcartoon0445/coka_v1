import 'package:coka/components/auto_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants.dart';

class HeaderCard extends StatelessWidget {
  final Map data;
  const HeaderCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: data.isEmpty
          ? buildShimmer()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    data["avatar"] == null
                        ? createRoundedAvatar(name: data["name"])
                        : Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.transparent,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: getAvatarWidget(data["avatar"]),
                            ),
                          ),
                    const SizedBox(
                      width: 12,
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 100),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ConstrainedBox(
                                constraints:
                                    BoxConstraints(maxWidth: Get.width - 200),
                                child: Text(
                                  data["name"],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              if (data["subscription"] != "PERSONAL")
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: data["status"] == 1
                                      ? Tooltip(
                                          message: "Đã xác minh",
                                          triggerMode: TooltipTriggerMode.tap,
                                          child: SvgPicture.asset(
                                            "assets/icons/verify_icon.svg",
                                            width: 18,
                                            height: 18,
                                          ),
                                        )
                                      : Tooltip(
                                          message: "Chưa được xác minh",
                                          triggerMode: TooltipTriggerMode.tap,
                                          child: SvgPicture.asset(
                                            "assets/icons/unverified_icon.svg",
                                            width: 18,
                                            height: 18,
                                          ),
                                        ),
                                )
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                                color: const Color(0xFFE8F2FE),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              data["subscription"] == "PERSONAL"
                                  ? "Cá nhân"
                                  : "Doanh nghiệp",
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1F2329),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            data["website"] ?? "",
                            style: TextStyle(
                                fontSize: 14,
                                color:
                                    const Color(0xFF1F2329).withOpacity(0.7)),
                          ),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: data["memberCount"].toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: Colors.black)),
                              const TextSpan(
                                  text: " Thành viên+",
                                  style: TextStyle(
                                      color: Color(0xFF1F2329), fontSize: 11))
                            ]),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                if (data["description"] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: Text(
                      data["description"] ?? "",
                      style: const TextStyle(color: Color(0xB21E1C1C)),
                    ),
                  )
              ],
            ),
    );
  }

  Shimmer buildShimmer() {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        enabled: true,
        child: Row(
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
            ),
            const SizedBox(
              width: 14,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140,
                  height: 22,
                  color: Colors.white,
                ),
                const SizedBox(
                  height: 6,
                ),
                Container(
                  width: 40,
                  height: 16,
                  color: Colors.white,
                ),
                const SizedBox(
                  height: 6,
                ),
                Container(
                  width: 100,
                  height: 14,
                  color: Colors.white,
                ),
                const SizedBox(
                  height: 6,
                ),
                Container(
                  width: 80,
                  height: 14,
                  color: Colors.white,
                ),
              ],
            )
          ],
        ));
  }
}
