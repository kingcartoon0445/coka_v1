import 'dart:async';

import 'package:coka/api/org_request.dart';
import 'package:coka/api/organization.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/components/join_org_item.dart';
import 'package:coka/screen/home/components/qr_scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

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

  String _extractOrganizationId(String raw) {
    try {
      final uri = Uri.tryParse(raw);
      if (uri != null && uri.scheme.isNotEmpty) {
        if (uri.queryParameters['organizationId']?.isNotEmpty == true) {
          return uri.queryParameters['organizationId']!;
        }
        final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
        if (segments.isNotEmpty) return segments.last;
      }
    } catch (_) {}
    return raw.trim();
  }

  Future<void> _handleQrResult(String result) async {
    final id = _extractOrganizationId(result);
    if (!mounted) return;

    // if (widget.dataItem.isRequest == true || stageBtn == 1) {
    //   return;
    // }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    Map<String, dynamic> response;
    try {
      response = await OrganApi().getOrganV2(id);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi gọi API: $e')),
      );
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop();

    final data = (response is Map<String, dynamic>)
        ? response as Map<String, dynamic>
        : <String, dynamic>{};
    final content = data['content'] as Map<String, dynamic>? ?? data;
    final String organizationId = (content['id'] ?? '--').toString();

    final String name = (content['name'] ?? '--').toString();
    final String description = (content['description'] ?? '').toString();
    final String avatar = (content['avatar'] ?? '').toString();
    final int? memberCount = content['memberCount'] as int?;
    final String? website = content['website'] as String? ??
        content['owner']?['name'] as String? ??
        name; // Fallback to organization name

    await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF2196F3).withOpacity(0.3),
                  width: 3,
                ),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Organization Logo
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: avatar.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            avatar,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.apartment,
                              color: Color(0xFFFF9800),
                              size: 32,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.apartment,
                          color: Color(0xFFFF9800),
                          size: 32,
                        ),
                ),
                const SizedBox(height: 16),

                // Organization Name with Verification Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  description.isNotEmpty
                      ? description
                      : 'Tổ chức chính thức của $name',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Owner Information
                Builder(
                  builder: (context) {
                    final websiteUrl = website;
                    return GestureDetector(
                      onTap: websiteUrl != null && websiteUrl.isNotEmpty
                          ? () async {
                              try {
                                String url = websiteUrl;
                                // Kiểm tra và thêm http:// hoặc https:// nếu chưa có
                                if (!url.startsWith('http://') &&
                                    !url.startsWith('https://')) {
                                  url = 'https://$url';
                                }
                                final uri = Uri.parse(url);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Không thể mở link này')),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Lỗi khi mở link: $e')),
                                  );
                                }
                              }
                            }
                          : null,
                      child: Text(
                        'Website: $website',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: websiteUrl != null && websiteUrl.isNotEmpty
                              ? Colors.black
                              : Colors.black87,
                          decoration:
                              websiteUrl != null && websiteUrl.isNotEmpty
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),

                // Member Count
                // if (memberCount != null)
                //   Text(
                //     '$memberCount thành viên',
                //     style: const TextStyle(
                //       fontSize: AppSize.sizeTextMedium,
                //       fontWeight: FontWeight.bold,
                //       color: Colors.black87,
                //     ),
                //     textAlign: TextAlign.center,
                //   ),
                // const SizedBox(height: 24),

                // Invitation Message

                if (memberCount != null)
                  Text(
                    'Hãy tham gia cùng $memberCount thành viên khác',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),

                // Member Avatars
                if (memberCount != null && memberCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Placeholder avatars (you can replace with actual member avatars)
                        ...List.generate(
                          memberCount > 3 ? 3 : memberCount,
                          (index) => Container(
                            // margin: const EdgeInsets.only(right: -8),
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.grey.shade300,
                              child: Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        if (memberCount > 3)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '+${memberCount - 3}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Decline Button
                    TextButton(
                      onPressed: () => Navigator.of(context).pop('decline'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Đóng',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Accept Button
                    ElevatedButton(
                      onPressed: () {
                        showLoadingDialog(context);
                        try {
                          OrgRequestApi()
                              .postOrgRequest(organizationId)
                              .then((res) {
                            Get.back();
                            if (isSuccessStatus(res["code"])) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Color(0xFFedf7ed),
                                  content:
                                      Text('Đã gửi yêu cầu tham gia tổ chức!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text("Lỗi: " + res["message"]),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          });
                        } catch (e) {
                          Get.back();
                        }

                        // showLoadingDialog(context);
                        // context.read<SettingBloc>().add(JoinOrganization(
                        //     organizationId: organizationId,
                        //     organizationName: name));
                        Navigator.of(context).pop('accept');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Tham gia',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
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
                ),
                InkWell(
                  onTap: () async {
                    final result = await Navigator.of(context).push<String>(
                      MaterialPageRoute(
                        builder: (_) => const QrScannerPage(title: 'Quét QR'),
                      ),
                    );
                    if (!mounted) return;
                    if (result != null && result.isNotEmpty) {
                      await _handleQrResult(result);
                    }
                  },
                  child: Container(
                    // color: AppColors.primary,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                    ),
                    child: const Icon(
                      Icons.qr_code_2,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12),
              ],
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
