import 'package:coka/screen/crm/crm_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../components/elevated_btn.dart';
import 'connect_web_form_next.dart';

void connectWebFormLayout() {
  CrmController ct = Get.put(CrmController());
  ct.fetchWebsiteList();
  showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.white,
    constraints: BoxConstraints(maxHeight: Get.height - 45),
    shape: const RoundedRectangleBorder(
      // <-- SEE HERE
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20.0),
      ),
    ),
    context: Get.context!,
    builder: (BuildContext context) {
      return Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedBtn(
                    onPressed: () {
                      Get.back();
                    },
                    circular: 30,
                    paddingAllValue: 10,
                    child: SvgPicture.asset(
                      'assets/icons/back_arrow.svg',
                      height: 30,
                      width: 30,
                    )),
                const Text(
                  'Kết nối Web form',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                const Spacer(),
                ElevatedBtn(
                    onPressed: () {
                      connectWebFormNext();
                    },
                    circular: 50,
                    paddingAllValue: 3,
                    child: const Icon(
                      Icons.add,
                      color: Color(0xFFf7706e),
                      size: 30,
                    )),
                const SizedBox(
                  width: 15,
                )
              ],
            ),
            Container(
              height: 1,
              width: double.infinity,
              color: const Color(0xFFF3F4F6),
            ),
            ListView.builder(
              itemCount: ct.websiteList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) =>
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 20),

                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color(0xFFF7706E),
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(23.0),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/globe-hemisphere-west.svg',
                              color: Colors.white,
                              width: 25,
                              height: 25,
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Text(
                              ct.websiteList[index]['domain'],
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 25,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
            )
          ],
        );
      });
    },
  );
}
