import 'package:flutter/material.dart';

ThemeData theme(BuildContext context) {
  return ThemeData(
    scaffoldBackgroundColor: const Color(0xFFFAF8FD),
    navigationDrawerTheme: const NavigationDrawerThemeData(),
    searchBarTheme: const SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(Colors.white),
        overlayColor: WidgetStatePropertyAll(Colors.white),
        padding: WidgetStatePropertyAll(EdgeInsets.only(left: 14)),
        elevation: WidgetStatePropertyAll(0)),
    // tabBarTheme: const TabBarTheme(
    //   labelColor: Color(0xFF554FE8),
    //   indicatorColor: Color(0xFF554FE8),
    // ),
    searchViewTheme: const SearchViewThemeData(
      backgroundColor: Color(0xFFF2F3F5),
      surfaceTintColor: Color(0xFFF2F3F5),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xfffddacc),
            textStyle: const TextStyle(color: Colors.black))),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.white),
    useMaterial3: true,
    fontFamily: 'GoogleSans',
    canvasColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white, // Màu nền cho tất cả AppBar
    ),
    // colorScheme: ThemeData().colorScheme.copyWith(
    //   primary: kPrimaryColor,
    // ),
    // inputDecorationTheme: inputDecorationTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
    color: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black),
  );
}
