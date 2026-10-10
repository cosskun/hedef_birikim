import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../models/asset_model.dart';
import '../models/market_rate_model.dart';
import '../models/transaction_model.dart';
import '../services/market_service.dart';

class PortfolioProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  List<AssetModel> _assets = [];
  List<MarketRateModel> _marketRates = [];
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  List<AssetModel> get assets => _assets;
  List<MarketRateModel> get marketRates => _marketRates;
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  PortfolioProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _marketRates = await MarketService.getOrInitRates();
      _assets = await _dbHelper.getAssets();
      _transactions = await _dbHelper.getTransactions();

      if (_assets.isNotEmpty) {
        // Refresh current prices from latest market rates
        _syncAssetsWithMarketRates();
      }
    } catch (e) {
      if (kDebugMode) print('loadData error: $e');
      if (_marketRates.isEmpty) {
        _marketRates = MarketService.defaultRates;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Auto-fetch latest live rates in background on app launch
    try {
      refreshMarketRates();
    } catch (e) {
      if (kDebugMode) print('Auto refresh rates: $e');
    }
  }

  void _syncAssetsWithMarketRates() {
    bool changed = false;
    for (int i = 0; i < _assets.length; i++) {
      final asset = _assets[i];
      final rate = _marketRates.where((r) => r.symbol == asset.symbol).firstOrNull;
      if (rate != null && rate.buyPrice > 0 && asset.currentPrice != rate.buyPrice) {
        _assets[i] = asset.copyWith(currentPrice: rate.buyPrice);
        changed = true;
      }
    }
    if (changed) {
      _dbHelper.saveAllAssets(_assets);
    }
  }

  Future<void> refreshMarketRates() async {
    _marketRates = await MarketService.fetchLiveRates();
    _syncAssetsWithMarketRates();
    notifyListeners();
  }

  Future<void> updateSingleRate(MarketRateModel rate) async {
    await _dbHelper.updateMarketRate(rate);
    final index = _marketRates.indexWhere((r) => r.symbol == rate.symbol);
    if (index >= 0) {
      _marketRates[index] = rate;
    } else {
      _marketRates.add(rate);
    }
    _syncAssetsWithMarketRates();
    notifyListeners();
  }

  // --- Portfolio Net Calculations ---
  double get totalPortfolioValue {
    return _assets.fold(0.0, (sum, asset) => sum + asset.totalCurrentValue);
  }

  double get totalPortfolioCost {
    return _assets.fold(0.0, (sum, asset) => sum + asset.totalCost);
  }

  double get totalProfitLossAmount => totalPortfolioValue - totalPortfolioCost;

  double get totalProfitLossPercentage {
    if (totalPortfolioCost == 0) return 0.0;
    return ((totalPortfolioValue - totalPortfolioCost) / totalPortfolioCost) * 100;
  }

  // Category Total Values
  double getCategoryValue(AssetCategory category) {
    return _assets
        .where((a) => a.category == category)
        .fold(0.0, (sum, asset) => sum + asset.totalCurrentValue);
  }

  Map<AssetCategory, double> get categoryDistribution {
    final map = <AssetCategory, double>{};
    for (final category in AssetCategory.values) {
      final val = getCategoryValue(category);
      if (val > 0) {
        map[category] = val;
      }
    }
    return map;
  }

  // Assets allocated for a specific goal
  List<AssetModel> getAssetsForGoal(String goalId) {
    return _assets.where((a) => a.linkedGoalId == goalId).toList();
  }

  double getTotalValueForGoal(String goalId) {
    return getAssetsForGoal(goalId).fold(0.0, (sum, asset) => sum + asset.totalCurrentValue);
  }

  // --- CRUD Operations ---
  Future<void> addAsset({
    required String name,
    required String symbol,
    required AssetCategory category,
    required double amount,
    required String unit,
    required double buyPrice,
    double? currentPrice,
    String? linkedGoalId,
    String note = '',
  }) async {
    // If currentPrice not provided, check market rates
    double resolvedCurrentPrice = currentPrice ?? buyPrice;
    final matchedRate = _marketRates.where((r) => r.symbol == symbol).firstOrNull;
    if (matchedRate != null) {
      resolvedCurrentPrice = matchedRate.buyPrice;
    }

    final newAsset = AssetModel(
      id: _uuid.v4(),
      name: name,
      symbol: symbol,
      category: category,
      amount: amount,
      unit: unit,
      buyPrice: buyPrice,
      currentPrice: resolvedCurrentPrice,
      linkedGoalId: linkedGoalId,
      updatedAt: DateTime.now(),
      note: note,
    );

    await _dbHelper.insertAsset(newAsset);

    // Record transaction
    final tx = TransactionModel(
      id: _uuid.v4(),
      assetId: newAsset.id,
      assetName: newAsset.name,
      type: TransactionType.buy,
      amount: amount,
      pricePerUnit: buyPrice,
      totalTRY: amount * buyPrice,
      date: DateTime.now(),
      goalId: linkedGoalId,
      note: note.isNotEmpty ? note : 'Varlık eklendi',
    );
    await _dbHelper.insertTransaction(tx);

    _assets.insert(0, newAsset);
    _transactions.insert(0, tx);
    notifyListeners();
  }

  Future<void> updateAsset(AssetModel asset) async {
    await _dbHelper.updateAsset(asset);
    final index = _assets.indexWhere((a) => a.id == asset.id);
    if (index >= 0) {
      _assets[index] = asset;
      notifyListeners();
    }
  }

  Future<void> deleteAsset(String id) async {
    await _dbHelper.deleteAsset(id);
    _assets.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  Future<void> linkAssetToGoal(String assetId, String? goalId) async {
    final index = _assets.indexWhere((a) => a.id == assetId);
    if (index >= 0) {
      final updated = _assets[index].copyWith(linkedGoalId: goalId);
      await _dbHelper.updateAsset(updated);
      _assets[index] = updated;
      notifyListeners();
    }
  }
}
