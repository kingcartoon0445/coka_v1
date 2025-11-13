// import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class CustomerOverlayWidget extends StatefulWidget {
  const CustomerOverlayWidget({super.key});

  @override
  State<CustomerOverlayWidget> createState() => _CustomerOverlayWidgetState();
}

class _CustomerOverlayWidgetState extends State<CustomerOverlayWidget> {
  Map notifyData = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      setState(() {
        notifyData = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            color: Colors.white70,
          ),
          height: 600,
          width: screenWidth * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        FlutterOverlayWindow.closeOverlay();
                      },
                      icon: const Icon(Icons.close)),
                  Text(
                    notifyData["title"] ?? "",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(notifyData["body"] ?? ""),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: FilledButton.tonalIcon(
                      onPressed: () async {
                        // await DeviceApps.openApp('com.azvidi.coka');

                        FlutterOverlayWindow.closeOverlay();

                        // final homeController = Get.put(HomeController());
                        //
                        // Timer(const Duration(milliseconds: 1000), () async {
                        //   final dataNotify = jsonDecode(notifyData["metadata"]);
                        //   final prefs = await SharedPreferences.getInstance();
                        //   await changeWorkspace(
                        //       homeController, dataNotify, prefs);
                        //   // Get.toNamed('/workspaceMain',
                        //   //     arguments: {"defaultIndex": 1});
                        //   final notifyController =
                        //       Get.put(NotificationController());
                        //   notifyController.onRefresh();
                        // });
                      },
                      icon: const Icon(
                        Icons.send,
                      ),
                      label: const Text("Truy cập ứng dụng")),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
