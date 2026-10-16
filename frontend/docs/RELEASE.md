# Publier l'application (Android / iOS)

## 1. Choisir l'identifiant de l'application
Valeur actuelle (proposée) : `com.issakazakou.quizislamique`

> ⚠️ **À confirmer avant la première publication** : sur le Play Store / l'App Store, l'identifiant
> ne peut plus être changé ensuite. Pour en utiliser un autre :
> - Android : `flutter build appbundle -PappId=com.votre.domaine` (ou éditer `applicationId` dans
>   `android/app/build.gradle.kts`)
> - iOS : remplacer `com.issakazakou.quizislamique` dans `ios/Runner.xcodeproj/project.pbxproj`
>   (ou Xcode → Runner → Signing & Capabilities → Bundle Identifier)

## 2. Créer la clé de signature Android (une seule fois)
```bash
keytool -genkey -v -keystore ~/quiz-islamique-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias quizislamique
```
**Sauvegardez ce fichier et son mot de passe** : sans eux, plus aucune mise à jour possible.

Créez `android/key.properties` (déjà ignoré par git, ne jamais le commiter) :
```properties
storePassword=VOTRE_MOT_DE_PASSE
keyPassword=VOTRE_MOT_DE_PASSE
keyAlias=quizislamique
storeFile=/chemin/absolu/vers/quiz-islamique-release.jks
```
Sans ce fichier, la release est signée avec la clé *debug* (un avertissement s'affiche) :
l'APK fonctionne mais **n'est pas publiable**.

## 3. Compiler avec l'URL de production (HTTPS)
```bash
flutter build appbundle --release --dart-define=API_BASE_URL=https://quiz.mondomaine.com
# ou un APK :
flutter build apk --release --dart-define=API_BASE_URL=https://quiz.mondomaine.com
```
Le backend doit être servi en HTTPS : voir `backend/README.md` (Déploiement HTTPS).
