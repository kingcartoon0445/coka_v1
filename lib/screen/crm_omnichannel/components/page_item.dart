
import 'dart:convert';
import 'dart:typed_data';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:coka/api/hub.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'more_verticle_dropdown.dart';

class PageItem extends StatefulWidget {
  final Map dataItem;
  const PageItem({super.key, required this.dataItem});

  @override
  State<PageItem> createState() => _PageItemState();
}

class _PageItemState extends State<PageItem> {
  bool _firstSwitchValue = false;
  Uint8List? ava;
  @override
  void initState() {
    _firstSwitchValue = widget.dataItem['status']==1?true:false;
    ava = base64Decode(widget.dataItem['avatar']??defaultAvatar);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13.0),
      child: Container(padding: const EdgeInsets.all(16),decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFF3F4F6),width: 1)
      ),child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              image: DecorationImage(image: MemoryImage(ava!),fit: BoxFit.cover)
            ),
          ),
          const SizedBox(width: 16,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: Get.width*0.36,child: Text(widget.dataItem['name']??'',style: const TextStyle(color: Color(0xFF323842),fontSize: 16,fontWeight: FontWeight.bold),maxLines: 2,overflow: TextOverflow.ellipsis,)),
              const SizedBox(height: 4,),
              Text(widget.dataItem['provider']??'',style: const TextStyle(color: Color(0xFF9095A0),fontSize: 16),)
            ],
          ),
          const Spacer(),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MoreVerticalDropdown(dataItem: widget.dataItem),
              Switch(
                value: _firstSwitchValue,
                thumbColor: const WidgetStatePropertyAll(Colors.white),
                onChanged:(bool value) {
                  showLoadingDialog(Get.context!);
                  HubApi().updateHubStatus(widget.dataItem['id'], value?1:0).then((res) {
                    Get.back();
                    setState(() {
                      _firstSwitchValue = value;
                    });
                    if(isSuccessStatus(res['code'])){
                      AwesomeDialog(
                        context: Get.context!,
                        animType: AnimType.leftSlide,
                        headerAnimationLoop: false,
                        dialogType: DialogType.success,
                        showCloseIcon: true,
                        title: 'Cập nhật trạng thái thành công',
                        btnOkIcon: Icons.check_circle,
                        btnOkOnPress: () {
                          debugPrint('OnClcik');
                        },
                      ).show();
                    }
                    else{
                      setState(() {
                        _firstSwitchValue = !value;
                      });
                      AwesomeDialog(
                        context: Get.context!,
                        animType: AnimType.leftSlide,
                        headerAnimationLoop: false,
                        dialogType: DialogType.error,
                        showCloseIcon: true,
                        title: 'Thất bại',
                        desc: res['message'],
                        btnOkIcon: Icons.check_circle,
                        btnOkOnPress: () {
                          debugPrint('OnClcik');
                        },
                      ).show();
                    }

                  }).catchError((e){
                    Get.back();
                    setState(() {
                      _firstSwitchValue = !value;
                    });
                    AwesomeDialog(
                      context: Get.context!,
                      animType: AnimType.leftSlide,
                      headerAnimationLoop: false,
                      dialogType: DialogType.error,
                      showCloseIcon: true,
                      title: 'Thất bại',
                      desc: e.toString(),
                      btnOkIcon: Icons.check_circle,
                      btnOkOnPress: () {
                        debugPrint('OnClcik');
                      },
                    ).show();
                  });
                },
                activeColor: const Color(0xFFF7706E),
                inactiveTrackColor: const Color(0xFFBCC1CA),
              )

            ],
          )

        ],
      )),
    );
  }
}
