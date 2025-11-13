import 'package:coka/screen/crm_customer/crm_customer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/elevated_btn.dart';


class BuildCustomerCategory extends StatelessWidget {
  final int index;
  const BuildCustomerCategory({super.key, required this.index});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<CrmCustomerController>(
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.only(right: 14.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  controller.currentPage.value == index
                      ? Container(
                    height: 4,
                    width: 64,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF7706E),
                        borderRadius: BorderRadius.circular(5)),
                  )
                      : Container(height: 4,),
                  ElevatedBtn(
                    paddingAllValue: 3,
                    circular: 2,
                    onPressed: () {
                      controller.currentPage.value = index;
                      controller.pageController.jumpToPage(index);

                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 7),
                          child: SizedBox(
                            width: 60,
                            child: Text(
                              controller.isReadList[index][0],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: controller.currentPage.value == index
                                    ? const Color(0xFFF7706E)
                                    : const Color(0xFF828282),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
              if(controller.isReadList[index][1]!=''&& controller.isReadList[index][1]!='0')Positioned(
                top: 5,
                right: 0,
                child: Container(
                  width: 20,
                  height: 14,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: Color(0xFFf22128),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8))
                  ),
                  child: Text(controller.isReadList[index][1],style: const TextStyle(color: Colors.white,fontSize: 10, fontWeight: FontWeight.bold
                  ),),
                ),
              ),
            ],
          ),
        );
      },
    );

  }
}

