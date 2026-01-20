import 'package:flutter/material.dart';
import '../product_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductAddPage extends StatefulWidget {
  const ProductAddPage({super.key});

  @override
  State<ProductAddPage> createState() => _ProductAddPageState();
}

class _ProductAddPageState extends State<ProductAddPage> {
  final ProductService _productService = ProductService();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    "Ajouter un produit",
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
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Nom du produit",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Description",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
            TextField(
              controller: _prixController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Prix",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF928DAB),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                setState(() => _isLoading = true);
                String nom = _nomController.text;
                String desc = _descriptionController.text;
                double prix = double.tryParse(_prixController.text) ?? 0;

                if (nom.isNotEmpty && prix > 0) {
                  await _productService.addProduct(nom, desc, prix);
                  _nomController.clear();
                  _descriptionController.clear();
                  _prixController.clear();

                  setState(() => _isLoading = false);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Produit ajouté avec succès")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Veuillez remplir correctement les champs")),
                  );
                }
              },
              child:  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                "Ajouter produit",
                style: 
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
