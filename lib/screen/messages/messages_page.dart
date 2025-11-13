import 'package:coka/components/auto_avatar.dart';
import 'package:coka/api/conversation.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/components/drawer.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/main/pages/notification.dart';
import 'package:coka/screen/workspace/pages/chat_conv.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'messages_controller.dart';

class MessagesPage extends GetView<MessagesController> {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
    Get.put(MessagesController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: scaffoldKey,
        drawer: HomeDrawer(
          onCloseDrawer: () => scaffoldKey.currentState?.closeDrawer(),
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GetBuilder<HomeController>(
                  builder: (homeController) => GestureDetector(
                    onTap: () {
                      if (scaffoldKey.currentState != null) {
                        scaffoldKey.currentState!.openDrawer();
                      }
                    },
                    child: homeController.userData["avatar"] == null
                        ? createCircleAvatar(
                            name: homeController.userData["fullName"] ?? '',
                            radius: 20)
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
                              child: getAvatarWidget(
                                  homeController.userData["avatar"]),
                            ),
                          ),
                  ),
                ),
              ),
              const Text(
                'Tin nhắn',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2329)),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Get.to(() => const NotificationPage());
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            dividerColor: Colors.transparent,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(
                child: Row(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Tất cả',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 6),
                        _TabCount(count: '54'),
                      ],
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Facebook Messenger',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Zalo OA",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMessageList(),
            _buildMessageList(),
            _buildMessageList(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: const Color(0xFF6C5CE7),
          child: const Icon(Icons.edit, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return Obx(() => controller.isRoomFetching.value
        ? const ListPlaceholder(
            length: 10,
            avatarSize: 44,
          )
        : RefreshIndicator(
            onRefresh: controller.onRefresh,
            child: SingleChildScrollView(
              controller: controller.sc,
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: Get.height - 120),
                child: controller.isRoomEmpty.value
                    ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 30.0, right: 30, top: 40),
                            child: Image.asset(
                              "assets/images/null_multi_connect.png",
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Hiện chưa có tin nhắn nào",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                        ],
                      )
                    : Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: controller.roomList.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final roomData = controller.roomList[index];
                              final title = roomData["personName"];
                              final subtitle = roomData["snippet"];
                              final avatar = roomData["personAvatar"];
                              final updatedTime = diffFunc(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      roomData["updatedTime"]));
                              bool isRead = roomData["isRead"];

                              return ListTile(
                                onTap: () async {
                                  // Mark as read on server if currently unread, then navigate
                                  if (roomData["isRead"] == false) {
                                    final res =
                                        await ConvApi().setRead(roomData["id"]);
                                    if (isSuccessStatus(res["code"])) {
                                      roomData["isRead"] = true;
                                      controller.roomList.refresh();
                                    }
                                  }
                                  Get.to(() => ChatConvPage(
                                        pageAvatar: null,
                                        pageName: null,
                                        provider: null,
                                        personAvatar: avatar,
                                        convId: roomData["id"],
                                        personName: title,
                                        personId: roomData["personId"],
                                      ));
                                },
                                title: Text(title,
                                    style: TextStyle(
                                        fontWeight:
                                            isRead ? null : FontWeight.bold)),
                                subtitle: Text(subtitle ?? "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                            isRead ? null : FontWeight.bold)),
                                trailing: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(updatedTime,
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: isRead
                                                ? null
                                                : FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Container(
                                      height: 16,
                                      width: 16,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: !isRead
                                              ? const Color(0xFF5C33F0)
                                              : Colors.transparent),
                                    )
                                  ],
                                ),
                                leading: avatar == null
                                    ? createCircleAvatar(
                                        name: title, radius: 22)
                                    : CircleAvatar(
                                        backgroundImage: getAvatarProvider(
                                            avatar ?? defaultAvatar),
                                        radius: 22,
                                      ),
                              );
                            },
                          ),
                          if (controller.isRoomLoadMore.value)
                            const Positioned(
                                bottom: 5, child: CircularProgressIndicator())
                        ],
                      ),
              ),
            ),
          ));
  }
}

class _TabCount extends StatelessWidget {
  final String count;

  const _TabCount({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 25),
      height: 16,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5252),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Center(
        child: Text(
          count,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }
}
