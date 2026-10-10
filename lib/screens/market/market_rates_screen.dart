import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/asset_model.dart';
import '../../models/market_rate_model.dart';
import '../../providers/portfolio_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/stat_badge.dart';
import '../portfolio/add_edit_asset_dialog.dart';

class MarketRatesScreen extends StatefulWidget {
  const MarketRatesScreen({super.key});

  @override
  State<MarketRatesScreen> createState() => _MarketRatesScreenState();
}

class _MarketRatesScreenState extends State<MarketRatesScreen> {
  AssetCategory? _selectedCategory = AssetCategory.gold; // null = Tümü
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final portfolio = context.watch<PortfolioProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final allRates = portfolio.marketRates.where((r) => r.category != AssetCategory.cash && r.symbol != 'TRY').toList();
    final filteredRates = allRates.where((r) {
      if (_selectedCategory != null && r.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName = r.name.toLowerCase().contains(q);
        final matchSymbol = r.symbol.toLowerCase().contains(q);
        final matchCategory = r.category.displayName.toLowerCase().contains(q);
        return matchName || matchSymbol || matchCategory;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Piyasa & Canlı Kurlar'),
        actions: [
          IconButton(
            tooltip: themeProvider.isDark ? 'Açık Mod' : 'Koyu Mod',
            icon: Icon(themeProvider.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            tooltip: 'Kurları Güncelle',
            icon: const Icon(Icons.sync_rounded),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Piyasa kurları güncelleniyor...'), duration: Duration(seconds: 1)),
              );
              await portfolio.refreshMarketRates();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enstrüman veya sembol ara (örn: THYAO, Dolar, BTC, TTE)...',
                hintStyle: TextStyle(fontSize: 13, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                filled: true,
                fillColor: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val.trim());
              },
            ),
          ),

          // Category Selector Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Tümü
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: const Icon(Icons.apps_rounded, size: 16),
                      label: Text('Tümü (${allRates.length})'),
                      selected: _selectedCategory == null,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = null);
                      },
                      selectedColor: AppColors.primaryEmerald.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _selectedCategory == null ? AppColors.primaryEmerald : null,
                        fontWeight: _selectedCategory == null ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  // Categories (Gold, Forex, Crypto, Stock, Fund)
                  ...[
                    AssetCategory.gold,
                    AssetCategory.forex,
                    AssetCategory.crypto,
                    AssetCategory.stock,
                    AssetCategory.fund,
                  ].map((cat) {
                    final isSelected = _selectedCategory == cat;
                    final count = allRates.where((r) => r.category == cat).length;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: Icon(cat.icon, size: 16),
                        label: Text('${cat.displayName} ($count)'),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedCategory = cat);
                        },
                        selectedColor: AppColors.primaryEmerald.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primaryEmerald : null,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Rates List
          Expanded(
            child: filteredRates.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                        const SizedBox(height: 10),
                        Text(
                          _searchQuery.isNotEmpty ? '\"$_searchQuery\" ile eşleşen piyasa verisi bulunamadı.' : 'Bu kategoride kur verisi bulunamadı.',
                          style: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRates.length,
                    itemBuilder: (context, index) {
                      final rate = filteredRates[index];
                      return _buildRateCard(context, rate, portfolio, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateCard(
    BuildContext context,
    MarketRateModel rate,
    PortfolioProvider portfolio,
    bool isDark,
  ) {
    final isUp = rate.changeRate24h >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(rate.category.icon, color: AppColors.gold, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rate.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.primaryEmerald.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              rate.symbol,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryEmerald),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '• ${rate.category.displayName} • Birim: ${rate.unit}',
                            style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                StatBadge(
                  text: CurrencyFormatter.formatPercent(rate.changeRate24h),
                  icon: isUp ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                  color: isUp ? AppColors.profit : AppColors.loss,
                ),
                const SizedBox(width: 2),
                IconButton(
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  tooltip: 'Özel Fiyat Belirle',
                  onPressed: () => _openEditRateModal(context, rate, portfolio),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bozdurma (Piyasa Alış)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryEmerald)),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(rate.buyPrice),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryEmerald),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Satın Alma (Piyasa Satış)', style: TextStyle(fontSize: 10, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(rate.sellPrice),
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Makas Farkı', style: TextStyle(fontSize: 10, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(rate.sellPrice - rate.buyPrice),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.info),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),
            // Quick Add Action
            SizedBox(
              width: double.infinity,
              height: 32,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Bu Varlığı Portföye / Hedefe Ekle', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryEmerald,
                  side: BorderSide(color: AppColors.primaryEmerald.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => AddEditAssetDialog(
                      assetToEdit: AssetModel(
                        id: '',
                        name: rate.name,
                        symbol: rate.symbol,
                        category: rate.category,
                        amount: 1.0,
                        unit: rate.unit,
                        buyPrice: rate.buyPrice,
                        currentPrice: rate.buyPrice,
                        updatedAt: DateTime.now(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditRateModal(BuildContext context, MarketRateModel rate, PortfolioProvider portfolio) {
    final buyController = TextEditingController(text: rate.buyPrice.toString());
    final sellController = TextEditingController(text: rate.sellPrice.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${rate.name} Fiyatını Güncelle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Yerel kuyumcu veya bankanızın özel kurunu kaydedebilirsiniz. Portföyünüz anında bu fiyattan yeniden hesaplanır.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 14),
            const Text('Alış Fiyatı (₺)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: buyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'örn. 2500'),
            ),
            const SizedBox(height: 12),
            const Text('Satış Fiyatı (₺)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: sellController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'örn. 2550'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              final newBuy = double.tryParse(buyController.text.replaceAll(',', '.')) ?? rate.buyPrice;
              final newSell = double.tryParse(sellController.text.replaceAll(',', '.')) ?? rate.sellPrice;
              portfolio.updateSingleRate(rate.copyWith(
                buyPrice: newBuy,
                sellPrice: newSell,
                lastUpdated: DateTime.now(),
              ));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${rate.name} kuru güncellendi!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryEmerald, foregroundColor: Colors.black),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
