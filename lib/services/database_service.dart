import 'package:bcrypt/bcrypt.dart';
import 'mysql_service.dart';
import '../models/account.dart';
import '../models/prospect.dart';
import '../models/interaction.dart';
import '../models/stats.dart';
import '../utils/exception_handler.dart';
import '../utils/app_logger.dart';
import '../utils/validators.dart';

class DatabaseService {
  final MySQLService _mysqlService = MySQLService();

  // === AUTHENTIFICATION ===

  Future<Account> authenticate(
    String username,
    String password,
  ) async {
    try {
      AppLogger.logRequest(
          'AUTH', 'SELECT * FROM Account WHERE username = ?', [username]);

      final results = await _mysqlService.query(
        'SELECT * FROM Account WHERE username = ?',
        [username],
      );

      if (results.isEmpty) {
        AppLogger.warning(
            'Tentative d\'authentification: utilisateur "$username" non trouvé');
        throw AuthException(
          message: 'Utilisateur non trouvé',
          code: 'USER_NOT_FOUND',
        );
      }

      final row = results.first;
      final hashedPassword = row['password'] as String;

      // Vérifier le mot de passe avec bcrypt
      final isPasswordValid = BCrypt.checkpw(password, hashedPassword);

      if (!isPasswordValid) {
        AppLogger.warning(
            'Tentative d\'authentification: mot de passe incorrect pour "$username"');
        throw AuthException(
          message: 'Mot de passe incorrect',
          code: 'INVALID_PASSWORD',
        );
      }

      final user = Account(
        id: row['id'] as int,
        nom: row['nom'] as String,
        prenom: row['prenom'] as String,
        email: row['email'] as String,
        username: row['username'] as String,
        typeCompte: row['type_compte'] as String,
        dateCreation: DateTime.parse(row['date_creation'].toString()),
      );

      AppLogger.success('Authentification réussie pour ${user.fullName}');
      return user;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de l\'authentification', e, stackTrace);
      throw DatabaseException(
        message: 'Erreur lors de l\'authentification: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> createAccount(
    String nom,
    String prenom,
    String email,
    String username,
    String password,
  ) async {
    try {
      // Valider les données
      final validationResult = Validators.validateRegistration(
        nom: nom,
        prenom: prenom,
        email: email,
        username: username,
        password: password,
      );

      if (!validationResult.isValid) {
        throw ValidationException(
          message: validationResult.error!,
          code: 'INVALID_INPUT',
        );
      }

      AppLogger.logRequest(
          'REGISTER', 'SELECT id FROM Account WHERE username = ?', [username]);

      // Vérifier l'unicité du username
      final existingUser = await _mysqlService.query(
        'SELECT id FROM Account WHERE username = ?',
        [username],
      );

      if (existingUser.isNotEmpty) {
        AppLogger.warning(
            'Tentative de création: utilisateur "$username" existe déjà');
        throw ValidationException(
          message: 'Cet identifiant existe déjà',
          code: 'USERNAME_EXISTS',
        );
      }

      // Hacher le mot de passe avec bcrypt
      final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

      AppLogger.logRequest(
        'REGISTER',
        'INSERT INTO Account',
        [nom, prenom, email, username, '***', 'Utilisateur'],
      );

      // Insérer le nouvel utilisateur
      await _mysqlService.query(
        '''INSERT INTO Account (nom, prenom, email, username, password, type_compte, date_creation)
           VALUES (?, ?, ?, ?, ?, ?, NOW())''',
        [nom, prenom, email, username, passwordHash, 'Utilisateur'],
      );

      AppLogger.success('Compte créé avec succès pour $username');
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la création du compte', e, stackTrace);
      throw DatabaseException(
        message: 'Erreur lors de la création du compte: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }

  // === PROSPECTS ===

  Future<List<Prospect>> getProspects(int userId) async {
    try {
      AppLogger.logRequest('PROSPECTS',
          'SELECT * FROM Prospect WHERE id_utilisateur = ?', [userId]);

      final results = await _mysqlService.query(
        'SELECT * FROM Prospect WHERE id_utilisateur = ? ORDER BY date_creation DESC',
        [userId],
      );

      AppLogger.logResponse('PROSPECTS', results.length);

      return results
          .map(
            (row) => Prospect(
              id: row['id'] as int,
              nom: row['nom'] as String,
              prenom: row['prenom'] as String,
              email: row['email'] as String,
              telephone: row['telephone'] as String? ?? '',
              entreprise: row['entreprise'] as String? ?? '',
              poste: row['poste'] as String? ?? '',
              statut: row['statut'] as String? ?? 'En cours',
              source: row['source'] as String? ?? '',
              notes: row['notes'] as String? ?? '',
              idUtilisateur: row['id_utilisateur'] as int,
              dateCreation: DateTime.parse(row['date_creation'].toString()),
              dateModification: row['date_modification'] != null
                  ? DateTime.parse(row['date_modification'].toString())
                  : null,
            ),
          )
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la récupération des prospects', e, stackTrace);
      throw DatabaseException(
        message: 'Erreur lors de la récupération des prospects: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> createProspect(
    int userId,
    String nom,
    String prenom,
    String email,
    String telephone,
    String entreprise,
    String poste,
    String statut,
    String source,
    String notes,
  ) async {
    try {
      // Valider les données
      final validationResult = Validators.validateProspect(
        nom: nom,
        prenom: prenom,
        email: email,
        telephone: telephone,
        entreprise: entreprise,
      );

      if (!validationResult.isValid) {
        throw ValidationException(
          message: validationResult.error!,
          code: 'INVALID_INPUT',
        );
      }

      AppLogger.logRequest('CREATE_PROSPECT', 'INSERT INTO Prospect', [
        nom,
        prenom,
        email,
        telephone,
        entreprise,
        poste,
        statut,
        source,
        notes,
        userId,
      ]);

      await _mysqlService.query(
        '''INSERT INTO Prospect 
           (nom, prenom, email, telephone, entreprise, poste, statut, source, notes, id_utilisateur, date_creation)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())''',
        [
          nom,
          prenom,
          email,
          telephone,
          entreprise,
          poste,
          statut,
          source,
          notes,
          userId,
        ],
      );

      AppLogger.success('Prospect "$prenom $nom" créé avec succès');
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la création du prospect', e, stackTrace);
      throw DatabaseException(
        message: 'Erreur lors de la création: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> updateProspect(int prospectId, Map<String, dynamic> data) async {
    try {
      final updates = <String>[];
      final values = <dynamic>[];

      data.forEach((key, value) {
        if (key != 'id') {
          updates.add('$key = ?');
          values.add(value);
        }
      });

      values.add(prospectId);

      if (updates.isEmpty) return;

      AppLogger.logRequest('UPDATE_PROSPECT',
          'UPDATE Prospect SET ${updates.join(", ")}', values);

      await _mysqlService.query(
        'UPDATE Prospect SET ${updates.join(", ")}, date_modification = NOW() WHERE id = ?',
        values,
      );

      AppLogger.success('Prospect #$prospectId mis à jour');
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la mise à jour du prospect', e, stackTrace);
      throw DatabaseException(
        message: 'Erreur lors de la mise à jour: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> deleteProspect(int prospectId) async {
    try {
      AppLogger.logRequest(
          'DELETE_PROSPECT', 'DELETE FROM Prospect WHERE id = ?', [prospectId]);

      await _mysqlService.query(
        'DELETE FROM Interaction WHERE id_prospect = ?',
        [prospectId],
      );
      await _mysqlService.query('DELETE FROM Prospect WHERE id = ?', [
        prospectId,
      ]);

      AppLogger.success('Prospect #$prospectId supprimé');
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la suppression du prospect', e, stackTrace);
      throw DatabaseException(
        message: 'Erreur lors de la suppression: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }

  // === INTERACTIONS ===

  Future<List<Interaction>> getInteractions(int prospectId) async {
    try {
      AppLogger.logRequest('INTERACTIONS',
          'SELECT * FROM Interaction WHERE id_prospect = ?', [prospectId]);

      final results = await _mysqlService.query(
        '''SELECT * FROM Interaction 
           WHERE id_prospect = ? 
           ORDER BY date_interaction DESC''',
        [prospectId],
      );

      AppLogger.logResponse('INTERACTIONS', results.length);

      return results
          .map(
            (row) => Interaction(
              id: row['id'] as int,
              idProspect: row['id_prospect'] as int,
              idUtilisateur: row['id_utilisateur'] as int,
              typeInteraction: row['type_interaction'] as String,
              description: row['description'] as String,
              dateInteraction: DateTime.parse(
                row['date_interaction'].toString(),
              ),
              dateCreation: DateTime.parse(row['date_creation'].toString()),
            ),
          )
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la récupération des interactions', e, stackTrace);
      throw DatabaseException(
        message: 'Erreur lors de la récupération: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> createInteraction(
    int prospectId,
    int userId,
    String typeInteraction,
    String description,
    DateTime dateInteraction,
  ) async {
    try {
      if (description.isEmpty) {
        throw ValidationException(
          message: 'La description est obligatoire',
          code: 'EMPTY_DESCRIPTION',
        );
      }

      AppLogger.logRequest('CREATE_INTERACTION', 'INSERT INTO Interaction', [
        prospectId,
        userId,
        typeInteraction,
        description,
        dateInteraction,
      ]);

      await _mysqlService.query(
        '''INSERT INTO Interaction 
           (id_prospect, id_utilisateur, type_interaction, description, date_interaction, date_creation)
           VALUES (?, ?, ?, ?, ?, NOW())''',
        [prospectId, userId, typeInteraction, description, dateInteraction],
      );

      AppLogger.success('Interaction créée pour le prospect #$prospectId');
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la création de l\'interaction', e, stackTrace);
      throw DatabaseException(
        message: 'Erreur lors de la création: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }

  // === STATISTIQUES ===

  Future<List<ProspectStats>> getProspectStats(int userId) async {
    try {
      AppLogger.logRequest(
          'STATS',
          'SELECT statut, COUNT(*) FROM Prospect WHERE id_utilisateur = ?',
          [userId]);

      final results = await _mysqlService.query(
        '''SELECT statut, COUNT(*) as count 
           FROM Prospect 
           WHERE id_utilisateur = ? 
           GROUP BY statut''',
        [userId],
      );

      AppLogger.logResponse('STATS', results.length);

      return results
          .map(
            (row) => ProspectStats(
              statut: row['statut'] as String,
              count: row['count'] as int,
            ),
          )
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error(
          'Erreur lors de la récupération des statistiques', e, stackTrace);
      throw DatabaseException(
        message: 'Erreur: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }

  Future<ConversionStats> getConversionStats(int userId) async {
    try {
      AppLogger.logRequest('CONVERSION_STATS',
          'SELECT COUNT(*), SUM(...) FROM Prospect', [userId]);

      final results = await _mysqlService.query(
        '''SELECT 
             COUNT(*) as total,
             SUM(CASE WHEN statut = 'Converti' THEN 1 ELSE 0 END) as converted
           FROM Prospect 
           WHERE id_utilisateur = ?''',
        [userId],
      );

      final row = results.first;
      final total = row['total'] as int;
      final converted = row['converted'] as int? ?? 0;
      final rate = total > 0 ? converted / total : 0.0;

      AppLogger.success('Conversion rate: ${(rate * 100).toStringAsFixed(2)}%');

      return ConversionStats(
        totalProspects: total,
        convertedClients: converted,
        conversionRate: rate,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la récupération des stats de conversion',
          e, stackTrace);
      throw DatabaseException(
        message: 'Erreur: $e',
        originalException: e as Exception,
        stackTrace: stackTrace,
      );
    }
  }
}
