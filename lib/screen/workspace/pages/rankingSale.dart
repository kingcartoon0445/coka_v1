import 'dart:async';
import 'dart:convert';

import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/search_anchor.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RankingSalePage extends StatefulWidget {
  final List userList;

  const RankingSalePage({super.key, required this.userList});

  @override
  State<RankingSalePage> createState() => _RankingSalePageState();
}

class _RankingSalePageState extends State<RankingSalePage> {
  CustomSearchController searchController = CustomSearchController();
  late StreamSubscription<bool> keyboardSubscription;
  HomeController hController = Get.put(HomeController());
  Map? currentUser = {};
  List hintUserList = [];
  var filteredUser = [];
  Timer? _debounce;
  bool isDismiss = true;
  Map hintPrefsData = {};

  Future getHintCustomer() async {
    searchController.clear();

    final prefs = await SharedPreferences.getInstance();
    hintPrefsData = jsonDecode(prefs.getString("hintUserData") ?? "{}");
    setState(() {
      hintUserList =
          hintPrefsData[hController.workGroupCardDataValue["id"]] ?? [];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getHintCustomer();
    try {
      currentUser = widget.userList.firstWhere(
          (element) => element["assignTo"] == hController.userData["id"]);
    } catch (e) {
      print(e);
    }
    filteredUser = widget.userList;
    var keyboardVisibilityController = KeyboardVisibilityController();
    // Subscribe
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) async {
      if (!visible) {
        final prefs = await SharedPreferences.getInstance();
        if (searchController.text.isNotEmpty) {
          if (hintUserList.contains(searchController.text)) {
            hintUserList.remove(searchController.text);
          }
          if (hintUserList.length > 4) {
            hintUserList.removeLast();
          }
          hintUserList.insert(0, searchController.text);

          hintPrefsData[hController.workGroupCardDataValue["id"]] =
              hintUserList;
          prefs.setString("hintUserData", jsonEncode(hintPrefsData));
        }
        if (isDismiss && searchController.isOpen) {
          Get.back();
        }
      }
    });
  }

  onTeamSearchChanged() {
    if (searchController.text == "") {
      setState(() {
        filteredUser = widget.userList;
      });
    }
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (searchController.text.isEmpty) {
        // show all contacts when the search query is empty
        filteredUser = widget.userList;
        return;
      }

      // filter the list of contacts based on the search query
      List filtered = [];
      for (var user in widget.userList) {
        if (user["fullName"]
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ==
            true) {
          filtered.add(user);
        }
      }
      setState(() {
        filteredUser = filtered;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Bảng xếp hạng sale",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          CustomSearchAnchor(
              builder: (BuildContext context, controller) {
                return IconButton(
                  icon: badges.Badge(
                    position: badges.BadgePosition.topEnd(end: 2, top: 2),
                    badgeStyle:
                        const badges.BadgeStyle(padding: EdgeInsets.all(2)),
                    showBadge: controller.text.isNotEmpty ? true : false,
                    child: Icon(Icons.search,
                        color: controller.text.isNotEmpty
                            ? const Color(0xFF5C33F0)
                            : null),
                  ),
                  onPressed: () {
                    controller.openView();
                  },
                );
              },
              searchController: searchController,
              onTextChanged: (p0) {
                if (p0.isEmpty) {
                  setState(() {
                    filteredUser = widget.userList;
                  });
                } else {
                  onTeamSearchChanged();
                }
              },
              isFullScreen: false,
              viewConstraints: BoxConstraints(
                  minHeight: 0,
                  maxHeight: hintUserList.length > 3
                      ? 300.0
                      : hintUserList.isEmpty
                          ? 112
                          : 57 + 62.0 * hintUserList.length,
                  maxWidth: double.infinity,
                  minWidth: double.infinity),
              suggestionsBuilder:
                  (BuildContext context, CustomSearchController sController) {
                return hintUserList.map((e) {
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(e),
                    onTap: () {
                      isDismiss = false;
                      searchController.closeView(e);
                      onTeamSearchChanged();

                      Timer(
                        const Duration(milliseconds: 300),
                        () {
                          isDismiss = true;
                        },
                      );
                    },
                  );
                }).toList();
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (currentUser!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE3DFFF),
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Vị trí của bạn",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Color(0xFF333333)),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: [
                            Text(
                              currentUser!["index"].toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            (currentUser?["avatar"] != null)
                                ? CircleAvatar(
                                    backgroundImage: getAvatarProvider(
                                        currentUser?["avatar"]),
                                    radius: 20,
                                  )
                                : createCircleAvatar(
                                    name: currentUser?["fullName"],
                                    radius: 20,
                                    fontSize: 14),
                            const SizedBox(
                              width: 8,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentUser?["fullName"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      currentUser!["total"].toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF554FE8),
                                          fontSize: 11),
                                    ),
                                    const Text(
                                      " Khách hàng",
                                      style: TextStyle(
                                          color: Color(0xFF554FE8),
                                          fontSize: 11),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(6.0),
                                      child: Icon(
                                        Icons.circle,
                                        size: 3,
                                      ),
                                    ),
                                    Text(
                                      currentUser!["potential"].toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF554FE8),
                                          fontSize: 11),
                                    ),
                                    const Text(
                                      " Tiềm năng",
                                      style: TextStyle(
                                          color: Color(0xFF554FE8),
                                          fontSize: 11),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const Spacer(),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "0 tỷ",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF554FE8)),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  "0 Giao dịch",
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF554FE8)),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ...filteredUser.map((userData) {
              return Container(
                padding: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 26,
                      child: Text(
                        userData["index"].toString(),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    (userData?["avatar"] != null)
                        ? CircleAvatar(
                            backgroundImage:
                                getAvatarProvider(userData?["avatar"]),
                            radius: 20,
                          )
                        : createCircleAvatar(
                            name: userData?["fullName"] ?? "T",
                            radius: 20,
                            fontSize: 14),
                    const SizedBox(
                      width: 8,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData?["fullName"] ?? "T",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            Text(
                              userData["total"].toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF29315F),
                                  fontSize: 11),
                            ),
                            const Text(
                              " Khách hàng",
                              style: TextStyle(
                                  color: Color(0xFF29315F), fontSize: 11),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Icon(
                                Icons.circle,
                                size: 3,
                              ),
                            ),
                            Text(
                              userData["potential"].toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF29315F),
                                  fontSize: 11),
                            ),
                            const Text(
                              " Tiềm năng",
                              style: TextStyle(
                                  color: Color(0xFF29315F), fontSize: 11),
                            ),
                          ],
                        )
                      ],
                    ),
                    const Spacer(),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "0 tỷ",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2329)),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          "0 Giao dịch",
                          style:
                              TextStyle(fontSize: 12, color: Color(0xFF29315F)),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
