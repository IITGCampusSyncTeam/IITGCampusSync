import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../apis/payments/payment_api.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  String razorpayKey = "";
  String orderId = "";

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    // Listen for payment events
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Fetch Razorpay Key from Backend
    loadRazorpayKey();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> loadRazorpayKey() async {
    String? key = await PaymentAPI.fetchRazorpayKey();
    if (key != null) {
      setState(() {
        razorpayKey = key;
      });
    }
  }

  Future<void> createOrder(String amount) async {
    String? id = await PaymentAPI.createOrder(amount);
    if (id != null) {
      orderId = id;
      openCheckout(amount);
    } else {
      print("Failed to create order");
    }
  }

  void openCheckout(String amount) {
    var options = {
      'key': razorpayKey,
      'amount': int.parse(amount) * 100,
      'order_id': orderId,
      'name': 'campus sync',
      'description': 'Payment for Order',
      'prefill': {'contact': '9876543210', 'email': 'user@example.com'},
      'theme': {'color': '#3399cc'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("Error: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    bool success = await PaymentAPI.verifyPayment(
        orderId, response.paymentId!, response.signature!);
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Payment Successful!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment Verification Failed!")));
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Failed: ${response.message}")));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet: ${response.walletName}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Razorpay Payment")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => createOrder("1"),
          child: Text("Pay ₹1"),
        ),
      ),
    );
  }
}
