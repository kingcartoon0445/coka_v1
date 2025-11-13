import 'dart:async';
import 'dart:math';

import 'package:coka/api/webform.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

import '../../components/awesome_alert.dart';

class CrmController extends GetxController {
  HomeController mainController = Get.put(HomeController());
  final contacts = <Contact>[].obs;
  final filteredContacts = <Contact>[].obs;
  final ScrollController sc = ScrollController();
  final currentAlphabet = 'A'.obs;
  final websiteList = [].obs;
  final isWebsiteLegit = false.obs;
  final isContactLoading = false.obs;
  final itemsPerPage = 10.obs; // Số lượng phần tử load mỗi lần
  final itemCount = 10.obs; // Tổng số lượng phần tử đã load
  Timer? _debounce;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    sc.addListener(() {
      print(sc.position);

      if (sc.position.pixels >= sc.position.maxScrollExtent) {
        if (itemCount < filteredContacts.length) {
          loadMoreData();
          print("loadmore");
          print(itemCount);
        }
      }
    });
  }

  onSearchChanged(String query) {
    if (query == "") {
      itemCount.value = 10;
      update();
    }
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (query.isEmpty) {
        // show all contacts when the search query is empty
        filteredContacts.value = contacts;
        return;
      }

      // filter the list of contacts based on the search query
      List<Contact> filtered = [];
      for (var contact in contacts) {
        if (contact.phones.isEmpty) {
          continue;
        }
        if (contact.displayName.toLowerCase().contains(query.toLowerCase()) ==
            true) {
          filtered.add(contact);
        } else if (contact.phones[0].number.contains(query) == true) {
          filtered.add(contact);
        }
      }
      filteredContacts.value = filtered;
    });
  }

  void loadMoreData() {
    itemCount.value += itemsPerPage.value;
    update();
  }

  Future<void> refreshContacts() async {
    contacts.value = await FlutterContacts.getContacts(withProperties: true);

    for (var x in contacts) {
      if (x.phones.isNotEmpty) {
        x.phones[0].number =
            x.phones[0].number.replaceAll(' ', '').replaceFirst('+84', "0");
      }
    }
    isContactLoading.value = false;
    filteredContacts.value = contacts;
  }

  Future fetchWebsiteList() async {
    WebformApi()
        .getWebsiteList(mainController.workGroupCardDataValue['id'])
        .then((res) {
      if (isSuccessStatus(res['code'])) {
        websiteList.value = res['content'];
      } else {
        errorAlert(title: 'Lỗi', desc: res['message']);
      }
    });
    update();
  }

  List<Color> generateColorList(int n) {
    final colors = [
      const Color(0xFFF1548B),
      const Color(0xFFF7706E),
      const Color(0xFFF2BE18),
      const Color(0xFF60AEFF),
      const Color(0xFF54D3EC),
    ];

    final shuffledColors =
        List<Color>.generate(n, (index) => colors[index % colors.length])
          ..shuffle(Random());

    return shuffledColors;
  }
}
