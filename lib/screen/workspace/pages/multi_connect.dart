import 'package:coka/api/lead.dart';
import 'package:coka/api/webform.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/workspace/components/connect_web_form_next.dart';
import 'package:coka/screen/workspace/getx/multi_connect_controller.dart';
import 'package:coka/screen/workspace/pages/zaloform_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class MultiConnect extends StatefulWidget {
  const MultiConnect({super.key});

  @override
  State<MultiConnect> createState() => _MultiConnectState();
}

class _MultiConnectState extends State<MultiConnect> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MultiConnectController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Kết nối đa nguồn",
            style: TextStyle(
                color: Color(0xFF1F2329),
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              Center(
                child: SizedBox(
                  width: Get.width - 32,
                  child: Row(
                    children: [
                      SizedBox(
                        width: Get.width - 110,
                        child: const SearchBar(
                          backgroundColor:
                              WidgetStatePropertyAll(Color(0xFFFAFBFB)),
                          leading: Icon(Icons.search),
                          hintText: "Tìm kiếm",
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Get.bottomSheet(
                            const AddConnectLayout(),
                          );
                        },
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFFAFBFB),
                            minimumSize: const Size(55, 55)),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                  child: controller.isFetching.value
                      ? const ListPlaceholder(length: 10)
                      : controller.connectObject["webform"] == []
                          ? const EmptyMultiConnect()
                          : RefreshIndicator(
                              onRefresh: () {
                                return controller.onRefresh();
                              },
                              child: SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(minHeight: 600),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      buildWebformList(controller, context),
                                      buildFazaList(controller)
                                    ],
                                  ),
                                ),
                              ),
                            ))
            ],
          ),
        ),
      );
    });
  }

  Widget buildFazaList(MultiConnectController controller) {
    return Column(
      children: [
        ...(controller.connectObject["faza"] as List).map((x) {
          var title = x["name"] ?? x["title"];
          var subTitle = x["provider"] ?? "ZALO";
          var iconPath = x["provider"] != "FACEBOOK"
              ? "assets/images/zalo_icon.png"
              : "assets/images/fb_icon.png";
          var isActive = x["status"] == 1 ? true : false;
          return ListTile(
              onTap: () {},
              onLongPress: () {
                // if (c.isOpen) {
                //   c.close();
                // } else {
                //   c.open();
                // }
              },
              title: Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(subTitle),
              trailing: Switch(
                value: isActive,
                activeTrackColor: const Color(0xFFF07A22),
                onChanged: (value) {
                  if (x["status"] != 1) {
                    showLoadingDialog(context);
                    if (x["provider"] == "FACEBOOK") {
                      LeadApi()
                          .updateLeadStatus(
                        controller.mainController.workGroupCardDataValue['id'],
                        x["id"],
                        1,
                      )
                          .then((res) {
                        Get.back();
                        if (isSuccessStatus(res["code"])) {
                          setState(() {
                            x["status"] = 1;
                          });
                        } else {
                          errorAlert(title: "Thất bại", desc: res["message"]);
                        }
                      });
                    } else {
                      LeadApi()
                          .updateZaloLeadStatus(
                        controller.mainController.workGroupCardDataValue['id'],
                        x["id"],
                        1,
                      )
                          .then((res) {
                        Get.back();
                        if (res["content"]) {
                          setState(() {
                            x["status"] = 1;
                          });
                        } else {
                          errorAlert(title: "Thất bại", desc: res["message"]);
                        }
                      });
                    }
                  } else {
                    showLoadingDialog(context);
                    if (x["provider"] == "FACEBOOK") {
                      LeadApi()
                          .updateLeadStatus(
                        controller.mainController.workGroupCardDataValue['id'],
                        x["id"],
                        0,
                      )
                          .then((res) {
                        Get.back();

                        if (isSuccessStatus(res["code"])) {
                          setState(() {
                            x["status"] = 0;
                          });
                        } else {
                          errorAlert(title: "Thất bại", desc: res["message"]);
                        }
                      });
                    } else {
                      LeadApi()
                          .updateZaloLeadStatus(
                        controller.mainController.workGroupCardDataValue['id'],
                        x["id"],
                        0,
                      )
                          .then((res) {
                        Get.back();

                        if (res["content"] != "") {
                          setState(() {
                            x["status"] = 0;
                          });
                        } else {
                          errorAlert(title: "Thất bại", desc: res["message"]);
                        }
                      });
                    }
                  }
                },
              ),
              leading: Image.asset(
                iconPath,
                height: 44,
                width: 44,
              ));
        })
      ],
    );
  }

  Widget buildWebformList(
      MultiConnectController controller, BuildContext context) {
    return Column(
      children: [
        ...(controller.connectObject["webform"] as List).map((x) {
          var title = "";
          title = x["url"];
          var subTitle = "";
          subTitle = x["type"] == "DOMAIN" ? "WEBFORM" : "Chưa xác định";
          var isActive = x["status"] == 1 ? true : false;
          return MenuAnchor(
              menuChildren: [
                MenuItemButton(
                  leadingIcon: const Icon(Icons.delete, size: 25),
                  onPressed: () {
                    warningAlert(
                        title: "Xoá website?",
                        desc: "Bạn có chắc chắn muốn xoá website này?",
                        btnOkOnPress: () {
                          showLoadingDialog(context);
                          WebformApi()
                              .deleteWebsite(
                                  x["id"],
                                  controller.mainController
                                      .workGroupCardDataValue['id'])
                              .then((res) {
                            Get.back();
                            if (isSuccessStatus(res["code"])) {
                              successAlert(
                                  title: "Thành công",
                                  desc: "Website đã bị xóa");
                              controller.onRefresh();
                            } else {
                              errorAlert(title: "Lỗi", desc: res["message"]);
                            }
                          });
                        });
                  },
                  child: const Text(
                    "Xoá website",
                    style: TextStyle(color: Colors.black),
                  ),
                )
              ],
              builder: (context, c, child) {
                return ListTile(
                    onTap: () {
                      connectWebFormNext(connectData: x);
                    },
                    onLongPress: () {
                      if (c.isOpen) {
                        c.close();
                      } else {
                        c.open();
                      }
                    },
                    title: Text(
                      title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(subTitle),
                    trailing: Switch(
                      value: isActive,
                      activeTrackColor: const Color(0xFFF07A22),
                      onChanged: (value) {
                        if (x["status"] != 1) {
                          showLoadingDialog(context);
                          WebformApi()
                              .verifyWebsite(
                                  x["id"],
                                  controller.mainController
                                      .workGroupCardDataValue['id'])
                              .then((res) {
                            Get.back();

                            if (res["content"]) {
                              setState(() {
                                x["status"] = 1;
                              });
                              successAlert(
                                desc: 'Website đã gắn script thành công',
                                title: "Thành công",
                              );
                            } else {
                              errorAlert(
                                  title: "Thất bại",
                                  desc: "Website chưa được cấu hình đúng cách");
                            }
                          });
                        } else {
                          showLoadingDialog(context);
                          WebformApi()
                              .updateStatusWebsite(
                                  x["id"],
                                  controller.mainController
                                      .workGroupCardDataValue['id'],
                                  0)
                              .then((res) {
                            Get.back();
                            if (isSuccessStatus(res["code"])) {
                              setState(() {
                                x["status"] = 0;
                              });
                            } else {
                              errorAlert(
                                  title: "Thất bại", desc: res["message"]);
                            }
                          });
                        }
                      },
                    ),
                    leading: SvgPicture.asset(
                      "assets/icons/webform_icon.svg",
                      height: 44,
                      width: 44,
                      color: const Color(0xFF1876F1),
                    ));
              });
        })
      ],
    );
  }
}

class EmptyMultiConnect extends StatelessWidget {
  const EmptyMultiConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset("assets/images/null_multi_connect.png"),
        const SizedBox(
          height: 20,
        ),
        const Text(
          "Hiện chưa có kênh nào",
          style: TextStyle(fontSize: 13, color: Colors.black),
        ),
        const SizedBox(
          height: 30,
        ),
        ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              backgroundColor: Colors.white,
              context: context,
              builder: (context) => const AddConnectLayout(),
            );
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C33F0),
              padding: const EdgeInsets.symmetric(horizontal: 50)),
          child: const Text(
            "Kết nối",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}

class AddConnectLayout extends StatelessWidget {
  const AddConnectLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      child: Wrap(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(18.0),
                child: Text("Kênh kết nối",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ),
              Divider(
                height: 1,
                color: Colors.black.withOpacity(0.2),
              ),
              const SizedBox(
                height: 20,
              ),
              buildConnectBtn(
                pathIcon: "assets/icons/webform_icon.svg",
                name: "Kết nối Webform",
                onTap: () {
                  connectWebFormNext();
                },
              ),
              const SizedBox(
                height: 8,
              ),
              buildConnectBtn(
                pathIcon: "assets/icons/fb_3_icon.svg",
                name: "Kết nối Facebook Lead",
                onTap: () async {
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
                    final homeController = Get.put(HomeController());
                    final multiConnectController =
                        Get.put(MultiConnectController());
                    Future.delayed(const Duration(milliseconds: 50),
                        () => showLoadingDialog(Get.context!));
                    LeadApi().facebookLeadConnect(
                        homeController.workGroupCardDataValue["id"], {
                      "socialAccessToken": result.accessToken!.token
                    }).then((res) {
                      Get.back();
                      if (isSuccessStatus(res["code"])) {
                        Get.back();
                        multiConnectController.onRefresh();
                        successAlert(
                            title: "Thành công",
                            desc: "Đã kết nối với facebook");
                      } else {
                        errorAlert(title: "Lỗi", desc: res["message"]);
                      }
                    });
                  } else {
                    errorAlert(
                        title: "Thất bại",
                        desc: "Đã có lỗi xảy ra, xin vui lòng thử lại");
                  }
                },
              ),
              const SizedBox(
                height: 8,
              ),
              buildConnectBtn(
                pathIcon: "assets/icons/zalo_icon.svg",
                name: "Kết nối ZaloForm",
                onTap: () async {
                  Get.to(() => const ZaloformConfigPage());
                },
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget buildConnectBtn(
    {String? pathIcon,
    Widget? icon,
    required String name,
    required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 5, top: 5),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
          ),
          icon ??
              SvgPicture.asset(
                pathIcon!,
                width: 40,
                height: 40,
              ),
          const SizedBox(
            width: 20,
          ),
          Text(
            name,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
          )
        ],
      ),
    ),
  );
}
