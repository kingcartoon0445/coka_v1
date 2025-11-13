import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BannerPlaceholder extends StatelessWidget {
  const BannerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200.0,
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.white,
      ),
    );
  }
}

class TitlePlaceholder extends StatelessWidget {
  final double width;

  const TitlePlaceholder({
    super.key,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width,
            height: 12.0,
            color: Colors.white,
          ),
          const SizedBox(height: 8.0),
          Container(
            width: width,
            height: 12.0,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

enum ContentLineType {
  twoLines,
  threeLines,
}

class ListPlaceholder extends StatelessWidget {
  final int length;
  final double? contentHeight, avatarSize, bottomPadding;
  const ListPlaceholder(
      {super.key,
      required this.length,
      this.contentHeight,
      this.avatarSize,
      this.bottomPadding});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        enabled: true,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              for (var x = 0; x < length; x++)
                Padding(
                  padding:
                      EdgeInsets.only(top: 11.0, bottom: bottomPadding ?? 23.0),
                  child: ContentPlaceholder(
                    lineType: ContentLineType.twoLines,
                    contentHeight: contentHeight ?? 10,
                    avatarSize: avatarSize ?? 50,
                  ),
                )
            ],
          ),
        ));
  }
}

class ListCustomerPlaceholder extends StatelessWidget {
  final int length;
  const ListCustomerPlaceholder({super.key, required this.length});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        enabled: true,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(
                height: 10,
              ),
              for (var x = 0; x < length; x++) const PlaceholderItem()
            ],
          ),
        ));
  }
}

class ListJourneyPlaceholder extends StatelessWidget {
  final int length;
  const ListJourneyPlaceholder({super.key, required this.length});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        enabled: true,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(
                height: 10,
              ),
              for (var x = 0; x < length; x++) const JourneyPlaceholderItem(),
            ],
          ),
        ));
  }
}

class JourneyPlaceholderItem extends StatelessWidget {
  const JourneyPlaceholderItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 18.0, bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 16,
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Container(
              width: double.infinity, // Adjust the width to your preference
              height: 75,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(8)), // Placeholder background color
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceholderItem extends StatelessWidget {
  const PlaceholderItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150, // Adjust the width to your preference
                  height: 14,
                  color: Colors.white, // Placeholder background color
                ),
                const SizedBox(height: 4),
                Container(
                  width: 70, // Adjust the width to your preference
                  height: 14,
                  color: Colors.white, // Placeholder background color
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
              ),
              const SizedBox(
                height: 4,
              ),
              Container(
                width: 40, // Adjust the width to your preference
                height: 14,
                color: Colors.white, // Placeholder background color
              )
            ],
          )
        ],
      ),
    );
  }
}

class ContentPlaceholder extends StatelessWidget {
  final ContentLineType lineType;
  final double contentHeight, avatarSize;

  const ContentPlaceholder({
    super.key,
    required this.lineType,
    required this.contentHeight,
    required this.avatarSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 160,
                  height: contentHeight,
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 8.0),
                ),
                if (lineType == ContentLineType.threeLines)
                  Container(
                    width: 160,
                    height: contentHeight,
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 8.0),
                  ),
                Container(
                  width: 70.0,
                  height: contentHeight,
                  color: Colors.white,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
