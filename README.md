# FLX — Full-Stack Flutter App

FLX est une application Flutter full-stack développée dans le cadre du **FlutterFire Summer Camp**.

Le projet a pour objectif de démontrer la maîtrise de l'intégration d'une API REST, de l'authentification, de la persistance locale, du mode hors-ligne, de la gestion des erreurs et d'une architecture Flutter structurée.

---

## 📱 Présentation

FLX est une application e-commerce permettant à un utilisateur de :

* créer un compte ;
* se connecter et se déconnecter ;
* consulter une liste de produits ;
* rechercher un produit ;
* consulter le détail d'un produit ;
* rafraîchir les données ;
* consulter les derniers produits disponibles hors connexion.

L'application communique avec une API REST et utilise un cache local afin de conserver les dernières données récupérées.

---

## ✨ Fonctionnalités

### 🔐 Authentification

L'authentification est gérée avec **Supabase Auth**.

Fonctionnalités disponibles :

* Register
* Login
* Logout
* Récupération de l'utilisateur courant
* Gestion de session
* Access Token JWT
* Injection automatique du token dans les requêtes HTTP
* Refresh du token après expiration
* Retry automatique d'une requête après un `401`

### 🛍️ Produits

L'application utilise l'API REST **DummyJSON**.

Fonctionnalités :

* Affichage de la liste des produits
* Recherche de produits
* Consultation du détail d'un produit
* Rafraîchissement des produits
* Affichage des images
* Prix et notation des produits

### 📴 Mode hors-ligne

Les données produits sont sauvegardées localement avec **Hive**.

Lorsque l'API n'est pas accessible :

```text
Internet ❌
     ↓
Repository
     ↓
Hive
     ↓
Données précédemment sauvegardées
     ↓
UI
```

L'utilisateur peut donc continuer à consulter les données disponibles localement.

---

# 🏗️ Architecture

Le projet utilise une architecture **Feature-First inspirée de la Clean Architecture**.

Chaque fonctionnalité est séparée en trois couches principales :

```text
Data
Domain
Presentation
```

Structure simplifiée :

```text
lib/
│
├── core/
│   ├── auth/
│   │   └── auth_session_manager.dart
│   │
│   ├── errors/
│   │   ├── exceptions.dart
│   │   ├── failures.dart
│   │   └── result.dart
│   │
│   ├── network/
│   │   ├── dio_client.dart
│   │   ├── dio_provider.dart
│   │   └── auth_interceptor.dart
│   │
│   └── storage/
│       ├── hive_boxes.dart
│       └── hive_service.dart
│
├── features/
│   │
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── repositories/
│   │   │
│   │   └── presentation/
│   │       ├── providers/
│   │       └── screens/
│   │
│   └── products/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       │
│       ├── domain/
│       │   ├── entities/
│       │   └── repositories/
│       │
│       └── presentation/
│           ├── providers/
│           └── screens/
│
└── main.dart
```

---

# 🔄 Architecture des données

Le flux principal des produits est :

```text
UI
 ↓
Riverpod
 ↓
Repository
 ↙       ↘
API       Hive
 ↓         ↓
Dio      Local Cache
 ↓
DummyJSON
```

L'UI ne communique jamais directement avec Dio ou Hive.

Le Repository joue le rôle d'intermédiaire entre la couche Presentation et les sources de données.

---

# 📦 Repository Pattern

Le projet utilise le **Repository Pattern** afin de séparer la logique métier de l'accès aux données.

Exemple :

```text
ProductRepository
       │
       ▼
ProductRepositoryImpl
      ↙ ↘
 Remote  Local
   ↓       ↓
  Dio     Hive
```

Cela permet notamment au Repository de décider quelle source utiliser.

### Avec Internet

```text
DummyJSON
    ↓
Dio
    ↓
Repository
    ↓
Hive
    ↓
UI
```

### Sans Internet

```text
DummyJSON ❌
      ↓
Repository
      ↓
Hive ✅
      ↓
UI
```

---

# 🌐 API REST

L'application utilise **DummyJSON** comme API publique pour les produits.

Base URL :

```text
https://dummyjson.com
```

Endpoints utilisés :

```text
GET /products
```

Récupération de la liste des produits.

```text
GET /products/{id}
```

Récupération du détail d'un produit.

```text
GET /products/search?q={query}
```

Recherche de produits.

---

# 🔐 Authentification et JWT

L'authentification utilisateur est assurée par **Supabase Auth**.

Le token de session est récupéré par `AuthSessionManager`.

Il est ensuite automatiquement injecté dans les requêtes Dio par `AuthInterceptor`.

```text
Supabase Auth
      ↓
Session
      ↓
Access Token
      ↓
AuthSessionManager
      ↓
AuthInterceptor
      ↓
Authorization: Bearer <token>
      ↓
API
```

---

# 🔄 Refresh Token

Lorsqu'une requête retourne une réponse HTTP `401`, l'intercepteur tente de récupérer un nouveau token.

```text
Request
   ↓
API
   ↓
401 Unauthorized
   ↓
Refresh Access Token
   ↓
New Token
   ↓
Retry Request
   ↓
Response
```

Une requête déjà rejouée n'est pas rejouée une deuxième fois.

Cela permet d'éviter les boucles infinies de refresh.

---

# 💾 Persistance locale

**Hive** est utilisé pour stocker localement les données des produits.

Les données mises en cache comprennent notamment :

* ID
* titre
* description
* prix
* rating
* thumbnail
* catégorie

La liste des produits est sauvegardée après une récupération réussie depuis l'API.

Le détail d'un produit est également sauvegardé localement.

---

# 📴 Gestion du mode hors-ligne

Le Repository utilise l'API en priorité.

Si une erreur réseau ou serveur survient, il tente de récupérer les données depuis Hive.

```text
             ┌───────────────┐
             │   Repository  │
             └───────┬───────┘
                     │
              Internet disponible ?
                 /           \
               Oui            Non
                ↓              ↓
               API            Hive
                ↓              ↓
             Products       Cached data
                 \             /
                  \           /
                     ↓
                     UI
```

Si aucune donnée n'est disponible dans le cache, l'application affiche un message d'erreur adapté.

---

# ⚠️ Gestion des erreurs

Les erreurs techniques sont représentées par des `Exception`.

```text
AppException
├── NetworkException
├── ServerException
├── CacheException
└── UnknownException
```

Elles sont ensuite converties au niveau du Repository en `Failure`.

```text
Failure
├── NetworkFailure
├── ServerFailure
├── CacheFailure
└── UnknownFailure
```

Les résultats des opérations sont encapsulés dans :

```dart
Result<T>
```

avec deux possibilités :

```text
Result
├── Success
└── Error
```

Cela permet de séparer les erreurs techniques de la logique de présentation.

---

# 🧠 Gestion d'état

**Riverpod** est utilisé pour gérer l'état de l'application et l'injection des dépendances.

Les principaux providers concernent notamment :

* Authentification
* Repository produits
* Liste des produits
* Recherche
* Détail d'un produit

---

# 🧭 Navigation

La navigation est gérée avec **GoRouter**.

Les principaux parcours sont :

```text
Login
  ↓
Home
  ↓
Products
  ├── Product Detail
  └── Search
```

---

# 🧪 Tests

Le projet contient des tests unitaires couvrant notamment :

* Product Repository
* Auth Repository
* Auth Interceptor
* Gestion du refresh token
* Retry après `401`
* Prévention des boucles de retry
* Gestion du cache
* Gestion des erreurs

### Lancer tous les tests

```bash
flutter test
```

Résultat attendu :

```text
All tests passed!
```

### Lancer les tests du Repository produits

```bash
flutter test test/features/products/data/repositories/product_repository_impl_test.dart
```

### Lancer les tests du Repository Auth

```bash
flutter test test/features/auth/data/repositories/auth_repository_impl_test.dart
```

### Lancer les tests de l'intercepteur

```bash
flutter test test/core/network/auth_interceptor_test.dart
```

---

# 🛠️ Technologies utilisées

| Technologie  | Utilisation                  |
| ------------ | ---------------------------- |
| Flutter      | Framework mobile             |
| Dart         | Langage                      |
| Riverpod     | Gestion d'état / dépendances |
| GoRouter     | Navigation                   |
| Dio          | Client HTTP                  |
| Supabase     | Authentification             |
| Hive         | Persistance locale           |
| Mocktail     | Mocking des tests            |
| Flutter Test | Tests unitaires              |
| DummyJSON    | API REST                     |

---

# 🚀 Installation

## 1. Cloner le repository

```bash
git clone https://github.com/myhrindra194/flux.git
```

Puis :

```bash
cd flux
```

## 2. Installer les dépendances

```bash
flutter pub get
```

## 3. Vérifier l'analyse du projet

```bash
flutter analyze
```

Le résultat attendu :

```text
No issues found!
```

## 4. Lancer les tests

```bash
flutter test
```

Le résultat attendu :

```text
All tests passed!
```

## 5. Lancer l'application

```bash
flutter run
```

---

# 🔑 Configuration Supabase

Le projet utilise Supabase pour l'authentification.

Créer un projet depuis le dashboard Supabase puis récupérer :

```text
SUPABASE_URL
SUPABASE_ANON_KEY
```

Ces valeurs doivent être configurées dans l'environnement du projet.

### ⚠️ Sécurité

Ne jamais publier de clés secrètes ou de credentials privés dans un repository public.

Le fichier `.env` local ne doit pas contenir de secrets qui doivent rester privés.

Pour un projet réel, les variables sensibles doivent être gérées via l'environnement approprié.

---

# 📋 Exigences du projet

Le projet répond aux fonctionnalités demandées :

| Exigence               | Implémentation                     |
| ---------------------- | ---------------------------------- |
| Login                  | Supabase Auth                      |
| Register               | Supabase Auth                      |
| Logout                 | Supabase Auth                      |
| JWT / OAuth            | Supabase Access Token              |
| API REST réelle        | DummyJSON                          |
| 3 écrans API           | Produits, Recherche, Détail        |
| Cache local            | Hive                               |
| Mode hors-ligne        | Fallback Hive                      |
| Gestion erreurs réseau | Exceptions + Failures              |
| Architecture           | Feature-First / Clean Architecture |
| Repository Pattern     | ProductRepository / AuthRepository |
| Client HTTP            | Dio                                |
| Intercepteur           | AuthInterceptor                    |
| Refresh Token          | AuthSessionManager                 |
| Tests Repository       | Tests unitaires                    |
| Documentation          | README                             |

---

# 📱 Écrans principaux

### Login

Permet à un utilisateur existant de se connecter.

### Register

Permet de créer un nouveau compte.

### Home

Affiche les informations de l'utilisateur connecté et la liste des produits.

### Product Search

Permet de rechercher des produits via l'API REST.

### Product Detail

Affiche les informations détaillées d'un produit.

---

# 🧪 Vérification finale

Avant chaque livraison ou modification importante, les commandes suivantes doivent être exécutées :

```bash
flutter analyze
```

puis :

```bash
flutter test
```

Le projet est considéré comme valide lorsque les deux commandes terminent sans erreur.

---

# 📂 Repository

Le code source du projet est disponible publiquement sur GitHub :

https://github.com/myhrindra194/flux

---

# 👩‍💻 Auteur

**Mirindra Randriambolamanjato**

Projet réalisé dans le cadre du **FlutterFire Summer Camp**.

---

## 🎯 Objectif du projet

Ce projet a été réalisé afin de mettre en pratique les concepts suivants :

* développement Flutter full-stack ;
* consommation d'API REST ;
* authentification JWT ;
* architecture Clean / Feature-First ;
* Repository Pattern ;
* gestion d'état avec Riverpod ;
* persistance locale avec Hive ;
* fonctionnement hors-ligne ;
* gestion des erreurs ;
* tests unitaires ;
* bonnes pratiques d'architecture logicielle.
