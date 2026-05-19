import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _kDark = 'dark_mode';
  static const _kLocale = 'locale';
  static const _kOnboarded = 'onboarded';
  static const _kTextScale = 'text_scale';
  static const _kBiometric = 'biometric';

  ThemeMode themeMode = ThemeMode.light;
  Locale locale = const Locale('en');
  bool onboarded = false;
  double textScale = 1.0;
  bool biometricEnabled = false;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    themeMode = p.getBool(_kDark) == true ? ThemeMode.dark : ThemeMode.light;
    final lang = p.getString(_kLocale) ?? 'en';
    locale = Locale(lang);
    onboarded = p.getBool(_kOnboarded) ?? false;
    textScale = p.getDouble(_kTextScale) ?? 1.0;
    biometricEnabled = p.getBool(_kBiometric) ?? false;
    notifyListeners();
  }

  Future<void> setDark(bool v) async {
    themeMode = v ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kDark, v);
  }

  Future<void> setLocale(String code) async {
    locale = Locale(code);
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kLocale, code);
  }

  Future<void> setOnboarded() async {
    onboarded = true;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kOnboarded, true);
  }

  Future<void> setTextScale(double v) async {
    textScale = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kTextScale, v);
  }

  Future<void> setBiometric(bool v) async {
    biometricEnabled = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kBiometric, v);
  }
}
