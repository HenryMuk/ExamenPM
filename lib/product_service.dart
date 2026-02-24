import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductService {
  // Référence à la collection des produits (existante)
  final CollectionReference _productsRef =
      FirebaseFirestore.instance.collection('produits');

  // ---------- Méthodes existantes (produits) ----------
  Future<void> addProduct(String nom, String description, double prix) async {
    await _productsRef.add({
      'nom': nom,
      'description': description,
      'prix': prix,
      'dateCreation': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getProducts() {
    return _productsRef.orderBy('dateCreation', descending: true).snapshots();
  }

  // ---------- Méthodes pour le panier ----------
  // Récupère l'ID de l'utilisateur connecté
  String _getUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");
    return user.uid;
  }

  // Référence à la sous-collection du panier d'un utilisateur donné
  CollectionReference _getCartRef(String userId) {
    return FirebaseFirestore.instance
        .collection('carts')
        .doc(userId)
        .collection('items');
  }

  // Ajouter un article au panier de l'utilisateur connecté
  Future<void> addToCart(String nom, String description, double prix) async {
    final userId = _getUserId();
    await _getCartRef(userId).add({
      'nom': nom,
      'description': description,
      'prix': prix,
      'ajout_le': FieldValue.serverTimestamp(),
    });
  }

  // Obtenir le flux en temps réel des articles du panier de l'utilisateur connecté
  Stream<QuerySnapshot> streamCartItems() {
    final userId = _getUserId();
    return _getCartRef(userId)
        .orderBy('ajout_le', descending: true)
        .snapshots();
  }

  // Supprimer un article spécifique du panier
  Future<void> removeFromCart(String itemId) async {
    final userId = _getUserId();
    await _getCartRef(userId).doc(itemId).delete();
  }

  // (Optionnel) Vider complètement le panier de l'utilisateur
  Future<void> clearCart() async {
    final userId = _getUserId();
    final snapshot = await _getCartRef(userId).get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
