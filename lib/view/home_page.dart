import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:l4_seance_2/view/login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;

  return Scaffold(
    backgroundColor: const Color(0xFF0E1115),
    body: Column(
      children: [
        // ***** HEADER CARD *****  
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 35),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1F1C2C), Color(0xFF928DAB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white.withOpacity(0.15),
                child: Text(
                  user?.displayName?.substring(0, 1).toUpperCase() ?? "U",
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Salut ${user?.displayName ?? 'Utilisateur'} 👋",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // ***** ACTION GRID *****  
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              children: [
                _buildRoundTile(Icons.person, "Mon Profil", () {}),
                _buildRoundTile(Icons.settings, "Paramètres", () {}),
                _buildRoundTile(Icons.help_center, "Support", () {}),
                _buildRoundTile(Icons.info_outline, "À propos", () {}),
              ],
            ),
          ),
        )
      ],
    ),
  );
}


/// ***** TILE CIRCULAIRE MODERNE *****
Widget _buildRoundTile(IconData icon, String title, VoidCallback onTap) {
  return InkWell(
    borderRadius: BorderRadius.circular(30),
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D22),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(18),
            child: Icon(icon, size: 35, color: Colors.white),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}


}
