import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../api/hub.dart';
import '../../../components/custom_snackbar.dart';
import '../../../components/loading_dialog.dart';
import '../../../constants.dart';

class UpdateFeedMessBottomSheet extends StatefulWidget {
  final Map dataItem;
  const UpdateFeedMessBottomSheet({super.key, required this.dataItem});

  @override
  State<UpdateFeedMessBottomSheet> createState() => _UpdateFeedMessBottomSheetState();
}

class _UpdateFeedMessBottomSheetState extends State<UpdateFeedMessBottomSheet> {
  bool _secondSwitchValue = false;
  bool _thirdSwitchValue = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    HubApi().getHubDetail(widget.dataItem['id']).then((res) {

      if(isSuccessStatus(res['code'])){
        setState(() {
          _secondSwitchValue = res['content']['message'];
          _thirdSwitchValue = res['content']['feed'];
        });
      }
      else{
        failSnackbar(text: res['message'], context: context);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/icons/message_icon.svg',width: 35,height: 35,),
                      const SizedBox(width: 3,),
                      const Text('Tin nhắn',style: TextStyle(fontSize: 15)),

                    ],
                  ),
                  const SizedBox(height: 2,),
                  Switch(
                    value: _secondSwitchValue,
                    thumbColor: const WidgetStatePropertyAll(Colors.white),
                    onChanged:(bool value) {
                      showLoadingDialog(Get.context!);
                      setState(() {
                        _secondSwitchValue = value;
                      });
                      HubApi().updateHubFeedMess(widget.dataItem['id'], _thirdSwitchValue,value).then((res) {
                        Get.back();
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
                            _secondSwitchValue = !value;
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
                          _secondSwitchValue = !value;
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
                        });
                      });
                    },
                    activeColor: const Color(0xFFF7706E),
                    inactiveTrackColor: const Color(0xFFBCC1CA),
                  ),

                ],
              ),

              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/icons/ads_icon.svg',width: 35,height: 35,),
                      const SizedBox(width: 3,),
                      const Text('Bảng tin',style: TextStyle(fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 2,),
                  Switch(
                    value: _thirdSwitchValue,
                    thumbColor: const WidgetStatePropertyAll(Colors.white),
                    onChanged:(bool value) {
                      showLoadingDialog(Get.context!);
                      setState(() {
                        _thirdSwitchValue = value;
                      });
                      HubApi().updateHubFeedMess(widget.dataItem['id'], value,_secondSwitchValue).then((res) {
                        Get.back();
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
                        AwesomeDialog(
                          context: Get.context!,
                          animType: AnimType.leftSlide,
                          headerAnimationLoop: false,
                          dialogType: DialogType.error,
                          showCloseIcon: true,
                          title: 'Thất bại',
                          desc: e,
                          btnOkIcon: Icons.check_circle,
                          btnOkOnPress: () {
                            debugPrint('OnClcik');
                          },
                        ).show();
                      });
                    },
                    activeColor: const Color(0xFFF7706E),
                    inactiveTrackColor: const Color(0xFFBCC1CA),
                  ),

                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
