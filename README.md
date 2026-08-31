# FLX

Application mobile Flutter développée dans le cadre du FlutterFire Summer Camp.

FLX est une application e-commerce permettant aux utilisateurs de créer un compte, se connecter et consulter des produits provenant d'une API REST. L'application intègre également un système de cache local permettant de consulter les derniers produits disponibles même sans connexion Internet.

## Fonctionnalités

### Authentification

* Inscription avec Supabase Auth
* Connexion avec email et mot de passe
* Déconnexion
* Récupération de l'utilisateur connecté
* Gestion de session
* JWT / Access Token

### Produits

* Affichage de la liste des produits
* Recherche de produits
* Consultation du détail d'un produit
* Rafraîchissement des produits
* Gestion des erreurs réseau et serveur

### Mode hors ligne

* Cache local avec Hive
* Sauvegarde de la liste des produits
* Sauvegarde du détail des produits
* Récupération des données depuis le cache en cas d'erreur réseau
* Indication lorsqu'une donnée provient du cache

## Architecture

Le projet utilise une architecture inspirée de la **Clean Architecture** et du **Repository Pattern**.

```text
lib/
│
├── core/
│   ├── auth/
│   ├── errors/
│   ├── network/
│   └── storage/
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── products/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart
```

### Flux des données

```text
UI
 ↓
Riverpod
 ↓
Repository
 ↙       ↘
API       Hive
 ↓         ↓
Dio      Cache
 ↓
DummyJSON
```

L'interface utilisateur ne communique donc pas directement avec Dio, Supabase ou Hive.

Le Repository est responsable de déterminer la source des données.

## Technologies

* Flutter
* Dart
* Riverpod
* GoRouter
* Dio
* Supabase
* Hive
* Mocktail
* Flutter Test
* DummyJSON API

## API

Les produits sont récupérés depuis l'API DummyJSON :

```text
https://dummyjson.com
```

Endpoints utilisés :

```text
GET /products
GET /products/{id}
GET /products/search?q={query}
```

## Authentification

L'authentification est gérée avec Supabase.

Le token de session est automatiquement ajouté aux requêtes HTTP grâce à un interceptor Dio.

```text
Supabase
   ↓
Access Token
   ↓
AuthSessionManager
   ↓
AuthInterceptor
   ↓
Authorization: Bearer <token>
```

Lorsqu'une requête retourne `401`, l'interceptor tente de rafraîchir le token puis rejoue la requête une seule fois.

Cela évite les boucles infinies de refresh.

## Gestion des erreurs

Le projet utilise deux niveaux pour gérer les erreurs.

### Exceptions

Les erreurs provenant des différentes sources sont représentées par :

```text
AppException
├── NetworkException
├── ServerException
├── CacheException
└── UnknownException
```

### Failures

Les exceptions sont ensuite converties en `Failure` au niveau du Repository :

```text
Failure
├── NetworkFailure
├── ServerFailure
├── CacheFailure
└── UnknownFailure
```

Les résultats sont encapsulés avec :

```dart
Result<T>
├── Success<T>
└── Error<T>
```

Cela permet de séparer clairement les erreurs techniques de leur représentation dans l'application.

## Cache et mode hors ligne

Lorsqu'une liste de produits est récupérée avec succès :

```text
API
 ↓
Products
 ↓
Hive
 ↓
Cache
```

Si l'API devient indisponible :

```text
API ❌
 ↓
Repository
 ↓
Hive ✅
 ↓
Products
```

Le cache ne bloque pas le fonctionnement de l'API : une erreur d'écriture dans Hive n'empêche pas l'affichage des données récupérées depuis le serveur.

## Installation

Cloner le projet :

```bash
git clone https://github.com/myhrindra194/flux.git
cd flux
```

Installer les dépendances :

```bash
flutter pub get
```

Vérifier le projet :

```bash
flutter analyze
```

Lancer les tests :

```bash
flutter test
```

Lancer l'application :

```bash
flutter run
```

## Configuration Supabase

Créer un projet Supabase puis configurer les variables nécessaires dans le projet.

Supabase Auth doit être activé afin de permettre :

* l'inscription ;
* la connexion ;
* la gestion des sessions ;
* la déconnexion.

## Tests

Le projet contient des tests unitaires couvrant notamment :

* Repository produits
* Repository authentification
* Auth Interceptor
* Refresh du token
* Retry après `401`
* Gestion du cache
* Gestion des erreurs

Exécuter tous les tests :

```bash
flutter test
```

Résultat attendu :

```text
All tests passed!
```

## Vérification du projet

Avant de considérer une modification comme terminée :

```bash
flutter analyze
flutter test
```

Les deux commandes doivent terminer sans erreur.

## Auteur

Projet réalisé dans le cadre du FlutterFire Summer Camp.

---

**FLX — Flutter E-commerce Application**
