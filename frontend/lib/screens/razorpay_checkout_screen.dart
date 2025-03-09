import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class RazorpayCheckoutScreen extends StatefulWidget {
  @override
  _RazorpayCheckoutScreenState createState() => _RazorpayCheckoutScreenState();
}

class _RazorpayCheckoutScreenState extends State<RazorpayCheckoutScreen> {
  late InAppWebViewController webViewController;
  late PullToRefreshController pullToRefreshController;

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(color: Colors.blue),
      onRefresh: () async {
        await webViewController.reload();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Razorpay Checkout")),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(
              "https://checkout.razorpay.com/v1/checkout.js"), // Use Razorpay URL
        ),
        initialOptions: InAppWebViewGroupOptions(
          android: AndroidInAppWebViewOptions(
            useHybridComposition: true, // Enable Hybrid Composition
          ),
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
            supportZoom: false,
            useShouldOverrideUrlLoading: true,
          ),
        ),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        pullToRefreshController: pullToRefreshController,
        onLoadStop: (controller, url) {
          pullToRefreshController.endRefreshing();
        },
        onConsoleMessage: (controller, consoleMessage) {
          print(consoleMessage);
        },
      ),
    );
  }
}
