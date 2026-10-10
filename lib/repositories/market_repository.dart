import '../core/database/database_helper.dart';
import '../core/errors/app_exception.dart';
import '../core/utils/app_logger.dart';
import '../models/market_rate_model.dart';
import '../services/market_service.dart';

abstract class IMarketRepository {
  Future<List<MarketRateModel>> getMarketRates();
  Future<List<MarketRateModel>> fetchLiveRates();
  Future<void> updateSingleRate(MarketRateModel rate);
}

class MarketRepository implements IMarketRepository {
  final DatabaseHelper _dbHelper;

  MarketRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<MarketRateModel>> getMarketRates() async {
    try {
      return await MarketService.getOrInitRates();
    } catch (e, stack) {
      AppLogger.error('Failed to load initial market rates', e, stack, 'MarketRepo');
      return MarketService.defaultRates;
    }
  }

  @override
  Future<List<MarketRateModel>> fetchLiveRates() async {
    try {
      return await MarketService.fetchLiveRates();
    } catch (e, stack) {
      AppLogger.error('Failed to fetch live market rates', e, stack, 'MarketRepo');
      return await getMarketRates();
    }
  }

  @override
  Future<void> updateSingleRate(MarketRateModel rate) async {
    try {
      await _dbHelper.updateMarketRate(rate);
    } catch (e, stack) {
      AppLogger.error('Failed to update single market rate: ${rate.symbol}', e, stack, 'MarketRepo');
      throw DatabaseException('Piyasa kuru güncellenemedi', originalError: e);
    }
  }
}
