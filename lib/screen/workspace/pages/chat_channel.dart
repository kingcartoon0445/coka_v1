import 'dart:convert';
import 'dart:io';

import 'package:coka/api/api_url.dart';
import 'package:coka/api/lead.dart';
import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/main/pages/web_view.dart';
import 'package:coka/screen/workspace/getx/chat_channel_controller.dart';
import 'package:coka/screen/workspace/pages/chat_room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../../../components/awesome_alert.dart';
import '../../../components/loading_dialog.dart';

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  final VoidCallback onWebClosed;

  MyChromeSafariBrowser({required this.onWebClosed});

  @override
  void onClosed() {
    onWebClosed();
    super.onClosed();
  }
}

class ChatChannelPage extends StatefulWidget {
  const ChatChannelPage({super.key});

  @override
  State<ChatChannelPage> createState() => _ChatChannelPageState();
}

class _ChatChannelPageState extends State<ChatChannelPage> {
  final homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatChannelController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text(
            "Trang kết nối",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2329)),
          ),
          centerTitle: true,
          automaticallyImplyLeading: true,
          actions: [
            IconButton(
                onPressed: () {
                  showSelectBottomsheet(context);
                },
                icon: const Icon(
                  Icons.add,
                  size: 26,
                ))
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(76.0), // Height of the search bar.
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              child: SearchBar(
                hintText: "Tìm kiếm",
                backgroundColor: WidgetStatePropertyAll(Color(0xFFF2F3F5)),
                leading: Icon(Icons.search),
              ),
            ),
          ),
          bottomOpacity:
              1.0, // Ensures the search bar stays visible when scrolling.
        ),
        body: controller.isChannelFetching.value
            ? const ListPlaceholder(
                length: 10,
                avatarSize: 44,
              )
            : RefreshIndicator(
                onRefresh: () => controller.onRefresh(),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: controller.isChannelEmpty.value
                      ? Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 30.0, right: 30, top: 40),
                              child: Image.asset(
                                "assets/images/null_multi_connect.png",
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            const Text(
                              "Hiện chưa có kết nối nào",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5C33F0)),
                                onPressed: () {
                                  showSelectBottomsheet(context);
                                },
                                child: const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 35.0),
                                  child: Text(
                                    "Liên kết",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white),
                                  ),
                                ))
                          ],
                        )
                      : ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: Get.height - 120),
                          child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final roomData = controller.channelList[index];
                                final title = roomData["name"];
                                final subtitle = roomData["provider"];
                                final avatar = roomData["avatar"];

                                var isActive =
                                    roomData["status"] == 1 ? true : false;
                                return ListTile(
                                    onTap: () {
                                      if (isActive) {
                                        Get.to(() => ChatRoomPage(
                                            pageName: title,
                                            pageAvatar: avatar,
                                            pageId:
                                                roomData["integrationAuthId"],
                                            provider: subtitle));
                                      }
                                    },
                                    title: Text(
                                      title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(subtitle),
                                    trailing: Switch(
                                      value: isActive,
                                      activeTrackColor: const Color(0xFFF07A22),
                                      onChanged: (value) {
                                        isActive = value;
                                        showLoadingDialog(context);
                                        LeadApi()
                                            .updateMessageStatus(
                                          roomData["id"],
                                          value ? 1 : 0,
                                        )
                                            .then((res) {
                                          Get.back();
                                          if (isSuccessStatus(res["code"])) {
                                            setState(() {
                                              roomData["status"] =
                                                  value ? 1 : 0;
                                            });
                                          } else {
                                            errorAlert(
                                                title: "Lỗi",
                                                desc: res["message"]);
                                          }
                                        });
                                      },
                                    ),
                                    leading: avatar == null
                                        ? createCircleAvatar(
                                            name: title, radius: 22)
                                        : Container(
                                            height: 44,
                                            width: 44,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color:
                                                        const Color(0x663949AB),
                                                    width: 1),
                                                color: Colors.white),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              child: getAvatarWidget(avatar),
                                            ),
                                          ));
                              },
                              itemCount: controller.channelList.length,
                              shrinkWrap: true),
                        ),
                ),
              ),
      );
    });
  }

  Future<List<Map<String, dynamic>>?> showSelectFacebookPagesDialog(
    BuildContext context,
    List<Map<String, dynamic>> pages,
  ) {
    return showDialog<List<Map<String, dynamic>>>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final selected = <int>{};
        bool selectAll = false;

        void toggleAll(bool v, void Function(void Function()) setState) {
          setState(() {
            selectAll = v;
            selected
              ..clear()
              ..addAll(v ? List.generate(pages.length, (i) => i) : <int>{});
          });
        }

        void toggleOne(int i, bool v, void Function(void Function()) setState) {
          setState(() {
            v ? selected.add(i) : selected.remove(i);
            selectAll = selected.length == pages.length;
          });
        }

        return StatefulBuilder(
          builder: (ctx, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 560, maxHeight: 560),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 16, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Chọn trang Facebook để kết nối',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Checkbox(
                            value: selectAll,
                            onChanged: (v) => toggleAll(v ?? false, setState),
                          ),
                          Text('Chọn tất cả (${pages.length} trang)',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: pages.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) {
                          final p = pages[i];
                          final name = (p['name'] ?? '') as String;
                          final id = (p['id']?.toString() ?? '');
                          final avatar =
                              (p['picture']?['data']?['url']) as String?;
                          final isChecked = selected.contains(i);

                          return InkWell(
                            onTap: () => toggleOne(i, !isChecked, setState),
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xFFE5E7EB)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isChecked,
                                    onChanged: (v) =>
                                        toggleOne(i, v ?? false, setState),
                                  ),
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor:
                                        Color(0xFF5C33F0).withOpacity(0.1),
                                    backgroundImage:
                                        (avatar != null && avatar.isNotEmpty)
                                            ? NetworkImage(avatar)
                                            : null,
                                    child: (avatar == null || avatar.isEmpty)
                                        ? Text(
                                            (name.isNotEmpty ? name[0] : '?')
                                                .toUpperCase(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(name,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 4),
                                        Text('ID: $id',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF6B7280))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(ctx).maybePop(),
                              child: const Text('Hủy'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: selected.isEmpty
                                  ? null
                                  : () {
                                      final chosen = selected
                                          .map((i) => pages[i])
                                          .toList();
                                      Navigator.of(ctx).maybePop(chosen);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF5C33F0),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Kết nối trang'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showSelectBottomsheet(BuildContext context) {
    final parentContext = context; // capture a stable parent context
    final connectChatList = [
      {
        "name": "Liên kết qua messenger",
        "iconPath": "assets/images/fb_messenger_icon.png",
        "onPressed": () async {
          if (Platform.isAndroid) {
            final result = await FacebookAuth.i.login(
              permissions: [
                "email",
                "openid",
                "pages_show_list",
                "pages_messaging",
                "instagram_basic",
                "leads_retrieval",
                "instagram_manage_messages",
                "pages_read_engagement",
                "pages_manage_metadata",
                "pages_read_user_content",
                "pages_manage_engagement",
                "public_profile"
              ],
            );
            if (result.status == LoginStatus.success) {
              if (!mounted) return;
              showLoadingDialog(parentContext);
              LeadApi().facebookMessageConnect(
                  {"socialAccessToken": result.accessToken!.token}).then((res) {
                Get.back();
                if (isSuccessStatus(res["code"])) {
                  final chatChannelController =
                      Get.put(ChatChannelController());
                  chatChannelController.onRefresh();
                  Get.back();
                  successAlert(
                      title: "Thành công", desc: "Đã kết nối với facebook");
                } else {
                  errorAlert(title: "Lỗi", desc: res["message"]);
                }
              });
            } else {
              errorAlert(
                  title: "Thất bại",
                  desc: "Đã có lỗi xảy ra, xin vui lòng thử lại");
            }
          } else {
            getConnectFacebookPageIOSUrl(
                    jsonDecode(await getOData())["id"], await getAccessToken())
                .then((url) {
              Navigator.of(parentContext, rootNavigator: true)
                  .push(MaterialPageRoute(
                      builder: (context) => WebViewScreen(
                          urlWebView: url,
                          onSuccess: (data) async {
                            final token = data['content'] as String;
                            final pages = await getListPageFacebook(token);
                            print("đuyasaudj" + data.toString());
                            if (pages.isEmpty) {
                              // UserNotification.showDialogNouti(context,
                              //     type: NotifyType.error,
                              //     title: 'Không có trang',
                              //     message: 'Tài khoản không có page nào');
                              return;
                            }
                            if (!mounted) return;
                            final selected =
                                await showSelectFacebookPagesDialog(
                                    parentContext, pages);
                            if (!mounted) return;
                            showLoadingDialog(parentContext);
                            if (selected != null && selected.isNotEmpty) {
                              // Lấy access tokens từ các trang đã chọn
                              final accessTokens = [
                                for (final p in selected)
                                  p['access_token'] as String,
                              ];

                              // Gọi API Facebook Lead Manual Connect
                              LeadApi().facebookLeadManualConnect({
                                "accessTokens": accessTokens,
                              }).then((res) {
                                Get.back(); // Đóng loading dialog
                                if (isSuccessStatus(res["code"])) {
                                  final chatChannelController =
                                      Get.put(ChatChannelController());
                                  chatChannelController.onRefresh();
                                  Navigator.of(parentContext,
                                          rootNavigator: true)
                                      .pop();
                                  successAlert(
                                      title: "Thành công",
                                      desc:
                                          "Đã kết nối Facebook Lead thành công");
                                } else {
                                  errorAlert(
                                      title: "Lỗi", desc: res["message"]);
                                }
                              }).catchError((error) {
                                Get.back(); // Đóng loading dialog
                                errorAlert(
                                    title: "Lỗi",
                                    desc:
                                        "Có lỗi xảy ra khi kết nối Facebook Lead");
                              });
                            }
                          })));
            });
          }
        }
      },
      {
        "name": "Liên kết qua Zalo OA",
        "iconPath": "assets/images/zalo_icon.png",
        "onPressed": () async {
          if (Platform.isIOS) {
            LeadApi().connectZaloPage();
            // return errorAlert(

            //     title: "Rất tiếc!",
            //     desc: "Tính năng này chưa được phát triển ở nền tảng iOS");
          }
          final webController = MyChromeSafariBrowser(onWebClosed: () {
            final chatChannelController = Get.put(ChatChannelController());
            chatChannelController.onRefresh();
            Get.back();
          });
          webController.open(
            url: WebUri(
              '${apiBaseUrl}api/v1/auth/zalo/message?accessToken=${await getAccessToken()}&organizationId=${jsonDecode(await getOData())["id"]}',
            ),
          );
        },
      },
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) => Wrap(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Liên kết trang",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const Divider(height: 1),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    ...connectChatList.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Card(
                          elevation: 0,
                          color: Colors.white,
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            onTap: e["onPressed"] as VoidCallback,
                            leading: Image.asset(e["iconPath"] as String,
                                width: 32, height: 32),
                            title: Text(e["name"] as String),
                          ),
                        ),
                      );
                    })
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
