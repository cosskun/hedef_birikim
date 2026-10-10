import 'package:flutter/material.dart';

class AppColors {
  // --- AÇIK PASTEL ANA RENK PALETİ ---
  
  // Ana Vurgu Pastel Renkler
  static const Color pastelMint = Color(0xFF38B289);        // Taze Nane Yeşili (Birikim, Kâr, Başarı)
  static const Color pastelMintSoft = Color(0xFFE6F7F0);    // Yumuşak Nane Arka Plan
  
  static const Color pastelGold = Color(0xFFE5A125);        // Sıcak Pastel Altın
  static const Color pastelGoldSoft = Color(0xFFFEF7E6);    // Yumuşak Altın / Krem Arka Plan
  
  static const Color pastelBlue = Color(0xFF4A90E2);        // Pudra / Gök Mavisi (Döviz)
  static const Color pastelBlueSoft = Color(0xFFEEF5FC);    // Yumuşak Mavi Arka Plan
  
  static const Color pastelPurple = Color(0xFF8E66C7);      // Pastel Lavanta (Kripto)
  static const Color pastelPurpleSoft = Color(0xFFF4EFFB);  // Yumuşak Lavanta Arka Plan
  
  static const Color pastelRose = Color(0xFFE56A8F);        // Pastel Gül / Mercan (Özel Hedefler)
  static const Color pastelRoseSoft = Color(0xFFFDEEF3);    // Yumuşak Gül Arka Plan
  
  static const Color pastelSage = Color(0xFF4E9B85);        // Adaçayı Yeşili (Hisseler)
  static const Color pastelSageSoft = Color(0xFFE8F5F1);    // Yumuşak Adaçayı Arka Plan

  // Geriye Dönük Uyumluluk Alias'ları (Tüm Renkler Pastel Palete Bağlandı)
  static const Color primaryEmerald = pastelMint;
  static const Color primaryDarkEmerald = pastelMint;
  static const Color gold = pastelGold;
  static const Color goldLight = pastelGoldSoft;
  static const Color goldDark = pastelGold;

  // Açık Pastel Arka Plan ve Kart Tonları (Varsayılan)
  static const Color backgroundLight = Color(0xFFF7F9FC);   // Çok yumuşak fildişi / gri-mavi
  static const Color surfaceLight = Color(0xFFFFFFFF);      // Saf Beyaz Kartlar
  static const Color surfaceLightElevated = Color(0xFFEEF2F7);
  static const Color borderLight = Color(0xFFE2E8F0);       // İnce pastel kenarlık

  // Koyu Mod Arka Planları (İsteğe bağlı geçiş için)
  static const Color backgroundDark = Color(0xFF131822);
  static const Color surfaceDark = Color(0xFF1C2433);
  static const Color surfaceDarkElevated = Color(0xFF253043);
  static const Color borderDark = Color(0xFF2C394F);

  // Varlık Kategori Renkleri (Pastel)
  static const Color goldAsset = pastelGold;
  static const Color forexAsset = pastelBlue;
  static const Color cryptoAsset = pastelPurple;
  static const Color stockAsset = pastelMint;
  static const Color fundAsset = Color(0xFF00B4D8);
  static const Color cashAsset = Color(0xFF43A047);

  // Durum & İpuçları
  static const Color profit = Color(0xFF2EAA7B);
  static const Color loss = Color(0xFFE55353);
  static const Color info = Color(0xFF3B82F6);
  static const Color warning = Color(0xFFF59E0B);

  // Metin Renkleri (Gözü yormayan yumuşak koyu antrasit)
  static const Color textPrimaryLight = Color(0xFF1E293B);   // Derin Slate Antrasit
  static const Color textSecondaryLight = Color(0xFF64748B); // Yumuşak Slate Gri
  static const Color textMutedLight = Color(0xFF94A3B8);     // Açık Gri

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Pastel Gradyanlar
  static const LinearGradient pastelMintGradient = LinearGradient(
    colors: [Color(0xFF48BB78), Color(0xFF38B289)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = pastelMintGradient;

  static const LinearGradient pastelHeroGradient = LinearGradient(
    colors: [Color(0xFFEBF7F2), Color(0xFFF4F9FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFEEBC8), Color(0xFFFBD38D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardDarkGradient = LinearGradient(
    colors: [Color(0xFF1E2837), Color(0xFF131D2A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
