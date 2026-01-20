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
    return PaymentResponse(
      success: json['success'] ?? false,
      transactionId: json['transactionId'] ?? json['transaction_id'] ?? '',
      reference: json['reference'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      status: json['status'] ?? 'PENDING',
      message: json['message'] ?? '',
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
