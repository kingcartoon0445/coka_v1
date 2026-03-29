import 'dart:async';

import 'package:coka/api/org_request.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/components/join_org_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/search_bar.dart';

class JoinOrgPage extends StatefulWidget {
  const JoinOrgPage({super.key});

  @override
  State<JoinOrgPage> createState() => _JoinOrgPageState();
}

class _JoinOrgPageState extends State<JoinOrgPage> {
  List orgList = [];
  bool isFetching = false;

  Timer? _debounce;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future fetchListOrg(searchText) async {
    setState(() {
      isFetching = true;
    });
    OrgRequestApi().getSearchOrg(searchText).then((res) {
      setState(() {
        isFetching = false;

        if (isSuccessStatus(res["code"])) {
          orgList = res["content"];
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
      searchFunction(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FD),
        title: const Text(
          "Tham gia tổ chức",
          style: TextStyle(
              color: Color(0xFF1F2329),
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: SizedBox(
        height: Get.height,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
              child: CustomSearchBar(
                width: double.infinity,
                hintText: "Nhập tên tổ chức",
                onQueryChanged: (value) {
                  onDebounce((v) {
                    fetchListOrg(value);
                  }, 800);
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: isFetching
                  ? const ListPlaceholder(length: 10)
                  : ListView.builder(
                      itemBuilder: (context, index) {
                        return JoinOrgItem(dataItem: orgList[index]);
                      },
                      itemCount: orgList.length,
                      shrinkWrap: true,
                    ),
            )
          ],
        ),
      ),
    );
  }
}
