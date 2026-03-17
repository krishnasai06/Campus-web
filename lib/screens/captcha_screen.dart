import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../services/storage_service.dart';

class CaptchaScreen extends StatefulWidget {
  const CaptchaScreen({super.key});

  @override
  State<CaptchaScreen> createState() => _CaptchaScreenState();
}

class _CaptchaScreenState extends State<CaptchaScreen> {
  final GlobalKey webViewKey = GlobalKey();
  late InAppWebViewController webViewController;
  final CookieManager _cookieManager = CookieManager.instance();
  final StorageService _storage = StorageService();

  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solve Security Check'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => webViewController.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(
              url: WebUri("https://academia.srmist.edu.in/"),
            ),
            initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
              javaScriptEnabled: true,
              cacheEnabled: true,
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() => _isLoading = true);
            },
            onLoadStop: (controller, url) async {
              setState(() => _isLoading = false);
              
              // Check if we are redirected to the dashboard (success)
              if (url.toString().contains('dashboard') || 
                  url.toString().contains('My_Attendance')) {
                
                final cookies = await _cookieManager.getCookies(url: WebUri("https://academia.srmist.edu.in"));
                if (cookies.isNotEmpty) {
                  final cookieString = cookies.map((c) => '${c.name}=${c.value}').join('; ');
                  await _storage.saveSessionCookie(cookieString);
                  
                  // Return success to the login screen
                  if (mounted) Navigator.pop(context, true);
                }
              }
            },
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
