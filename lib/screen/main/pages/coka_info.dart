import 'package:flutter/material.dart';

final infoData = [
  {
    "title": "CoKa",
    "subtitle": "Ứng dụng đa chức năng dành cho Bất động sản Giúp: ",
    "detail": [
      "Tìm kiếm khách hàng",
      "Quản lý khách hàng",
      "Chăm sóc khách hàng",
      "Bán hàng"
    ],
  },
  {
    "title": "Coka MANG LẠI CHO BẠN NHỮNG GÌ?",
    "subtitle": "",
    "detail": [
      "Hàng nghìn dự án và hàng trăm nghìn sản phẩm bất động sản",
      "Mạng lưới cộng đồng môi giới có mặt ở 63 tỉnh thành và nước ngoài sở hữu mối quan hệ với khách hàng có nhu cầu mua bán sản phẩm BĐS vô cùng lớn",
      "Linh hoạt, có thể làm việc mọi lúc mọi nơi",
      "Các agent có thể trao đổi nguồn hàng, giới thiệu khách hàng cho nhau",
      "Cung cấp hệ thống các công cụ quản lý (Tool) có thể sử dụng ngay để quản lý sản phẩm, bán hàng, chiến dịch marketing, đội nhóm, chăm sóc khách hàng",
      "Hệ thống đào tạo bài bản & chuyên sâu: Giúp môi giới nắm bắt được lộ trình nghề agent và nâng cấp bản thân: Thương hiệu cá nhân. Sale & marketing",
    ],
  }
];

class CokaInfo extends StatelessWidget {
  const CokaInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: Offset(0, 2))
                ]),
            child: Wrap(
              children: [
                Column(
                  children: [
                    ...infoData.map((Map e) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e["title"],
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          if (e["subtitle"] != "")
                            Text(
                              e["subtitle"],
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ...e["detail"].map((String x) => Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        right: 8, top: 8, left: 8),
                                    child: const Icon(
                                      Icons
                                          .fiber_manual_record, // Use a bullet point icon
                                      size: 6,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      x,
                                      style: const TextStyle(
                                        height: 1.7,
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ))
                        ],
                      );
                    })
                  ],
                ),
              ],
            ),
          )),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFAF8FD),
      title: const Text(
        "Giới thiệu về CoKa",
        style: TextStyle(
            color: Color(0xFF1F2329),
            fontSize: 20,
            fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      automaticallyImplyLeading: true,
    );
  }
}
