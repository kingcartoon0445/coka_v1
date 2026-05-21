import 'dart:async';
import 'dart:convert';

import 'package:coka/api/conversation.dart';
import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/workspace/pages/chat_conv.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatRoomPage extends StatefulWidget {
  final String? pageName, pageAvatar, pageId, provider;

  const ChatRoomPage(
      {super.key,
      required this.pageName,
      required this.pageAvatar,
      required this.pageId,
      required this.provider});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final homeController = Get.put(HomeController());
  var isRoomFetching = false;
  var isRoomLoadMore = false;
  var isRoomEmpty = false;
  var roomList = [];
  var offset = 0;
  ScrollController sc = ScrollController();
  final searchText = TextEditingController();
  Timer? _debounce;
  late StreamSubscription onChangedListener;

  Future onRefresh() async {
    roomList.clear();
    isRoomFetching = true;
    offset = 0;
    setState(() {});
    await Future.wait([fetchRoomList("")]);
    isRoomFetching = false;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    onRefresh();
    sc.addListener(() async {
      if (sc.position.pixels == sc.position.maxScrollExtent) {
        if (!isRoomFetching) {
          offset += 20;
          isRoomLoadMore = true;
          setState(() {});
          await fetchRoomList("");
          isRoomLoadMore = false;
          setState(() {});
        }
      }
    });
    getOData().then((value) {
      final oId = jsonDecode(value)["id"];
      print(oId);
      DatabaseReference syncRef = FirebaseDatabase.instance
          .ref('root/OrganizationId: $oId/CreateOrUpdateConversation');
      onChangedListener = syncRef.onValue.listen((event) async {
        final value = event.snapshot.value;
        if (value is! Map) return;

        final data = Map<String, dynamic>.from(value);
        if (data["ConversationId"] == null) return;

        try {
          var roomData =
              roomList.firstWhere((e) => e["id"] == data["ConversationId"]);
          roomData["snippet"] = data["Message"];
          roomData["updatedTime"] = DateTime.now().millisecondsSinceEpoch;
          roomData["isRead"] = false;
          setState(() {});
        } catch (e) {
          roomList.clear();
          offset = 0;
          fetchRoomList("").then((value) => setState(() {}));
        }
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    onChangedListener.cancel();

    // onValueListener.cancel();
    // onAddedListener.cancel();
  }

  Future fetchRoomList(searchText) async {
    await ConvApi()
        .getRoomList(widget.pageId, widget.provider, offset,
            searchText: searchText)
        .then((res) {
      if (isSuccessStatus(res["code"])) {
        roomList.addAll(res["content"]);

        if (roomList.isEmpty) {
          isRoomEmpty = true;
        } else {
          isRoomEmpty = false;
        }
      } else {
        errorAlert(title: "Lỗi", desc: res["message"]);
      }
    });
  }

  void onDebounce(Function(String) searchFunction, int debounceTime) {
    // Hủy bỏ bất kỳ timer nào nếu có
    _debounce?.cancel();

    // Tạo mới timer với thời gian debounce
    _debounce = Timer(Duration(milliseconds: debounceTime), () async {
      offset = 0;
      roomList.clear();
      isRoomFetching = true;
      setState(() {});
      await searchFunction(searchText.text);
      isRoomFetching = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              widget.pageName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            subtitle:
                Text(widget.provider!, style: const TextStyle(fontSize: 12)),
            leading: widget.pageAvatar == null
                ? createCircleAvatar(name: widget.pageName!, radius: 16)
                : CircleAvatar(
                    backgroundImage: getAvatarProvider(widget.pageAvatar),
                    radius: 16,
                  )),
        automaticallyImplyLeading: true,
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(76.0), // Height of the search bar.
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: SearchBar(
              backgroundColor: const WidgetStatePropertyAll(Color(0xFFF2F3F5)),
              hintText: "Tìm kiếm",
              controller: searchText,
              onChanged: (value) {
                onDebounce(fetchRoomList, 800);
              },
              leading: const Icon(Icons.search),
            ),
          ),
        ),
        bottomOpacity: 1.0,
      ),
      body: isRoomFetching
          ? const ListPlaceholder(
              length: 10,
              avatarSize: 44,
            )
          : RefreshIndicator(
              onRefresh: onRefresh,
              child: SingleChildScrollView(
                  controller: sc,
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: Get.height - 120),
                    child: isRoomEmpty
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
                                "Hiện chưa có khách hàng nào",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                            ],
                          )
                        : Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: roomList.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final roomData = roomList[index];
                                  final title = roomData["personName"];
                                  final subtitle = roomData["snippet"];
                                  final avatar = roomData["personAvatar"];
                                  final updatedTime = diffFunc(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          roomData["updatedTime"]));
                                  bool isRead = roomData["isRead"];
                                  return ListTile(
                                      onTap: () async {
                                        setState(() {
                                          roomData["isRead"] = true;
                                        });
                                        final result =
                                            await Get.to(() => ChatConvPage(
                                                  pageAvatar: widget.pageAvatar,
                                                  pageName: widget.pageName,
                                                  provider: widget.provider,
                                                  personAvatar: avatar,
                                                  convId: roomData["id"],
                                                  personName: title,
                                                  personId:
                                                      roomData["personId"],
                                                ));

                                        if (result is Map<String, dynamic>) {
                                          setState(() {
                                            if (result["snippet"] != null) {
                                              roomData["snippet"] =
                                                  result["snippet"];
                                            }
                                            if (result["updatedTime"] != null) {
                                              roomData["updatedTime"] =
                                                  result["updatedTime"];
                                            }
                                            roomData["isRead"] = true;
                                          });
                                        }
                                      },
                                      title: Text(title,
                                          style: TextStyle(
                                              fontWeight: isRead
                                                  ? null
                                                  : FontWeight.bold)),
                                      subtitle: Text(subtitle ?? "",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: isRead
                                                  ? null
                                                  : FontWeight.bold)),
                                      trailing: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(updatedTime,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: isRead
                                                      ? null
                                                      : FontWeight.bold)),
                                          const SizedBox(
                                            height: 4,
                                          ),
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
                                              backgroundImage:
                                                  getAvatarProvider(
                                                      avatar ?? defaultAvatar),
                                              radius: 22,
                                            ));
                                },
                              ),
                              if (isRoomLoadMore)
                                const Positioned(
                                    bottom: 5,
                                    child: CircularProgressIndicator())
                            ],
                          ),
                  ))),
    );
  }
}
