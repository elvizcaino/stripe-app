import "package:meta/meta.dart";
import 'package:dio/dio.dart';
import 'package:stripe_payment/stripe_payment.dart';

import 'package:stripe_app/models/stripe_custom_response.dart';
import 'package:stripe_app/models/payment_intent_response.dart';

class StripeService {
  // Singleton
  StripeService._privateConstructor();
  static final StripeService _instance = StripeService._privateConstructor();
  factory StripeService() => _instance;

  String _paymentApiURL = "https://api.stripe.com/v1/payment_intents";
  static String _secretKey = "sk_test_51HPXUHKPeW3DGjXbFwdqsaJlsScox7QdDq7M2XTEeDbVJNngAQPxmwPP8mGnvhYQsnbcU1RhsURkBov0yuxOnoIV00yKOLCWvz";
  String _apiKey = "pk_test_51HPXUHKPeW3DGjXbKU90Lwue3JJRpAfSgMu0u5lPVNnwhWft84G26FoRMUsIbfCk7o5Zx0qFveweUxzRgxajijZm00ESenBz1C";

  final headerOptions = new Options(
    contentType: Headers.formUrlEncodedContentType,
    headers: {
      "Authorization": "Bearer ${StripeService._secretKey}"
    }
  );
  
  void init() {
    StripePayment.setOptions(
      StripeOptions(
        publishableKey: this._apiKey,
        androidPayMode: "test",
        merchantId: "test"
      )
    );
  }

  Future<StripeCustomResponse> pagarConTarjetaExistente({@required String amount, @required String currency, @required CreditCard card}) async {
    try {
      final paymentMethod = await StripePayment.createPaymentMethod(
        PaymentMethodRequest(card: card)
      );

      final res = await this._realizarCobro(
        amount: amount, 
        currency: currency, 
        paymentMethod: paymentMethod
      );

      return res;

    } catch (error) {
      return StripeCustomResponse(
        ok: false,
        msg: error.toString()
      );
    }
  }

  Future<StripeCustomResponse> pagarConNuevaTarjeta({@required String amount, @required String currency}) async {
    try {
      final paymentMethod = await StripePayment.paymentRequestWithCardForm(
        CardFormPaymentRequest()
      );

      final res = await this._realizarCobro(
        amount: amount, 
        currency: currency, 
        paymentMethod: paymentMethod
      );

      return res;

    } catch (error) {
      return StripeCustomResponse(
        ok: false,
        msg: error.toString()
      );
    }
  }

  Future<StripeCustomResponse> pagarConApplePayGooglePay({@required String amount, @required String currency}) async {
    try {
      final appleAmount = double.parse(amount) / 100;

      final token = await StripePayment.paymentRequestWithNativePay(
        androidPayOptions: AndroidPayPaymentRequest(
          totalPrice: amount,
          currencyCode: currency
        ), 
        applePayOptions: ApplePayPaymentOptions(
          countryCode: "US",
          currencyCode: currency,
          items: [
            ApplePayItem(
              label: "Super producto 1",
              amount: "$appleAmount"
            )
          ]
        )
      );

      final paymentMethod = await StripePayment.createPaymentMethod(
        PaymentMethodRequest(
          card: CreditCard(
            token: token.tokenId
          )
        )
      );

      final res = await this._realizarCobro(
        amount: amount, 
        currency: currency, 
        paymentMethod: paymentMethod
      );

      await StripePayment.completeNativePayRequest();

      return res;

    } catch (error) {
      print("Error en inteto: ${error.toString()}");

      return StripeCustomResponse(
        ok: false,
        msg: error.toString()
      );
    }
  }

  Future<PaymentIntentResponse> _crearPaymentIntent({@required String amount, @required String currency}) async {
    try {
      final dio = Dio();
      final data = {
        "amount": amount,
        "currency": currency
      };

      final res = await dio.post(
        this._paymentApiURL,
        data: data,
        options: headerOptions
      );

      return PaymentIntentResponse.fromJson(res.data);

    } catch (error) {
      print("Error en intento: ${error.toString()}");
      return PaymentIntentResponse(
        status: "400",
      );
    }
  }

  Future<StripeCustomResponse> _realizarCobro({@required String amount, @required String currency, @required PaymentMethod paymentMethod}) async {
    try {
      final paymentIntent = await this._crearPaymentIntent(
        amount: amount, 
        currency: currency
      );

      final paymentResult = await StripePayment.confirmPaymentIntent(
        PaymentIntent(
          clientSecret: paymentIntent.clientSecret,
          paymentMethodId: paymentMethod.id
        )
      );

      if(paymentResult.status == "succeeded") {
        return StripeCustomResponse(ok: true);
      } else {
        return StripeCustomResponse(
          ok: false,
          msg: "Falló: ${paymentResult.status}"
        );
      }

    } catch (error) {
      print(error.toString());

      return StripeCustomResponse(
        ok: false, 
        msg: error.toString()
      );
    }
    
  }

}