// local_cart_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCartService extends ChangeNotifier {
  static const String _cartKey = 'user_cart';
  List<Map<String, dynamic>> _cartItems = [];

  // Constructeur
  LocalCartService() {
    _loadCart();
  }


  // Getter pour les articles
  List<Map<String, dynamic>> get cartItems => List.unmodifiable(_cartItems);

  // Getter pour le nombre d'articles
  int get itemCount => _cartItems.length;

  // Getter pour le total
  double get total {
    double sum = 0;
    for (var item in _cartItems) {
      sum += (item['prix'] ?? 0).toDouble();
    }
    return sum;
  }

  // Charger le panier depuis SharedPreferences
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cartString = prefs.getString(_cartKey);

      if (cartString != null && cartString.isNotEmpty) {
        final List<dynamic> cartList = json.decode(cartString);
        _cartItems =
            cartList.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        _cartItems = [];
      }
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement du panier: $e');
      _cartItems = [];
      notifyListeners();
    }
  }

  // Sauvegarder le panier dans SharedPreferences
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = json.encode(_cartItems);
      await prefs.setString(_cartKey, cartString);
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la sauvegarde du panier: $e');
    }
  }

  // Ajouter un article au panier
  Future<void> addToCart(Map<String, dynamic> item) async {
    // S'assurer que l'article a un ID unique
    if (!item.containsKey('id')) {
      item['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    }

    // Ajouter la date d'ajout si elle n'existe pas
    if (!item.containsKey('date_ajout')) {
      item['date_ajout'] = DateTime.now().toIso8601String();
    }

    _cartItems.add(item);
    await _saveCart();
  }

  // Ajouter plusieurs articles
  Future<void> addMultipleToCart(List<Map<String, dynamic>> items) async {
    for (var item in items) {
      if (!item.containsKey('id')) {
        item['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      }
      if (!item.containsKey('date_ajout')) {
        item['date_ajout'] = DateTime.now().toIso8601String();
      }
    }
    _cartItems.addAll(items);
    await _saveCart();
  }

  // Supprimer un article du panier par son ID
  Future<void> removeFromCart(String itemId) async {
    _cartItems.removeWhere((item) => item['id'] == itemId);
    await _saveCart();
  }

  // Supprimer un article par son nom (utile pour éviter les doublons)
  Future<void> removeByName(String itemName) async {
    _cartItems.removeWhere((item) => item['nom'] == itemName);
    await _saveCart();
  }

  // Mettre à jour la quantité d'un article
  Future<void> updateQuantity(String itemId, int newQuantity) async {
    final index = _cartItems.indexWhere((item) => item['id'] == itemId);
    if (index != -1) {
      _cartItems[index]['quantite'] = newQuantity;
      await _saveCart();
    }
  }

  // Vider complètement le panier
  Future<void> clearCart() async {
    _cartItems.clear();
    await _saveCart();
  }

  // Vérifier si un article est déjà dans le panier
  bool isInCart(String itemName) {
    return _cartItems.any((item) => item['nom'] == itemName);
  }

  // Obtenir le nombre d'articles
  Future<int> getItemCount() async {
    return _cartItems.length;
  }

  // Obtenir le panier complet
  Future<List<Map<String, dynamic>>> getCart() async {
    return List.unmodifiable(_cartItems);
  }

  // Obtenir le total du panier
  Future<double> getTotal() async {
    double total = 0;
    for (var item in _cartItems) {
      final prix = item['prix'] ?? 0;
      final quantite = item['quantite'] ?? 1;
      total += (prix * quantite).toDouble();
    }
    return total;
  }

  // Obtenir un article par son ID
  Map<String, dynamic>? getItemById(String itemId) {
    try {
      return _cartItems.firstWhere((item) => item['id'] == itemId);
    } catch (e) {
      return null;
    }
  }

  // Obtenir les articles groupés par nom (pour éviter les doublons)
  Map<String, List<Map<String, dynamic>>> getGroupedItems() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in _cartItems) {
      final name = item['nom'] ?? 'Inconnu';
      if (!grouped.containsKey(name)) {
        grouped[name] = [];
      }
      grouped[name]!.add(item);
    }
    return grouped;
  }

  // Compter les occurrences d'un article
  int countOccurrences(String itemName) {
    return _cartItems.where((item) => item['nom'] == itemName).length;
  }

  // Formater le panier pour affichage
  String formatCartForDisplay() {
    final buffer = StringBuffer();
    for (var item in _cartItems) {
      buffer
          .writeln('${item['nom']} - ${item['prix']} ${item['devise'] ?? '€'}');
    }
    buffer.writeln('Total: $total €');
    return buffer.toString();
  }

  // Exporter le panier en JSON
  String exportCartAsJson() {
    return json.encode(_cartItems);
  }

  // Importer un panier depuis JSON
  Future<void> importCartFromJson(String jsonString) async {
    try {
      final List<dynamic> imported = json.decode(jsonString);
      _cartItems =
          imported.map((item) => Map<String, dynamic>.from(item)).toList();
      await _saveCart();
    } catch (e) {
      print('Erreur lors de l\'import du panier: $e');
      rethrow;
    }
  }

  // Sauvegarder le panier (méthode utilitaire)
  Future<void> saveCart() async {
    await _saveCart();
  }

  // Recharger le panier (méthode utilitaire)
  Future<void> reloadCart() async {
    await _loadCart();
  }

  // Obtenir le nombre total d'articles (en comptant les quantités)
  int getTotalItemCount() {
    int count = 0;
    for (var item in _cartItems) {
      count += item['quantite'] ?? 1;
    }
    return count;
  }

  // Fusionner avec un autre panier
  Future<void> mergeWithCart(List<Map<String, dynamic>> otherCart) async {
    _cartItems.addAll(otherCart);
    await _saveCart();
  }

  // Vérifier si le panier est vide
  bool get isEmpty => _cartItems.isEmpty;

  // Vérifier si le panier n'est pas vide
  bool get isNotEmpty => _cartItems.isNotEmpty;

  // Obtenir les articles triés par date d'ajout
  List<Map<String, dynamic>> getItemsSortedByDate() {
    final sorted = List<Map<String, dynamic>>.from(_cartItems);
    sorted.sort((a, b) {
      final dateA = DateTime.tryParse(a['date_ajout'] ?? '') ?? DateTime.now();
      final dateB = DateTime.tryParse(b['date_ajout'] ?? '') ?? DateTime.now();
      return dateB.compareTo(dateA); // Du plus récent au plus ancien
    });
    return sorted;
  }

  // Obtenir les articles triés par prix
  List<Map<String, dynamic>> getItemsSortedByPrice({bool ascending = true}) {
    final sorted = List<Map<String, dynamic>>.from(_cartItems);
    sorted.sort((a, b) {
      final priceA = (a['prix'] ?? 0).toDouble();
      final priceB = (b['prix'] ?? 0).toDouble();
      return ascending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
    });
    return sorted;
  }

  // Obtenir les articles triés par nom
  List<Map<String, dynamic>> getItemsSortedByName({bool ascending = true}) {
    final sorted = List<Map<String, dynamic>>.from(_cartItems);
    sorted.sort((a, b) {
      final nameA = a['nom'] ?? '';
      final nameB = b['nom'] ?? '';
      return ascending ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
    });
    return sorted;
  }

  // Filtrer les articles par prix minimum/maximum
  List<Map<String, dynamic>> filterByPriceRange(
      double minPrice, double maxPrice) {
    return _cartItems.where((item) {
      final price = (item['prix'] ?? 0).toDouble();
      return price >= minPrice && price <= maxPrice;
    }).toList();
  }

  // Rechercher des articles par nom
  List<Map<String, dynamic>> searchItems(String query) {
    if (query.isEmpty) return _cartItems;
    final lowercaseQuery = query.toLowerCase();
    return _cartItems.where((item) {
      final name = (item['nom'] ?? '').toString().toLowerCase();
      return name.contains(lowercaseQuery);
    }).toList();
  }
}
