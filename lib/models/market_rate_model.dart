import 'asset_model.dart';

class MarketRateModel {
  final String symbol; // GA, CEYREK, YARIM, TAM, ATA, USD, EUR, GBP, BTC, ETH, SOL, THYAO, EREGL, etc.
  final String name;
  final AssetCategory category;
  final double buyPrice;
  final double sellPrice;
  final double changeRate24h; // percentage e.g. +1.45% or -0.8%
  final DateTime lastUpdated;
  final String unit; // gr, adet, lot, etc.

  MarketRateModel({
    required this.symbol,
    required this.name,
    required this.category,
    required this.buyPrice,
    required this.sellPrice,
    this.changeRate24h = 0.0,
    required this.lastUpdated,
    this.unit = 'adet',
  });

  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'name': name,
      'category': category.name,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'changeRate24h': changeRate24h,
      'lastUpdated': lastUpdated.toIso8601String(),
      'unit': unit,
    };
  }

  factory MarketRateModel.fromMap(Map<String, dynamic> map) {
    return MarketRateModel(
      symbol: map['symbol'] as String,
      name: map['name'] as String,
      category: AssetCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => AssetCategory.gold,
      ),
      buyPrice: (map['buyPrice'] as num).toDouble(),
      sellPrice: (map['sellPrice'] as num).toDouble(),
      changeRate24h: (map['changeRate24h'] as num? ?? 0.0).toDouble(),
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
      unit: map['unit'] as String? ?? 'adet',
    );
  }

  MarketRateModel copyWith({
    String? symbol,
    String? name,
    AssetCategory? category,
    double? buyPrice,
    double? sellPrice,
    double? changeRate24h,
    DateTime? lastUpdated,
    String? unit,
  }) {
    return MarketRateModel(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      category: category ?? this.category,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      changeRate24h: changeRate24h ?? this.changeRate24h,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      unit: unit ?? this.unit,
    );
  }
}
