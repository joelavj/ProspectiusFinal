import 'package:flutter/material.dart';
import '../models/stats.dart';
import '../services/database_service.dart';
import '../services/error_handling_service.dart';
import '../utils/app_logger.dart';

class StatsProvider extends ChangeNotifier {
  List<ProspectStats> _prospectStats = [];
  ConversionStats? _conversionStats;
  bool _isLoading = false;
  String? _error;
  int _loadingCount = 0;

  List<ProspectStats> get prospectStats => _prospectStats;
  ConversionStats? get conversionStats => _conversionStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final DatabaseService _databaseService = DatabaseService();

  void _setLoading(bool loading) {
    if (loading) {
      _loadingCount++;
    } else {
      _loadingCount--;
    }
    _isLoading = _loadingCount > 0;
    notifyListeners();
  }

  Future<void> loadAllStats(int userId) async {
    _error = null;
    _setLoading(true);

    try {
      final results = await Future.wait([
        ErrorHandlingService.executeWithTimeout(
          () => _databaseService.getProspectStats(userId),
          operationName: 'Chargement des statistiques',
          timeout: ErrorHandlingService.defaultTimeout,
        ),
        ErrorHandlingService.executeWithTimeout(
          () => _databaseService.getConversionStats(userId),
          operationName: 'Chargement des statistiques de conversion',
          timeout: ErrorHandlingService.defaultTimeout,
        ),
      ]);

      _prospectStats = results[0] as List<ProspectStats>;
      _conversionStats = results[1] as ConversionStats;
    } on TimeoutException catch (e) {
      _error = 'Timeout: ${e.message}';
      AppLogger.error('Timeout lors du chargement des stats', null);
    } catch (e, stackTrace) {
      _error = 'Erreur: $e';
      AppLogger.error('Erreur lors du chargement des stats', e, stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadProspectStats(int userId) async {
    _setLoading(true);

    try {
      _prospectStats = await ErrorHandlingService.executeWithTimeout(
        () => _databaseService.getProspectStats(userId),
        operationName: 'Chargement des statistiques',
        timeout: ErrorHandlingService.defaultTimeout,
      );
    } on TimeoutException catch (e) {
      _error = 'Timeout: ${e.message}';
      AppLogger.error('Timeout lors du chargement des stats', null);
    } catch (e, stackTrace) {
      _error = 'Erreur: $e';
      AppLogger.error('Erreur lors du chargement des stats', e, stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadConversionStats(int userId) async {
    _setLoading(true);

    try {
      _conversionStats = await ErrorHandlingService.executeWithTimeout(
        () => _databaseService.getConversionStats(userId),
        operationName: 'Chargement des statistiques de conversion',
        timeout: ErrorHandlingService.defaultTimeout,
      );
    } on TimeoutException catch (e) {
      _error = 'Timeout: ${e.message}';
      AppLogger.error(
          'Timeout lors du chargement des stats de conversion', null);
    } catch (e, stackTrace) {
      _error = 'Erreur: $e';
      AppLogger.error(
          'Erreur lors du chargement des stats de conversion', e, stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
