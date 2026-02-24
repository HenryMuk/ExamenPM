# Examen Flutter, Application de Recettes et Courses

## Description

Cette application Flutter est une plateforme e-commerce dédiée aux recettes africaines. Les utilisateurs peuvent s'inscrire, se connecter, parcourir une liste de recettes, consulter les détails des recettes et effectuer des paiements pour accéder aux details des recettes. L'application utilise Firebase pour l'authentification et le stockage des données, ainsi qu'une intégration de paiement via l'API Labyrinthe.

## Fonctionnalités

- **Authentification utilisateur** : Inscription et connexion via Firebase Auth
- **Gestion des recettes** : Affichage de la liste des recettes, détails des recettes avec images
- **Système de paiement** : Intégration de paiement mobile pour acheter l'accès aux recettes

## Technologies utilisées

- **Flutter** : Framework pour le développement d'applications multiplateformes
- **Dart** : Langage de programmation
- **Firebase** :
  - Authentication pour la gestion des utilisateurs
  - Firestore pour le stockage des données (recettes, utilisateurs)
- **API de paiement** : Labyrinthe pour les transactions mobiles
- **Images** : Sources d'images depuis Unsplash pour éviter les problèmes CORS sur le Web

## Installation

### Prérequis

- Flutter SDK installé (version 3.0 ou supérieure)
- Dart SDK
- Un compte Firebase avec un projet configuré
- Android Studio ou VS Code pour le développement

### Étapes d'installation

1. Clonez le repository :
   ```
   git clone <url-du-repository>
   cd src
   ```

2. Installez les dépendances :
   ```
   flutter pub get
   ```

3. Configurez Firebase :
   - Ajoutez votre fichier `google-services.json` dans `android/app/`
   - Ajoutez votre fichier `GoogleService-Info.plist` dans `ios/Runner/`
   - Mettez à jour `firebase_options.dart` avec vos configurations Firebase

4. Configurez l'API de paiement :
   - Obtenez vos clés API de Labyrinthe
   - Mettez à jour les configurations dans `payment_service.dart`

## Lancement de l'application

### Pour Android/iOS :
```
flutter run
```

### Pour le Web :
```
flutter run -d chrome
```

### Pour le développement :
```
flutter run --debug
```

## Structure du projet

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── auth_service.dart         # Service d'authentification Firebase
├── payment_service.dart      # Service de paiement
├── product_service.dart      # Service de gestion des produits/recettes
├── firebase_options.dart     # Configuration Firebase
├── controller/
│   ├── login_controller.dart    # Contrôleur de connexion
│   └── register_controller.dart # Contrôleur d'inscription
├── models/
│   └── payment_request.dart     # Modèle de requête de paiement
└── view/
    ├── home_page.dart           # Page d'accueil
    ├── login_page.dart          # Page de connexion
    ├── register_page.dart       # Page d'inscription
    ├── product_list_page.dart   # Liste des recettes
    ├── product_add_page.dart    # Ajout de recette
    └── payment_page.dart        # Page de paiement
```

