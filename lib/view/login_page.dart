import 'package:flutter/material.dart';
import 'package:l4_seance_2/controller/login_controller.dart';
import 'package:l4_seance_2/view/home_page.dart';
import 'package:l4_seance_2/view/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _controller = LoginController();
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

              // ***** AVATAR CERCLE *****
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

              const SizedBox(height: 25),

              const Text(
                "Connexion",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Accédez à votre espace personnel",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // ***** EMAIL *****
              _label("Email"),
              const SizedBox(height: 8),
              _glassField(
                controller: _emailController,
                hint: "email@example.com",
                keyboard: TextInputType.emailAddress,
              ),

              const SizedBox(height: 25),

              // ***** PASSWORD *****
              _label("Mot de passe"),
              const SizedBox(height: 8),
              _glassField(
                controller: _passwordController,
                hint: "Votre mot de passe",
                obscure: true,
              ),

              const SizedBox(height: 40),

              // ***** BUTTON NEON *****
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _doLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF9D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    shadowColor: const Color(0xFF00FF9D).withOpacity(0.5),
                    elevation: 10,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          "SE CONNECTER",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage()));
                },
                child: Text(
                  "Créer un compte",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
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

// ***** LABEL *****
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

// ***** CHAMP DE SAISIE STYLE GLASS *****
Widget _glassField({
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


  void _doLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Veuillez remplir tous les champs'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    final error = await _controller.login(email, password);

    if (error == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
    }

    setState(() => _isLoading = false);
  }
}
