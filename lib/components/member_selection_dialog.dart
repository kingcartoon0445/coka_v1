import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../api/organization.dart';
import '../api/conversation.dart';

class MemberSelectionDialog extends StatefulWidget {
  final Function(Map<String, dynamic>)? onMemberSelected;
  final List<String>? excludedProfileIds;
  final String? conversationId; // ID của conversation để assign
  final String? assignedId; // ID của người đã được assign
  final VoidCallback? onAssignmentSuccess; // Callback khi assignment thành công

  const MemberSelectionDialog({
    Key? key,
    this.onMemberSelected,
    this.excludedProfileIds,
    this.conversationId,
    this.assignedId,
    this.onAssignmentSuccess,
  }) : super(key: key);

  @override
  State<MemberSelectionDialog> createState() => _MemberSelectionDialogState();
}

class _MemberSelectionDialogState extends State<MemberSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  final OrganApi _organApi = OrganApi();
  final ConvApi _convApi = ConvApi();
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _filteredMembers = [];
  bool _isLoading = false;
  bool _isAssigning = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _organApi.getOrgMembersForSelection(
        searchText: '', // Lấy tất cả rồi filter ở client
        offset: 0,
        limit: 1000,
        status: 1,
      );

      if (mounted && response != null && response['code'] == 0) {
        List<Map<String, dynamic>> members = List<Map<String, dynamic>>.from(
          response['content'] ?? [],
        );

        if (widget.excludedProfileIds != null &&
            widget.excludedProfileIds!.isNotEmpty) {
          members = members
              .where((member) =>
                  !widget.excludedProfileIds!.contains(member['profileId']))
              .toList();
        }

        setState(() {
          _members = members;
          _filteredMembers = members;
        });
      }
    } catch (e) {
      print('Error loading members: $e');
      // Xử lý lỗi, ví dụ hiển thị SnackBar
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterMembers(String searchText) {
    if (searchText.isEmpty) {
      _filteredMembers = _members;
    } else {
      _filteredMembers = _members.where((member) {
        final fullName = member['fullName']?.toString().toLowerCase() ?? '';
        final email = member['email']?.toString().toLowerCase() ?? '';
        final searchLower = searchText.toLowerCase();
        return fullName.contains(searchLower) || email.contains(searchLower);
      }).toList();
    }
    setState(() {});
  }

  Future<void> _assignMember(Map<String, dynamic> member) async {
    if (widget.conversationId == null) {
      // Nếu không có conversationId, chỉ gọi callback
      if (widget.onMemberSelected != null) {
        widget.onMemberSelected!(member);
      }
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isAssigning = true;
    });

    try {
      final response = await _convApi.assignTo(
        widget.conversationId!,
        member['profileId'],
      );

      if (response != null && response['code'] == 0) {
        // Thành công
        if (widget.onMemberSelected != null) {
          widget.onMemberSelected!(member);
        }
        Navigator.of(context).pop();

        // Hiển thị thông báo thành công
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã gán ${member['fullName']} vào cuộc trò chuyện'),
              backgroundColor: Colors.green,
            ),
          );

          // Gọi callback để reload page
          if (widget.onAssignmentSuccess != null) {
            widget.onAssignmentSuccess!();
          }
        }
      } else {
        // Lỗi từ API
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Lỗi: ${response?['message'] ?? 'Không thể gán thành viên'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error assigning member: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAssigning = false;
        });
      }
    }
  }

  Widget _buildActionButton(Map<String, dynamic> member) {
    final memberId = member['profileId']?.toString();
    final isAssigned =
        widget.assignedId != null && memberId == widget.assignedId;

    if (isAssigned) {
      // Nút xám "Đã mời" khi đã được assign
      return _buildCommonButton(
        text: 'Đã mời',
        backgroundColor: Colors.grey[300]!,
        textColor: Colors.grey,
        onTap: null,
        isLoading: false,
      );
    }

    // Nút tím "Thêm" khi chưa được assign
    return _buildCommonButton(
      text: 'Thêm',
      backgroundColor:
          _isAssigning ? Colors.grey[400]! : const Color(0xFF554FE8),
      textColor: Colors.white,
      onTap: _isAssigning ? null : () => _assignMember(member),
      isLoading: _isAssigning,
    );
  }

  Widget _buildCommonButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    VoidCallback? onTap,
    required bool isLoading,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 37,
        width: 65,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }

  Widget _buildAvatar(String? avatarUrl, String fullName) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: avatarUrl,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          backgroundImage: imageProvider,
          radius: 20,
        ),
        placeholder: (context, url) => CircleAvatar(
          backgroundColor: Colors.grey[200],
          radius: 20,
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          backgroundColor: Colors.purple.shade100,
          radius: 20,
          child: Text(
            fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else {
      return CircleAvatar(
        backgroundColor: Colors.purple.shade100,
        radius: 20,
        child: Text(
          fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  // ===================================================================
  // PHẦN THAY ĐỔI CHÍNH NẰM Ở ĐÂY
  // ===================================================================
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          const Text(
            'Chọn người phụ trách',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Search bar
          TextField(
            controller: _searchController,
            onChanged: _filterMembers,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo tên hoặc email',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Members list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMembers.isEmpty
                    ? const Center(
                        child: Text(
                          'Không tìm thấy thành viên nào',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredMembers.length,
                        itemBuilder: (context, index) {
                          final member = _filteredMembers[index];
                          final fullName = member['fullName'] ?? '';
                          final email = member['email'] ?? '';
                          final avatar = member['avatar'];

                          return ListTile(
                            leading: _buildAvatar(avatar, fullName),
                            title: Text(
                              fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: email.isNotEmpty ? Text(email) : null,
                            trailing: _buildActionButton(member),
                          );
                        },
                      ),
          ),

          // Cancel button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
          ),
        ],
      ),
    );
  }
}

// Lớp giả lập để code chạy được, bạn không cần copy phần này
// class OrganApi {
//   Future<Map<String, dynamic>> getOrgMembersForSelection({
//     String? searchText,
//     int? offset,
//     int? limit,
//     int? status,
//   }) async {
//     await Future.delayed(const Duration(seconds: 1));
//     return {
//       "code": 0,
//       "content": [
//         {'profileId': '1', 'fullName': 'Nguyễn Văn A', 'email': 'a.nguyen@example.com', 'avatar': 'https://i.pravatar.cc/150?img=1'},
//         {'profileId': '2', 'fullName': 'Trần Thị B', 'email': 'b.tran@example.com', 'avatar': 'https://i.pravatar.cc/150?img=2'},
//         {'profileId': '3', 'fullName': 'Lê Văn C', 'email': 'c.le@example.com', 'avatar': ''},
//         {'profileId': '4', 'fullName': 'Phạm Thị D', 'email': 'd.pham@example.com', 'avatar': 'https://i.pravatar.cc/150?img=4'},
//       ]
//     };
//   }
// }
