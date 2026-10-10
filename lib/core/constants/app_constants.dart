/// Centralized Application Constants
class AppConstants {
  // Application Info
  static const String appName = 'Hedef Birikim';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Kişisel Çok Varlıklı Birikim ve Finansal Hedef Takip';

  // API Endpoints
  static const String truncgilFinanceApiUrl = 'https://finans.truncgil.com/v4/today.json';
  static const String binanceTickerPriceApiUrl = 'https://api.binance.com/api/v3/ticker/price';

  // Database & Storage Keys
  static const String databaseName = 'hedef_birikim.db';
  static const int databaseVersion = 1;
  static const String tableAssets = 'assets';
  static const String tableGoals = 'goals';
  static const String tableTransactions = 'transactions';
  static const String prefsMarketRatesKey = 'market_rates_cache';
  static const String prefsThemeModeKey = 'is_dark_mode';
  static const String prefsPrivacyModeKey = 'is_privacy_mode';

  // Default Values
  static const String defaultCurrency = 'TRY';
  static const String defaultCurrencySymbol = '₺';
  static const double defaultUsdFallbackRate = 36.50;

  // Timeouts & Durations
  static const Duration apiTimeout = Duration(seconds: 6);
  static const Duration snackBarDurationShort = Duration(seconds: 2);
  static const Duration snackBarDurationLong = Duration(seconds: 4);
  static const Duration confettiDuration = Duration(seconds: 3);

  // Validation Limits
  static const double maxGoalAmount = 1000000000.0; // 1 Billion TRY
  static const int maxGoalTitleLength = 60;
  static const int maxAssetNoteLength = 200;
}
