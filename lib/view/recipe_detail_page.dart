import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:l4_seance_2/view/login_page.dart';
import 'package:l4_seance_2/view/card_page.dart';
import '../models/recipe.dart';
import '../local_cart_service.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final LocalCartService _cartService = LocalCartService();
  bool _isLoading = false;
  int _cartItemCount = 0;
  bool _isInCart = false;

  @override
  void initState() {
    super.initState();
    _loadCartItemCount();
    _checkIfInCart();
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    _loadCartItemCount();
    _checkIfInCart();
  }

  Future<void> _loadCartItemCount() async {
    final count = await _cartService.getItemCount();
    if (mounted) {
      setState(() {
        _cartItemCount = count;
      });
    }
  }

  Future<void> _checkIfInCart() async {
    final cartItems = await _cartService.getCart();
    final isInCart =
        cartItems.any((item) => item['nom'] == widget.recipe.title);
    if (mounted) {
      setState(() {
        _isInCart = isInCart;
      });
    }
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
        actions: [
          // Panier avec badge du nombre d'articles
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CardPage()),
                  ).then((_) => _loadCartItemCount());
                },
              ),
              if (_cartItemCount > 0)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_cartItemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de la recette avec superposition
            Stack(
              children: [
                Hero(
                  tag: 'recipe_image_${widget.recipe.id}',
                  child: Image.network(
                    widget.recipe.imageUrl,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 250,
                        color: Colors.grey[800],
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF00FF9D)),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        color: Colors.grey[800],
                        child: const Icon(Icons.broken_image,
                            color: Colors.white54, size: 50),
                      );
                    },
                  ),
                ),
                // Gradient pour meilleure lisibilité du titre
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                // Titre sur l'image
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Text(
                    widget.recipe.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informations (note, likes, temps de préparation)
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.star,
                        label: '${widget.recipe.rating}',
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        icon: Icons.favorite,
                        label: '${widget.recipe.likes}',
                        color: Colors.red,
                      ),
                      if (widget.recipe.preparationTime != null) ...[
                        const SizedBox(width: 12),
                        _buildInfoChip(
                          icon: Icons.timer,
                          label: '${widget.recipe.preparationTime} min',
                          color: Colors.blue,
                        ),
                      ],
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF9D).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF00FF9D)),
                        ),
                        child: Text(
                          '${widget.recipe.price.toStringAsFixed(2)} ${widget.recipe.currency}',
                          style: const TextStyle(
                            color: Color(0xFF00FF9D),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Description complète
                  _buildSection(
                    title: 'Description',
                    icon: Icons.description,
                    child: Text(
                      widget.recipe.fullDescription,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Ingrédients
                  if (widget.recipe.ingredients != null &&
                      widget.recipe.ingredients!.isNotEmpty)
                    _buildSection(
                      title: 'Ingrédients',
                      icon: Icons.shopping_basket,
                      child: Column(
                        children: widget.recipe.ingredients!
                            .map(
                              (ingredient) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.circle,
                                        color: Color(0xFF00FF9D), size: 8),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        ingredient,
                                        style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Instructions
                  if (widget.recipe.instructions != null &&
                      widget.recipe.instructions!.isNotEmpty)
                    _buildSection(
                      title: 'Instructions',
                      icon: Icons.menu_book,
                      child: Column(
                        children: widget.recipe.instructions!
                            .asMap()
                            .entries
                            .map((entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Bouton d'ajout au panier (change selon état)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleAddToCart,
                      icon: _isLoading
                          ? Container(
                              width: 24,
                              height: 24,
                              child: const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Icon(
                              _isInCart
                                  ? Icons.check_circle
                                  : Icons.add_shopping_cart,
                              color: Colors.black,
                            ),
                      label: Text(
                        _isLoading
                            ? 'Ajout en cours...'
                            : _isInCart
                                ? 'Déjà dans le panier'
                                : 'Ajouter au panier',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isInCart ? Colors.green : const Color(0xFF00FF9D),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Bouton pour voir le panier
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CardPage()),
                        ).then((_) => _loadCartItemCount());
                      },
                      icon: const Icon(Icons.shopping_cart,
                          color: Colors.white70),
                      label: const Text(
                        'Voir mon panier',
                        style: TextStyle(color: Colors.white70),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF00FF9D), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Future<void> _handleAddToCart() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showLoginRequiredDialog();
      return;
    }

    if (_isInCart) {
      _showAlreadyInCartDialog();
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _cartService.addToCart({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'nom': widget.recipe.title,
        'description': widget.recipe.fullDescription,
        'prix': widget.recipe.price,
        'devise': widget.recipe.currency,
        'imageUrl': widget.recipe.imageUrl,
        'date_ajout': DateTime.now().toIso8601String(),
      });

      final newCount = await _cartService.getItemCount();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _cartItemCount = newCount;
          _isInCart = true;
        });

        _showSuccessSnackBar();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Erreur: ${e.toString()}');
      }
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.recipe.title} ajouté au panier'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'VOIR',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CardPage()),
            );
          },
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Vous devez être connecté pour ajouter des articles à votre panier.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("Annuler", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FF9D),
              foregroundColor: Colors.black,
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

  void _showAlreadyInCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1C2C),
        title: const Text(
          "Article dans le panier",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Cet article est déjà dans votre panier.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Continuer",
                style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FF9D),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CardPage()),
              );
            },
            child: const Text("Voir le panier"),
          ),
        ],
      ),
    );
  }

  void _showDuplicateItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1C2C),
        title: const Text(
          "Ajouter à nouveau ?",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Cet article est déjà dans votre panier. Voulez-vous l'ajouter à nouveau ?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isLoading = false);
            },
            child: const Text("Non", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FF9D),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _cartService.addToCart({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'nom': widget.recipe.title,
                  'description': widget.recipe.fullDescription,
                  'prix': widget.recipe.price,
                  'devise': widget.recipe.currency,
                  'imageUrl': widget.recipe.imageUrl,
                  'date_ajout': DateTime.now().toIso8601String(),
                });

                final newCount = await _cartService.getItemCount();
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _cartItemCount = newCount;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.recipe.title} ajouté à nouveau'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isLoading = false);
                  _showErrorSnackBar('Erreur: $e');
                }
              }
            },
            child: const Text("Oui, ajouter"),
          ),
        ],
      ),
    );
  }
}
