import 'package:coka/components/elevated_btn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RouteConfigLog extends StatefulWidget {
  final String? teamId;
  const RouteConfigLog({super.key, this.teamId});

  @override
  State<RouteConfigLog> createState() => _RouteConfigLogState();
}

class _RouteConfigLogState extends State<RouteConfigLog> {
  String dateString = "Toàn bộ thời gian";
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 10000));
  DateTime toDate = DateTime.now().add(const Duration(days: 10000));
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // buildDatePickerBtn(context),
        ],
      ),
    );
  }

  Widget buildDatePickerBtn(BuildContext context) {
    final now = DateTime.now();
    return MenuAnchor(
      style: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(Colors.white),
          maximumSize: WidgetStatePropertyAll(Size(Get.width - 32, 350)),
          padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 30))),
      menuChildren: [
        MenuItemButton(
          child: const Text("Hôm nay",
              style: TextStyle(color: Colors.black, fontSize: 14)),
          onPressed: () {
            fromDate = DateTime(now.year, now.month, now.day);
            toDate = fromDate.add(const Duration(days: 1));
            dateString = "Hôm nay";
            setState(() {});
          },
        ),
        MenuItemButton(
          child: const Text("Hôm qua",
              style: TextStyle(color: Colors.black, fontSize: 14)),
          onPressed: () {
            fromDate = DateTime(now.year, now.month, now.day)
                .subtract(const Duration(days: 1));
            toDate = DateTime(now.year, now.month, now.day - 1);
            dateString = "Hôm qua";
            setState(() {});
          },
        ),
        MenuItemButton(
          child: const Text("7 ngày qua",
              style: TextStyle(color: Colors.black, fontSize: 14)),
          onPressed: () {
            fromDate = DateTime.now().subtract(const Duration(days: 7));
            toDate = DateTime.now().add(const Duration(days: 1));
            dateString = "7 ngày qua";
            setState(() {});
          },
        ),
        MenuItemButton(
          child: const Text("30 ngày qua",
              style: TextStyle(color: Colors.black, fontSize: 14)),
          onPressed: () {
            fromDate = DateTime.now().subtract(const Duration(days: 30));
            toDate = DateTime.now().add(const Duration(days: 1));
            dateString = "30 ngày qua";
            setState(() {});
          },
        ),
        MenuItemButton(
          child: const Text("Năm nay",
              style: TextStyle(color: Colors.black, fontSize: 14)),
          onPressed: () {
            fromDate = DateTime.now().subtract(const Duration(days: 365));
            toDate = DateTime.now().add(const Duration(days: 1));
            dateString = "Năm nay";
            setState(() {});
          },
        ),
        MenuItemButton(
          child: const Text("Toàn bộ thời gian",
              style: TextStyle(color: Colors.black, fontSize: 14)),
          onPressed: () {
            fromDate = DateTime.now().subtract(const Duration(days: 10000));
            toDate = DateTime.now().add(const Duration(days: 10000));
            dateString = "Toàn bộ thời gian";
            setState(() {});
          },
        ),
        MenuItemButton(
          child: const Text("Phạm vị ngày tùy chỉnh",
              style: TextStyle(color: Colors.black, fontSize: 14)),
          onPressed: () {
            showDateRangePicker(
                    context: context,
                    initialDateRange: DateTimeRange(
                      start: DateTime.now().subtract(const Duration(days: 30)),
                      end: DateTime.now().add(const Duration(days: 1)),
                    ),
                    firstDate: DateTime(2018),
                    lastDate: DateTime(2030))
                .then((dateRange) {
              if (dateRange != null) {
                fromDate = dateRange.start;
                toDate = dateRange.end;
                dateString =
                    "${DateFormat("dd-MM-yyyy").format(dateRange.start)} đến ${DateFormat("dd-MM-yyyy").format(dateRange.end)}";
              }
              setState(() {});
            });
          },
        )
      ],
      builder: (context, c, child) => ElevatedBtn(
        onPressed: () {
          if (c.isOpen) {
            c.close();
          } else {
            c.open();
          }
        },
        paddingAllValue: 0,
        circular: 12,
        child: FittedBox(
          child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE3DFFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    color: Color(0xFF5C33F0),
                    size: 20,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    dateString,
                    style: const TextStyle(
                        color: Color(0xFF2C160C),
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
