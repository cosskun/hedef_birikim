enum TransactionType {
  buy,
  sell,
  deposit,
  withdraw,
}

class TransactionModel {
  final String id;
  final String assetId;
  final String assetName;
  final TransactionType type;
  final double amount;
  final double pricePerUnit;
  final double totalTRY;
  final DateTime date;
  final String? goalId;
  final String note;

  TransactionModel({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.type,
    required this.amount,
    required this.pricePerUnit,
    required this.totalTRY,
    required this.date,
    this.goalId,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assetId': assetId,
      'assetName': assetName,
      'type': type.name,
      'amount': amount,
      'pricePerUnit': pricePerUnit,
      'totalTRY': totalTRY,
      'date': date.toIso8601String(),
      'goalId': goalId,
      'note': note,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      assetId: map['assetId'] as String,
      assetName: map['assetName'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.buy,
      ),
      amount: (map['amount'] as num).toDouble(),
      pricePerUnit: (map['pricePerUnit'] as num).toDouble(),
      totalTRY: (map['totalTRY'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      goalId: map['goalId'] as String?,
      note: map['note'] as String? ?? '',
    );
  }
}
