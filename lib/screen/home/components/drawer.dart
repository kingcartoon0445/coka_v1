import 'package:coka/components/navigation_drawer_section.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeDrawer extends StatelessWidget {
  final Function onCloseDrawer;
  const HomeDrawer({super.key, required this.onCloseDrawer});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (controller) {
      return Drawer(
        child: NavigationDrawerSection(
          onCloseDrawer: onCloseDrawer,
        ),
      );
    });
  }
}
