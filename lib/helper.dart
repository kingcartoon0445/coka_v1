import 'package:coka/api/api_url.dart';
import 'package:flutter/material.dart';

class Helpers {
  static String getAvatarUrl(String? imgData) {
    if (imgData == null || imgData.isEmpty) return '';
    if (imgData.contains('https')) return imgData;
    return '${apiBaseUrl}$imgData';
  }

  static Color getColorFromText(String text) {
    final List<Color> colors = [
      const Color(0xFF1E88E5), // Blue
      const Color(0xFFE53935), // Red
      const Color(0xFF43A047), // Green
      const Color(0xFF8E24AA), // Purple
      const Color(0xFFFFB300), // Amber
      const Color(0xFF00897B), // Teal
      const Color(0xFF3949AB), // Indigo
      const Color(0xFFD81B60), // Pink
      const Color(0xFF6D4C41), // Brown
      const Color(0xFF546E7A), // Blue Grey
    ];

    // Tính tổng mã ASCII của các ký tự trong text
    int sum = 0;
    for (int i = 0; i < text.length; i++) {
      sum += text.codeUnitAt(i);
    }

    // Lấy màu dựa trên phần dư của tổng với số lượng màu
    return colors[sum % colors.length];
  }
}
