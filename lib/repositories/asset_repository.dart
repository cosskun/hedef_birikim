import '../core/database/database_helper.dart';
import '../core/errors/app_exception.dart';
import '../core/utils/app_logger.dart';
import '../models/asset_model.dart';
import '../models/transaction_model.dart';

abstract class IAssetRepository {
  Future<List<AssetModel>> getAssets();
  Future<void> saveAsset(AssetModel asset);
  Future<void> updateAsset(AssetModel asset);
  Future<void> deleteAsset(String id);
  Future<void> saveAllAssets(List<AssetModel> assets);
  Future<List<TransactionModel>> getTransactions();
  Future<void> saveTransaction(TransactionModel transaction);
}

class AssetRepository implements IAssetRepository {
  final DatabaseHelper _dbHelper;

  AssetRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<AssetModel>> getAssets() async {
    try {
      return await _dbHelper.getAssets();
    } catch (e, stack) {
      AppLogger.error('Failed to retrieve assets', e, stack, 'AssetRepo');
      throw DatabaseException('Varlıklar veritabanından yüklenemedi', originalError: e);
    }
  }

  @override
  Future<void> saveAsset(AssetModel asset) async {
    try {
      await _dbHelper.insertAsset(asset);
    } catch (e, stack) {
      AppLogger.error('Failed to insert asset: ${asset.id}', e, stack, 'AssetRepo');
      throw DatabaseException('Varlık kaydedilemedi', originalError: e);
    }
  }

  @override
  Future<void> updateAsset(AssetModel asset) async {
    try {
      await _dbHelper.updateAsset(asset);
    } catch (e, stack) {
      AppLogger.error('Failed to update asset: ${asset.id}', e, stack, 'AssetRepo');
      throw DatabaseException('Varlık güncellenemedi', originalError: e);
    }
  }

  @override
  Future<void> deleteAsset(String id) async {
    try {
      await _dbHelper.deleteAsset(id);
    } catch (e, stack) {
      AppLogger.error('Failed to delete asset: $id', e, stack, 'AssetRepo');
      throw DatabaseException('Varlık silinemedi', originalError: e);
    }
  }

  @override
  Future<void> saveAllAssets(List<AssetModel> assets) async {
    try {
      await _dbHelper.saveAllAssets(assets);
    } catch (e, stack) {
      AppLogger.error('Failed to batch save assets', e, stack, 'AssetRepo');
      throw DatabaseException('Varlıklar toplu güncellenemedi', originalError: e);
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    try {
      return await _dbHelper.getTransactions();
    } catch (e, stack) {
      AppLogger.error('Failed to retrieve transactions', e, stack, 'AssetRepo');
      throw DatabaseException('İşlem geçmişi yüklenemedi', originalError: e);
    }
  }

  @override
  Future<void> saveTransaction(TransactionModel transaction) async {
    try {
      await _dbHelper.insertTransaction(transaction);
    } catch (e, stack) {
      AppLogger.error('Failed to record transaction: ${transaction.id}', e, stack, 'AssetRepo');
      throw DatabaseException('İşlem kaydedilemedi', originalError: e);
    }
  }
}
