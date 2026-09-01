# Construction Web et mobile

La même base Flutter produit désormais deux expériences cohérentes :

| Cible | Expérience | Authentification |
|---|---|---|
| Web | Administration responsive uniquement | Compte administrateur et JWT |
| Android | Kiosque repas et administration | Clé tablette pour le kiosque, JWT pour l’administration |

Les routes du kiosque ne sont pas enregistrées dans le routeur Web. La clé
partagée de la tablette n’est jamais injectée dans le bundle JavaScript. La
capture biométrique reste disponible sur la tablette Android, où la caméra et
ML Kit sont contrôlés. Les autres écrans d’administration sont utilisables dans
un navigateur.

## Construction des deux versions

Depuis `mobile_app`, exécuter en développement :

```powershell
.\tool\build_all.ps1 `
  -ApiBaseUrl http://127.0.0.1:4212/api/v1 `
  -AndroidApiBaseUrl http://10.0.2.2:4212/api/v1
```

`AndroidApiBaseUrl` est facultatif. Sans cette option, les deux cibles utilisent
la même URL, ce qui est le cas normal avec une API HTTPS de production ou une
adresse LAN accessible à la fois depuis le poste et la tablette.

Pour une version de production :

```powershell
$env:RESTO_TABLET_API_KEY = '<clé-tablette-réelle>'
.\tool\build_all.ps1 `
  -Production `
  -ApiBaseUrl https://api.example.org/api/v1
Remove-Item Env:RESTO_TABLET_API_KEY
```

Le script exécute l’analyse et les tests, puis construit les cibles l’une après
l’autre. Lancer deux processus Flutter simultanés dans le même répertoire n’est
pas sûr, car ils partagent `.dart_tool` et `build`.

Résultats :

- Web : `mobile_app/build/web`
- Android : `mobile_app/build/app/outputs/flutter-apk/app-release.apk`

Utiliser `-SkipTests` uniquement après une exécution réussie de l’analyse et des
tests dans le même commit.

## Exécution locale

Backend :

```powershell
cd 03_Backend
.\.venv\Scripts\Activate.ps1
uvicorn app.main:app --reload --host 0.0.0.0 --port 4212
```

Web :

```powershell
cd mobile_app
flutter run -d chrome `
  --dart-define=API_BASE_URL=http://127.0.0.1:4212/api/v1
```

En développement, l’API accepte automatiquement les origines `localhost` et
`127.0.0.1` sur n’importe quel port (le port Flutter Web peut être dynamique).
En production, seules les origines explicitement déclarées dans
`CORS_ORIGINS` sont autorisées.

Android Emulator :

```powershell
flutter run -d <identifiant-emulateur> `
  --dart-define=API_BASE_URL=http://10.0.2.2:4212/api/v1 `
  --dart-define=TABLET_API_KEY=<clé-locale>
```

Pour un appareil physique, remplacer `10.0.2.2` par une adresse HTTPS ou une
adresse LAN accessible depuis la tablette.

## Déploiement Web

Servir le contenu de `build/web` derrière HTTPS et configurer le serveur pour
rediriger les URL inconnues vers `index.html`. Autoriser précisément le domaine
Web dans la configuration CORS du backend ; ne pas utiliser `*` en production.

Le stockage Web fourni par `flutter_secure_storage` nécessite HTTPS (localhost
est accepté en développement). Comme tout stockage piloté par JavaScript, il ne
remplace pas un cookie `HttpOnly`. Une architecture BFF avec cookie sécurisé est
une amélioration future possible pour un portail exposé sur Internet.
