import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _tryFormatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  static final NumberFormat _usdFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _eurFormatter = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 2,
  );

  static final NumberFormat _compactNumber = NumberFormat.compact(locale: 'tr_TR');
  static final NumberFormat _thousandsFormat = NumberFormat('#,###', 'tr_TR');

  static String format(double amount, {String currencyCode = 'TRY', int? decimals, bool isPrivacy = false}) {
    if (isPrivacy) {
      final symbol = getSymbol(currencyCode);
      return '•••••• $symbol';
    }

    if (decimals != null) {
      final formatter = NumberFormat.currency(
        locale: currencyCode == 'USD' ? 'en_US' : (currencyCode == 'EUR' ? 'de_DE' : 'tr_TR'),
        symbol: getSymbol(currencyCode),
        decimalDigits: decimals,
      );
      return formatter.format(amount);
    }

    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return _usdFormatter.format(amount);
      case 'EUR':
        return _eurFormatter.format(amount);
      case 'TRY':
      default:
        return _tryFormatter.format(amount);
    }
  }

  static String formatThousands(double amount, {bool isPrivacy = false}) {
    if (isPrivacy) return '••••••';
    if (amount == amount.roundToDouble()) {
      return _thousandsFormat.format(amount.toInt());
    }
    return NumberFormat('#,##0.00', 'tr_TR').format(amount);
  }

  /// Safely parse formatted strings like "1.000.000", "1.000.000,50", "1000000" to double
  static double parse(String text) {
    if (text.trim().isEmpty) return 0.0;
    // Replace dots (thousand separators) and replace comma with dot for decimal
    final cleaned = text.replaceAll('₺', '').replaceAll('\$', '').replaceAll('€', '').trim();
    
    if (cleaned.contains(',') && cleaned.contains('.')) {
      // 1.000.000,50 format
      final normalized = cleaned.replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(normalized) ?? 0.0;
    } else if (cleaned.contains(',')) {
      // 1000,50 format
      final normalized = cleaned.replaceAll(',', '.');
      return double.tryParse(normalized) ?? 0.0;
    } else if (cleaned.contains('.')) {
      // Could be thousand dots like 1.000.000 or decimal 1000.5
      // If dot is followed by 3 digits and no more dots (like 1.000), it's likely thousand
      final parts = cleaned.split('.');
      if (parts.length > 2 || (parts.length == 2 && parts[1].length == 3)) {
        return double.tryParse(cleaned.replaceAll('.', '')) ?? 0.0;
      }
      return double.tryParse(cleaned) ?? 0.0;
    }
    return double.tryParse(cleaned) ?? 0.0;
  }

  static String formatQuantity(double quantity, String unit) {
    if (quantity == quantity.roundToDouble()) {
      return '${quantity.toInt()} $unit';
    }
    if (quantity < 0.01) {
      return '${quantity.toStringAsFixed(6)} $unit';
    } else if (quantity < 1) {
      return '${quantity.toStringAsFixed(4)} $unit';
    } else {
      return '${quantity.toStringAsFixed(2)} $unit';
    }
  }

  static String formatPercent(double percent, {bool includeSign = true}) {
    final sign = includeSign && percent > 0 ? '+' : '';
    return '$sign${percent.toStringAsFixed(2)}%';
  }

  static String formatCompact(double amount, {String currencyCode = 'TRY', bool isPrivacy = false}) {
    if (isPrivacy) {
      final symbol = getSymbol(currencyCode);
      return '•••• $symbol';
    }
    final symbol = getSymbol(currencyCode);
    return '$symbol${_compactNumber.format(amount)}';
  }

  static String formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d.$m.$y';
  }

  static String getSymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'TRY':
      default:
        return '₺';
    }
  }
}

/// Real-time Thousand Separator Formatter for TextFormFields (e.g. 1000000 -> 1.000.000)
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Only allow digits and decimal comma
    final rawText = newValue.text;
    
    // Check if user is typing comma for decimals
    String integerPart = rawText;
    String decimalPart = '';
    final hasComma = rawText.contains(',');

    if (hasComma) {
      final split = rawText.split(',');
      integerPart = split[0];
      if (split.length > 1) {
        decimalPart = ',${split[1]}';
      }
    }

    // Clean dots and non-digits from integer part
    final digitsOnly = integerPart.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) {
      return hasComma ? const TextEditingValue(text: '0,', selection: TextSelection.collapsed(offset: 2)) : const TextEditingValue();
    }

    final number = int.tryParse(digitsOnly);
    if (number == null) return oldValue;

    final formattedInteger = NumberFormat('#,###', 'tr_TR').format(number);
    final formattedResult = '$formattedInteger$decimalPart';

    // Calculate cursor position
    return TextEditingValue(
      text: formattedResult,
      selection: TextSelection.collapsed(offset: formattedResult.length),
    );
  }
}
