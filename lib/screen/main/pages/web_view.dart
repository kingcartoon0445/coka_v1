import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String urlWebView;
  final Function(Map<String, dynamic>) onSuccess;
  const WebViewScreen({
    super.key,
    required this.urlWebView,
    required this.onSuccess,
  });

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _loadingProgress = 0;
            });
          },
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _loadingProgress = 100;
            });
            // Inject JavaScript để intercept form submissions
            _controller.runJavaScript('''
              // Override form submission để gửi data qua channel thay vì navigate
              function interceptForms() {
                const forms = document.querySelectorAll('form');
                forms.forEach(form => {
                  form.addEventListener('submit', function(e) {
                    console.log('duy loggg: Form submitted');
                    if (window.ConsoleChannel && window.ConsoleChannel.postMessage) {
                      window.ConsoleChannel.postMessage('Form submitted');
                    }
                    e.preventDefault();
                    
                    // Simulate the response that would normally be shown
                    const responseData = {
                      "code": 0,
                      "content": "PAAY501TMBEABPdtUURqxshNoDFDxLuj2Tb6QbzKgnF5Okzcg09kX7xjMLelcuyHnBT2BXBGn1ZCkzZC3v98K3ZAVks4t1ZA0NxPk1wSZAeO2SLCtdL31MO9QgqE9l1mPziXB7nYKYFfHLzpZAyfLxaUMCu4I4M2lc02T30MUFLFZBBw5y8jsfzyJbgQXc9"
                    };
                    
                    // Send data to Flutter via JavaScript channel
                    if (window.JsonChannel && window.JsonChannel.postMessage) {
                      window.JsonChannel.postMessage(JSON.stringify(responseData));
                    }
                  });
                });
              }
              
              // Also handle direct button clicks for "Kết nối lại"
              function interceptButtons() {
                const buttons = document.querySelectorAll('button, input[type="submit"], a');
                buttons.forEach(button => {
                  if (button.textContent && button.textContent.includes('Kết nối')) {
                    button.addEventListener('click', function(e) {
                      console.log('duy loggg: Button clicked - Kết nối');
                      if (window.ConsoleChannel && window.ConsoleChannel.postMessage) {
                        window.ConsoleChannel.postMessage('Button clicked - Kết nối');
                      }
                      e.preventDefault();
                      
                      const responseData = {
                        "code": 0,
                        "content": "PAAY501TMBEABPdtUURqxshNoDFDxLuj2Tb6QbzKgnF5Okzcg09kX7xjMLelcuyHnBT2BXBGn1ZCkzZC3v98K3ZAVks4t1ZA0NxPk1wSZAeO2SLCtdL31MO9QgqE9l1mPziXB7nYKYFfHLzpZAyfLxaUMCu4I4M2lc02T30MUFLFZBBw5y8jsfzyJbgQXc9"
                      };
                      
                      if (window.JsonChannel && window.JsonChannel.postMessage) {
                        window.JsonChannel.postMessage(JSON.stringify(responseData));
                      }
                    });
                  }
                });
              }
              
              // Intercept all button clicks for logging
              function interceptAllClicks() {
                document.addEventListener('click', function(e) {
                  const target = e.target;
                  if (target.tagName === 'BUTTON' || 
                      target.tagName === 'INPUT' || 
                      target.tagName === 'A' ||
                      target.type === 'submit') {
                    const clickInfo = {
                      tagName: target.tagName,
                      text: target.textContent || target.value || target.innerText,
                      id: target.id,
                      className: target.className,
                      type: target.type
                    };
                    console.log('duy loggg: Element clicked -', clickInfo);
                    if (window.ConsoleChannel && window.ConsoleChannel.postMessage) {
                      window.ConsoleChannel.postMessage('Element clicked - ' + JSON.stringify(clickInfo));
                    }
                  }
                });
              }
              
              // Check if page shows JSON response directly
              function checkForJsonResponse() {
                const bodyText = document.body.textContent || document.body.innerText;
                if (bodyText.includes('"code":') && bodyText.includes('"content":')) {
                  try {
                    const jsonData = JSON.parse(bodyText);
                    if (window.JsonChannel && window.JsonChannel.postMessage) {
                      window.JsonChannel.postMessage(JSON.stringify(jsonData));
                    }
                  } catch (e) {
                    console.log('Failed to parse JSON from page:', e);
                  }
                }
              }
              
              // Run all interceptors
              setTimeout(() => {
                interceptForms();
                interceptButtons();
                interceptAllClicks();
                checkForJsonResponse();
              }, 500);
            ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            // Intercept navigation to JSON response pages
            if (request.url.contains('json') || request.url.contains('api')) {
              // Allow navigation but handle it specially
              return NavigationDecision.navigate;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'JsonChannel',
        onMessageReceived: (message) {
          final data = message.message;
          // print('Received JSON from WebView: $data');

          try {
            // Parse JSON
            final decoded = jsonDecode(data);
            // log('duy decoded: $decoded');

            // final content = decoded['content'];

            log('duy decoded: $decoded');

            if (decoded.containsKey('provider')) {
              setState(() {
                _isLoading = false;
              });
              Navigator.pop(
                context,
              );
              widget.onSuccess(decoded);
            }
            // print('duy Content: $content');
          } catch (e) {
            print('Error parsing JSON: $e');
          }
        },
      )
      ..addJavaScriptChannel(
        'ConsoleChannel',
        onMessageReceived: (message) {
          print('duy loggg: ${message.message}');
          setState(() {
            _isLoading = true;
          });
        },
      )
      ..loadRequest(Uri.parse(widget.urlWebView));
  }

  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
        ),
        // title: const Text('WebView'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3.0),
          child: _loadingProgress < 100
              ? LinearProgressIndicator(
                  value: _loadingProgress / 100.0,
                  backgroundColor: Colors.blueGrey,
                )
              : Container(),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
