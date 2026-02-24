import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:l4_seance_2/view/login_page.dart';
import 'package:l4_seance_2/view/card_page.dart'; // Nouvel import
import '../models/recipe.dart';
import '../recipe_service.dart';
import '../product_service.dart'; // Import du service panier

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final RecipeService _recipeService = RecipeService();
  final ProductService _productService =
      ProductService(); // Service pour le panier
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1C2C),
        title: Text(
          widget.recipe.title,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.recipe.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              cacheHeight: 300,
              cacheWidth: 1000,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 250,
                  color: Colors.grey[800],
                  child: const Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: Colors.grey[800],
                  child:
                      const Icon(Icons.image, color: Colors.white54, size: 50),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      Text(
                        '${widget.recipe.rating}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.favorite, color: Colors.red, size: 20),
                      Text(
                        '${widget.recipe.likes}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${widget.recipe.price.toStringAsFixed(2)} ${widget.recipe.currency}',
                        style: const TextStyle(
                          color: Color(0xFF00FF9D),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.recipe.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.recipe.fullDescription,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleAddToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FF9D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Ajouter au panier',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
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

  Future<void> _handleAddToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Rediriger vers la page de connexion
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Ajouter la recette au panier via ProductService
      await _productService.addToCart(
        widget.recipe.title,
        widget.recipe.fullDescription,
        widget.recipe.price,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        // Message de confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.recipe.title} ajouté au panier'),
            backgroundColor: Colors.green,
          ),
        );

        // Rediriger vers la page du panier
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CardPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout au panier : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
