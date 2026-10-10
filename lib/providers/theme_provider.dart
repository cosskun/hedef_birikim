import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themePrefKey = 'is_dark_theme';
  static const String _privacyPrefKey = 'is_privacy_mode';
  static const String _salaryDayKey = 'salary_day_preference';
  static const String _salaryReminderEnabledKey = 'salary_reminder_enabled';

  // Varsayilan olarak Açık Pastel Tema (false)
  bool _isDark = false;
  bool _isPrivacyMode = false;
  int _salaryDay = 15; // Varsayılan: Her ayın 15'i
  bool _isSalaryReminderEnabled = true;

  bool get isDark => _isDark;
  bool get isPrivacyMode => _isPrivacyMode;
  int get salaryDay => _salaryDay;
  bool get isSalaryReminderEnabled => _isSalaryReminderEnabled;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDark = prefs.getBool(_themePrefKey) ?? false;
      _isPrivacyMode = prefs.getBool(_privacyPrefKey) ?? false;
      _salaryDay = prefs.getInt(_salaryDayKey) ?? 15;
      _isSalaryReminderEnabled = prefs.getBool(_salaryReminderEnabledKey) ?? true;
      notifyListeners();
    } catch (e) {
      _isDark = false;
      _isPrivacyMode = false;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePrefKey, _isDark);
    } catch (_) {}
  }

  Future<void> togglePrivacyMode() async {
    _isPrivacyMode = !_isPrivacyMode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_privacyPrefKey, _isPrivacyMode);
    } catch (_) {}
  }

  Future<void> setSalaryDay(int day) async {
    _salaryDay = day.clamp(1, 31);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_salaryDayKey, _salaryDay);
    } catch (_) {}
  }

  Future<void> toggleSalaryReminder(bool enabled) async {
    _isSalaryReminderEnabled = enabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_salaryReminderEnabledKey, _isSalaryReminderEnabled);
    } catch (_) {}
  }
}
