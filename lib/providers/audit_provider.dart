import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audit_service.dart';
import '../services/transfer_service.dart';
import '../services/mysql_service.dart';
import '../utils/app_logger.dart';

/// Provider pour le service d'audit
final auditServiceProvider = Provider<AuditService?>((ref) {
  try {
    final mysql = MySQLService();
    if (mysql.isConnected) {
      return AuditService(mysql.getConnection());
    }
  } catch (e) {
    AppLogger.warning('Service d\'audit non disponible: $e');
  }
  return null;
});

/// Provider pour le service de transfert
final transferServiceProvider = Provider<TransferService?>((ref) {
  try {
    final mysql = MySQLService();
    if (mysql.isConnected) {
      return TransferService(mysql.getConnection());
    }
  } catch (e) {
    AppLogger.warning('Service de transfert non disponible: $e');
  }
  return null;
});

/// Provider pour l'historique d'audit d'un prospect
final prospectAuditHistoryProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>(
        (ref, prospectId) async {
  final auditService = ref.watch(auditServiceProvider);
  if (auditService == null) return [];

  try {
    return await auditService.getAuditHistory(
      tableName: 'prospects',
      recordId: prospectId,
    );
  } catch (e) {
    AppLogger.error('Erreur lors du chargement de l\'historique d\'audit: $e');
    rethrow;
  }
});

/// Provider pour l'historique de transfert d'un prospect
final prospectTransferHistoryProvider =
    FutureProvider.family<List<ProspectTransfer>, int>((ref, prospectId) async {
  final transferService = ref.watch(transferServiceProvider);
  if (transferService == null) return [];

  try {
    return await transferService.getProspectTransferHistory(prospectId);
  } catch (e) {
    AppLogger.error('Erreur lors du chargement de l\'historique de transfert');
    rethrow;
  }
});

/// Provider pour les transferts reçus par l'utilisateur actuel
final receivedTransfersProvider =
    FutureProvider.family<List<ProspectTransfer>, int>((ref, userId) async {
  final transferService = ref.watch(transferServiceProvider);
  if (transferService == null) return [];

  try {
    return await transferService.getReceivedTransfers(userId);
  } catch (e) {
    AppLogger.error('Erreur lors du chargement des transferts reçus');
    rethrow;
  }
});

/// Provider pour les transferts envoyés par l'utilisateur actuel
final sentTransfersProvider =
    FutureProvider.family<List<ProspectTransfer>, int>((ref, userId) async {
  final transferService = ref.watch(transferServiceProvider);
  if (transferService == null) return [];

  try {
    return await transferService.getSentTransfers(userId);
  } catch (e) {
    AppLogger.error('Erreur lors du chargement des transferts envoyés');
    rethrow;
  }
});

/// Provider pour les statistiques de transfert
final transferStatsProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, userId) async {
  final transferService = ref.watch(transferServiceProvider);
  if (transferService == null) return {};

  try {
    return await transferService.getTransferStats(userId);
  } catch (e) {
    AppLogger.error('Erreur lors du chargement des statistiques de transfert');
    rethrow;
  }
});

/// Provider pour créer un transfert
final createTransferProvider = FutureProvider.autoDispose
    .family<ProspectTransfer, Map<String, dynamic>>((ref, params) async {
  final transferService = ref.watch(transferServiceProvider);
  if (transferService == null) {
    throw Exception('Service de transfert non disponible');
  }

  try {
    final transfer = await transferService.createTransfer(
      prospectId: params['prospect_id'] as int,
      fromUserId: params['from_user_id'] as int,
      toUserId: params['to_user_id'] as int,
      reason: params['reason'] as String?,
      notes: params['notes'] as String?,
    );

    // Invalider les providers de transfert
    ref.refresh(receivedTransfersProvider(params['to_user_id'] as int));
    ref.refresh(sentTransfersProvider(params['from_user_id'] as int));
    ref.refresh(transferStatsProvider(params['to_user_id'] as int));
    ref.refresh(transferStatsProvider(params['from_user_id'] as int));

    return transfer;
  } catch (e) {
    AppLogger.error('Erreur lors de la création du transfert');
    rethrow;
  }
});
