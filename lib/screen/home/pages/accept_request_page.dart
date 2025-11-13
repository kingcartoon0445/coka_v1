import 'package:coka/api/org_request.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/components/profile_request_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AcceptRequestPage extends StatefulWidget {
  const AcceptRequestPage({super.key});

  @override
  State<AcceptRequestPage> createState() => _AcceptRequestPageState();
}

class _AcceptRequestPageState extends State<AcceptRequestPage> {
  List invList = [];
  bool isFetching = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchInviteList("");
  }

  Future fetchInviteList(searchText) async {
    setState(() {
      isFetching = true;
    });
    OrgRequestApi().getRequestList(searchText, 2).then((res) {
      isFetching = false;

      if (isSuccessStatus(res["code"])) {
        invList = res["content"];
      } else {
        errorAlert(title: "Thất bại", desc: res["message"]);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Lời mời",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2329)),
          ),
          centerTitle: true,
          automaticallyImplyLeading: true,
          bottom: const TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(
                child: Text("Đã nhận",
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
              Tab(
                child: Text("Đã gửi",
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        body: isFetching
            ? const ListPlaceholder(length: 10)
            : TabBarView(
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      fetchInviteList("");
                    },
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: Get.height - 120),
                      child: InviteList(
                        invitedList: invList,
                        onReload: () {
                          fetchInviteList("");
                        },
                      ),
                    ),
                  ),
                  RefreshIndicator(
                    onRefresh: () async {
                      fetchInviteList("");
                    },
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: Get.height - 120),
                      child: RequestList(
                        requestList: invList,
                        onReload: () {
                          fetchInviteList("");
                        },
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}

class InviteList extends StatelessWidget {
  final List invitedList;
  final Function onReload;
  const InviteList(
      {super.key, required this.invitedList, required this.onReload});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        if (invitedList[index]["type"] == "INVITE") {
          return ProfileInviteItem(
            dataItem: invitedList[index],
            onReload: onReload,
          );
        }
        return Container();
      },
      itemCount: invitedList.length,
      shrinkWrap: true,
    );
  }
}

class RequestList extends StatelessWidget {
  final List requestList;
  final Function onReload;
  const RequestList(
      {super.key, required this.requestList, required this.onReload});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        if (requestList[index]["type"] == "REQUEST") {
          return ProfileRequestItem(
            dataItem: requestList[index],
            onReload: onReload,
          );
        }
        return Container();
      },
      itemCount: requestList.length,
      shrinkWrap: true,
    );
  }
}
