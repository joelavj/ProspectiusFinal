# Prospectius

Une application Flutter pour Windows.

## Prérequis

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.16.0 ou supérieure)
- [Visual Studio 2022](https://visualstudio.microsoft.com/) avec les outils de développement C++
- Git

## Installation

```bash
# Cloner le projet
git clone <repository-url>
cd prospectius

# Récupérer les dépendances Flutter
flutter pub get

# Activer le support Windows Desktop
flutter config --enable-windows-desktop
```

## Développement

### Lancer l'application en mode debug

```bash
flutter run -d windows
```

### Lancer l'application en mode release

```bash
flutter run -d windows --release
```

## Build

### Créer une version Windows Release

```bash
flutter build windows --release
```

L'exécutable sera disponible à: `build/windows/x64/runner/Release/prospectius.exe`

## Release Automatisée

La pipeline GitHub Actions automatise la création de releases pour Windows:

1. **Via les tags Git:**
   - Créer un tag: `git tag v1.0.0`
   - Pusher le tag: `git push origin v1.0.0`
   - Une release sera créée automatiquement

2. **Manuellement:**
   - Aller à l'onglet "Actions" sur GitHub
   - Sélectionner "Build and Release Windows"
   - Cliquer sur "Run workflow"
   - Entrer la version (ex: v1.0.1)

## Structure du projet

```
prospectius/
├── lib/                  # Code source Dart/Flutter
│   └── main.dart        # Point d'entrée de l'application
├── windows/             # Configuration Windows
├── .github/
│   └── workflows/       # GitHub Actions pipelines
├── pubspec.yaml         # Configuration du projet Flutter
└── README.md            # Ce fichier
```

## Fichiers importants

- `pubspec.yaml` - Dépendances et configuration du projet
- `.github/workflows/build-release-windows.yml` - Pipeline CI/CD pour Windows
- `.gitignore` - Fichiers à ignorer dans Git

## License

Tous droits réservés.
