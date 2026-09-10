# Couche Firestore — MiniBlog

Point d'entrée pour l'équipe Flutter. **Ne pas appeler `FirebaseFirestore.instance` dans les widgets.** Tout passe par les repositories / use cases.

Cette couche **ne gère pas Firebase Auth**. Le `uid` Auth est un identifiant passé en `authorId` / `users/{uid}`.

## Collections

### `articles/{articleId}`

Rôle : publication et brouillons. Identifiant = id auto Firestore (ou id fourni).

| Champ | Type Firestore | Type Dart | Obligatoire | Notes |
|---|---|---|---|---|
| *(id document)* | string | `String id` | oui | pas stocké dans le document |
| `title` | string | `String` | oui | 1–200 caractères |
| `content` | string | `String` | publié : oui ; brouillon : peut être vide | max 100 000 |
| `authorId` | string | `String` | oui | **uid Firebase Auth**, immuable |
| `authorName` | string | `String` | oui | dénormalisé pour la liste, 1–80 |
| `status` | string | `ArticleStatus` | oui | `draft` ou `published` |
| `createdAt` | timestamp | `DateTime` | oui | `serverTimestamp`, immuable |
| `updatedAt` | timestamp | `DateTime` | oui | `serverTimestamp` à chaque écriture |
| `publishedAt` | timestamp \| null | `DateTime?` | non | `null` tant que brouillon ; posé à la 1re publication |

Champs volontairement **absents** : `slug`, `excerpt`, `coverImage`, `tags`, `viewsCount`, `likesCount` (pas dans le besoin MiniBlog, compteurs = Cloud Functions).

`authorName` est conservé (déjà dans l'entité domain) pour afficher l'auteur sans jointure `users`.

### `users/{uid}`

Rôle : profil applicatif. **Même uid que Firebase Auth.** Pas une 2e auth.

| Champ | Type Firestore | Type Dart | Obligatoire |
|---|---|---|---|
| *(id = uid)* | string | `String uid` | oui |
| `displayName` | string \| null | `String?` | non |
| `photoUrl` | string \| null | `String?` | non |
| `createdAt` | timestamp | `DateTime` | oui, immuable |
| `updatedAt` | timestamp | `DateTime` | oui |

L'email n'est **pas** stocké ici (lisible par tout user connecté sinon). Il reste côté Auth.

`startUserProfileSync()` (appelé dans `main.dart`) écoute `FirebaseAuth.authStateChanges()` et écrit `users/{uid}`. L'équipe Auth n'a **pas** à appeler `upsertProfile` elle-même pour la création du doc. Elle peut quand même l'appeler après une édition de `displayName` / photo.

### `articles/{articleId}/comments/{commentId}`

Sous-collection (pas une collection racine). Un commentaire n'existe que sous un article.

| Champ | Type Firestore | Type Dart | Obligatoire |
|---|---|---|---|
| *(id document)* | string | `String id` | oui |
| *(parent)* | — | `String articleId` | oui (chemin, pas un champ) |
| `authorId` | string | `String` | oui, uid Auth, immuable |
| `authorName` | string | `String` | oui |
| `content` | string | `String` | oui, 1–2000 |
| `createdAt` | timestamp | `DateTime` | oui, immuable |
| `updatedAt` | timestamp | `DateTime` | oui, serverTimestamp |

Lecture : article publié, ou auteur de l'article (ses brouillons).  
Création : utilisateur connecté, article **publié**, `authorId == uid`.  
Update / delete : auteur du commentaire uniquement.

Index : `createdAt` ASC suffit (index automatique).

```dart
ref.watch(commentRepositoryProvider)
ref.read(getCommentsProvider)
ref.read(createCommentProvider)
```

## Modèles Dart

- Entité : `lib/features/blog/domain/entities/article.dart` (`Article`, `ArticleStatus`)
- Pagination : `lib/features/blog/domain/entities/article_page.dart` (`ArticlePage`, `ArticlePageCursor`)
- Modèle Firestore : `lib/features/blog/data/models/article_model.dart` (`fromFirestore`, `toCreateMap`, `toUpdateMap`)
- Profil : `lib/features/auth/domain/entities/user_profile.dart` + `user_profile_model.dart`
- Commentaire : `lib/features/blog/domain/entities/comment.dart` + `comment_model.dart`

Les timestamps Firestore (`Timestamp` / `FieldValue.serverTimestamp`) restent dans la couche data.

## Repositories

Injectés via Riverpod (déjà utilisé par le projet) :

```dart
ref.watch(articleRepositoryProvider)
ref.watch(userProfileRepositoryProvider)
ref.watch(commentRepositoryProvider)
```

Use cases prêts : `getArticlesProvider`, `getArticleProvider`, `watchArticleProvider`, `getMyArticlesProvider`, `getMyDraftsProvider`, `createArticleProvider`, `saveDraftProvider`, `updateArticleProvider`, `publishArticleProvider`, `deleteArticleProvider`.

### `ArticleRepository`

| Méthode | Rôle |
|---|---|
| `createArticle(Article)` | Crée un doc, retourne `(id, failure)` |
| `getArticle(id)` | Lecture ponctuelle |
| `watchArticle(id)` | Snapshot temps réel |
| `getPublishedArticles({authorId, cursor, limit})` | Feed public paginé |
| `getMyArticles({authorId, status, cursor, limit})` | Articles du uid connecté |
| `getMyDrafts({authorId, cursor, limit})` | Brouillons du uid connecté |
| `updateArticle(Article)` | Titre / contenu / nom ; **jamais** `authorId` |
| `saveDraft(Article)` | Crée ou met à jour un brouillon, retourne l'id |
| `publishArticle(id)` | `status = published` + `publishedAt` serveur |
| `deleteArticle(id)` | Suppression |

Erreurs : `(data, null)` ou `(null, Failure)`. Types : `ServerFailure`, `PermissionDeniedFailure`, `NotFoundFailure`.

`getMyArticles` / `getMyDrafts` : passer **uniquement le uid de l'utilisateur connecté**. Un autre `authorId` fera échouer la requête (les rules bloquent la lecture des brouillons d'autrui).

### Pagination

Pas d'`offset`. Le frontend garde `ArticlePage.nextCursor` et le renvoie :

```dart
final getArticles = ref.read(getArticlesProvider);

var (page, failure) = await getArticles(limit: 20);
// ...
if (page!.hasMore) {
  (page, failure) = await getArticles(cursor: page.nextCursor, limit: 20);
}
```

Le curseur est un id de document. Firestore n'est pas exposé.

## Security Rules

Fichier : `firestore.rules`. Le client n'est pas fiable.

| Action | Condition |
|---|---|
| Lire un `published` | tout le monde (y compris anonyme) |
| Lire un `draft` | uniquement `request.auth.uid == authorId` |
| Create | authentifié **et** `authorId == uid` |
| Update / delete | uniquement l'auteur |
| Changer `authorId` | interdit |
| `createdAt` | égal à `request.time` à la création, ensuite immuable |
| `updatedAt` | doit être `request.time` (`FieldValue.serverTimestamp()`) |
| `publishedAt` | `null` si draft ; `request.time` au passage published ; ensuite immuable |
| `status` | `draft` ou `published` seulement |
| Anonyme | aucun create / update / delete |
| `users/{uid}` | lecture si connecté ; écriture uniquement son uid ; pas de delete |
| Commentaire publié | lecture si l'article est publié (ou auteur de l'article) |
| Créer un commentaire | connecté + article published + `authorId == uid` |
| Modifier / supprimer un commentaire | auteur du commentaire |

Les timestamps importants ne peuvent pas être forgés : les rules exigent `== request.time`, ce qui correspond à `FieldValue.serverTimestamp()`.

## Index

Fichier : `firestore.indexes.json`

1. `status` + `publishedAt` DESC — feed publié
2. `authorId` + `status` + `publishedAt` DESC — publiés d'un auteur
3. `authorId` + `createdAt` DESC — mes articles
4. `authorId` + `status` + `createdAt` DESC — mes brouillons / mes publiés

Déployer : `firebase deploy --only firestore:indexes`

## Émulateur Firestore

Ne touche **pas** la base de production.

```bash
firebase emulators:start --only firestore
```

UI : http://127.0.0.1:4000 — Firestore : port **8080**.

App :

```bash
flutter run --dart-define=USE_FIRESTORE_EMULATOR=true
```

Android émulateur : host `10.0.2.2` (géré dans `lib/core/firebase/firestore_emulator.dart`).

## Tests

Couche data (sans émulateur) :

```bash
flutter test
```

Security Rules (émulateur requis) :

```bash
cd test/firestore_rules && npm install
firebase emulators:exec --only firestore "npm test --prefix test/firestore_rules"
```

Couverture rules : lecture publié / brouillon auteur / brouillon tiers ; création own / foreign authorId / anonyme ; update auteur / tiers / `authorId` ; delete auteur / tiers ; publish auteur / tiers ; commentaires (create own, foreign authorId, delete own / tiers).

## Côté console Firebase (Firestore)

Ce n'est **pas** vide : une partie se gère dans le projet `mini-blog-app-3ff95`, pas dans Dart.

1. **Créer la base** Firestore Native (une seule fois), région de préférence `europe-west1`.
2. **Déployer rules + index** (ne jamais laisser `allow read, write: if true`).
3. Attendre que les **index** passent à l'état Enabled.
4. Auth (email/password) reste à l'équipe Auth, mais le uid doit exister pour que les writes articles / commentaires / profil passent les rules.

```bash
npx firebase-tools login
npx firebase-tools deploy --only firestore --project mini-blog-app-3ff95
```

Console : [Firestore](https://console.firebase.google.com/project/mini-blog-app-3ff95/firestore)

## Exemple UI (Riverpod)

```dart
class HomeController {
  HomeController(this._getArticles);
  final GetArticles _getArticles;

  Future<void> loadFeed() async {
    final (page, failure) = await _getArticles();
    if (failure != null) {
      // afficher failure.message
      return;
    }
    // page!.items → List<Article>
  }
}

// Dans un widget :
// ref.read(getArticlesProvider)
// ref.read(articleRepositoryProvider)
```

Création d'un brouillon (le uid vient de l'équipe Auth) :

```dart
final article = Article(
  id: '',
  title: title,
  content: content,
  authorId: currentUid, // FirebaseAuth.currentUser!.uid
  authorName: displayName ?? 'Utilisateur',
  status: ArticleStatus.draft,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
final (id, failure) = await ref.read(createArticleProvider)(article);
```

`createdAt` / `updatedAt` envoyés par le client sont **ignorés** : le data source écrit `FieldValue.serverTimestamp()`.

## Cloud Functions

**Aucune.** MiniBlog n'a pas besoin d'agrégats, de compteurs fiables, ni de secrets serveur. La confiance est dans les Security Rules + `serverTimestamp`.

## Config Firebase

Projet : `mini-blog-app-3ff95`. `firebase_options.dart` couvre iOS, macOS, Windows, Android, Web **et Linux** (Linux réutilise l'app Web Firebase, comme Windows).
