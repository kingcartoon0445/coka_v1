import 'package:coka/api/invite.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/components/org_request_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AcceptInvitePage extends StatefulWidget {
  const AcceptInvitePage({super.key});

  @override
  State<AcceptInvitePage> createState() => _AcceptInvitePageState();
}

class _AcceptInvitePageState extends State<AcceptInvitePage> {
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
    InviteApi().getInviteList(searchText, 2).then((res) {
      setState(() {
        isFetching = false;
        if (isSuccessStatus(res["code"])) {
          invList = res["content"];
        } else {
          errorAlert(title: "Thất bại", desc: res["message"]);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Yêu cầu gia nhập",
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
                          constraints:
                              BoxConstraints(minHeight: Get.height - 120),
                          child: RequestList(
                            requestList: invList,
                            onReload: () {
                              fetchInviteList("");
                            },
                          ))),
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
                          }),
                    ),
                  )
                ],
              ),
      ),
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
          return OrgRequestItem(
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

class InviteList extends StatelessWidget {
  final List invitedList;
  final Function onReload;
  const InviteList(
      {super.key, required this.invitedList, required this.onReload});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: Get.height - 120),
      child: ListView.builder(
        itemBuilder: (context, index) {
          if (invitedList[index]["type"] == "INVITE") {
            return OrgInviteItem(
              dataItem: invitedList[index],
              onReload: onReload,
            );
          }
          return Container();
        },
        itemCount: invitedList.length,
        shrinkWrap: true,
      ),
    );
  }
}
