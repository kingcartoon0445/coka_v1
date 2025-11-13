import 'dart:async';

import 'package:coka/api/lead.dart';
import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/placeholders.dart';
import '../../../constants.dart';

class AddPage2ChatBotBottomSheet extends StatefulWidget {
  final Map selectedData;
  final Function onSubmit;
  final String provider;

  const AddPage2ChatBotBottomSheet(
      {super.key,
      required this.selectedData,
      required this.onSubmit,
      required this.provider});

  @override
  State<AddPage2ChatBotBottomSheet> createState() =>
      _AddPage2ChatBotBottomSheetState();
}

class _AddPage2ChatBotBottomSheetState
    extends State<AddPage2ChatBotBottomSheet> {
  final homeController = Get.put(HomeController());
  var isChannelEmpty = false;
  var channelList = [];
  var selectedList = [];
  var isChannelFetching = false;
  var searchController = TextEditingController();
  Map selected = {};
  var filteredChannel = [];

  Timer? _debounce;

  Future onRefresh() async {
    isChannelFetching = true;
    channelList.clear();
    setState(() {});
    await Future.wait([fetchChannelList(searchController.text)]);
    isChannelFetching = false;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.selectedData);
    onRefresh();
  }

  void createFalseMap() {
    for (var x in channelList) {
      selected[x["id"]] = widget.selectedData[x["id"]] ?? false;
    }
  }

  Future fetchChannelList(searchText) async {
    await LeadApi()
        .getFbMessageList(
            subscribed: "messages",
            searchText: searchText,
            provider: widget.provider)
        .then((res) {
      if (isSuccessStatus(res["code"])) {
        channelList = res["content"];
        createFalseMap();

        if (channelList.isEmpty) {
          isChannelEmpty = true;
        } else {
          isChannelEmpty = false;
        }
      } else {
        if (res["message"].contains("không có quyền")) {
          Get.back();
        }
        errorAlert(title: "Lỗi", desc: res["message"]);
      }
    });
  }

  void onDebounce(int debounceTime) {
    // Hủy bỏ bất kỳ timer nào nếu có
    _debounce?.cancel();

    // Tạo mới timer với thời gian debounce
    _debounce = Timer(Duration(milliseconds: debounceTime), () async {
      if (searchController.text.isEmpty) {
        // show all contacts when the search query is empty
        filteredChannel = channelList;
        return;
      }

      // filter the list of contacts based on the search query
      List filtered = [];
      for (var channel in channelList) {
        if (channel["name"]
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ==
            true) {
          filtered.add(channel);
        }
      }
      setState(() {
        filteredChannel = filtered;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (searchController.text == "") filteredChannel = channelList;

    return SizedBox(
      height: Get.height - 100,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Trang kết nối",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                      onPressed: () {
                        selectedList.clear();
                        for (var x = 0; x < channelList.length; x++) {
                          if (selected[channelList[x]["id"]]) {
                            selectedList.add(channelList[x]);
                          }
                        }
                        widget.onSubmit(selectedList, selected);
                        Get.back();
                      },
                      icon: const Icon(
                        CupertinoIcons.checkmark_alt,
                        size: 32,
                      )),
                  const SizedBox(
                    width: 10,
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SearchBar(
                  leading: const Icon(Icons.search),
                  hintText: "Tìm kiếm",
                  backgroundColor:
                      const WidgetStatePropertyAll(Color(0xFFF2F3F5)),
                  controller: searchController,
                  onChanged: (value) {
                    onDebounce(50);
                  },
                ),
              ),
              const Divider(
                height: 1,
                color: Color(0xFFFAF8FD),
              ),
              isChannelFetching
                  ? const Expanded(child: ListPlaceholder(length: 12))
                  : Expanded(
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          RefreshIndicator(
                            onRefresh: onRefresh,
                            child: ListView.builder(
                              itemBuilder: (context, index) {
                                final profile = filteredChannel[index];
                                final title = profile["name"];
                                final subTitle = profile["provider"];
                                final avatar = profile["avatar"];
                                return buildListTile(avatar, title, subTitle,
                                    isMember: true,
                                    isSelected: selected[profile["id"]],
                                    onChange: (value) {
                                  setState(() {
                                    selected[profile["id"]] = value;
                                  });
                                });
                              },
                              itemCount: filteredChannel.length,
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                            ),
                          ),
                        ],
                      ),
                    )
            ],
          ),
        ],
      ),
    );
  }

  ListTile buildListTile(avatar, name, subtitle,
      {bool? isMember, required bool? isSelected, required Function onChange}) {
    return ListTile(
      leading: avatar == null
          ? createCircleAvatar(name: name, radius: 20)
          : Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x663949AB), width: 1),
                  color: Colors.white),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: getAvatarWidget(avatar),
              ),
            ),
      title: Text(name,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
      subtitle: Row(
        children: [
          if (isMember ?? false)
            const Padding(
              padding: EdgeInsets.only(right: 3.0),
              child: Icon(Icons.group_outlined, size: 16),
            ),
          Text(
            subtitle,
            style:
                TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 13),
          ),
        ],
      ),
      trailing: Checkbox(
        value: isSelected,
        onChanged: (value) {
          onChange(value);
        },
      ),
    );
  }
}
