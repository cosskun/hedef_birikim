import 'package:flutter/material.dart';

class GoalModel {
  final String id;
  final String title;
  final String description;
  final double targetAmount;
  final String currency; // 'TRY', 'USD', 'EUR'
  final DateTime targetDate;
  final DateTime createdAt;
  final String category; // 'Araba', 'Ev', 'Teknoloji', 'Tatil', 'Yatırım', 'Diğer'
  final String iconKey; // 'car', 'home', 'tech', 'vacation', 'invest', 'wedding', 'education', 'flag'
  final int colorValue;
  final bool isCompleted;
  final double manualSavedAmount; // Direct cash added specifically to this goal

  GoalModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.targetAmount,
    this.currency = 'TRY',
    required this.targetDate,
    required this.createdAt,
    this.category = 'Genel',
    this.iconKey = 'flag',
    this.colorValue = 0xFF38B289,
    this.isCompleted = false,
    this.manualSavedAmount = 0.0,
  });

  static IconData getIconFromKey(String key) {
    switch (key.toLowerCase()) {
      case 'car':
      case 'araba':
        return Icons.directions_car_rounded;
      case 'home':
      case 'ev':
        return Icons.home_rounded;
      case 'tech':
      case 'teknoloji':
        return Icons.laptop_mac_rounded;
      case 'vacation':
      case 'tatil':
        return Icons.flight_takeoff_rounded;
      case 'invest':
      case 'yatırım':
      case 'yatirim':
        return Icons.show_chart_rounded;
      case 'wedding':
      case 'düğün':
      case 'dugun':
        return Icons.favorite_rounded;
      case 'education':
      case 'eğitim':
      case 'egitim':
        return Icons.school_rounded;
      default:
        return Icons.flag_rounded;
    }
  }

  IconData get iconData => getIconFromKey(iconKey);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'currency': currency,
      'targetDate': targetDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'category': category,
      'iconKey': iconKey,
      'colorValue': colorValue,
      'isCompleted': isCompleted ? 1 : 0,
      'manualSavedAmount': manualSavedAmount,
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      targetAmount: (map['targetAmount'] as num).toDouble(),
      currency: (map['currency'] as String?) ?? 'TRY',
      targetDate: DateTime.parse(map['targetDate'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      category: (map['category'] as String?) ?? 'Genel',
      iconKey: map['iconKey'] as String? ?? map['category']?.toString().toLowerCase() ?? 'flag',
      colorValue: map['colorValue'] as int? ?? 0xFF38B289,
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
      manualSavedAmount: (map['manualSavedAmount'] as num? ?? 0.0).toDouble(),
    );
  }

  GoalModel copyWith({
    String? id,
    String? title,
    String? description,
    double? targetAmount,
    String? currency,
    DateTime? targetDate,
    DateTime? createdAt,
    String? category,
    String? iconKey,
    int? colorValue,
    bool? isCompleted,
    double? manualSavedAmount,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currency: currency ?? this.currency,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      isCompleted: isCompleted ?? this.isCompleted,
      manualSavedAmount: manualSavedAmount ?? this.manualSavedAmount,
    );
  }

  int get remainingDays {
    final now = DateTime.now();
    final difference = targetDate.difference(now).inDays;
    return difference < 0 ? 0 : difference;
  }
}
