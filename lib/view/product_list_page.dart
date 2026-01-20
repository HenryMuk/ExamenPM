import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../product_service.dart';

class ProductListPage extends StatelessWidget {
  final ProductService _productService = ProductService();

  ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    "Liste des produits",
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  backgroundColor: const Color(0xFF1F1C2C),
  iconTheme: const IconThemeData(color: Colors.white),
),

      backgroundColor: const Color(0xFF0E1115),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: _productService.getProducts(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text("Erreur: ${snapshot.error}", style: const TextStyle(color: Colors.white));
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final docs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var data = docs[index].data() as Map<String, dynamic>;
                return Card(
                  color: const Color(0xFF1A1D22),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    title: Text(
                      data['nom'] ?? "",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      data['description'] ?? "",
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                    trailing: Text(
                      "${data['prix'] ?? 0} \$",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
