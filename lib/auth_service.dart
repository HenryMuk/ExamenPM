import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  Future<UserCredential> signInWithGoogle() async {
    GoogleSignInAccount? googleUser;

    if (kIsWeb) {
      googleUser = await GoogleSignIn(
        clientId: "117460258962-k32b7n56d8jnn9t870vvarjftu8qf6rq.apps.googleusercontent.com",
      ).signIn();
    } else {
      googleUser = await GoogleSignIn().signIn();
    }


    if (googleUser == null) {
      throw Exception('Connexion annulée');
    }


    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    await _saveLoginState(true);
    return userCredential;
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _saveLoginState(true);
    return userCredential;
  }

  Future<UserCredential> registerWithEmail(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _saveLoginState(true);
    return userCredential;
  }


  Future<void> signOut() async {
    await _auth.signOut();
    await _saveLoginState(false);
  }


  Future<void> _saveLoginState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }


  Future<bool> isLoggedIn() async {
    return FirebaseAuth.instance.currentUser != null;
  }
}
