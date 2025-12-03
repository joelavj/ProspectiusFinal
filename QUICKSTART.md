# 🚀 Prospectius - Démarrage Rapide

Bienvenue dans **Prospectius**, une application CRM moderne pour Windows et Linux.

## ⚡ Installation Rapide

### Option 1: Depuis les Exécutables Compilés (Recommandé) ⭐

**1. Téléchargez les fichiers:**
- Rendez-vous sur la [page des releases](https://github.com/josoavj/ProspectiusFinal/releases/latest)
- Téléchargez les fichiers pour votre système:
  - **Windows:** `prospectius.exe`
  - **Linux:** `prospectius`
  - **Tous:** `Prospectius.sql` (script de base de données)

**2. Installez MariaDB:**
- [Windows](https://mariadb.org/download/)
- [Linux Ubuntu/Debian](https://mariadb.org/download/#mariadb-repositories): `sudo apt install mariadb-server`
- [Linux Fedora/RHEL](https://mariadb.org/download/#mariadb-repositories): `sudo dnf install mariadb-server`

**3. Importez la base de données:**
```bash
# Linux/macOS
mysql -u root -proot < Prospectius.sql

# Windows (dans PowerShell ou CMD)
mysql -u root -proot < Prospectius.sql
```

**4. Lancez l'application:**
- **Windows:** Double-cliquez sur `prospectius.exe`
- **Linux:** `./prospectius`

### Option 2: Depuis les Scripts d'Installation

**Sur Linux:**
```bash
git clone https://github.com/josoavj/ProspectiusFinal.git
cd ProspectiusFinal
bash scripts/install-linux.sh
```

**Sur Windows (PowerShell):**
```powershell
git clone https://github.com/josoavj/ProspectiusFinal.git
cd ProspectiusFinal
powershell -ExecutionPolicy Bypass -File scripts/install-windows.ps1
```

Les scripts téléchargeront automatiquement les fichiers et configureront la base de données.

---

## 🔐 Premier Accès

Une fois l'application lancée:

### 1. Configuration de la Base de Données
À la première exécution, vous devrez configurer la connexion:

```
Host: localhost
Port: 3306
User: root
Password: root
Database: Prospectius
```

### 2. Créer un Compte
- Cliquez sur le bouton **"S'inscrire"**
- Remplissez le formulaire avec vos informations
- Complétez l'inscription
- Vous pourrez alors vous connecter avec vos identifiants

---

## ❓ Besoin d'Aide?

### Pour les Développeurs (Construction depuis les sources)

Si vous voulez compiler depuis le code source:

```bash
# Cloner le projet
git clone https://github.com/josoavj/ProspectiusFinal.git
cd ProspectiusFinal

# Installer les dépendances
flutter pub get

# Compiler pour votre plateforme
flutter build windows   # Windows
flutter build linux     # Linux
flutter build macos     # macOS
```

### Validation de l'Installation
```bash
bash scripts/validate.sh
```

Cela affiche un diagnostic complet du système.

### Nettoyage et Réinitialisation
```bash
bash scripts/clean.sh
```

Nettoie les caches et réinstalle les dépendances (pour développeurs).

### Documentation Complète

- **[INSTALLATION.md](INSTALLATION.md)** - Guide détaillé pour chaque OS
- **[ENVIRONMENT.md](ENVIRONMENT.md)** - Variables et configuration
- **[scripts/README.md](scripts/README.md)** - Documentation des scripts
- **[README.md](README.md)** - Vue d'ensemble du projet

---

## 🐛 Problèmes Courants

### "MariaDB non trouvé"
```bash
# Linux (Ubuntu/Debian)
sudo systemctl start mariadb

# macOS
brew services start mariadb

# Windows
# Services.msc → Chercher "MariaDB" → Démarrer
```

### "Flutter non trouvé"
Installez Flutter: https://flutter.dev/docs/get-started/install

### "Base de données non importée"
```bash
bash scripts/download-sql.sh
mysql -u root -proot < scripts/prospectius.sql
```

---

## 🎯 Fonctionnalités Principales

✅ **Gestion de Prospects**
- Ajouter/modifier/supprimer des prospects
- Classer par statut (Nouveau, En cours, Qualifié, etc.)
- Ajouter des notes et contacts

✅ **Suivi des Interactions**
- Enregistrer les interactions avec les prospects
- Historique complet par prospect

✅ **Statistiques**
- Tableau de bord avec métriques clés
- Taux de conversion
- Distribution par statut

✅ **Authentification**
- Connexion sécurisée
- Gestion des comptes utilisateurs

---

## 📋 Prérequis Système

| Plateforme | Req. Minimum | Recommandé |
|-----------|-------------|-----------|
| **Windows** | Windows 8.1+ | Windows 10+ (64-bit) |
| **Linux** | Ubuntu 18.04+ | Ubuntu 22.04+ (64-bit) |
| **macOS** | 10.11+ | 12.0+ |

**Logiciels requis:**
- **MariaDB 10.3+** ou **MySQL 5.7+**

**Pour les développeurs:**
- Flutter 3.16.0+
- Dart 3.0.0+

---

## 🔧 Configuration Avancée

Pour des configurations personnalisées, consultez:
- [ENVIRONMENT.md](ENVIRONMENT.md) pour les variables
- [CONFIGURATION.md](CONFIGURATION.md) pour les paramètres par défaut
- [scripts/README.md](scripts/README.md) pour les options des scripts

---

## 🤝 Contribution

Pour contribuer au projet:

1. Fork le dépôt
2. Créez une branche (`git checkout -b feature/improvement`)
3. Commitez vos changements (`git commit -am 'Add improvement'`)
4. Poussez vers la branche (`git push origin feature/improvement`)
5. Ouvrez une Pull Request

---

## 📄 Licence

Tous droits réservés.

---

## 📞 Support

Pour toute question ou problème:
1. Exécutez `bash scripts/validate.sh` pour un diagnostic
2. Consultez la [documentation](./docs)
3. Vérifiez les [issues existantes](../../issues)

---

**Version:** 1.0.0  
**Dernière mise à jour:** 2024-11-29

Bon démarrage! 🎉
