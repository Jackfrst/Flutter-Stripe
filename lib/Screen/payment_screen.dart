import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe_payment/utils/model/stripe_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

import '../utils/constants/api_constants.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Map<String, dynamic>? paymentIntentData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Stripe Payment"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () async {
                await makePayment();
              },
              child: Container(
                height: 50,
                color: Colors.green,
                child: const Center(
                  child: Text(
                    'Pay',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
            InkWell(
              onTap: () async {

              },
              child: Container(
                height: 50,
                color: Colors.green,
                child: const Center(
                  child: Text(
                    'Add a Payment Method',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
            InkWell(
              onTap: () async {

              },
              child: Container(
                height: 50,
                color: Colors.green,
                child: const Center(
                  child: Text(
                    'Pay Now',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      paymentIntentData = await createPaymentIntent('20', 'USD');

      await Stripe.instance
          .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              setupIntentClientSecret: '$stripePrivateKey',
              paymentIntentClientSecret: paymentIntentData!['client_secret'],
              //applePay: PaymentSheetApplePay.,
              //googlePay: true,
              customerEphemeralKeySecret: paymentIntentData!['ephemeralKey'],
              customFlow: true,
              style: ThemeMode.light,
              merchantDisplayName: 'ARML',
            ),
          )
          .then((value) {});

      ///now finally display payment sheet
      displayPaymentSheet();
    } catch (e, s) {
      print('Payment exception:$e$s');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((newValue) async {
        await Stripe.instance.confirmPaymentSheetPayment();

        print('payment intent' + paymentIntentData!['id'].toString());
        print(
            'payment intent' + paymentIntentData!['client_secret'].toString());
        print('payment intent' + paymentIntentData!['amount'].toString());
        print('payment intent' + paymentIntentData.toString());

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("paid successfully")));

        paymentIntentData = null;
      }).onError((error, stackTrace) {
        print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Exception/DISPLAYPAYMENTSHEET==> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      print('$e');
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      StripeModel body = StripeModel(
        amount: calculateAmount('20'),
        currency: currency,
        paymentMethodTypes: 'card',
      );

      print(body.toJson());
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body.toJson(),
          headers: {
            'Authorization': 'Bearer $stripePrivateKey',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      print('Create Intent reponse -------${response.body.toString()}------');
      return jsonDecode(response.body);
    } catch (error) {
      print('error charging user: ${error.toString()}');
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }

}
