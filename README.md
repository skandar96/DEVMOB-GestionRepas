# GestionRepas

GestionRepas est une application Flutter de gestion de repas qui permet de:

- créer et organiser des recettes personnelles
- planifier les repas par jour et par type de repas
- generer et gerer une liste de courses automatiquement
- synchroniser toutes les donnees dans Firebase pour chaque utilisateur

L'application utilise `Firebase Authentication` pour l'identification des utilisateurs, `Cloud Firestore` pour la persistance des donnees, et `Provider` pour la gestion d'etat.

## Vue d'ensemble

L'application est structuree autour de 4 grands blocs fonctionnels:

1. Authentification.
2. Gestion des recettes.
3. Planning des repas.
4. Liste de courses.

## Fonctionnalites

### Authentification

- Connexion avec email et mot de passe.
- Creation de compte.
- Reinitialisation du mot de passe.
- Sauvegarde du contexte utilisateur pour charger les donnees personnelles apres connexion.

### Recettes

- Liste des recettes de l'utilisateur.
- Recherche par nom.
- Filtrage par categorie: petit dejeuner, dejeuner, diner.
- Ajout d'une recette avec formulaire complet.
- Edition d'une recette existante.
- Consultation du detail d'une recette.
- Suppression d'une recette.

### Planning repas

- Vue calendrier hebdomadaire.
- Navigation jour par jour dans la semaine.
- Gestion des repas pour petit dejeuner, dejeuner et diner.
- Association d'une recette a un repas planifie.
- Chargement des repas planifies pour la semaine en cours.

### Liste de courses

- Liste de courses personnelle par utilisateur.
- Ajout manuel d'articles.
- Cocher / decocher un article comme achete.
- Suppression d'un article.
- Vidage de la liste ou seulement des articles achetes.
- Generation automatique a partir des repas planifies et des recettes.
- Conservation des articles manuels lors de la synchronisation automatique.

## Architecture technique

### Stack principale

- Flutter
- Dart
- Provider
- Firebase Auth
- Cloud Firestore
- intl
- table_calendar

### Navigation

La navigation est actuellement geree par une classe `AppRoutes` avec `MaterialApp`.

Routes principales:

- `/login` : connexion.
- `/register` : inscription.
- `/forgot-password` : mot de passe oublie.
- `/home` : navigation principale.
- `/addRecipe` : ajout / edition de recette.
- `/recipeDetail` : detail d'une recette.

La page principale utilise une barre de navigation inferieure avec 4 onglets:

1. Accueil.
2. Recettes.
3. Planning.
4. Courses.

### Etat global

Les providers principaux sont:

- `AuthProvider` : etat de connexion, utilisateur courant, chargement et erreurs.
- `RecipeProvider` : chargement, ajout, mise a jour et suppression des recettes.
- `MealPlanProvider` : gestion des repas planifies par semaine.
- `ShoppingListProvider` : gestion de la liste de courses de l'utilisateur.

## Structure des donnees

### Modeles

#### `User`

Represente l'utilisateur authentifie avec:

- `id`
- `email`
- `password`

#### `Recipe`

Represente une recette avec:

- `id`
- `userId`
- `name`
- `description`
- `preparationTime`
- `servings`
- `ingredients`
- `instructions`
- `category`
- `difficulty`
- `isFavorite`
- `imageUrl`

Categories de recette:

- Petit dejeuner.
- Dejeuner.
- Diner.

Niveaux de difficulte:

- Facile.
- Moyen.
- Difficile.

#### `Ingredient`

Un ingredient est compose de:

- `name`
- `quantity`
- `unit`

#### `MealPlan`

Represente un repas planifie avec:

- `id`
- `userId`
- `date`
- `mealType`
- `recipeId`
- `recipeName`
- `servings`

Types de repas:

- breakfast.
- lunch.
- dinner.

#### `ShoppingItem`

Represente une ligne de la liste de courses avec:

- `id`
- `userId`
- `name`
- `quantity`
- `unit`
- `isPurchased`
- `category`
- `mealType`
- `sourceMealPlanIds`
- `createdAt`
- `updatedAt`

## Persistance Firebase

Les donnees sont stockees dans Firestore sous la structure suivante:

```text
users/{userId}/recipes
users/{userId}/meal_plans
users/{userId}/shopping_list
```

### Services Firestore

- `RecipeService` : CRUD des recettes.
- `MealPlanService` : ajout, mise a jour, suppression et chargement des repas planifies.
- `ShoppingListService` : gestion complete de la liste de courses.
- `AuthService` : authentification Firebase et mot de passe oublie.

## Synchronisation de la liste de courses

La liste de courses peut etre alimentee automatiquement a partir du planning repas.

Le flux principal est le suivant:

1. les repas planifies sont charges pour la semaine courante;
2. les recettes associees sont recuperees;
3. les ingredients sont transformes en articles de courses;
4. les quantites sont ajustees selon le nombre de portions;
5. les ingredients identiques sont regroupes et agreges;
6. les articles manuels sont conserves lors de la synchronisation.

Le moteur de generation est implante dans `shopping_list_generator.dart`.

## Interface utilisateur

### Ecran de connexion

- formulaire email / mot de passe;
- bascule vers inscription;
- lien vers mot de passe oublie;
- chargement de la liste de courses apres connexion reussie.

### Accueil

- header graphique avec logo;
- carte de bienvenue;
- raccourcis vers recettes, ajout de recette, planning et courses;
- statistiques rapides sur les recettes, repas planifies et articles de courses.

### Recettes

- recherche textuelle;
- filtre par categorie;
- carte recette avec temps, portions et categorie;
- acces au detail;
- bouton flottant pour ajouter une recette.

### Detail recette

- affichage complet de la recette;
- ingredients;
- instructions;
- favori;
- suppression;
- edition via redirection vers le formulaire d'ajout.

### Planning hebdomadaire

- navigation par jour dans la semaine;
- affichage des repas par type;
- lecture des repas planifies pour l'utilisateur connecte;
- preparation a l'affectation des recettes au calendrier.

### Liste de courses

- affichage des articles achetes et non achetes;
- regroupement par type de repas ou par saisie manuelle;
- ajout manuel d'un article;
- suppression d'un article et des repas associes si necessaire;
- synchronisation automatique avec le planning et les recettes.

## Arborescence du projet

```text
lib/
	main.dart
	controllers/
	Models/
	navigation/
	providers/
	services/
	theme/
	views/
		Auth/
		Home/
		Mealplan/
		Recipe/
		Shopping/
		widgets/
```

### Roles des dossiers

- `controllers/` : orchestration de la logique d'authentification.
- `Models/` : objets metier et serialization Firestore.
- `navigation/` : definition des routes.
- `providers/` : etat global de l'application.
- `services/` : acces Firebase et regles metier.
- `theme/` : couleurs, gradients et style de l'application.
- `views/` : ecrans utilisateur.
- `views/widgets/` : composants reutilisables.


## Theme visuel

L'application utilise une identite visuelle violette / rose avec des accents orange et cyan.

Le theme est defini dans `lib/theme/app_theme.dart`, avec:

- une palette principale violette;
- des gradients pour les headers et boutons;
- des cartes arrondies;
- un style Material 3.

## Configuration requise

- Flutter SDK compatible avec Dart `^3.10.8`.
- Un projet Firebase configure.
- Android Firebase configure via `android/app/google-services.json`.

## Installation

1. Recuperer les dependances.

```bash
flutter pub get
```

2. Verifier que Firebase est correctement configure.

3. Lancer l'application.

```bash
flutter run
```

=> Projet prive de gestion de repas sous Flutter et Firebase.
