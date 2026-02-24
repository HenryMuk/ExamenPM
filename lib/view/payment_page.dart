import 'dart:async';
import 'package:flutter/material.dart';
import '../payment_service.dart';
import '../models/payment_request.dart';

class PaymentPage extends StatefulWidget {
  final String? productName;
  final String? productDescription;
  final double? productPrice;
  final String? currency;

  const PaymentPage({
    super.key,
    this.productName,
    this.productDescription,
    this.productPrice,
    this.currency = 'USD',
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _selectedProvider = 'ORANGE';
  String _selectedCurrency = 'USD';
  bool _isLoading = false;
  PaymentResponse? _paymentResult;

  final List<String> _providers = ['ORANGE', 'VODACOM', 'AIRTEL'];
  final List<String> _currencies = ['USD', 'CDF'];

  @override
  void dispose() {
    _statusTimer?.cancel();
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.productPrice != null) {
      _amountController.text = widget.productPrice!.toStringAsFixed(2);
    }
    if (widget.currency != null) {
      _selectedCurrency = widget.currency!;
    }
  }

  Timer? _statusTimer;

  Future<void> _processPayment() async {
    final phone = _phoneController.text.trim();
    final amountText = _amountController.text.trim();

    if (phone.isEmpty) {
      _showError('Veuillez entrer un numéro de téléphone');
      return;
    }

    if (!PaymentService.isValidPhoneNumber(phone)) {
      _showError('Numéro invalide. Format: +243... ou 0...');
      return;
    }

    if (amountText.isEmpty || double.tryParse(amountText) == null) {
      _showError('Veuillez entrer un montant valide');
      return;
    }

    final amount = double.parse(amountText);
    if (amount <= 0) {
      _showError('Le montant doit être supérieur à 0');
      return;
    }

    // Afficher popup de paiement initié
    _showPaymentInitiated();

    setState(() => _isLoading = true);

    try {
      final callback = 'https://us-central1-projet-blue-beam-l4.cloudfunctions.net/labyrintheCallback?phone=$phone';

      final paymentRequest = PaymentRequest(
        reference: PaymentService.generateReference(),
        amount: amount,
        currency: _selectedCurrency,
        description: widget.productName != null
            ? 'Paiement pour ${widget.productName}'
            : 'Paiement simulation Labyrinthe',
        phoneNumber: phone,
        providerCode: _selectedProvider,
        callbackUrl: callback,
      );

      final response = await PaymentService().initiatePayment(paymentRequest);

      setState(() {
        _paymentResult = response;
        _isLoading = false;
      });

      // Fermer la popup d'initiation
      Navigator.pop(context);

      // If initial status is pending, start polling check endpoint
      if (response.status.toUpperCase() == 'PENDING') {
        _startStatusPolling(response.reference);
        return;
      }

      if (response.success || response.status.toUpperCase() == 'SUCCESS') {
        _showPaymentSuccess('Paiement réussi !\nRéférence: ${response.reference}');
        // Retourner true pour indiquer le succès
        Navigator.pop(context, true);
      } else {
        _showPaymentFailed('Paiement échoué: ${response.message}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      // Fermer la popup d'initiation
      Navigator.pop(context);
      _showPaymentFailed('Erreur: ${e.toString()}');
    }
  }

  void _startStatusPolling(String reference) {
    _statusTimer?.cancel();
    int attempts = 0;
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      attempts++;
      if (attempts > 24) {
        timer.cancel();
        // Fermer la popup d'initiation si elle est encore ouverte et que le widget est monté
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        // Afficher la popup d'échec seulement si le widget est encore monté
        if (mounted) {
          _showPaymentFailed('Délai d\'attente dépassé pour la vérification du statut');
        }
        return;
      }

      final status = await PaymentService().checkPaymentStatus(reference);
      final s = status.status.toUpperCase();

      if (s == 'SUCCESS' || s == 'COMPLETED') {
        timer.cancel();
        setState(() {
          _paymentResult = PaymentResponse(
            success: true,
            transactionId: '',
            reference: reference,
            amount: double.tryParse(_amountController.text) ?? 0,
            currency: _selectedCurrency,
            status: 'SUCCESS',
            message: 'Paiement confirmé',
            timestamp: DateTime.now(),
          );
        });
        // Fermer la popup d'initiation si elle est encore ouverte et que le widget est monté
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        // Afficher la popup de succès seulement si le widget est encore monté
        if (mounted) {
          _showPaymentSuccess('Paiement confirmé avec succès !');
          Navigator.pop(context, true);
        }
      } else if (s == 'FAILED' || s == 'CANCELLED') {
        timer.cancel();
        setState(() {
          _paymentResult = PaymentResponse(
            success: false,
            transactionId: '',
            reference: reference,
            amount: double.tryParse(_amountController.text) ?? 0,
            currency: _selectedCurrency,
            status: 'FAILED',
            message: 'Paiement annulé',
            timestamp: DateTime.now(),
          );
        });
        // Fermer la popup d'initiation si elle est encore ouverte et que le widget est monté
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        // Afficher la popup d'échec seulement si le widget est encore monté
        if (mounted) {
          _showPaymentFailed('Paiement échoué');
        }
      } else {
        // still pending, update UI seulement si le widget est monté
        if (mounted) {
          setState(() {
            _paymentResult = PaymentResponse(
              success: false,
              transactionId: '',
              reference: reference,
              amount: double.tryParse(_amountController.text) ?? 0,
              currency: _selectedCurrency,
              status: 'PENDING',
              message: 'En attente',
              timestamp: DateTime.now(),
            );
          });
        }
      }
    });
  }

  void _showPaymentInitiated() {
    showDialog(
      context: context,
      barrierDismissible: true, // Permettre à l'utilisateur de fermer la popup
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D22),
        title: Text(
          'Paiement en cours',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF00FF9D)),
            const SizedBox(height: 16),
            Text(
              'Votre paiement est en cours de traitement...\nVeuillez patienter.',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Annuler le timer quand l'utilisateur ferme la popup
              _statusTimer?.cancel();
              Navigator.pop(context);
            },
            child: const Text('Annuler', style: TextStyle(color: Color(0xFF00FF9D))),
          ),
        ],
      ),
    ).then((_) {
      // Callback appelé quand la popup est fermée (par Annuler ou clic extérieur)
      // Annuler le timer pour éviter les popups inappropriées
      _statusTimer?.cancel();
      setState(() => _isLoading = false);
    });
  }

  void _showPaymentSuccess(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D22),
        title: Text(
          'Paiement réussi !',
          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF00FF9D))),
          ),
        ],
      ),
    );
  }

  void _showPaymentFailed(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D22),
        title: Text(
          'Paiement échoué',
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fermer la popup
              Navigator.pop(context, false); // Retourner false à recipe_detail_page
            },
            child: const Text('Réessayer', style: TextStyle(color: Color(0xFF00FF9D))),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D22),
        title: Text(
          'Erreur',
          style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF00FF9D))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<String>> providerItems = [];
    for (final provider in _providers) {
      providerItems.add(
        DropdownMenuItem(
          value: provider,
          child: Text(provider, style: const TextStyle(color: Colors.white)),
        ),
      );
    }

    final List<DropdownMenuItem<String>> currencyItems = [];
    for (final c in _currencies) {
      currencyItems.add(
        DropdownMenuItem(
          value: c,
          child: Text(c, style: const TextStyle(color: Colors.white)),
        ),
      );
    }
    return WillPopScope(
      onWillPop: () async {
        // Annuler le timer et fermer les popups avant de quitter la page
        _statusTimer?.cancel();
        // Fermer toutes les popups ouvertes
        if (Navigator.canPop(context)) {
          Navigator.pop(context); // Retourne null pour indiquer l'annulation
        }
        // Permettre la navigation arrière
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Effectuer un Paiement',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF1F1C2C),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0E1115),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1F1C2C),
                        const Color(0xFF928DAB),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 24),

                if (widget.productName != null) ...[
                  Text(
                    widget.productName!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (widget.productDescription != null)
                    Text(
                      widget.productDescription!,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Prix: ${widget.productPrice?.toStringAsFixed(2) ?? '0.00'} $_selectedCurrency',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                ],

                const Text(
                  'Opérateur',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1C2C),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      value: _selectedProvider,
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: const Color(0xFF1F1C2C),
                      items: providerItems,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedProvider = value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Devise',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1C2C),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      value: _selectedCurrency,
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: const Color(0xFF1F1C2C),
                      items: currencyItems,
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedCurrency = value);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Numéro de téléphone',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '+243 98 1234567',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.phone, color: Colors.white54),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF928DAB), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Montant ($_selectedCurrency)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '10.00',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.attach_money, color: Colors.white54),
                    suffixText: _selectedCurrency,
                    suffixStyle: const TextStyle(color: Colors.white54),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF928DAB), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF928DAB),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _processPayment,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Valider le paiement',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}