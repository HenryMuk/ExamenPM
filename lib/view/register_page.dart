import 'package:flutter/material.dart';
import 'package:l4_seance_2/controller/register_controller.dart';
import 'package:l4_seance_2/view/home_page.dart';
import 'package:l4_seance_2/view/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth_service.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _controller = RegisterController();
  bool _isLoading = false;

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF0D0F12),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            children: [

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 3,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF1F2430),
                  child: Icon(Icons.lock_outline, size: 45, color: Colors.white),
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Inscription",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                "Créer votre nouveau compte",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 35),

              _label("Nom"),
              const SizedBox(height: 8),
              _neuField(
                controller: _nameController,
                hint: "Votre nom",
              ),

              const SizedBox(height: 25),

              _label("Email"),
              const SizedBox(height: 8),
              _neuField(
                controller: _emailController,
                hint: "email@example.com",
                keyboard: TextInputType.emailAddress,
              ),

              const SizedBox(height: 25),

              _label("Mot de passe"),
              const SizedBox(height: 8),
              _neuField(
                controller: _passwordController,
                hint: "Votre mot de passe",
                obscure: true,
              ),

              const SizedBox(height: 40),

              _neuButton(
                text: "S'INSCRIRE",
                loading: _isLoading,
                onPressed: _isLoading ? null : _register,
              ),


              const SizedBox(height: 15),

ElevatedButton.icon(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    minimumSize: Size(double.infinity, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  icon: Image.asset(
    'assets/images/google_logo.jpg',
    height: 24,
    width: 24,
  ),
  label: Text(
    "Continuer avec Google",
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  ),
  onPressed: () async {
    try {
      UserCredential userCredential = await AuthService().signInWithGoogle();

      if (userCredential.user != null) {
        String? displayName = userCredential.user!.displayName;
        String? email = userCredential.user!.email;
        String? photoURL = userCredential.user!.photoURL;

        print("Nom: $displayName");
        print("Email: $email");
        print("PhotoURL: $photoURL");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      }
    } catch (e) {
      print("Erreur Google Sign-In: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connexion Google échouée")),
      );
    }
  },
),

              const SizedBox(height: 25),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                },
                child: Text(
                  "Déjà un compte ? Se connecter",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _label(String text) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

Widget _neuField({
  required TextEditingController controller,
  required String hint,
  bool obscure = false,
  TextInputType keyboard = TextInputType.text,
}) {
  return TextField(
    controller: controller,
    obscureText: obscure,
    keyboardType: keyboard,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.07),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF00FF9D), width: 2),
      ),
    ),
  );
}

Widget _neuButton({
  required String text,
  required VoidCallback? onPressed,
  required bool loading,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      height: 58,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF00FF9D),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(6, 6),
            blurRadius: 15,
          ),
        ],
      ),
      child: loading
          ? const CircularProgressIndicator()
          : Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A2D33),
              ),
            ),
    ),
  );
}


  void _register() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Veuillez remplir tous les champs'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    final error = await _controller.register(name, email, password);

    if (error == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
    }

    setState(() => _isLoading = false);
  }
}
