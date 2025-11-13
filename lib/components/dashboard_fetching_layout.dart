import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DashboardFetching extends StatelessWidget {
  const DashboardFetching({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: Column(
        children: [
          GridView.count(
            shrinkWrap: true,
            childAspectRatio: 2.2,
            crossAxisCount: 2,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              buildContainer(),
              buildContainer(),
              buildContainer(),
              buildContainer(),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            width: double.infinity,
            height: 380,
            color: Colors.white,
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            width: double.infinity,
            height: 340,
            color: Colors.white,
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            width: double.infinity,
            height: 300,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

Widget buildSummaryFetching() {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    enabled: true,
    child: GridView.count(
      shrinkWrap: true,
      childAspectRatio: 2.2,
      crossAxisCount: 2,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        buildContainer(),
        buildContainer(),
        buildContainer(),
        buildContainer(),
      ],
    ),
  );
}

Widget buildChartFetching(height) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    enabled: true,
    child: Container(
      width: double.infinity,
      height: height,
      color: Colors.white,
    ),
  );
}

Container buildContainer() {
  return Container(
    height: 30,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
