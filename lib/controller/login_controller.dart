import 'package:firebase_auth/firebase_auth.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'Utilisateur non trouvé';
      if (e.code == 'wrong-password') return 'Mot de passe incorrect';
      if (e.code == 'invalid-email') return 'Email invalide';
      return 'Erreur: ${e.message}';
    } catch (e) {
      return 'Une erreur inattendue est survenue: $e';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
