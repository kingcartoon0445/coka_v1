import 'dart:async';

import 'package:coka/api/invite.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/components/inv_member_item.dart';
import 'package:coka/screen/home/pages/organization_invite_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/search_bar.dart';

class FindMemberBottomSheet extends StatefulWidget {
  const FindMemberBottomSheet({super.key});

  @override
  State<FindMemberBottomSheet> createState() => _FindMemberBottomSheetState();
}

class _FindMemberBottomSheetState extends State<FindMemberBottomSheet>
    with SingleTickerProviderStateMixin {
  List profileList = [];
  int offset = 0;
  final sc = ScrollController();
  bool isFetching = false;
  bool isLoadingMore = false;
  String orgId = "";
  String orgName = "";
  Timer? _debounce;
  late TabController _tabController;
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    getOData().then((value) {
      orgId = value["id"];
      orgName = value["name"];
    });
    // _searchController.addListener(_onSearchChanged);
    sc.addListener(() {
      if (sc.position.pixels >= sc.position.maxScrollExtent) {
        if (profileList.isNotEmpty && !isFetching && !isLoadingMore) {
          setState(() {
            isLoadingMore = true;
          });
          fetchListOrg(searchController.text).then((value) {
            Timer(const Duration(milliseconds: 100), () {
              setState(() {
                isLoadingMore = false;
              });
            });
          });
        }
      }
    });
  }

  void _onTabChanged() {}

  Future fetchListOrg(searchText) async {
    setState(() {
      isFetching = true;
    });
    await InviteApi().getSearchProfile(searchText, offset).then((res) {
      setState(() {
        isFetching = false;
        if (isSuccessStatus(res["code"])) {
          offset += 15;
          print(offset);
          profileList.addAll(res["content"]);
        } else {
          // errorAlert(title: "Thất bại", desc: res["message"]);
        }
      });
    });
  }

  void onDebounce(Function(String) searchFunction, int debounceTime) {
    // Hủy bỏ bất kỳ timer nào nếu có
    _debounce?.cancel();

    // Tạo mới timer với thời gian debounce
    _debounce = Timer(Duration(milliseconds: debounceTime), () {
      // Lấy dữ liệu từ trường văn bản và gọi hàm tìm kiếm
      offset = 0;
      profileList.clear();
      searchFunction(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFfaf8fd),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: SizedBox(
        height: Get.height - 100,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 30,
                    )),
                SizedBox(
                  width: Get.width / 2 - 120,
                ),
                const Text(
                  "Tìm kiếm thành viên",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CustomSearchBar(
                width: double.infinity,
                hintText: "Nhập tên tài khoản",
                onQueryChanged: (value) {
                  onDebounce((v) {
                    fetchListOrg(value);
                  }, 800);
                },
              ),
            ),
            TabBar(
              controller: _tabController,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: Color(0xFF4C46F1),
              tabs: const [
                Tab(text: 'Thủ công'),
                Tab(text: 'Mã QR'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  isFetching && !isLoadingMore
                      ? const ListPlaceholder(
                          length: 11,
                          bottomPadding: 5,
                        )
                      : ListView.builder(
                          controller: sc,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                InvMemberItem(dataItem: profileList[index]),
                                if (isLoadingMore &&
                                    index == profileList.length - 1)
                                  const CircularProgressIndicator()
                              ],
                            );
                          },
                          itemCount: profileList.length,
                          shrinkWrap: true,
                        ),
                  OrganizationInvitePage(
                    organizationId: orgId,
                    organizationName: orgName,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
