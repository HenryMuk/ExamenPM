import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/payment_request.dart';

class PaymentService {
  static const String apiUrl = 'https://api.labyrinthe-rdc.com/api/V1/payment/mobile';
  static const String apiKey = r'$2y$12$9LkDOkTwZAMfsiDO9MY4KuK77Rf8MsN9ZxSQlEABfLfjoijsopTOO';

  Future<PaymentResponse> initiatePayment(PaymentRequest request) async {
    try {
      print('Initiation paiement: ${request.reference}');
      print('Numéro: ${request.phoneNumber}');
      print('Montant: ${request.amount} ${request.currency}');


      final Map<String, dynamic> payload = {
        'api_key': apiKey,
        'token': apiKey,
        'reference': request.reference,
        'amount': request.amount,
        'currency': request.currency,
        'description': request.description,
        'phone': request.phoneNumber,
        'provider_code': request.providerCode,
        'country': request.country,
        'callback': request.callbackUrl ?? 'https://example.com/callback',
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(payload),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Délai d\'attente dépassé');
        },
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return PaymentResponse.fromJson(jsonResponse);
      } else {
        final errorBody = jsonDecode(response.body);
        return PaymentResponse(
          success: false,
          transactionId: '',
          reference: request.reference,
          amount: request.amount,
          currency: request.currency,
          status: 'FAILED',
          message: errorBody['message'] ?? 'Erreur lors du paiement',
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      print('Erreur: $e');
      return PaymentResponse(
        success: false,
        transactionId: '',
        reference: request.reference,
        amount: request.amount,
        currency: request.currency,
        status: 'ERROR',
        message: 'Erreur: ${e.toString()}',
        timestamp: DateTime.now(),
      );
    }
  }

  Future<PaymentStatus> checkPaymentStatus(String reference) async {
    try {
      final Map<String, dynamic> payload = {
        'api_key': apiKey,
        'reference': reference,
      };

      final response = await http.post(
        Uri.parse('$apiUrl/check'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Délai d\'attente dépassé');
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return PaymentStatus(
          reference: reference,
          status: jsonResponse['status'] ?? 'UNKNOWN',
        );
      } else {
        return PaymentStatus(
          reference: reference,
          status: 'FAILED',
          errorMessage: 'Impossible de vérifier le statut',
        );
      }
    } catch (e) {
      return PaymentStatus(
        reference: reference,
        status: 'ERROR',
        errorMessage: e.toString(),
      );
    }
  }

  static String generateReference() {
    return 'REF-${DateTime.now().millisecondsSinceEpoch}-${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }

  static bool isValidPhoneNumber(String phone) {
    final regex = RegExp(r'^\+?2430\d{8}$|^0\d{9}$');
    return regex.hasMatch(phone.replaceAll(' ', '').replaceAll('-', ''));
  }
}
