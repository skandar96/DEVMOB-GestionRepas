# 📋 GestionRepas - Étapes & Progression du Projet

**Date**: Avril 2026  
**Status**: En cours de développement  


---

## 📊 Vue d'ensemble du Projet

**GestionRepas** est une application mobile Flutter pour la gestion de recettes, repas et listes de course. L'application utilise Firebase pour l'authentification et le stockage des données, avec une architecture propre basée sur le pattern Provider.

---

## ✅ ÉTAPES RÉALISÉES (Phase 1 - Authentication & Recipe Management)

### 1️⃣ **Configuration du Projet** ✓
- [x] Initialisation du projet Flutter
- [x] Configuration de Firebase (Firebase Core, Authentication, Firestore)
- [x] Setup des dépendances principales (Provider, GoRouter, etc.)
- [x] Configuration du fichier `pubspec.yaml` avec toutes les dépendances nécessaires
- [x] Création de la structure de base du projet

**Fichiers impliqués:**
- `pubspec.yaml` - Gestion des dépendances
- `android/app/google-services.json` - Configuration Firebase pour Android
- `ios/Runner/GoogleService-Info.plist` - Configuration Firebase pour iOS

---

### 2️⃣ **Modèles de Données** ✓
- [x] Création du modèle `Recipe` avec tous les attributs
- [x] Création du modèle `Ingredient` 
- [x] Création du modèle `User` pour l'authentification
- [x] Implémentation des méthodes `toJson()` et `fromJson()` pour la sérialisation

**Fichiers créés:**
- `lib/Models/recipe.dart` - Modèle complet pour les recettes
- `lib/Models/ingredient.dart` - Modèle pour les ingrédients
- `lib/Models/user.dart` - Modèle utilisateur

**Détails du modèle Recipe:**
```
- id (String)
- name (String)
- description (String)
- preparationTime (int)
- servings (int)
- ingredients (List<Ingredient>)
- instructions (List<String>)
- category (RecipeCategory: Petit Déjeuner, Déjeuner, Dîner, Dessert)
- difficulty (Difficulty: Facile, Moyen, Difficile)
- isFavorite (bool)
- imageUrl (String?)
```

---

### 3️⃣ **Services Backend (Firebase)** ✓
- [x] Création de `AuthService` - Gestion de l'authentification Firebase
- [x] Création de `RecipeService` - Intégration Firestore pour les recettes
- [x] Implémentation des méthodes CRUD pour les recettes
- [x] Gestion des erreurs et exceptions

**Fichiers créés:**
- `lib/services/auth_service.dart` - Service d'authentification
- `lib/services/recipe_service.dart` - Service de gestion des recettes

**Méthodes AuthService:**
- `signUp(email, password)` - Créer un compte
- `signIn(email, password)` - Se connecter
- `signOut()` - Se déconnecter
- `getCurrentUser()` - Récupérer l'utilisateur actuel

**Méthodes RecipeService:**
- `addRecipe(recipe)` - Ajouter une recette
- `updateRecipe(recipeId, recipe)` - Modifier une recette
- `deleteRecipe(recipeId)` - Supprimer une recette
- `getRecipes()` - Récupérer toutes les recettes
- `getRecipeById(recipeId)` - Récupérer une recette spécifique

---

### 4️⃣ **Gestion d'État (Provider)** ✓
- [x] Création de `AuthProvider` - Gestion de l'état d'authentification
- [x] Création de `RecipeProvider` - Gestion de l'état des recettes
- [x] Implémentation des états de chargement et d'erreur
- [x] Intégration avec les Services

**Fichiers créés:**
- `lib/providers/auth_provider.dart` - Provider pour l'auth
- `lib/providers/recipe_provider.dart` - Provider pour les recettes

**AuthProvider:**
```
Propriétés:
- user (User?)
- isLoggedIn (bool)
- isLoading (bool)
- error (String?)

Méthodes:
- login(email, password)
- register(email, password)
- logout()
- clearError()
```

**RecipeProvider:**
```
Propriétés:
- recipes (List<Recipe>)
- isLoading (bool)
- error (String?)

Méthodes:
- addRecipe(recipe)
- updateRecipe(id, recipe)
- deleteRecipe(id)
- fetchRecipes()
- searchRecipes(keyword)
```

---

### 5️⃣ **Contrôleurs (Logique Métier)** ✓
- [x] Création de `AuthController` - Logique d'authentification
- [x] Liaison entre Services et Providers

**Fichiers créés:**
- `lib/controllers/auth_controller.dart` - Contrôleur d'authentification

---

### 6️⃣ **Navigation & Routing** ✓
- [x] Configuration de GoRouter pour la navigation
- [x] Définition des routes principales
- [x] Navigation avec arguments
- [x] Bottom navigation bar avec 4 onglets

**Fichiers créés:**
- `lib/navigation/routes.dart` - Configuration des routes
- `lib/views/MainNavigation.dart` - Composant de navigation principale

**Routes définies:**
```
/ (HomePage)
/login (LoginPage)
/register (RegisterPage)
/recipes (RecipeListPage)
/addRecipe (AddRecipePage)
/recipeDetail (RecipeDetailPage)
/mealCalendar (MealCalendarPage)
/shoppingList (ShoppingListPage)
```

---

### 7️⃣ **Écrans Implémentés** ✓

#### **a) LoginPage** ✓
- [x] Formulaire de connexion
- [x] Validation des emails
- [x] Gestion des erreurs
- [x] Lien vers la page d'inscription
- [x] Intégration AuthProvider

**Fichier:** `lib/views/Auth/LoginPage.dart`

#### **b) RegisterPage** ✓
- [x] Formulaire d'inscription
- [x] Validation des champs
- [x] Vérification de la force du mot de passe
- [x] Gestion des erreurs
- [x] Redirection après inscription réussie

**Fichier:** `lib/views/Auth/RegisterPage.dart`

#### **c) HomePage** ✓
- [x] Écran d'accueil avec bienvenue
- [x] Cards rapides d'accès aux fonctionnalités
- [x] Statistiques (nombre de recettes, etc.)
- [x] Bouton de déconnexion
- [x] Appel API au chargement de la page

**Fichier:** `lib/views/HomePage.dart`

#### **d) RecipeListPage** ✓
- [x] Affichage de toutes les recettes
- [x] Filtrage par catégorie
- [x] Recherche par nom
- [x] Cards pour chaque recette
- [x] Navigation vers détails
- [x] Icône favoris

**Fichier:** `lib/views/Recipe/RecipeListPage.dart`

#### **e) AddRecipePage** ✓
- [x] Formulaire complet de création/édition
- [x] Champs: nom, description, temps, servings, catégorie, difficulté
- [x] Gestion dynamique des ingrédients (ajout/suppression)
- [x] Gestion dynamique des instructions (ajout/suppression)
- [x] Validation des données
- [x] Upload d'image (structure prête)
- [x] Boutons Ajouter/Modifier
- [x] Gestion des erreurs

**Fichier:** `lib/views/Recipe/AddRecipePage.dart`

#### **f) RecipeDetailPage** ✓
- [x] Affichage détaillé de la recette
- [x] Card header avec image, nom, description
- [x] Row d'infos (temps, servings, difficulté, catégorie)
- [x] Section Ingrédients avec quantités
- [x] Section Instructions numérotées
- [x] Boutons Éditer et Supprimer
- [x] Système de favoris
- [x] Dialogue de confirmation pour suppression
- [x] Messages de succès/erreur

**Fichier:** `lib/views/Recipe/RecipeDetailPage.dart`

#### **g) MealCalendarPage** ⏳ (Placeholder)
- [x] Structure créée
- [x] Widget Calendar intégré (table_calendar)
- [] Implémentation de la logique complète (À faire)

**Fichier:** `lib/views/MealPlanning/MealCalendarPage.dart`

#### **h) ShoppingListPage** ⏳ (Placeholder)
- [x] Structure créée
- [] Implémentation complète (À faire)

**Fichier:** `lib/views/ShoppingList/ShoppingListPage.dart`

---

### 8️⃣ **Thème & Styling** ✓
- [x] Création du système de thème personnalisé
- [x] Définition des couleurs principales (violet, rose, orange, cyan)
- [x] Configuration des gradients
- [x] Thème Material 3

**Fichier:** `lib/theme/app_theme.dart`

**Palette de couleurs:**
```
Primaire: Violet (#7C3AED)
Secondaire: Rose (#EC4899)
Accents: Orange (#F59E0B), Cyan (#06B6D4)
```

---

### 9️⃣ **Point d'entrée (main.dart)** ✓
- [x] Configuration de MultiProvider avec tous les providers
- [x] Intégration Firebase
- [x] Setup du routeur GoRouter
- [x] Application du thème personnalisé

**Fichier:** `lib/main.dart`

---

## 🔗 RELATIONS ENTRE LES COMPOSANTS

### **Architecture générale:**
```
┌─────────────────────────────────────────────────────────┐
│                    USER INTERFACE (Views)                │
│  LoginPage | RegisterPage | HomePage | RecipeListPage   │
│  AddRecipePage | RecipeDetailPage | MealCalendarPage    │
└──────────────────────┬──────────────────────────────────┘
                       │
          ┌────────────┴────────────┐
          │                         │
┌─────────▼──────────┐    ┌────────▼────────┐
│     PROVIDERS      │    │   CONTROLLERS   │
│ - AuthProvider    │    │ - AuthController│
│ - RecipeProvider  │    └─────────────────┘
└─────────┬──────────┘
          │
┌─────────▼──────────────────────┐
│       SERVICES (Repos)         │
│ - AuthService (Firebase Auth)  │
│ - RecipeService (Firestore)    │
└─────────┬──────────────────────┘
          │
       ┌──┴──┐
       │     │
  ┌────▼──┐ ┌──────▼──────┐
  │Models │ │ Firebase API│
  │- User │ │ - Auth      │
  │- Recipe
   ├─ Ingredient
  │- Category
  │- Difficulty
```

### **Flux de données - Authentification:**
```
1. Utilisateur saisit email/password
2. LoginPage appelle AuthProvider.login()
3. AuthProvider appelle AuthService.signIn()
4. AuthService contacte Firebase Authentication
5. Firebase retourne l'utilisateur authentifié
6. AuthProvider met à jour l'état (hasurastate, user)
7. GoRouter redirige vers HomePage
8. HomePage s'affiche avec les données de l'utilisateur
```

### **Flux de données - Gestion des recettes:**
```
1. Utilisateur clique "Ajouter une recette"
2. Navigation vers AddRecipePage
3. Utilisateur remplit le formulaire
4. Click sur "Ajouter"
5. AddRecipePage appelle RecipeProvider.addRecipe()
6. RecipeProvider appelle RecipeService.addRecipe()
7. RecipeService envoie les données à Firestore
8. Firestore retourne la confirmation + ID du document
9. RecipeProvider met à jour recipes list
10. Navigation automatique vers RecipeListPage
11. Nouvelle recette s'affiche dans la liste
```

### **Flux de données - Affichage des détails:**
```
1. Utilisateur clique sur une recette dans la liste
2. Navigation vers RecipeDetailPage avec l'ID de recette
3. RecipeDetailPage charge les données
4. Affichage des détails (ingredrédients, instructions, etc.)
5. Utilisateur peut éditer ou supprimer
6. Actions mises à jour via RecipeProvider
```

---

## 📦 DÉPENDANCES PRINCIPALES

```yaml
Dependencies:
  - flutter: ^3.10.8
  - provider: ^6.1.5+1          # State management
  - firebase_core: ^4.6.0       # Core Firebase
  - firebase_auth: ^6.2.0       # Authentication
  - cloud_firestore: ^6.1.3     # Database
  - go_router: ^14.2.7          # Navigation
  - table_calendar: ^3.1.2      # Calendar widget
  - cached_network_image: ^3.4.1# Image caching
  - uuid: ^4.5.3                # ID generation
  - image_picker: ^1.1.2        # Image selection
  - shared_preferences: ^2.3.2  # Local storage

Dev Dependencies:
  - flutter_test
```

---

## 🚀 ÉTAPES À FAIRE (Phase 2)

### **A) Fonctionnalités recettes (Priorité Haute)**
- [ ] Système de favoris (déjà structuré, à finaliser)
- [ ] Uploads d'images pour les recettes
- [ ] Recherche avancée (par ingrédient, difficulté, temps)
- [ ] Trier les recettes (par temps, difficulté, nom)
- [ ] Filtres multiples en même temps

### **B) Calendar & Meal Planning (Priorité Haute)**
- [ ] Implémenter MealCalendarPage
- [ ] Associer recettes au calendrier
- [ ] Afficher les recettes du jour
- [ ] Glisser-déposer les recettes sur le calendrier

### **C) Shopping List (Priorité Haute)**
- [ ] Implémenter ShoppingListPage
- [ ] Générer liste de course à partir des recettes planifiées
- [ ] Cocher/décocher les ingrédients
- [ ] Dupliquer recettes sur le panier
- [ ] Exporter la liste (PDF, partage)

### **D) Fonctionnalités utilisateur (Priorité Moyenne)**
- [ ] Profil utilisateur avec avatar
- [ ] Historique des recettes consultées
- [ ] Collections de recettes personnalisées
- [ ] Partage de recettes avec d'autres utilisateurs
- [ ] Commentaires et évaluations sur les recettes

### **E) Optimisations (Priorité Moyenne)**
- [ ] Pagination de la liste des recettes
- [ ] Cache local avec Hive
- [ ] Mode hors ligne
- [ ] Notifications pour la planification des repas

### **F) Tests & Quality (Priorité Basse)**
- [ ] Tests unitaires pour les services
- [ ] Tests des widgets
- [ ] Tests d'intégration Firebase
- [ ] Analyse du code (lint, format)

---

## 📁 STRUCTURE DES FICHIERS COMPLÈTE

```
gestionrepas/
├── android/                     # Configuration Android
├── ios/                         # Configuration iOS
├── lib/
│   ├── main.dart              # Point d'entrée principal
│   ├── Models/
│   │   ├── recipe.dart        # Modèle recette
│   │   ├── ingredient.dart    # Modèle ingrédient
│   │   └── user.dart          # Modèle utilisateur
│   ├── services/
│   │   ├── auth_service.dart  # Service d'authentification Firebase
│   │   └── recipe_service.dart# Service des recettes Firestore
│   ├── providers/
│   │   ├── auth_provider.dart # Provider authentification
│   │   └── recipe_provider.dart# Provider recettes
│   ├── controllers/
│   │   └── auth_controller.dart# Logique d'authentification
│   ├── navigation/
│   │   └── routes.dart        # Configuration des routes
│   ├── views/
│   │   ├── Auth/
│   │   │   ├── LoginPage.dart
│   │   │   └── RegisterPage.dart
│   │   ├── Recipe/
│   │   │   ├── RecipeListPage.dart
│   │   │   ├── AddRecipePage.dart
│   │   │   └── RecipeDetailPage.dart
│   │   ├── MealPlanning/
│   │   │   └── MealCalendarPage.dart
│   │   ├── ShoppingList/
│   │   │   └── ShoppingListPage.dart
│   │   ├── HomePage.dart
│   │   ├── MainNavigation.dart
│   │   └── widgets/           # Composants réutilisables
│   ├── theme/
│   │   └── app_theme.dart    # Configuration du thème
│   └── constants/             # Constantes (à créer si besoin)
├── pubspec.yaml               # Dépendances
└── README.md                  # Documentation

```

---

## 🎨 DESIGN & COULEURS

| Élément | Couleur | Code |
|---------|---------|------|
| Primary | Violet | #7C3AED |
| Secondary | Rose/Magenta | #EC4899 |
| Accent 1 | Orange | #F59E0B |
| Accent 2 | Cyan | #06B6D4 |
| Background | Light Gray | #F5F5F5 |
| Text Primary | Dark Gray | #1F2937 |

---

## 📊 STATISTIQUES DU PROJET

```
Fichiers Dart créés:     15+
Lignes de code:         ~3000+
Modèles implémentés:    3
Providers:              2
Services:              2
Écrans:                8
Routes:                7
```

---

## 🐛 BUGS CONNUS & À CORRIGER

- [ ] Validation du formulaire récette à améliorer
- [ ] Messages d'erreur pas toujours clairs
- [ ] Gestion de la connexion Internet (offline mode)
- [ ] Performance sur listes très longues

---

## 💡 NOTES IMPORTANTES

1. **Firebase Firestore Collections:**
   - `users` - Profils utilisateur
   - `recipes` - Toutes les recettes
   - Chaque recette a un `userId` pour les données personnelles

2. **Authentification:**
   - Firebase Auth gère les sessions
   - Token vérifié automatiquement au démarrage

3. **Architecture:**
   - Clean architecture avec séparation des concerns
   - Provider Pattern pour state management
   - Service Layer pour l'accès aux données

4. **Prochaines priorités:**
   - Finaliser Calendar & Meal Planning
   - Impléments Shopping List
   - Améliorer la gestion des images

---

**Dernière mise à jour:** 10 Avril 2026  
**Prochaine révision:** Après implémentation de Meal Planning
