# mon_application

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Profil utilisateur et certificats de réussite
- **Profil** (connecté : bouton compte de l'accueil) : nom modifiable, statistiques (quiz terminés, précision, série de jours, étoiles), badges, certificats, synchronisation manuelle et déconnexion. Code : `lib/profile_screen.dart`.
- **Ce qui est gardé sur le compte** : la progression (étoiles par étape), les statistiques, les badges et les certificats. Tout est envoyé automatiquement après chaque quiz et récupéré à la connexion, sur n'importe quel téléphone (`lib/services/auth_service.dart`). Les statistiques et la progression de l'appareil sont effacées à la déconnexion.
- **Certificats** : délivrés pour une catégorie quand **toutes** ses étapes (3 niveaux × 5 étapes) sont réussies (au moins 1 étoile) ; le groupe **Coran** a le sien quand Méditer, Tajwid et Culture coranique sont terminés. Connecté, c'est le **serveur** qui délivre le certificat (date et code de vérification `XXXX-XXXX-XXXX`, vérifiable via `GET /api/certificates/{code}`). Sans compte, le certificat est local, sans code.
- Code : `lib/certificates.dart`, `lib/certificates_screen.dart` ; tests : `test/certificates_test.dart`, `test/profile_test.dart`.
