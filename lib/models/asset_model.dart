import 'package:flutter/material.dart';

enum AssetCategory {
  gold,
  forex,
  crypto,
  stock,
  fund,
  cash,
}

extension AssetCategoryExtension on AssetCategory {
  String get displayName {
    switch (this) {
      case AssetCategory.gold:
        return 'Altın & Emtia';
      case AssetCategory.forex:
        return 'Döviz';
      case AssetCategory.crypto:
        return 'Kripto Para';
      case AssetCategory.stock:
        return 'Hisse Senedi';
      case AssetCategory.fund:
        return 'Yatırım Fonu (TEFAS)';
      case AssetCategory.cash:
        return 'Nakit & Mevduat';
    }
  }

  String get defaultUnit {
    switch (this) {
      case AssetCategory.gold:
        return 'gr';
      case AssetCategory.forex:
        return 'adet';
      case AssetCategory.crypto:
        return 'adet';
      case AssetCategory.stock:
        return 'lot';
      case AssetCategory.fund:
        return 'adet';
      case AssetCategory.cash:
        return '₺';
    }
  }

  IconData get icon {
    switch (this) {
      case AssetCategory.gold:
        return Icons.monetization_on_rounded;
      case AssetCategory.forex:
        return Icons.currency_exchange_rounded;
      case AssetCategory.crypto:
        return Icons.currency_bitcoin_rounded;
      case AssetCategory.stock:
        return Icons.show_chart_rounded;
      case AssetCategory.fund:
        return Icons.pie_chart_rounded;
      case AssetCategory.cash:
        return Icons.account_balance_wallet_rounded;
    }
  }
}

class AssetModel {
  final String id;
  final String name; // e.g. "Gram Altın", "ABD Doları", "Bitcoin", "THYAO", "Banka Mevduat"
  final String symbol; // e.g. "GA", "USD", "BTC", "THYAO", "TRY"
  final AssetCategory category;
  final double amount; // Gram, Adet, Lot or Cash Amount
  final String unit; // 'gr', 'adet', 'lot', '₺', '$'
  final double buyPrice; // Ortalama Alış Fiyatı (TRY cinsinden)
  final double currentPrice; // Güncel Birim Fiyatı (TRY cinsinden)
  final String? linkedGoalId; // Opsiyonel: Belli bir hedefe tahsis edilmişse
  final DateTime updatedAt;
  final String note;

  AssetModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.category,
    required this.amount,
    required this.unit,
    required this.buyPrice,
    required this.currentPrice,
    this.linkedGoalId,
    required this.updatedAt,
    this.note = '',
  });

  // Toplam Maliyet (₺)
  double get totalCost => amount * buyPrice;

  // Güncel Toplam Değer (₺)
  double get totalCurrentValue => amount * currentPrice;

  // Kâr / Zarar Tutarı (₺)
  double get profitLossAmount => totalCurrentValue - totalCost;

  // Kâr / Zarar Yüzdesi (%)
  double get profitLossPercentage {
    if (totalCost == 0) return 0.0;
    return ((totalCurrentValue - totalCost) / totalCost) * 100;
  }

  bool get isProfitable => profitLossAmount >= 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'category': category.name,
      'amount': amount,
      'unit': unit,
      'buyPrice': buyPrice,
      'currentPrice': currentPrice,
      'linkedGoalId': linkedGoalId,
      'updatedAt': updatedAt.toIso8601String(),
      'note': note,
    };
  }

  factory AssetModel.fromMap(Map<String, dynamic> map) {
    return AssetModel(
      id: map['id'] as String,
      name: map['name'] as String,
      symbol: map['symbol'] as String,
      category: AssetCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => AssetCategory.cash,
      ),
      amount: (map['amount'] as num).toDouble(),
      unit: map['unit'] as String? ?? 'adet',
      buyPrice: (map['buyPrice'] as num).toDouble(),
      currentPrice: (map['currentPrice'] as num).toDouble(),
      linkedGoalId: map['linkedGoalId'] as String?,
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      note: map['note'] as String? ?? '',
    );
  }

  AssetModel copyWith({
    String? id,
    String? name,
    String? symbol,
    AssetCategory? category,
    double? amount,
    String? unit,
    double? buyPrice,
    double? currentPrice,
    String? linkedGoalId,
    DateTime? updatedAt,
    String? note,
  }) {
    return AssetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      buyPrice: buyPrice ?? this.buyPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      linkedGoalId: linkedGoalId ?? this.linkedGoalId,
      updatedAt: updatedAt ?? this.updatedAt,
      note: note ?? this.note,
    );
  }
}
