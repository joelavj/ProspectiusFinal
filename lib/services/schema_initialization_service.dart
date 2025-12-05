import 'package:mysql1/mysql1.dart' as mysql;
import '../utils/app_logger.dart';

/// Service d'initialisation du schéma de base de données
/// Crée les tables principales si elles n'existent pas
class SchemaInitializationService {
  final mysql.MySqlConnection _connection;

  SchemaInitializationService(this._connection);

  /// Initialise le schéma complet de la base de données
  Future<void> initializeSchema() async {
    try {
      AppLogger.info('Initialisation du schéma de la base de données...');

      await _createAccountsTable();
      await _createProspectsTable();
      await _createInteractionsTable();
      await _createAuditLogsTable();
      await _createTransferHistoryTable();

      AppLogger.success('✓ Schéma de base de données initialisé avec succès');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de l\'initialisation du schéma', e, stackTrace);
      rethrow;
    }
  }

  /// Crée la table accounts
  Future<void> _createAccountsTable() async {
    try {
      await _connection.query('''
        CREATE TABLE IF NOT EXISTS Account (
          id INT AUTO_INCREMENT PRIMARY KEY,
          username VARCHAR(255) NOT NULL UNIQUE,
          email VARCHAR(255) NOT NULL UNIQUE,
          password_hash VARCHAR(255) NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
          last_login TIMESTAMP NULL,
          is_active TINYINT(1) DEFAULT 1,
          INDEX idx_username (username),
          INDEX idx_email (email)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      ''');
      AppLogger.success('Table Account créée/vérifiée');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la création de la table Account', e, stackTrace);
      rethrow;
    }
  }

  /// Crée la table prospects
  Future<void> _createProspectsTable() async {
    try {
      await _connection.query('''
        CREATE TABLE IF NOT EXISTS Prospect (
          id INT AUTO_INCREMENT PRIMARY KEY,
          nom VARCHAR(255) NOT NULL,
          prenom VARCHAR(255) NOT NULL,
          email VARCHAR(255),
          telephone VARCHAR(20),
          adresse TEXT,
          type VARCHAR(50),
          status VARCHAR(50) DEFAULT 'nouveau',
          assignation INT,
          creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          dateUpdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
          deleted_at TIMESTAMP NULL DEFAULT NULL,
          created_by INT,
          updated_by INT,
          INDEX idx_assignation (assignation),
          INDEX idx_status (status),
          INDEX idx_type (type),
          INDEX idx_creation (creation),
          INDEX idx_deleted_at (deleted_at),
          FOREIGN KEY (assignation) REFERENCES Account(id) ON DELETE SET NULL,
          FOREIGN KEY (created_by) REFERENCES Account(id) ON DELETE SET NULL,
          FOREIGN KEY (updated_by) REFERENCES Account(id) ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      ''');
      AppLogger.success('Table Prospect créée/vérifiée');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la création de la table Prospect', e, stackTrace);
      rethrow;
    }
  }

  /// Crée la table interactions
  Future<void> _createInteractionsTable() async {
    try {
      await _connection.query('''
        CREATE TABLE IF NOT EXISTS Interaction (
          id INT AUTO_INCREMENT PRIMARY KEY,
          prospect_id INT NOT NULL,
          description TEXT,
          date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          type VARCHAR(100),
          created_by INT,
          updated_by INT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
          deleted_at TIMESTAMP NULL DEFAULT NULL,
          INDEX idx_prospect_id (prospect_id),
          INDEX idx_date (date),
          INDEX idx_type (type),
          INDEX idx_deleted_at (deleted_at),
          FOREIGN KEY (prospect_id) REFERENCES Prospect(id) ON DELETE CASCADE,
          FOREIGN KEY (created_by) REFERENCES Account(id) ON DELETE SET NULL,
          FOREIGN KEY (updated_by) REFERENCES Account(id) ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      ''');
      AppLogger.success('Table Interaction créée/vérifiée');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la création de la table Interaction', e, stackTrace);
      rethrow;
    }
  }

  /// Crée la table audit_logs
  Future<void> _createAuditLogsTable() async {
    try {
      await _connection.query('''
        CREATE TABLE IF NOT EXISTS audit_logs (
          id INT AUTO_INCREMENT PRIMARY KEY,
          user_id INT,
          table_name VARCHAR(100) NOT NULL,
          action VARCHAR(50) NOT NULL,
          record_id INT,
          old_value JSON,
          new_value JSON,
          timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          ip_address VARCHAR(45),
          INDEX idx_user_id (user_id),
          INDEX idx_table_name (table_name),
          INDEX idx_timestamp (timestamp),
          FOREIGN KEY (user_id) REFERENCES Account(id) ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      ''');
      AppLogger.success('Table audit_logs créée/vérifiée');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la création de la table audit_logs', e, stackTrace);
      rethrow;
    }
  }

  /// Crée la table transfer_history
  Future<void> _createTransferHistoryTable() async {
    try {
      await _connection.query('''
        CREATE TABLE IF NOT EXISTS transfer_history (
          id INT AUTO_INCREMENT PRIMARY KEY,
          prospect_id INT NOT NULL,
          from_user INT NOT NULL,
          to_user INT NOT NULL,
          reason TEXT,
          transferred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          INDEX idx_prospect_id (prospect_id),
          INDEX idx_from_user (from_user),
          INDEX idx_to_user (to_user),
          INDEX idx_transferred_at (transferred_at),
          FOREIGN KEY (prospect_id) REFERENCES Prospect(id) ON DELETE CASCADE,
          FOREIGN KEY (from_user) REFERENCES Account(id) ON DELETE RESTRICT,
          FOREIGN KEY (to_user) REFERENCES Account(id) ON DELETE RESTRICT
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      ''');
      AppLogger.success('Table transfer_history créée/vérifiée');
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la création de la table transfer_history',
          e, stackTrace);
      rethrow;
    }
  }
}
