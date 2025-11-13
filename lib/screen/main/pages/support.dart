import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final helpCardList = [
      {
        "imgPath": "assets/images/help_create_workspace.png",
        "name": "Hướng dẫn tạo nhóm làm việc"
      },
      {
        "imgPath": "assets/images/help_add_customer.png",
        "name": "Hướng dẫn thêm khách hàng"
      },
      {
        "imgPath": "assets/images/help_create_workspace.png",
        "name": "Hướng dẫn tạo nhóm làm việc"
      },
      {
        "imgPath": "assets/images/help_use_multichannel.png",
        "name": "Hướng dẫn sử dụng đa kênh"
      },
      {
        "imgPath": "assets/images/help_post_demand.png",
        "name": "Hướng dẫn đăng nhu cầu"
      },
      {
        "imgPath": "assets/images/help_post_product.png",
        "name": "Hướng dẫn đăng sản phẩm"
      },
      {
        "imgPath": "assets/images/help_create_team.png",
        "name": "Hướng dẫn tạo đội sale"
      },
    ];
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 95.0),
                  child: Container(
                    width: double.infinity,
                    height: 140,
                    padding: const EdgeInsets.only(top: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE3DFFF),
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(16)),
                    ),
                    child: const Text("Trung tâm hỗ trợ",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                  ),
                ),
                Positioned(
                    bottom: 0,
                    left: 16,
                    right: 16,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x1F0E1E25),
                                blurRadius: 4,
                                spreadRadius: 0,
                                offset: Offset(0, 2))
                          ]),
                      child: Column(
                        children: [
                          const Text(
                            "Nếu bạn cần hỗ trợ nhanh vui lòng gọi vào số hotline: 0947 984 684 hoặc gửi tin nhắn để được tư vấn ngay lập tức.",
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    var url = Uri.parse("tel:0947 984 684");
                                    if (!await launchUrl(url)) {
                                      throw Exception('Could not launch $url');
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFF5A48F1),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.call_outlined,
                                    color: Color(0xFF5A48F1),
                                    size: 16,
                                  ),
                                  label: const Text(
                                    "Gọi",
                                    style: TextStyle(
                                        color: Color(0xFF5A48F1),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                  width: 16), // Khoảng cách 16px giữa hai nút
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    var url = Uri.parse("sms:0947 984 684");
                                    if (!await launchUrl(url)) {
                                      throw Exception('Could not launch $url');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5A48F1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.message_outlined,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    "Gửi tin nhắn",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ))
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Hướng dẫn",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    itemCount: helpCardList.length,
                    controller: PageController(
                      viewportFraction: 0.9,
                    ),
                    itemBuilder: (context, index) {
                      final imgPath = helpCardList[index]["imgPath"];
                      final name = helpCardList[index]["name"];
                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: buildHelpCardItem(imgPath, name));
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Container buildHelpCardItem(imgPath, name) {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: const Color(0xFFE3DFFF),
          boxShadow: const [
            BoxShadow(
                color: Color(0x1A000000),
                spreadRadius: 0,
                blurRadius: 8,
                offset: Offset(0, 2))
          ]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imgPath,
            width: 150,
            fit: BoxFit.cover,
          ),
          const SizedBox(
            width: 10,
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                name,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
