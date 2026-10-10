import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/database/database_helper.dart';
import '../models/asset_model.dart';
import '../models/market_rate_model.dart';

class MarketService {
  static final List<MarketRateModel> defaultRates = [
    // ==========================================
    // 1. ALTIN & KIYMETLİ MADENLER
    // ==========================================
    MarketRateModel(
      symbol: 'GA',
      name: 'Gram Altın',
      category: AssetCategory.gold,
      buyPrice: 3380.00,
      sellPrice: 3395.00,
      changeRate24h: 1.25,
      lastUpdated: DateTime.now(),
      unit: 'gr',
    ),
    MarketRateModel(
      symbol: 'CEYREK',
      name: 'Çeyrek Altın',
      category: AssetCategory.gold,
      buyPrice: 5520.00,
      sellPrice: 5580.00,
      changeRate24h: 1.10,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'YARIM',
      name: 'Yarım Altın',
      category: AssetCategory.gold,
      buyPrice: 11040.00,
      sellPrice: 11160.00,
      changeRate24h: 1.10,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'TAM',
      name: 'Tam Altın',
      category: AssetCategory.gold,
      buyPrice: 22050.00,
      sellPrice: 22280.00,
      changeRate24h: 1.15,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'ATA',
      name: 'Ata Altın',
      category: AssetCategory.gold,
      buyPrice: 22650.00,
      sellPrice: 22900.00,
      changeRate24h: 1.20,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'CUMHURIYET',
      name: 'Cumhuriyet Altını',
      category: AssetCategory.gold,
      buyPrice: 22750.00,
      sellPrice: 23050.00,
      changeRate24h: 1.15,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'RESAT',
      name: 'Reşat Altın',
      category: AssetCategory.gold,
      buyPrice: 22700.00,
      sellPrice: 23000.00,
      changeRate24h: 1.10,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'GREMSE',
      name: 'Gremse Altın (2.5)',
      category: AssetCategory.gold,
      buyPrice: 55100.00,
      sellPrice: 55900.00,
      changeRate24h: 1.15,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'BILEZIK22',
      name: '22 Ayar Bilezik (gr)',
      category: AssetCategory.gold,
      buyPrice: 3080.00,
      sellPrice: 3120.00,
      changeRate24h: 1.20,
      lastUpdated: DateTime.now(),
      unit: 'gr',
    ),
    MarketRateModel(
      symbol: 'ALTIN18',
      name: '18 Ayar Altın (gr)',
      category: AssetCategory.gold,
      buyPrice: 2470.00,
      sellPrice: 2540.00,
      changeRate24h: 1.05,
      lastUpdated: DateTime.now(),
      unit: 'gr',
    ),
    MarketRateModel(
      symbol: 'ALTIN14',
      name: '14 Ayar Altın (gr)',
      category: AssetCategory.gold,
      buyPrice: 1920.00,
      sellPrice: 1980.00,
      changeRate24h: 0.95,
      lastUpdated: DateTime.now(),
      unit: 'gr',
    ),
    MarketRateModel(
      symbol: 'ONS',
      name: 'Ons Altın (\$)',
      category: AssetCategory.gold,
      buyPrice: 2715.00,
      sellPrice: 2720.00,
      changeRate24h: 0.80,
      lastUpdated: DateTime.now(),
      unit: '\$',
    ),
    MarketRateModel(
      symbol: 'GUMUS',
      name: 'Gümüş (Gram)',
      category: AssetCategory.gold,
      buyPrice: 41.50,
      sellPrice: 42.80,
      changeRate24h: 0.85,
      lastUpdated: DateTime.now(),
      unit: 'gr',
    ),
    MarketRateModel(
      symbol: 'PLATIN',
      name: 'Platin (Gram)',
      category: AssetCategory.gold,
      buyPrice: 1150.00,
      sellPrice: 1180.00,
      changeRate24h: 0.40,
      lastUpdated: DateTime.now(),
      unit: 'gr',
    ),
    MarketRateModel(
      symbol: 'PALADYUM',
      name: 'Paladyum (Gram)',
      category: AssetCategory.gold,
      buyPrice: 1220.00,
      sellPrice: 1260.00,
      changeRate24h: -0.30,
      lastUpdated: DateTime.now(),
      unit: 'gr',
    ),

    // ==========================================
    // 2. DÖVİZ KURLARI (TRY Cinsinden)
    // ==========================================
    MarketRateModel(
      symbol: 'USD',
      name: 'Amerikan Doları',
      category: AssetCategory.forex,
      buyPrice: 36.45,
      sellPrice: 36.55,
      changeRate24h: 0.15,
      lastUpdated: DateTime.now(),
      unit: '\$',
    ),
    MarketRateModel(
      symbol: 'EUR',
      name: 'Euro',
      category: AssetCategory.forex,
      buyPrice: 39.75,
      sellPrice: 39.88,
      changeRate24h: 0.35,
      lastUpdated: DateTime.now(),
      unit: '€',
    ),
    MarketRateModel(
      symbol: 'GBP',
      name: 'İngiliz Sterlini',
      category: AssetCategory.forex,
      buyPrice: 47.30,
      sellPrice: 47.50,
      changeRate24h: 0.25,
      lastUpdated: DateTime.now(),
      unit: '£',
    ),
    MarketRateModel(
      symbol: 'CHF',
      name: 'İsviçre Frangı',
      category: AssetCategory.forex,
      buyPrice: 41.20,
      sellPrice: 41.40,
      changeRate24h: -0.10,
      lastUpdated: DateTime.now(),
      unit: 'CHF',
    ),
    MarketRateModel(
      symbol: 'CAD',
      name: 'Kanada Doları',
      category: AssetCategory.forex,
      buyPrice: 25.80,
      sellPrice: 25.95,
      changeRate24h: 0.20,
      lastUpdated: DateTime.now(),
      unit: 'C\$',
    ),
    MarketRateModel(
      symbol: 'AUD',
      name: 'Avustralya Doları',
      category: AssetCategory.forex,
      buyPrice: 23.40,
      sellPrice: 23.55,
      changeRate24h: 0.10,
      lastUpdated: DateTime.now(),
      unit: 'A\$',
    ),
    MarketRateModel(
      symbol: 'JPY',
      name: '100 Japon Yeni',
      category: AssetCategory.forex,
      buyPrice: 23.85,
      sellPrice: 24.05,
      changeRate24h: -0.15,
      lastUpdated: DateTime.now(),
      unit: '¥',
    ),
    MarketRateModel(
      symbol: 'SAR',
      name: 'Suudi Arabistan Riyali',
      category: AssetCategory.forex,
      buyPrice: 9.70,
      sellPrice: 9.78,
      changeRate24h: 0.05,
      lastUpdated: DateTime.now(),
      unit: 'SAR',
    ),
    MarketRateModel(
      symbol: 'AED',
      name: 'BAE Dirhemi',
      category: AssetCategory.forex,
      buyPrice: 9.90,
      sellPrice: 9.98,
      changeRate24h: 0.08,
      lastUpdated: DateTime.now(),
      unit: 'AED',
    ),
    MarketRateModel(
      symbol: 'QAR',
      name: 'Katar Riyali',
      category: AssetCategory.forex,
      buyPrice: 9.95,
      sellPrice: 10.05,
      changeRate24h: 0.05,
      lastUpdated: DateTime.now(),
      unit: 'QAR',
    ),
    MarketRateModel(
      symbol: 'KWD',
      name: 'Kuveyt Dinarı',
      category: AssetCategory.forex,
      buyPrice: 118.20,
      sellPrice: 119.10,
      changeRate24h: 0.12,
      lastUpdated: DateTime.now(),
      unit: 'KWD',
    ),
    MarketRateModel(
      symbol: 'NOK',
      name: 'Norveç Kronu',
      category: AssetCategory.forex,
      buyPrice: 3.35,
      sellPrice: 3.42,
      changeRate24h: -0.20,
      lastUpdated: DateTime.now(),
      unit: 'NOK',
    ),
    MarketRateModel(
      symbol: 'SEK',
      name: 'İsveç Kronu',
      category: AssetCategory.forex,
      buyPrice: 3.45,
      sellPrice: 3.52,
      changeRate24h: -0.15,
      lastUpdated: DateTime.now(),
      unit: 'SEK',
    ),
    MarketRateModel(
      symbol: 'DKK',
      name: 'Danimarka Kronu',
      category: AssetCategory.forex,
      buyPrice: 5.30,
      sellPrice: 5.38,
      changeRate24h: 0.20,
      lastUpdated: DateTime.now(),
      unit: 'DKK',
    ),
    MarketRateModel(
      symbol: 'RUB',
      name: 'Rus Rublesi',
      category: AssetCategory.forex,
      buyPrice: 0.38,
      sellPrice: 0.40,
      changeRate24h: 0.45,
      lastUpdated: DateTime.now(),
      unit: 'RUB',
    ),
    MarketRateModel(
      symbol: 'CNY',
      name: 'Çin Yuanı',
      category: AssetCategory.forex,
      buyPrice: 5.02,
      sellPrice: 5.10,
      changeRate24h: 0.10,
      lastUpdated: DateTime.now(),
      unit: '¥',
    ),
    MarketRateModel(
      symbol: 'AZN',
      name: 'Azerbaycan Manatı',
      category: AssetCategory.forex,
      buyPrice: 21.35,
      sellPrice: 21.55,
      changeRate24h: 0.05,
      lastUpdated: DateTime.now(),
      unit: '₼',
    ),

    // ==========================================
    // 3. KRİPTO PARALAR (TRY Cinsinden)
    // ==========================================
    MarketRateModel(
      symbol: 'BTC',
      name: 'Bitcoin',
      category: AssetCategory.crypto,
      buyPrice: 3350000.00,
      sellPrice: 3360000.00,
      changeRate24h: 2.80,
      lastUpdated: DateTime.now(),
      unit: 'BTC',
    ),
    MarketRateModel(
      symbol: 'ETH',
      name: 'Ethereum',
      category: AssetCategory.crypto,
      buyPrice: 102500.00,
      sellPrice: 103200.00,
      changeRate24h: -1.20,
      lastUpdated: DateTime.now(),
      unit: 'ETH',
    ),
    MarketRateModel(
      symbol: 'SOL',
      name: 'Solana',
      category: AssetCategory.crypto,
      buyPrice: 6950.00,
      sellPrice: 7050.00,
      changeRate24h: 4.50,
      lastUpdated: DateTime.now(),
      unit: 'SOL',
    ),
    MarketRateModel(
      symbol: 'USDT',
      name: 'Tether (USDT)',
      category: AssetCategory.crypto,
      buyPrice: 36.50,
      sellPrice: 36.60,
      changeRate24h: 0.05,
      lastUpdated: DateTime.now(),
      unit: 'USDT',
    ),
    MarketRateModel(
      symbol: 'BNB',
      name: 'Binance Coin (BNB)',
      category: AssetCategory.crypto,
      buyPrice: 24500.00,
      sellPrice: 24700.00,
      changeRate24h: 1.80,
      lastUpdated: DateTime.now(),
      unit: 'BNB',
    ),
    MarketRateModel(
      symbol: 'XRP',
      name: 'Ripple (XRP)',
      category: AssetCategory.crypto,
      buyPrice: 92.50,
      sellPrice: 93.80,
      changeRate24h: 5.20,
      lastUpdated: DateTime.now(),
      unit: 'XRP',
    ),
    MarketRateModel(
      symbol: 'AVAX',
      name: 'Avalanche (AVAX)',
      category: AssetCategory.crypto,
      buyPrice: 1080.00,
      sellPrice: 1100.00,
      changeRate24h: 3.10,
      lastUpdated: DateTime.now(),
      unit: 'AVAX',
    ),
    MarketRateModel(
      symbol: 'ADA',
      name: 'Cardano (ADA)',
      category: AssetCategory.crypto,
      buyPrice: 29.50,
      sellPrice: 30.20,
      changeRate24h: 2.15,
      lastUpdated: DateTime.now(),
      unit: 'ADA',
    ),
    MarketRateModel(
      symbol: 'DOGE',
      name: 'Dogecoin (DOGE)',
      category: AssetCategory.crypto,
      buyPrice: 9.80,
      sellPrice: 10.10,
      changeRate24h: 6.40,
      lastUpdated: DateTime.now(),
      unit: 'DOGE',
    ),
    MarketRateModel(
      symbol: 'DOT',
      name: 'Polkadot (DOT)',
      category: AssetCategory.crypto,
      buyPrice: 275.00,
      sellPrice: 280.00,
      changeRate24h: -0.50,
      lastUpdated: DateTime.now(),
      unit: 'DOT',
    ),
    MarketRateModel(
      symbol: 'LINK',
      name: 'Chainlink (LINK)',
      category: AssetCategory.crypto,
      buyPrice: 650.00,
      sellPrice: 665.00,
      changeRate24h: 1.90,
      lastUpdated: DateTime.now(),
      unit: 'LINK',
    ),
    MarketRateModel(
      symbol: 'NEAR',
      name: 'NEAR Protocol',
      category: AssetCategory.crypto,
      buyPrice: 215.00,
      sellPrice: 220.00,
      changeRate24h: 3.40,
      lastUpdated: DateTime.now(),
      unit: 'NEAR',
    ),
    MarketRateModel(
      symbol: 'TON',
      name: 'Toncoin (TON)',
      category: AssetCategory.crypto,
      buyPrice: 185.00,
      sellPrice: 190.00,
      changeRate24h: 0.80,
      lastUpdated: DateTime.now(),
      unit: 'TON',
    ),
    MarketRateModel(
      symbol: 'TRX',
      name: 'TRON (TRX)',
      category: AssetCategory.crypto,
      buyPrice: 8.60,
      sellPrice: 8.75,
      changeRate24h: 0.40,
      lastUpdated: DateTime.now(),
      unit: 'TRX',
    ),
    MarketRateModel(
      symbol: 'SUI',
      name: 'Sui Network (SUI)',
      category: AssetCategory.crypto,
      buyPrice: 110.00,
      sellPrice: 113.00,
      changeRate24h: 7.20,
      lastUpdated: DateTime.now(),
      unit: 'SUI',
    ),
    MarketRateModel(
      symbol: 'SHIB',
      name: 'Shiba Inu (SHIB)',
      category: AssetCategory.crypto,
      buyPrice: 0.00078,
      sellPrice: 0.00080,
      changeRate24h: 4.10,
      lastUpdated: DateTime.now(),
      unit: 'SHIB',
    ),
    MarketRateModel(
      symbol: 'PEPE',
      name: 'Pepe (PEPE)',
      category: AssetCategory.crypto,
      buyPrice: 0.00042,
      sellPrice: 0.00044,
      changeRate24h: 8.50,
      lastUpdated: DateTime.now(),
      unit: 'PEPE',
    ),
    MarketRateModel(
      symbol: 'RENDER',
      name: 'Render (RENDER)',
      category: AssetCategory.crypto,
      buyPrice: 260.00,
      sellPrice: 268.00,
      changeRate24h: 4.80,
      lastUpdated: DateTime.now(),
      unit: 'RENDER',
    ),
    MarketRateModel(
      symbol: 'FET',
      name: 'Artificial Superintelligence (FET)',
      category: AssetCategory.crypto,
      buyPrice: 52.00,
      sellPrice: 54.00,
      changeRate24h: 3.60,
      lastUpdated: DateTime.now(),
      unit: 'FET',
    ),

    // ==========================================
    // 4. HİSSE SENETLERİ (BIST & ABD)
    // ==========================================
    // --- BIST HİSSELERİ ---
    MarketRateModel(
      symbol: 'THYAO',
      name: 'Türk Hava Yolları',
      category: AssetCategory.stock,
      buyPrice: 312.00,
      sellPrice: 312.50,
      changeRate24h: 1.80,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'ASELS',
      name: 'Aselsan',
      category: AssetCategory.stock,
      buyPrice: 64.50,
      sellPrice: 65.00,
      changeRate24h: 0.90,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'EREGL',
      name: 'Ereğli Demir Çelik',
      category: AssetCategory.stock,
      buyPrice: 52.20,
      sellPrice: 52.60,
      changeRate24h: -0.40,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'TUPRS',
      name: 'Tüpraş Türkiye Petrol',
      category: AssetCategory.stock,
      buyPrice: 154.00,
      sellPrice: 154.80,
      changeRate24h: 1.10,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'KCHOL',
      name: 'Koç Holding',
      category: AssetCategory.stock,
      buyPrice: 202.00,
      sellPrice: 203.20,
      changeRate24h: 1.45,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'SAHOL',
      name: 'Sabancı Holding',
      category: AssetCategory.stock,
      buyPrice: 94.80,
      sellPrice: 95.40,
      changeRate24h: 0.75,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'SISE',
      name: 'Şişecam',
      category: AssetCategory.stock,
      buyPrice: 46.50,
      sellPrice: 46.90,
      changeRate24h: -0.20,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'BIMAS',
      name: 'BİM Birleşik Mağazalar',
      category: AssetCategory.stock,
      buyPrice: 512.00,
      sellPrice: 515.00,
      changeRate24h: 2.10,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'AKBNK',
      name: 'Akbank',
      category: AssetCategory.stock,
      buyPrice: 58.40,
      sellPrice: 58.90,
      changeRate24h: 1.60,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'GARAN',
      name: 'Garanti BBVA',
      category: AssetCategory.stock,
      buyPrice: 118.50,
      sellPrice: 119.20,
      changeRate24h: 1.95,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'ISCTR',
      name: 'İş Bankası (C)',
      category: AssetCategory.stock,
      buyPrice: 14.10,
      sellPrice: 14.25,
      changeRate24h: 0.85,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'YKBNK',
      name: 'Yapı Kredi Bankası',
      category: AssetCategory.stock,
      buyPrice: 32.20,
      sellPrice: 32.50,
      changeRate24h: 1.20,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'FROTO',
      name: 'Ford Otosan',
      category: AssetCategory.stock,
      buyPrice: 1040.00,
      sellPrice: 1048.00,
      changeRate24h: 0.60,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'TOASO',
      name: 'Tofaş Oto Fabrika',
      category: AssetCategory.stock,
      buyPrice: 228.00,
      sellPrice: 230.00,
      changeRate24h: -0.90,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'PGSUS',
      name: 'Pegasus Hava Taşımacılığı',
      category: AssetCategory.stock,
      buyPrice: 236.00,
      sellPrice: 238.00,
      changeRate24h: 2.30,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'ENKAI',
      name: 'Enka İnşaat',
      category: AssetCategory.stock,
      buyPrice: 48.10,
      sellPrice: 48.50,
      changeRate24h: 0.50,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'MGROS',
      name: 'Migros Ticaret',
      category: AssetCategory.stock,
      buyPrice: 490.00,
      sellPrice: 494.00,
      changeRate24h: 1.30,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'PETKM',
      name: 'Petkim Petrokimya',
      category: AssetCategory.stock,
      buyPrice: 20.10,
      sellPrice: 20.30,
      changeRate24h: -0.30,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'ASTOR',
      name: 'Astor Enerji',
      category: AssetCategory.stock,
      buyPrice: 92.30,
      sellPrice: 93.10,
      changeRate24h: 3.40,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'KONTR',
      name: 'Kontrolmatik Teknoloji',
      category: AssetCategory.stock,
      buyPrice: 47.80,
      sellPrice: 48.40,
      changeRate24h: 2.80,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'REEDR',
      name: 'Reeder Teknoloji',
      category: AssetCategory.stock,
      buyPrice: 29.40,
      sellPrice: 29.80,
      changeRate24h: -1.10,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'EKGYO',
      name: 'Emlak Konut GMYO',
      category: AssetCategory.stock,
      buyPrice: 11.20,
      sellPrice: 11.35,
      changeRate24h: 0.60,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),

    // --- ABD / YABANCI HİSSELER ---
    MarketRateModel(
      symbol: 'AAPL',
      name: 'Apple Inc.',
      category: AssetCategory.stock,
      buyPrice: 8400.00,
      sellPrice: 8450.00,
      changeRate24h: 1.40,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'NVDA',
      name: 'NVIDIA Corp.',
      category: AssetCategory.stock,
      buyPrice: 4950.00,
      sellPrice: 5000.00,
      changeRate24h: 3.20,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'MSFT',
      name: 'Microsoft Corp.',
      category: AssetCategory.stock,
      buyPrice: 15300.00,
      sellPrice: 15400.00,
      changeRate24h: 0.90,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'AMZN',
      name: 'Amazon.com Inc.',
      category: AssetCategory.stock,
      buyPrice: 7600.00,
      sellPrice: 7680.00,
      changeRate24h: 1.70,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'GOOGL',
      name: 'Alphabet (Google)',
      category: AssetCategory.stock,
      buyPrice: 6500.00,
      sellPrice: 6560.00,
      changeRate24h: 0.80,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'TSLA',
      name: 'Tesla Inc.',
      category: AssetCategory.stock,
      buyPrice: 9100.00,
      sellPrice: 9220.00,
      changeRate24h: 4.10,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),
    MarketRateModel(
      symbol: 'META',
      name: 'Meta Platforms (Facebook)',
      category: AssetCategory.stock,
      buyPrice: 21800.00,
      sellPrice: 22000.00,
      changeRate24h: 2.20,
      lastUpdated: DateTime.now(),
      unit: 'lot',
    ),

    // ==========================================
    // 5. YATIRIM FONLARI (TEFAS / Katılım / BES / Emtia)
    // ==========================================
    MarketRateModel(
      symbol: 'TTE',
      name: 'İş Portföy BIST Teknoloji Ağırlıklı Hisse Fonu',
      category: AssetCategory.fund,
      buyPrice: 18.45,
      sellPrice: 18.45,
      changeRate24h: 2.30,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'AFT',
      name: 'Ak Portföy Yeni Teknolojiler Yabancı Hisse Fonu',
      category: AssetCategory.fund,
      buyPrice: 0.385,
      sellPrice: 0.385,
      changeRate24h: 1.65,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'YAY',
      name: 'Yapı Kredi Yabancı Teknoloji BYF Fon Sepeti',
      category: AssetCategory.fund,
      buyPrice: 0.420,
      sellPrice: 0.420,
      changeRate24h: 1.80,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'MAC',
      name: 'Marmara Capital Portföy Hisse Senedi Fonu',
      category: AssetCategory.fund,
      buyPrice: 1.280,
      sellPrice: 1.280,
      changeRate24h: 1.15,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'TI3',
      name: 'İş Portföy İş\'te Kadın Hisse Senedi Fonu',
      category: AssetCategory.fund,
      buyPrice: 0.145,
      sellPrice: 0.145,
      changeRate24h: 0.95,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'IIH',
      name: 'İstanbul Portföy Üçüncü Hisse Senedi Fonu',
      category: AssetCategory.fund,
      buyPrice: 0.625,
      sellPrice: 0.625,
      changeRate24h: 1.40,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'NNF',
      name: 'Hedef Portföy Birinci Hisse Senedi Fonu',
      category: AssetCategory.fund,
      buyPrice: 5.40,
      sellPrice: 5.40,
      changeRate24h: 1.20,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'GMR',
      name: 'Inveo Portföy İkinci Hisse Senedi Fonu',
      category: AssetCategory.fund,
      buyPrice: 0.890,
      sellPrice: 0.890,
      changeRate24h: 0.85,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'KZL',
      name: 'Kuveyt Türk Altın Katılım Fonu',
      category: AssetCategory.fund,
      buyPrice: 3.48,
      sellPrice: 3.48,
      changeRate24h: 1.10,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'TGE',
      name: 'İş Portföy Emtia Yabancı BYF Fon Sepeti',
      category: AssetCategory.fund,
      buyPrice: 0.082,
      sellPrice: 0.082,
      changeRate24h: 0.60,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'PPZ',
      name: 'Azimut Portföy Para Piyasası Fonu',
      category: AssetCategory.fund,
      buyPrice: 4.85,
      sellPrice: 4.85,
      changeRate24h: 0.13,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'KUT',
      name: 'Kuveyt Türk Para Piyasası Katılım Fonu',
      category: AssetCategory.fund,
      buyPrice: 1.92,
      sellPrice: 1.92,
      changeRate24h: 0.12,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'OJT',
      name: 'QNB Finansportföy Teknoloji BYF Fon Sepeti',
      category: AssetCategory.fund,
      buyPrice: 0.095,
      sellPrice: 0.095,
      changeRate24h: 1.55,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'TAU',
      name: 'İş Portföy BIST Banka Endeksi Hisse Fonu',
      category: AssetCategory.fund,
      buyPrice: 8.90,
      sellPrice: 8.90,
      changeRate24h: 1.70,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'BUY',
      name: 'Bosphorus Capital Para Piyasası Fonu',
      category: AssetCategory.fund,
      buyPrice: 2.15,
      sellPrice: 2.15,
      changeRate24h: 0.13,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'ZGOLD',
      name: 'Ziraat Portföy Altın Katılım Fonu',
      category: AssetCategory.fund,
      buyPrice: 4.10,
      sellPrice: 4.10,
      changeRate24h: 1.15,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),
    MarketRateModel(
      symbol: 'IHK',
      name: 'İstanbul Portföy Birinci Hisse Senedi Fonu',
      category: AssetCategory.fund,
      buyPrice: 0.450,
      sellPrice: 0.450,
      changeRate24h: 1.05,
      lastUpdated: DateTime.now(),
      unit: 'adet',
    ),

  ];

  /// Initialize market rates in DB if empty, and merge new instruments seamlessly
  static Future<List<MarketRateModel>> getOrInitRates() async {
    final dbHelper = DatabaseHelper.instance;
    var rates = await dbHelper.getMarketRates();
    // Exclude any legacy cash/TRY entries from market rates
    rates = rates.where((r) => r.category != AssetCategory.cash && r.symbol != 'TRY').toList();
    if (rates.isEmpty) {
      await dbHelper.saveMarketRates(defaultRates);
      return defaultRates;
    }

    // Merge any new default rates that don't exist yet in saved rates
    final merged = List<MarketRateModel>.from(rates);
    for (final def in defaultRates) {
      if (!merged.any((r) => r.symbol == def.symbol)) {
        merged.add(def);
      }
    }
    await dbHelper.saveMarketRates(merged);
    return merged;
  }

  static double _parseVal(dynamic val, [double fallback = 0.0]) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    if (val is String) {
      final clean = val.replaceAll(' ', '').replaceAll('%', '').trim();
      if (clean.contains(',') && clean.contains('.')) {
        return double.tryParse(clean.replaceAll('.', '').replaceAll(',', '.')) ?? fallback;
      } else if (clean.contains(',')) {
        return double.tryParse(clean.replaceAll(',', '.')) ?? fallback;
      }
      return double.tryParse(clean) ?? fallback;
    }
    return fallback;
  }

  /// Live rate refresh via public free Turkish Financial API & Binance Crypto API
  static Future<List<MarketRateModel>> fetchLiveRates() async {
    final dbHelper = DatabaseHelper.instance;
    var currentRates = await getOrInitRates();

    try {
      double usdRate = 36.5;

      // 1. Fetch Real-time Turkish Gold & Forex Data from Truncgil
      try {
        final response = await http
            .get(Uri.parse('https://finans.truncgil.com/v4/today.json'))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

          // Map live rates
          currentRates = currentRates.map((r) {
            switch (r.symbol) {
              // --- ALTIN & KIYMETLİ MADENLER ---
              case 'GA':
                if (data.containsKey('GRA')) {
                  final item = data['GRA'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'CEYREK':
                if (data.containsKey('CEYREKALTIN')) {
                  final item = data['CEYREKALTIN'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'YARIM':
                if (data.containsKey('YARIMALTIN')) {
                  final item = data['YARIMALTIN'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'TAM':
                if (data.containsKey('TAMALTIN')) {
                  final item = data['TAMALTIN'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'ATA':
                if (data.containsKey('ATAALTIN')) {
                  final item = data['ATAALTIN'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'CUMHURIYET':
                if (data.containsKey('CUMHURIYETALTINI')) {
                  final item = data['CUMHURIYETALTINI'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'RESAT':
                if (data.containsKey('RESATALTIN')) {
                  final item = data['RESATALTIN'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'GREMSE':
                if (data.containsKey('GREMSEALTIN')) {
                  final item = data['GREMSEALTIN'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'BILEZIK22':
                if (data.containsKey('YIA')) {
                  final item = data['YIA'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'ALTIN14':
                if (data.containsKey('14-ayar-altin')) {
                  final item = data['14-ayar-altin'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'ALTIN18':
                if (data.containsKey('18-ayar-altin')) {
                  final item = data['18-ayar-altin'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'ONS':
                if (data.containsKey('ONS')) {
                  final item = data['ONS'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'GUMUS':
                if (data.containsKey('GUMUS')) {
                  final item = data['GUMUS'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'PLATIN':
                if (data.containsKey('PLATIN')) {
                  final item = data['PLATIN'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              // --- DÖVİZ KURLARI ---
              case 'USD':
                if (data.containsKey('USD')) {
                  final item = data['USD'];
                  final buy = _parseVal(item['Buying'], r.buyPrice);
                  final sell = _parseVal(item['Selling'], r.sellPrice);
                  final change = _parseVal(item['Change'], r.changeRate24h);
                  usdRate = buy > 0 ? buy : usdRate;
                  return r.copyWith(buyPrice: buy, sellPrice: sell, changeRate24h: change, lastUpdated: DateTime.now());
                }
                break;

              case 'EUR':
                if (data.containsKey('EUR')) {
                  final item = data['EUR'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'GBP':
                if (data.containsKey('GBP')) {
                  final item = data['GBP'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'CHF':
                if (data.containsKey('CHF')) {
                  final item = data['CHF'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'CAD':
                if (data.containsKey('CAD')) {
                  final item = data['CAD'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'AUD':
                if (data.containsKey('AUD')) {
                  final item = data['AUD'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'JPY':
                if (data.containsKey('JPY')) {
                  final item = data['JPY'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'SAR':
                if (data.containsKey('SAR')) {
                  final item = data['SAR'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'AED':
                if (data.containsKey('AED')) {
                  final item = data['AED'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'QAR':
                if (data.containsKey('QAR')) {
                  final item = data['QAR'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'KWD':
                if (data.containsKey('KWD')) {
                  final item = data['KWD'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'NOK':
                if (data.containsKey('NOK')) {
                  final item = data['NOK'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'SEK':
                if (data.containsKey('SEK')) {
                  final item = data['SEK'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'DKK':
                if (data.containsKey('DKK')) {
                  final item = data['DKK'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'RUB':
                if (data.containsKey('RUB')) {
                  final item = data['RUB'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'CNY':
                if (data.containsKey('CNY')) {
                  final item = data['CNY'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'AZN':
                if (data.containsKey('AZN')) {
                  final item = data['AZN'];
                  return r.copyWith(
                    buyPrice: _parseVal(item['Buying'], r.buyPrice),
                    sellPrice: _parseVal(item['Selling'], r.sellPrice),
                    changeRate24h: _parseVal(item['Change'], r.changeRate24h),
                    lastUpdated: DateTime.now(),
                  );
                }
                break;

              case 'USDT':
                return r.copyWith(buyPrice: usdRate, sellPrice: usdRate + 0.05, lastUpdated: DateTime.now());
            }
            return r;
          }).toList();
        }
      } catch (e) {
        if (kDebugMode) print('Truncgil fetch error: $e');
      }

      // 2. Fetch Live Crypto Rates (Binance Public API)
      try {
        final cryptoSymbols = [
          'BTCUSDT', 'ETHUSDT', 'SOLUSDT', 'BNBUSDT', 'XRPUSDT',
          'AVAXUSDT', 'ADAUSDT', 'DOGEUSDT', 'DOTUSDT', 'LINKUSDT',
          'NEARUSDT', 'TONUSDT', 'TRXUSDT', 'SUIUSDT', 'SHIBUSDT',
          'PEPEUSDT', 'RENDERUSDT', 'FETUSDT'
        ];
        final urlSymbols = Uri.encodeComponent(json.encode(cryptoSymbols));
        final cryptoRes = await http
            .get(Uri.parse('https://api.binance.com/api/v3/ticker/price?symbols=$urlSymbols'))
            .timeout(const Duration(seconds: 4));

        if (cryptoRes.statusCode == 200) {
          final cryptoData = json.decode(cryptoRes.body) as List<dynamic>;
          for (final c in cryptoData) {
            final sym = c['symbol'] as String;
            final priceUsd = double.tryParse(c['price'] as String) ?? 0.0;
            final priceTry = priceUsd * usdRate;

            if (priceTry > 0) {
              final targetSym = sym.replaceAll('USDT', '');
              final idx = currentRates.indexWhere((r) => r.symbol == targetSym);
              if (idx >= 0) {
                currentRates[idx] = currentRates[idx].copyWith(
                  buyPrice: priceTry,
                  sellPrice: priceTry * 1.002,
                  lastUpdated: DateTime.now(),
                );
              }
            }
          }
        }
      } catch (e) {
        if (kDebugMode) print('Binance fetch error: $e');
      }

      await dbHelper.saveMarketRates(currentRates);
      return currentRates;
    } catch (e) {
      if (kDebugMode) {
        print('Live market fetch error: $e');
      }
    }

    return currentRates;
  }
}
