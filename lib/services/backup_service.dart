import 'dart:convert';
import 'package:flutter/services.dart';
import '../core/database/database_helper.dart';
import '../models/goal_model.dart';
import '../models/asset_model.dart';
import '../models/transaction_model.dart';
import '../core/utils/currency_formatter.dart';

class BackupService {
  static const String backupPrefix = 'HEDEFBIRIKIM-YEDEK-V1:';

  /// Generates an encoded string containing all user goals, assets, and transactions
  static Future<String> generateBackupString() async {
    final dbHelper = DatabaseHelper.instance;
    final goals = await dbHelper.getGoals();
    final assets = await dbHelper.getAssets();
    final transactions = await dbHelper.getTransactions();

    final data = {
      'version': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'goals': goals.map((g) => g.toMap()).toList(),
      'assets': assets.map((a) => a.toMap()).toList(),
      'transactions': transactions.map((t) => t.toMap()).toList(),
    };

    final jsonStr = json.encode(data);
    final bytes = utf8.encode(jsonStr);
    final base64Str = base64.encode(bytes);

    return '$backupPrefix$base64Str';
  }

  /// Copies backup code to clipboard
  static Future<void> copyBackupToClipboard() async {
    final code = await generateBackupString();
    await Clipboard.setData(ClipboardData(text: code));
  }

  /// Creates an email subject and body template ready to share
  static Future<Map<String, String>> generateEmailContent() async {
    final code = await generateBackupString();
    final dateStr = CurrencyFormatter.formatDate(DateTime.now());
    
    return {
      'subject': 'HedefBirikim Güvenli Veri Yedeğim ($dateStr)',
      'body': '''
Merhaba,

HedefBirikim uygulamasındaki hedefleriniz ve birikim verileriniz aşağıda yer almaktadır. 
Telefonunuzu değiştirdiğinizde veya verilerinizi geri yüklemek istediğinizde aşağıdaki YEDEK KODUNU kopyalayıp uygulamaya yapıştırmanız yeterlidir:

----------------- YEDEK KODUNUZ (DOKUNUP KOPYALAYIN) -----------------
$code
----------------------------------------------------------------------

Tarih: $dateStr
HedefBirikim Uygulaması
''',
    };
  }

  /// Restores data from an encoded backup string
  /// Returns a map with success boolean, message, and restored counts
  static Future<Map<String, dynamic>> restoreFromBackupString(String input) async {
    try {
      var raw = input.trim();
      if (raw.contains(backupPrefix)) {
        raw = raw.substring(raw.indexOf(backupPrefix) + backupPrefix.length).trim();
      }

      final bytes = base64.decode(raw);
      final jsonStr = utf8.decode(bytes);
      final Map<String, dynamic> data = json.decode(jsonStr);

      final dbHelper = DatabaseHelper.instance;

      int restoredGoalsCount = 0;
      int restoredAssetsCount = 0;

      // Restore Goals
      if (data.containsKey('goals') && data['goals'] is List) {
        final List<dynamic> goalsList = data['goals'];
        final goals = goalsList.map((e) => GoalModel.fromMap(e as Map<String, dynamic>)).toList();
        await dbHelper.saveAllGoals(goals);
        restoredGoalsCount = goals.length;
      }

      // Restore Assets
      if (data.containsKey('assets') && data['assets'] is List) {
        final List<dynamic> assetsList = data['assets'];
        final assets = assetsList.map((e) => AssetModel.fromMap(e as Map<String, dynamic>)).toList();
        await dbHelper.saveAllAssets(assets);
        restoredAssetsCount = assets.length;
      }

      // Restore Transactions
      if (data.containsKey('transactions') && data['transactions'] is List) {
        final List<dynamic> txList = data['transactions'];
        final txs = txList.map((e) => TransactionModel.fromMap(e as Map<String, dynamic>)).toList();
        final prefs = await dbHelper.getTransactions();
        for (final tx in txs) {
          await dbHelper.insertTransaction(tx);
        }
      }

      return {
        'success': true,
        'message': '$restoredGoalsCount hedef ve $restoredAssetsCount varlık başarıyla geri yüklendi! 🎉',
        'goalsCount': restoredGoalsCount,
        'assetsCount': restoredAssetsCount,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Geçersiz veya bozuk yedek kodu. Lütfen kodu kontrol edin.',
      };
    }
  }
}
