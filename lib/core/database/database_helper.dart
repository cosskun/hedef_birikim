import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/goal_model.dart';
import '../../models/asset_model.dart';
import '../../models/transaction_model.dart';
import '../../models/market_rate_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  static const String _goalsKey = 'hedef_birikim_clean_goals_v1';
  static const String _assetsKey = 'hedef_birikim_clean_assets_v1';
  static const String _transactionsKey = 'hedef_birikim_clean_transactions_v1';
  static const String _marketRatesKey = 'hedef_birikim_clean_market_rates_v1';

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_goalsKey);
    await prefs.remove(_assetsKey);
    await prefs.remove(_transactionsKey);
    // Also clear legacy keys
    await prefs.remove('hedef_birikim_goals_json');
    await prefs.remove('hedef_birikim_assets_json');
    await prefs.remove('hedef_birikim_transactions_json');
  }

  // --- GOAL CRUD ---
  Future<List<GoalModel>> getGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_goalsKey);
      if (raw == null || raw.isEmpty) return [];
      final list = json.decode(raw) as List<dynamic>;
      return list.map((e) => GoalModel.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) print('getGoals error: $e');
      return [];
    }
  }

  Future<void> saveAllGoals(List<GoalModel> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(goals.map((g) => g.toMap()).toList());
    await prefs.setString(_goalsKey, jsonStr);
  }

  Future<int> insertGoal(GoalModel goal) async {
    final list = await getGoals();
    final index = list.indexWhere((g) => g.id == goal.id);
    if (index >= 0) {
      list[index] = goal;
    } else {
      list.insert(0, goal);
    }
    await saveAllGoals(list);
    return 1;
  }

  Future<int> updateGoal(GoalModel goal) async {
    return await insertGoal(goal);
  }

  Future<int> deleteGoal(String id) async {
    final list = await getGoals();
    list.removeWhere((g) => g.id == id);
    await saveAllGoals(list);

    // Unlink assets
    final assetsList = await getAssets();
    bool changed = false;
    for (int i = 0; i < assetsList.length; i++) {
      if (assetsList[i].linkedGoalId == id) {
        assetsList[i] = assetsList[i].copyWith(linkedGoalId: null);
        changed = true;
      }
    }
    if (changed) {
      await saveAllAssets(assetsList);
    }
    return 1;
  }

  // --- ASSET CRUD ---
  Future<List<AssetModel>> getAssets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_assetsKey);
      if (raw == null || raw.isEmpty) return [];
      final list = json.decode(raw) as List<dynamic>;
      return list.map((e) => AssetModel.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) print('getAssets error: $e');
      return [];
    }
  }

  Future<void> saveAllAssets(List<AssetModel> assets) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(assets.map((a) => a.toMap()).toList());
    await prefs.setString(_assetsKey, jsonStr);
  }

  Future<int> insertAsset(AssetModel asset) async {
    final list = await getAssets();
    final index = list.indexWhere((a) => a.id == asset.id);
    if (index >= 0) {
      list[index] = asset;
    } else {
      list.insert(0, asset);
    }
    await saveAllAssets(list);
    return 1;
  }

  Future<int> updateAsset(AssetModel asset) async {
    return await insertAsset(asset);
  }

  Future<int> deleteAsset(String id) async {
    final list = await getAssets();
    list.removeWhere((a) => a.id == id);
    await saveAllAssets(list);
    return 1;
  }

  // --- TRANSACTION CRUD ---
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_transactionsKey);
      if (raw == null || raw.isEmpty) return [];
      final list = json.decode(raw) as List<dynamic>;
      return list.map((e) => TransactionModel.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) print('getTransactions error: $e');
      return [];
    }
  }

  Future<int> insertTransaction(TransactionModel tx) async {
    final list = await getTransactions();
    list.insert(0, tx);
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(list.map((t) => t.toMap()).toList());
    await prefs.setString(_transactionsKey, jsonStr);
    return 1;
  }

  // --- MARKET RATES ---
  Future<List<MarketRateModel>> getMarketRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_marketRatesKey);
      if (raw == null || raw.isEmpty) return [];
      final list = json.decode(raw) as List<dynamic>;
      return list.map((e) => MarketRateModel.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) print('getMarketRates error: $e');
      return [];
    }
  }

  Future<void> saveMarketRates(List<MarketRateModel> rates) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(rates.map((r) => r.toMap()).toList());
    await prefs.setString(_marketRatesKey, jsonStr);
  }

  Future<void> updateMarketRate(MarketRateModel rate) async {
    final list = await getMarketRates();
    final index = list.indexWhere((r) => r.symbol == rate.symbol);
    if (index >= 0) {
      list[index] = rate;
    } else {
      list.add(rate);
    }
    await saveMarketRates(list);
  }
}
