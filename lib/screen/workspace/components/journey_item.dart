import 'dart:convert';

import 'package:coka/components/auto_avatar.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/workspace/getx/customer_controller.dart';
import 'package:coka/screen/workspace/pages/info_customer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_audio/flutter_html_audio.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

String getIconPath(type, isSource) {
  if (isSource) {
    if (type == "FORM") {
      return "assets/images/form_icon.png";
    }
    if (type == "NHẬP VÀO") {
      return "assets/images/pencil.png";
    }
  }
  if (type == "UPDATE_RATING") {
    return "assets/images/review.png";
  }
  if (type == "CALL") {
    return "assets/images/journey_phone.png";
  }
  if (type == "UPDATE_AVATAR" || type == "UPDATE_INFO") {
    return "assets/images/pencil.png";
  }
  if (type == "UPDATE_STAGE" || type == "CREATE_NOTE") {
    return "assets/images/sticky-notes.png";
  }
  if (type == "UPDATE_ASSIGNTEAM" || type == "UPDATE_ASSIGNTO") {
    return "assets/images/change.png";
  }

  return "assets/images/bot.png";
}

String translateCallStatus(status) {
  if (status == "CANCEL") {
    return "Hủy cuộc gọi";
  }
  if (status == "ANSWER") {
    return "Thành công";
  }
  if (status == "BUSY") {
    return "Máy bận";
  }
  return "Không xác định";
}

String? getSubtitle(type, oldValue, newValue) {
  try {
    if (type == "UPDATE_RATING" || type == "UPDATE_AVATAR") {
      return null;
    }

    final oldData = jsonDecode(oldValue == "" ? "{}" : oldValue ?? "{}");
    final newData = jsonDecode(newValue == "" ? "{}" : newValue ?? "{}");

    if (type == "UPDATE_INFO") {
      final diff = compareMaps(oldData, newData);

      String htmlString = "";
      for (var x in diff.entries) {
        if (x.key == "FullName") {
          htmlString +=
              "Tên: <a>${x.value[0]}</a> sang <a>${x.value[1]}</a><br/>";
        } else if (x.key == "Phone") {
          htmlString +=
              "Số điện thoại: <a>${getValue(x.key, x.value[0])}</a> sang <a>${getValue(x.key, x.value[1])}</a><br/>";
        } else if (x.key == "Dob") {
          htmlString +=
              "Ngày sinh: <a>${getValue(x.key, x.value[0]) ?? "Chưa có"}</a> sang <a>${getValue(x.key, x.value[1])}</a><br/>";
        } else if (x.key == "Gender") {
          htmlString +=
              "Giới tính: <a>${getValue(x.key, x.value[0])}</a> sang <a>${getValue(x.key, x.value[1])}</a><br/>";
        } else if (x.key == "Email") {
          htmlString +=
              "Email: <a>${x.value[0] ?? "Chưa có"}</a> sang <a>${x.value[1]}</a><br/>";
        } else if (x.key == "Work") {
          htmlString +=
              "Nghề nghiệp: <a>${x.value[0] ?? "Chưa có"}</a> sang <a>${x.value[1]}</a><br/>";
        } else if (x.key == "Address") {
          htmlString +=
              "Nơi ở: <a>${x.value[0] ?? "Chưa có"}</a> sang <a>${x.value[1]}</a><br/>";
        } else if (x.key == "PhysicalId") {
          htmlString +=
              "CMND/CCCD: <a>${x.value[0] ?? "Chưa có"}</a> sang <a>${x.value[1]}</a><br/>";
        }
      }
      if (htmlString.length > 6) {
        htmlString = htmlString.replaceRange(
            htmlString.length - 6, htmlString.length - 1, "");
      }
      return htmlString;
    }
    if (type == "UPDATE_STAGE") {
      return "Sang: <a>${newData["Name"]}.</a>${newData["Note"] != "" && newData["Note"] != null ? "<br/>Nội dung: <a>${newData["Note"]}</a>" : ""}";
    }
    if (type == "CREATE_NOTE") return "\nNội dung: <a>${newData["Note"]}</a>";
    if (type == "UPDATE_ASSIGNTEAM") {
      return "Sang: <a>${newData["Team"]?["Name"] ?? "Nhóm làm việc"}</a>";
    }
    if (type == "UPDATE_ASSIGNTO") {
      return "Sang: <a>${newData["User"]["FullName"]}</a>";
    }
    if (type == "CALL") {
      return "<div class='column'>Trạng thái: <a>${translateCallStatus(newData["CallStatus"])}</a>${newData["RecordingFile"] != null && newData["RecordingFile"] != "" ? "\n<audio controls> <source src='${newData["RecordingFile"]}' type='audio/mpeg'>Audio</audio>" : ""}</div>";
    }
  } catch (e) {
    print(e);
  }

  return null;
}

class JourneyItem extends StatelessWidget {
  final Map dataItem;

  const JourneyItem({super.key, required this.dataItem});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerController>(builder: (controller) {
      String snipTime = diffFunc(DateTime.parse(dataItem['date']));
      String fullTime = DateFormat('dd-MM-yyyy HH:mm:ss')
          .format(DateTime.parse(dataItem['date']));
      String? title = dataItem["data"]["title"] ??
          "Data được thêm vào bởi ${dataItem["data"]["sourceName"]}";
      bool isSource = dataItem["type"] == "SOURCE" ? true : false;
      String? type =
          isSource ? dataItem["data"]["sourceName"] : dataItem["data"]["type"];
      String? oldValue = dataItem["data"]["oldValue"];
      String? newValue = dataItem["data"]["newValue"];
      String? noteText = dataItem["data"]["note"];

      final utmSrc = dataItem["data"]["utmSource"]?.toUpperCase();
      final website = dataItem["data"]["website"];
      String subTitle = getSubtitle(type, oldValue, newValue) ??
          ((utmSrc == null || utmSrc == "") ? "" : "Nguồn: <a>$utmSrc</a>");
      if (website != null && website != '') {
        subTitle +=
            "</br>Đích: <a href='$website'>${staticURLFromURLString(website)}</a>";
      }
      if (noteText != null && noteText != '') {
        subTitle += "</br>Nội dung: <a >$noteText</a>";
      }
      print(subTitle);
      String name = dataItem["createdBy"]["fullName"];
      String? avatar = dataItem["createdBy"]["avatar"];
      String iconPath = getIconPath(type?.toUpperCase(), isSource);

      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  CircleAvatar(
                      backgroundColor: const Color(0xFFE3DFFF),
                      radius: 20,
                      child: Image.asset(iconPath, width: 24, height: 24)),
                ],
              ),
              const SizedBox(
                width: 12,
              ),
              Container(
                width: Get.width - 90,
                constraints: const BoxConstraints(minHeight: 50),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 2,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: Get.width - 150,
                              child: Text(title ?? "",
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF1F2329),
                                      fontWeight: FontWeight.bold)),
                            ),
                            const Spacer(),
                            Tooltip(
                              message: fullTime,
                              triggerMode: TooltipTriggerMode.tap,
                              waitDuration: const Duration(seconds: 2),
                              child: Text(
                                snipTime,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (subTitle != "")
                              SizedBox(
                                  width: double.infinity,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Html(
                                      data: "<p>$subTitle</p>",
                                      onLinkTap:
                                          (url, attributes, element) async {
                                        if (url!.contains("http")) {
                                          if (!await launchUrl(
                                              Uri.parse(url))) {
                                            throw Exception(
                                                'Could not launch $url');
                                          }
                                        }
                                      },
                                      extensions: const [
                                        AudioHtmlExtension(),
                                      ],
                                      style: {
                                        "body": Style(margin: Margins.zero),
                                        ".column": Style(
                                            display: Display.block,
                                            backgroundColor:
                                                Colors.transparent),
                                        "a": Style(
                                            textDecoration: TextDecoration.none,
                                            color: const Color(0xFF554FE8),
                                            fontWeight: FontWeight.bold),
                                        "p": Style(
                                            padding: HtmlPaddings.zero,
                                            margin:
                                                Margins.symmetric(vertical: 2))
                                      },
                                    ),
                                  )),
                            if (type == "UPDATE_RATING")
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: RatingBar.builder(
                                  initialRating: double.parse(newValue ?? "0"),
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Color(0xFFF27B21),
                                  ),
                                  itemSize: 20,
                                  onRatingUpdate: (value) {},
                                  ignoreGestures: true,
                                ),
                              ),
                            const SizedBox(
                              height: 4,
                            ),
                            Row(
                              children: [
                                const Spacer(),
                                Text(name,
                                    style: const TextStyle(
                                        color: Colors.black54, fontSize: 10)),
                                const SizedBox(
                                  width: 5,
                                ),
                                avatar == null
                                    ? createCircleAvatar(
                                        name: name, radius: 9, fontSize: 9)
                                    : CircleAvatar(
                                        backgroundImage:
                                            getAvatarProvider(avatar),
                                        radius: 9,
                                      )
                              ],
                            )
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          )
        ],
      );
    });
  }
}
