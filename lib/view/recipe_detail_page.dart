import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:l4_seance_2/view/login_page.dart';
import 'package:l4_seance_2/view/payment_page.dart';
import '../models/recipe.dart';
import '../recipe_service.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final RecipeService _recipeService = RecipeService();
  bool _isPurchased = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPurchaseStatus();
  }

  Future<void> _checkPurchaseStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final purchasedIds = await _recipeService.getPurchasedRecipeIds(user.uid);
      setState(() {
        _isPurchased = purchasedIds.contains(widget.recipe.id);
      });
    }
  }

  Future<void> _handlePurchase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Rediriger vers la page de connexion
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    if (_isPurchased) {
      // Si déjà acheté, montrer les détails complets
      _showFullRecipe();
      return;
    }

    // Afficher popup de transaction initiée
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D22),
        title: Text(
          'Transaction initiée',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF00FF9D)),
            const SizedBox(height: 16),
            Text(
              'Votre paiement de ${widget.recipe.price.toStringAsFixed(2)} ${widget.recipe.currency} est en cours de traitement...',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    try {
      // Procéder au paiement
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentPage(
            productName: widget.recipe.title,
            productDescription: widget.recipe.fullDescription,
            productPrice: widget.recipe.price,
            currency: widget.recipe.currency,
          ),
        ),
      );

      // Fermer le popup de chargement
      Navigator.pop(context);

      if (result == true) {
        // Paiement réussi
        await _recipeService.purchaseRecipe(user.uid, widget.recipe.id);
        setState(() => _isPurchased = true);

        // Afficher popup de succès
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1D22),
            title: Text(
              'Paiement réussi !',
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Votre achat de "${widget.recipe.title}" a été confirmé. Vous pouvez maintenant accéder à la recette complète.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showFullRecipe();
                },
                child: const Text('Voir la recette', style: TextStyle(color: Color(0xFF00FF9D))),
              ),
            ],
          ),
        );
      } else if (result == false) {
        // Paiement échoué explicitement
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1D22),
            title: Text(
              'Paiement échoué',
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Le paiement n\'a pas pu être traité. Veuillez réessayer.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Réessayer', style: TextStyle(color: Color(0xFF00FF9D))),
              ),
            ],
          ),
        );
      }
      // Si result == null, c'est un simple retour arrière, ne rien afficher
    } catch (e) {
      // Fermer le popup de chargement
      Navigator.pop(context);

      // Afficher popup d'erreur
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1D22),
          title: Text(
            'Erreur',
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Une erreur s\'est produite: $e',
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
  }

  void _showFullRecipe() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D22),
        title: Text(
          widget.recipe.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description complète
              Text(
                'Description:',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.recipe.fullDescription,
                style: const TextStyle(color: Colors.white70, height: 1.4),
              ),
              const SizedBox(height: 16),

              // Ingrédients
              Text(
                'Ingrédients:',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ...widget.recipe.ingredients.map((ingredient) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Text('• ', style: TextStyle(color: Color(0xFF00FF9D))),
                    Expanded(
                      child: Text(
                        ingredient,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 16),

              // Instructions
              Text(
                'Instructions de préparation:',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ...widget.recipe.instructions.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00FF9D),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(color: Colors.white70, height: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer', style: TextStyle(color: Color(0xFF00FF9D))),
          ),
        ],
      ),
    );
  }

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
                if (loadingProgress == null) {
                  return child;
                }
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
                  child: const Icon(Icons.image, color: Colors.white54, size: 50),
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
                      onPressed: _isLoading ? null : _handlePurchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPurchased
                            ? Colors.green
                            : const Color(0xFF00FF9D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _isPurchased ? 'Voir la recette complète' : 'Acheter la recette',
                              style: const TextStyle(
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
}