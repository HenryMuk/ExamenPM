class PaymentRequest {
  final String reference;
  final double amount;
  final String currency;
  final String description;
  final String phoneNumber;
  final String providerCode;
  final String country;
  final String? callbackUrl;

  PaymentRequest({
    required this.reference,
    required this.amount,
    this.currency = 'USD',
    this.description = 'Paiement simulation',
    required this.phoneNumber,
    this.providerCode = 'ORANGE',
    this.country = 'CD',
    this.callbackUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'amount': amount,
      'currency': currency,
      'description': description,
      'phone': phoneNumber,
      'provider_code': providerCode,
      'country': country,
      'callback_url': callbackUrl ?? 'https://example.com/callback',
    };
  }
}

class PaymentResponse {
  final bool success;
  final String transactionId;
  final String reference;
  final double amount;
  final String currency;
  final String status;
  final String message;
  final DateTime timestamp;

  PaymentResponse({
    required this.success,
    required this.transactionId,
    required this.reference,
    required this.amount,
    this.currency = 'USD',
    required this.status,
    required this.message,
    required this.timestamp,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    // Try to parse several possible API response shapes (flat or nested under `results`).
    final results = json['results'] is Map<String, dynamic> ? json['results'] as Map<String, dynamic> : null;

    String status = 'PENDING';
    if (json['status'] != null) {
      status = (json['status'] as String).toUpperCase();
    } else if (results != null) {
      final st = results['status'];
      if (st is Map && st['name'] != null) {
        status = (st['name'] as String).toUpperCase();
      } else if (st is String) {
        status = st.toUpperCase();
      }
    }

    final transactionId = json['orderNumber'] ?? json['transactionId'] ?? json['transaction_id'] ?? '';
    final reference = json['reference'] ?? '';

    double amount = 0;
    String currency = 'USD';
    String message = json['message'] ?? '';

    if (json['amount'] != null) {
      try {
        amount = (json['amount'] as num).toDouble();
      } catch (_) {}
    }

    if (results != null) {
      final details = results['details'];
      if (details is Map<String, dynamic>) {
        if (details['amount'] != null) {
          try {
            amount = (details['amount'] as num).toDouble();
          } catch (_) {}
        }
        if (details['currency'] != null) {
          currency = details['currency'] as String;
        }
      }

      // message / description might be in results.status.description
      final st = results['status'];
      if (st is Map && st['description'] != null && (message == '' || message == null)) {
        message = st['description'] as String;
      }
    }

    return PaymentResponse(
      success: json['success'] ?? false,
      transactionId: transactionId ?? '',
      reference: reference ?? '',
      amount: amount,
      currency: currency,
      status: status,
      message: message ?? '',
      timestamp: DateTime.now(),
    );
  }
}

class PaymentStatus {
  final String reference;
  final String status;
  final String? errorMessage;

  PaymentStatus({
    required this.reference,
    required this.status,
    this.errorMessage,
  });
}
