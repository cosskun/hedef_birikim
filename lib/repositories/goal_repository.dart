import '../core/database/database_helper.dart';
import '../core/errors/app_exception.dart';
import '../core/utils/app_logger.dart';
import '../models/goal_model.dart';

abstract class IGoalRepository {
  Future<List<GoalModel>> getGoals();
  Future<void> saveGoal(GoalModel goal);
  Future<void> updateGoal(GoalModel goal);
  Future<void> deleteGoal(String id);
  Future<void> updateGoalCashAmount(String goalId, double newAmount);
}

class GoalRepository implements IGoalRepository {
  final DatabaseHelper _dbHelper;

  GoalRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<GoalModel>> getGoals() async {
    try {
      return await _dbHelper.getGoals();
    } catch (e, stack) {
      AppLogger.error('Failed to retrieve goals', e, stack, 'GoalRepo');
      throw DatabaseException('Hedefler veritabanından yüklenemedi', originalError: e);
    }
  }

  @override
  Future<void> saveGoal(GoalModel goal) async {
    try {
      await _dbHelper.insertGoal(goal);
    } catch (e, stack) {
      AppLogger.error('Failed to insert goal: ${goal.id}', e, stack, 'GoalRepo');
      throw DatabaseException('Hedef kaydedilemedi', originalError: e);
    }
  }

  @override
  Future<void> updateGoal(GoalModel goal) async {
    try {
      await _dbHelper.updateGoal(goal);
    } catch (e, stack) {
      AppLogger.error('Failed to update goal: ${goal.id}', e, stack, 'GoalRepo');
      throw DatabaseException('Hedef güncellenemedi', originalError: e);
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    try {
      await _dbHelper.deleteGoal(id);
    } catch (e, stack) {
      AppLogger.error('Failed to delete goal: $id', e, stack, 'GoalRepo');
      throw DatabaseException('Hedef silinemedi', originalError: e);
    }
  }

  @override
  Future<void> updateGoalCashAmount(String goalId, double newAmount) async {
    try {
      await _dbHelper.updateGoalManualSavedAmount(goalId, newAmount);
    } catch (e, stack) {
      AppLogger.error('Failed to update goal cash amount: $goalId', e, stack, 'GoalRepo');
      throw DatabaseException('Hedef nakit birikimi güncellenemedi', originalError: e);
    }
  }
}
