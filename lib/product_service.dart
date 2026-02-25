import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../product_service.dart';
import 'payment_service.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  final ProductService _productService = ProductService();
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mon Panier'),
          backgroundColor: const Color(0xFF1F1C2C),
        ),
        body: const Center(
          child: Text(
            'Veuillez vous connecter pour voir votre panier',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mon Panier",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1F1C2C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF0E1115),
      body: StreamBuilder<QuerySnapshot>(
        stream: _productService.streamCartItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Erreur : ${snapshot.error}",
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF928DAB)),
            );
          }

          final cartDocs = snapshot.data?.docs ?? [];
          if (cartDocs.isEmpty) {
            return _buildEmptyCart();
          }

          double total = 0.0;
          for (var doc in cartDocs) {
            final data = doc.data() as Map<String, dynamic>;
            total += (data['prix'] ?? 0).toDouble();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartDocs.length,
                  itemBuilder: (context, index) {
                    final doc = cartDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildCartItem(doc.id, data);
                  },
                ),
              ),
              _buildTotalBar(total),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(String docId, Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1F1C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF928DAB).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_bag, color: Colors.white70),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['nom'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['description'] ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${(data['prix'] ?? 0).toStringAsFixed(2)} €",
                    style: const TextStyle(
                      color: Color(0xFF928DAB),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white70),
              onPressed: () => _removeItem(docId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            "Votre panier est vide",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Ajoutez des recettes depuis la page d'accueil",
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF928DAB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Découvrir des recettes"),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBar(double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1C2C),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                "${total.toStringAsFixed(2)} €",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF928DAB),
              foregroundColor: Colors.white,
              minimumSize: const Size(150, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PaymentPage()),
              );
            },
            child: const Text("Valider"),
          ),
        ],
      ),
    );
  }

  Future<void> _removeItem(String itemId) async {
    try {
      await _productService.removeFromCart(itemId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la suppression : $e")),
      );
    }
  }
}
