import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../models/goal_model.dart';
import '../models/transaction_model.dart';
import 'portfolio_provider.dart';

class GoalProgressInfo {
  final GoalModel goal;
  final double currentAmount;
  final double targetAmount;
  final double remainingAmount;
  final double progressPercent;
  final bool isReached;
  final int daysLeft;
  final double dailyNeededRate; // Daily savings required to hit target date

  GoalProgressInfo({
    required this.goal,
    required this.currentAmount,
    required this.targetAmount,
    required this.remainingAmount,
    required this.progressPercent,
    required this.isReached,
    required this.daysLeft,
    required this.dailyNeededRate,
  });
}

class GoalProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  List<GoalModel> _goals = [];
  bool _isLoading = true;

  List<GoalModel> get goals => _goals;
  bool get isLoading => _isLoading;
  double get totalManualSavedAmount => _goals.fold(0.0, (sum, g) => sum + g.manualSavedAmount);

  GoalProvider() {
    loadGoals();
  }

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();

    try {
      _goals = await _dbHelper.getGoals();
    } catch (e) {
      if (kDebugMode) print('loadGoals error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  GoalProgressInfo calculateGoalProgress(GoalModel goal, PortfolioProvider portfolio) {
    // 1. Calculate assigned assets value
    final assignedAssetsValue = portfolio.getTotalValueForGoal(goal.id);
    
    // 2. If there are no specifically linked assets, we combine manualSavedAmount
    // or if goal has linked assets, we sum them
    double totalSaved = goal.manualSavedAmount + assignedAssetsValue;

    // If no assets are explicitly linked to this goal and manualSavedAmount is 0,
    // let's proportionally reflect total portfolio if it's the primary goal
    if (assignedAssetsValue == 0 && goal.manualSavedAmount == 0 && _goals.isNotEmpty && _goals.first.id == goal.id) {
      totalSaved = portfolio.totalPortfolioValue;
    }

    final target = goal.targetAmount > 0 ? goal.targetAmount : 1.0;
    final remaining = (target - totalSaved) > 0 ? (target - totalSaved) : 0.0;
    final progress = (totalSaved / target).clamp(0.0, 1.0);
    final days = goal.remainingDays;
    final dailyNeeded = (days > 0 && remaining > 0) ? (remaining / days) : 0.0;

    return GoalProgressInfo(
      goal: goal,
      currentAmount: totalSaved,
      targetAmount: target,
      remainingAmount: remaining,
      progressPercent: progress * 100,
      isReached: totalSaved >= target || goal.isCompleted,
      daysLeft: days,
      dailyNeededRate: dailyNeeded,
    );
  }

  // --- CRUD Operations ---
  Future<void> addGoal({
    required String title,
    String description = '',
    required double targetAmount,
    String currency = 'TRY',
    required DateTime targetDate,
    String category = 'Genel',
    String iconKey = 'flag',
    int colorValue = 0xFF38B289,
    double manualSavedAmount = 0.0,
  }) async {
    final newGoal = GoalModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      targetAmount: targetAmount,
      currency: currency,
      targetDate: targetDate,
      createdAt: DateTime.now(),
      category: category,
      iconKey: iconKey,
      colorValue: colorValue,
      manualSavedAmount: manualSavedAmount,
    );

    await _dbHelper.insertGoal(newGoal);
    _goals.insert(0, newGoal);
    notifyListeners();
  }

  Future<void> updateGoal(GoalModel goal) async {
    await _dbHelper.updateGoal(goal);
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index >= 0) {
      _goals[index] = goal;
      notifyListeners();
    }
  }

  Future<void> addDepositToGoal(String goalId, double amount, {String? note}) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index >= 0) {
      final updated = _goals[index].copyWith(
        manualSavedAmount: _goals[index].manualSavedAmount + amount,
      );
      await _dbHelper.updateGoal(updated);

      final tx = TransactionModel(
        id: _uuid.v4(),
        assetId: 'CASH',
        assetName: 'Nakit Birikim',
        type: TransactionType.deposit,
        amount: 1,
        pricePerUnit: amount,
        totalTRY: amount,
        date: DateTime.now(),
        goalId: goalId,
        note: (note != null && note.trim().isNotEmpty) ? note.trim() : 'Nakit Birikimi',
      );
      await _dbHelper.insertTransaction(tx);

      _goals[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    await _dbHelper.deleteGoal(id);
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  Future<void> toggleGoalCompleted(String id) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index >= 0) {
      final updated = _goals[index].copyWith(
        isCompleted: !_goals[index].isCompleted,
      );
      await _dbHelper.updateGoal(updated);
      _goals[index] = updated;
      notifyListeners();
    }
  }
}
