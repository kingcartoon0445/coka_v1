import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ZaloWebView extends StatefulWidget {
  final String apiToken;
  final String projectId;

  const ZaloWebView(
      {super.key, required this.apiToken, required this.projectId});

  @override
  State<ZaloWebView> createState() => _ZaloWebViewState();
}

class _ZaloWebViewState extends State<ZaloWebView> {
  InAppWebViewController? webView;
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
