import 'package:flutter_test/flutter_test.dart';
import 'package:hedef_birikim/models/asset_model.dart';
import 'package:hedef_birikim/models/goal_model.dart';
import 'package:hedef_birikim/core/utils/currency_formatter.dart';

void main() {
  group('Asset Model Calculations', () {
    test('Gold Asset Profit and Total Value calculation', () {
      final goldAsset = AssetModel(
        id: 'gold-1',
        name: 'Gram Altın',
        symbol: 'GA',
        category: AssetCategory.gold,
        amount: 20.0, // 20 grams
        unit: 'gr',
        buyPrice: 3000.0, // bought at 3,000 TRY
        currentPrice: 3500.0, // now at 3,500 TRY
        updatedAt: DateTime.now(),
      );

      expect(goldAsset.totalCost, 60000.0);
      expect(goldAsset.totalCurrentValue, 70000.0);
      expect(goldAsset.profitLossAmount, 10000.0);
      expect(goldAsset.profitLossPercentage, closeTo(16.666, 0.01));
      expect(goldAsset.isProfitable, true);
    });

    test('Forex USD Asset calculation', () {
      final usdAsset = AssetModel(
        id: 'usd-1',
        name: 'Amerikan Doları',
        symbol: 'USD',
        category: AssetCategory.forex,
        amount: 1000.0,
        unit: '\$',
        buyPrice: 34.0,
        currentPrice: 36.5,
        updatedAt: DateTime.now(),
      );

      expect(usdAsset.totalCost, 34000.0);
      expect(usdAsset.totalCurrentValue, 36500.0);
      expect(usdAsset.profitLossAmount, 2500.0);
      expect(usdAsset.isProfitable, true);
    });
  });

  group('Goal Model Calculations', () {
    test('Goal remaining days and data integrity', () {
      final futureDate = DateTime.now().add(const Duration(days: 60));
      final goal = GoalModel(
        id: 'goal-1',
        title: 'Araba Peşinatı',
        targetAmount: 500000.0,
        targetDate: futureDate,
        createdAt: DateTime.now(),
        manualSavedAmount: 150000.0,
      );

      expect(goal.targetAmount, 500000.0);
      expect(goal.manualSavedAmount, 150000.0);
      expect(goal.remainingDays, inInclusiveRange(59, 61));
      expect(goal.isCompleted, false);
    });
  });

  group('Currency Formatter Tests', () {
    test('Format TRY and USD correctly', () {
      final tryStr = CurrencyFormatter.format(1250.50, currencyCode: 'TRY');
      expect(tryStr, contains('1.250,50'));

      final usdStr = CurrencyFormatter.format(1250.50, currencyCode: 'USD');
      expect(usdStr, contains('1,250.50'));

      final percentStr = CurrencyFormatter.formatPercent(15.42);
      expect(percentStr, '+15.42%');
    });
  });
}
