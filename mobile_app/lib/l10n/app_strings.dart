import 'package:flutter/material.dart';

/// Lightweight EN / MS strings (no codegen).
class AppStrings {
  AppStrings(this.locale);

  final Locale locale;
  bool get isMs => locale.languageCode == 'ms';

  String t(String en, String ms) => isMs ? ms : en;

  String get appTitle => t('SME Advisor', 'Penasihat PKS');
  String get health => t('Health', 'Kesihatan');
  String get simulate => t('Simulate', 'Simulasi');
  String get aiAdvisor => t('AI Advisor', 'Penasihat AI');
  String get grants => t('Grants', 'Geran');
  String get performance => t('Performance', 'Prestasi');
  String get compare => t('Compare', 'Banding');
  String get settings => t('Settings', 'Tetapan');
  String get onboardingTitle => t('Welcome to SME Advisor', 'Selamat datang ke Penasihat PKS');
  String get onboardingBody => t(
        'Upload transactions, simulate purchases, and get AI-powered financing advice for Malaysian SMEs.',
        'Muat naik transaksi, simulasi pembelian, dan dapatkan nasihat pembiayaan berkuasa AI untuk PKS Malaysia.',
      );
  String get includeSst => t('Include SST (6%) estimate', 'Termasuk anggaran SST (6%)');
  String get islamicOnly => t('Islamic financing only', 'Pembiayaan Islam sahaja');
  String get shareReport => t('Share report', 'Kongsi laporan');
  String get exportPdf => t('Export PDF', 'Eksport PDF');
}
