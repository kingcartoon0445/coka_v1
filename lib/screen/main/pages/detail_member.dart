import 'package:coka/api/user.dart';
import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/elevated_btn.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class DetailMember extends StatefulWidget {
  final Map dataItem;
  final bool isMyProfile;

  const DetailMember(
      {super.key, required this.dataItem, required this.isMyProfile});

  @override
  State<DetailMember> createState() => _DetailMemberState();
}

class _DetailMemberState extends State<DetailMember> {
  var userItem = {};
  final homeController = Get.put(HomeController());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userItem = widget.isMyProfile ? homeController.userData : widget.dataItem;
    if (!widget.isMyProfile) fetchDetailUser();
  }

  Future fetchDetailUser() async {
    UserApi().getUserProfile(userItem["profileId"]).then((res) {
      if (isSuccessStatus(res["code"])) {
        setState(() {
          userItem = res["content"];
        });
      } else {
        errorAlert(title: "Lỗi", desc: res["message"]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (controller) {
      return Scaffold(
        appBar: buildAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeader(userItem),
                const SizedBox(
                  height: 20,
                ),
                buildDescription(userItem),
                const SizedBox(
                  height: 20,
                ),
                buildProfileCard(
                    name: "Kinh nghiệm",
                    onAddPressed: () {},
                    title: "Bạn chưa cập nhật kinh nghiệm",
                    subtitle: 'Kinh nghiệm của bạn sẽ được xuất hiện tại dây'),
                const SizedBox(
                  height: 20,
                ),
                buildProfileCard(
                    name: "Thành tích",
                    onAddPressed: () {},
                    title: "Bạn chưa cập nhật thành tích",
                    subtitle: 'Thành tích của bạn sẽ được xuất hiện tại dây'),
                const SizedBox(
                  height: 20,
                ),
                buildProfileCard(
                    name: "Tin đăng",
                    onAddPressed: () {},
                    title: "Bạn chưa có tin nào",
                    subtitle: 'Tin đăng của bạn sẽ được xuất hiện tại đây'),
                const SizedBox(
                  height: 20,
                ),
                buildProfileCard(
                    name: "Sản phẩm",
                    onAddPressed: () {},
                    title: "Bạn chưa có sản phẩm nào",
                    subtitle: 'Sản phẩm của bạn sẽ được xuất hiện tại đây'),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget buildProfileCard(
      {required String name,
      required String title,
      required String subtitle,
      required VoidCallback onAddPressed}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2329)),
              ),
              const Spacer(),
              ElevatedBtn(
                  paddingAllValue: 1,
                  onPressed: onAddPressed,
                  circular: 50,
                  child: const Icon(Icons.add)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  title,
                  style: const TextStyle(
                      color: Color(0xFF1F2329), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  subtitle,
                  style:
                      const TextStyle(color: Color(0xFF48454E), fontSize: 12),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Column buildDescription(Map<dynamic, dynamic> userItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Mô tả",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xB2000000)),
        ),
        const SizedBox(
          height: 6,
        ),
        Text(
          userItem["description"] ?? "Không có mô tả nào ở đây",
          style: const TextStyle(fontSize: 12, color: Color(0xB2000000)),
        ),
      ],
    );
  }

  Row buildHeader(Map<dynamic, dynamic> userItem) {
    return Row(
      children: [
        userItem["avatar"] == null
            ? createCircleAvatar(
                name: userItem["fullName"], radius: 42, fontSize: 25)
            : Container(
                height: 84,
                width: 84,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0x663949AB), width: 1),
                    color: Colors.white),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: getAvatarWidget(userItem["avatar"]),
                ),
              ),
        const SizedBox(
          width: 16,
        ),
        SizedBox(
          height: 95,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                userItem["fullName"] ?? "",
                style: const TextStyle(
                    color: Color(0xFF1F2329),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              if (userItem["typeOfEmployee"] != null)
                Text(
                  getEmployee(userItem["typeOfEmployee"] ?? ""),
                  style:
                      const TextStyle(color: Color(0xB2000000), fontSize: 12),
                ),
              Row(
                children: [
                  const Icon(Icons.mail_outline, size: 18),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    userItem["email"] ?? "Chưa có email",
                    style:
                        const TextStyle(color: Color(0xB2000000), fontSize: 11),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 18),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    userItem["phone"] ?? "Chưa có sđt",
                    style:
                        const TextStyle(color: Color(0xB2000000), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFAF8FD),
      title: const Text(
        "Thông tin cá nhân",
        style: TextStyle(
            color: Color(0xFF1F2329),
            fontSize: 20,
            fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      automaticallyImplyLeading: true,
      actions: [
        if (widget.isMyProfile)
          MenuAnchor(
              builder: (context, controller, child) {
                return InkWell(
                  onTap: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  child: const Icon(
                    Icons.more_vert,
                    size: 30,
                  ),
                );
              },
              menuChildren: [
                MenuItemButton(
                  leadingIcon: const Icon(Icons.edit_note),
                  onPressed: () {
                    Get.toNamed("/updateProfile");
                  },
                  child: const Text(
                    "Chỉnh sửa thông tin",
                    style: TextStyle(color: Colors.black),
                  ),
                )
              ]),
        const SizedBox(
          width: 10,
        )
      ],
    );
  }
}
