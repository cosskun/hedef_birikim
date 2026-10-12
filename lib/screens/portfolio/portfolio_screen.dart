import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/asset_model.dart';
import '../../models/goal_model.dart';
import '../../providers/portfolio_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/stat_badge.dart';
import 'add_edit_asset_dialog.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  AssetCategory? _selectedCategory; // null = Tümü

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final portfolio = context.watch<PortfolioProvider>();
    final goalProvider = context.watch<GoalProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isPrivacy = themeProvider.isPrivacyMode;

    final allAssets = portfolio.assets;
    final goalsWithCash = goalProvider.goals.where((g) => g.manualSavedAmount > 0).toList();
    final totalGoalCash = goalProvider.totalManualSavedAmount;

    final filteredAssets = _selectedCategory == null
        ? allAssets
        : allAssets.where((a) => a.category == _selectedCategory).toList();

    final showGoalCash = (_selectedCategory == null || _selectedCategory == AssetCategory.cash) && goalsWithCash.isNotEmpty;

    final totalValue = portfolio.totalPortfolioValue + totalGoalCash;
    final totalPnL = portfolio.totalProfitLossAmount;
    final totalCost = portfolio.totalPortfolioCost + totalGoalCash;
    final totalPnLPercent = totalCost > 0 ? (totalPnL / totalCost) * 100 : 0.0;
    final isProfitable = totalPnL >= 0;

    final totalItemsCount = allAssets.length + goalsWithCash.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portföy & Varlıklarım'),
        actions: [
          IconButton(
            tooltip: isPrivacy ? 'Tutarları Göster' : 'Tutarları Gizle',
            icon: Icon(isPrivacy ? Icons.visibility_off_rounded : Icons.visibility_rounded),
            onPressed: () => themeProvider.togglePrivacyMode(),
          ),
          IconButton(
            tooltip: 'Kurları Yenile',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => portfolio.refreshMarketRates(),
          ),
          IconButton(
            tooltip: 'Varlık Ekle',
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => _openAddAssetModal(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Portfolio mini summary banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Toplam Portföy Değeri',
                        style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          CurrencyFormatter.format(totalValue, isPrivacy: isPrivacy),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatBadge(
                  text: isPrivacy ? '•••••• ₺' : '${isProfitable ? '+' : ''}${CurrencyFormatter.format(totalPnL)} (${CurrencyFormatter.formatPercent(totalPnLPercent)})',
                  icon: isProfitable ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  color: isProfitable ? AppColors.profit : AppColors.loss,
                ),
              ],
            ),
          ),

          // 2. Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildCategoryFilterChip(null, 'Tümü ($totalItemsCount)'),
                ...AssetCategory.values.map((cat) {
                  final assetCount = allAssets.where((a) => a.category == cat).length;
                  final extraCount = (cat == AssetCategory.cash) ? goalsWithCash.length : 0;
                  final count = assetCount + extraCount;
                  return _buildCategoryFilterChip(cat, '${cat.displayName} ($count)');
                }),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // 3. Asset List (combining regular assets & goal cash deposits)
          Expanded(
            child: (filteredAssets.isEmpty && !showGoalCash)
                ? _buildEmptyState(isDark)
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Goal specific cash deposits
                      if (showGoalCash)
                        ...goalsWithCash.map((goal) => _buildGoalCashCard(context, goal, isDark, isPrivacy)),

                      // Portfolio assets
                      ...filteredAssets.map((asset) => _buildAssetCard(context, asset, goalProvider, portfolio, isDark, isPrivacy)),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddAssetModal(context),
        backgroundColor: AppColors.pastelMint,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni Varlık Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCategoryFilterChip(AssetCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedCategory = category),
        selectedColor: AppColors.pastelMint,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildAssetCard(
    BuildContext context,
    AssetModel asset,
    GoalProvider goalProvider,
    PortfolioProvider portfolio,
    bool isDark,
    bool isPrivacy,
  ) {
    final isProfit = asset.isProfitable;
    final linkedGoal = asset.linkedGoalId != null
        ? goalProvider.goals.where((g) => g.id == asset.linkedGoalId).firstOrNull
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(asset.category).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(asset.category.icon, color: _getCategoryColor(asset.category), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            asset.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              asset.symbol,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Miktar: ${CurrencyFormatter.formatQuantity(asset.amount, asset.unit)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(asset.totalCurrentValue, isPrivacy: isPrivacy),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    StatBadge(
                      text: CurrencyFormatter.formatPercent(asset.profitLossPercentage),
                      icon: isProfit ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                      color: isProfit ? AppColors.profit : AppColors.loss,
                      fontSize: 10,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Bottom stats & Link Goal indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maliyet: ${CurrencyFormatter.format(asset.buyPrice, isPrivacy: isPrivacy)} | Bozdurma: ${CurrencyFormatter.format(asset.currentPrice, isPrivacy: isPrivacy)}',
                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                    ),
                    if (linkedGoal != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.link_rounded, size: 12, color: AppColors.gold),
                          const SizedBox(width: 4),
                          Text(
                            'Hedef: ${linkedGoal.title}',
                            style: const TextStyle(fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      tooltip: 'Düzenle',
                      onPressed: () => _openEditAsset(context, asset),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.loss),
                      tooltip: 'Sil',
                      onPressed: () => _confirmDeleteAsset(context, asset.id),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCashCard(
    BuildContext context,
    GoalModel goal,
    bool isDark,
    bool isPrivacy,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cashAsset.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.cashAsset, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${goal.title} (Nakit Birikim)',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'TRY',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.flag_rounded, size: 12, color: AppColors.gold),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Tahsis Edilen Hedef: ${goal.title}',
                          style: const TextStyle(fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(goal.manualSavedAmount, isPrivacy: isPrivacy),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.profit),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.profit.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Hedef Birikimi',
                    style: TextStyle(fontSize: 9, color: AppColors.profit, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(AssetCategory category) {
    switch (category) {
      case AssetCategory.gold:
        return AppColors.goldAsset;
      case AssetCategory.forex:
        return AppColors.forexAsset;
      case AssetCategory.crypto:
        return AppColors.cryptoAsset;
      case AssetCategory.stock:
        return AppColors.stockAsset;
      case AssetCategory.fund:
        return AppColors.fundAsset;
      case AssetCategory.cash:
        return AppColors.cashAsset;
    }
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 64, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
          const SizedBox(height: 16),
          const Text(
            'Bu kategoride varlık bulunamadı',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Gram altın, dolar, kripto veya hisse senedi ekleyerek başla!',
            style: TextStyle(fontSize: 13, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _openAddAssetModal(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Varlık Ekle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pastelMint,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _openAddAssetModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddEditAssetDialog(),
    );
  }

  void _openEditAsset(BuildContext context, AssetModel asset) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditAssetDialog(assetToEdit: asset),
    );
  }

  void _confirmDeleteAsset(BuildContext context, String assetId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Varlığı Sil'),
        content: const Text('Bu varlık kaydını portföyünüzden silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          ElevatedButton(
            onPressed: () {
              context.read<PortfolioProvider>().deleteAsset(assetId);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.loss, foregroundColor: Colors.white),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
