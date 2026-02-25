// view/product_add_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../product_service.dart';
import 'card_page.dart';
import 'login_page.dart'; // Ajouté pour la redirection

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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ajouter un produit",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1F1C2C),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Icône du panier avec navigation directe
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CardPage()),
                );
              } else {
                _showLoginRequiredSnackBar();
              }
            },
          ),
        ],
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
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);

                      String nom = _nomController.text.trim();
                      String desc = _descriptionController.text.trim();
                      double? prix =
                          double.tryParse(_prixController.text.trim());

                      if (nom.isNotEmpty && prix != null && prix > 0) {
                        try {
                          // Vérifier si l'utilisateur est connecté
                          if (user == null) {
                            if (mounted) {
                              setState(() => _isLoading = false);
                              _showLoginRequiredDialog();
                            }
                            return;
                          }

                          // Ajout du produit au panier (pas à la collection produits)
                          await _productService.addToCart(nom, desc, prix);

                          // Réinitialisation des champs
                          _nomController.clear();
                          _descriptionController.clear();
                          _prixController.clear();

                          if (mounted) {
                            setState(() => _isLoading = false);

                            // Message de succès
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Produit ajouté au panier avec succès"),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );

                            // Redirection vers la page du panier
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CardPage(),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            setState(() => _isLoading = false);

                            String errorMessage = "Erreur lors de l'ajout";
                            if (e.toString().contains('permission-denied')) {
                              errorMessage =
                                  "Permission refusée. Vérifiez les règles Firestore.";
                            } else if (e
                                .toString()
                                .contains('Utilisateur non connecté')) {
                              errorMessage =
                                  "Vous devez être connecté pour ajouter au panier";
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text("$errorMessage : ${e.toString()}"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      } else {
                        if (mounted) {
                          setState(() => _isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Veuillez remplir correctement tous les champs",
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      }
                    },
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Ajouter au panier", // Changé le texte
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            // Message d'information sur l'authentification
            if (user == null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Connectez-vous pour ajouter des produits au panier",
                        style: TextStyle(color: Colors.orange[200]),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        "Se connecter",
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1C2C),
        title: const Text(
          "Connexion requise",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Vous devez être connecté pour ajouter des produits au panier",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Annuler",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF928DAB),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text("Se connecter"),
          ),
        ],
      ),
    );
  }

  void _showLoginRequiredSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Connectez-vous pour voir votre panier"),
        action: SnackBarAction(
          label: "Connexion",
          textColor: Colors.orange,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.orange[900],
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    super.dispose();
  }
}
