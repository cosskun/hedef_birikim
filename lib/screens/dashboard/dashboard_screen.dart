import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:confetti/confetti.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/asset_model.dart';
import '../../providers/portfolio_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/backup_service.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/milestone_progress_bar.dart';
import '../../widgets/stat_badge.dart';
import '../goals/goal_detail_screen.dart';
import '../goals/add_edit_goal_dialog.dart';
import '../portfolio/add_edit_asset_dialog.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onNavigateTab;

  const DashboardScreen({super.key, required this.onNavigateTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final portfolio = context.watch<PortfolioProvider>();
    final goalProvider = context.watch<GoalProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isPrivacy = themeProvider.isPrivacyMode;

    if (portfolio.isLoading || goalProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalGoalCash = goalProvider.totalManualSavedAmount;
    final totalNetWorth = portfolio.totalPortfolioValue + totalGoalCash;
    final totalPnL = portfolio.totalProfitLossAmount;
    final totalCost = portfolio.totalPortfolioCost + totalGoalCash;
    final totalPnLPercent = totalCost > 0 ? (totalPnL / totalCost) * 100 : 0.0;
    final isProfitable = totalPnL >= 0;

    // Primary target (First uncompleted goal or first goal)
    final primaryGoal = goalProvider.goals.where((g) => !g.isCompleted).firstOrNull ??
        (goalProvider.goals.isNotEmpty ? goalProvider.goals.first : null);

    GoalProgressInfo? primaryGoalProgress;
    if (primaryGoal != null) {
      primaryGoalProgress = goalProvider.calculateGoalProgress(primaryGoal, portfolio);
    }

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pastelMint.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        color: AppColors.pastelMint.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.savings_rounded, color: AppColors.pastelMint, size: 22),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text('HedefBirikim', overflow: TextOverflow.ellipsis, maxLines: 1),
            ],
          ),
        ),
        actions: [
          // 1. TEMA DEĞİŞTİR (DARK / LIGHT MOD)
          IconButton(
            tooltip: themeProvider.isDark ? 'Açık Mod' : 'Koyu Mod',
            icon: Icon(themeProvider.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          // 2. GİZLİ MOD (GÖZ BUTONU)
          IconButton(
            tooltip: isPrivacy ? 'Tutarları Göster' : 'Gizli Mod (Tutarları Gizle)',
            icon: Icon(
              isPrivacy ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: isPrivacy ? AppColors.gold : null,
            ),
            onPressed: () => themeProvider.togglePrivacyMode(),
          ),
          // 3. YEDEKLEME & PAYLAŞ BUTONU
          IconButton(
            tooltip: 'Yedekleme & Geri Yükleme',
            icon: const Icon(Icons.cloud_sync_rounded),
            onPressed: () => _showBackupRestoreModal(context, isDark),
          ),
          // 4. KURLARI YENİLE
          IconButton(
            tooltip: 'Kurları Yenile',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Piyasa kurları güncelleniyor...'), duration: Duration(seconds: 1)),
              );
              await portfolio.refreshMarketRates();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await portfolio.loadData();
              await goalProvider.loadGoals();
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // 1. MAIN NET WORTH CARD
                _buildNetWorthHeroCard(
                  totalNetWorth: totalNetWorth,
                  totalPnL: totalPnL,
                  totalPnLPercent: totalPnLPercent,
                  isProfitable: isProfitable,
                  isDark: isDark,
                  isPrivacy: isPrivacy,
                  onAddAsset: () => _openAddAssetModal(context),
                  onAddGoal: () => _openAddGoalModal(context),
                ),

                const SizedBox(height: 18),

                // MAAS GUNU HATIRLATICI BANNERI (Eğer maaş günü civarındaysa)
                if (themeProvider.isSalaryReminderEnabled) ...[
                  _buildSalaryReminderBanner(context, themeProvider, goalProvider, isDark),
                  const SizedBox(height: 18),
                ],

                // 2. PRIMARY GOAL HIGHLIGHT & REMAINING TRACKER
                if (primaryGoal != null && primaryGoalProgress != null) ...[
                  _buildPrimaryGoalCard(
                    context: context,
                    goal: primaryGoal,
                    progressInfo: primaryGoalProgress,
                    isDark: isDark,
                    isPrivacy: isPrivacy,
                  ),
                  const SizedBox(height: 18),
                ],

                // 3. ASSET CATEGORY PIE CHART & BREAKDOWN
                _buildPortfolioDistributionCard(
                  portfolio: portfolio,
                  totalGoalCash: totalGoalCash,
                  isDark: isDark,
                  isPrivacy: isPrivacy,
                ),

                const SizedBox(height: 18),

                // 4. ACTIVE GOALS QUICK CAROUSEL WITH QUICK DEPOSIT (+)
                _buildActiveGoalsSection(
                  context: context,
                  goals: goalProvider.goals,
                  portfolio: portfolio,
                  goalProvider: goalProvider,
                  isDark: isDark,
                  isPrivacy: isPrivacy,
                ),

                const SizedBox(height: 18),

                // 5. QUICK SIMULATOR BANNER
                _buildSimulatorBanner(isDark: isDark),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // Confetti celebratory overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.primaryEmerald,
                AppColors.gold,
                AppColors.forexAsset,
                AppColors.cryptoAsset,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetWorthHeroCard({
    required double totalNetWorth,
    required double totalPnL,
    required double totalPnLPercent,
    required bool isProfitable,
    required bool isDark,
    required bool isPrivacy,
    required VoidCallback onAddAsset,
    required VoidCallback onAddGoal,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E2837), const Color(0xFF131D2A)]
              : [const Color(0xFFE8F7F0), const Color(0xFFF6FBF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.pastelMint).withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFCDECE0),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'TOPLAM BİRİKİM & VARLIKLAR',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              StatBadge(
                text: isPrivacy ? '••• %' : CurrencyFormatter.formatPercent(totalPnLPercent),
                icon: isProfitable ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: isProfitable ? AppColors.profit : AppColors.loss,
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.format(totalNetWorth, isPrivacy: isPrivacy),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  'Toplam Kâr/Zarar: ',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  isPrivacy ? '••••••' : '${isProfitable ? '+' : ''}${CurrencyFormatter.format(totalPnL)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isProfitable ? AppColors.profit : AppColors.loss,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Divider(color: isDark ? Colors.white12 : AppColors.borderLight, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onAddAsset,
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                  label: const Text('Varlık Ekle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pastelMint,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAddGoal,
                  icon: const Icon(Icons.flag_outlined, size: 18),
                  label: const Text('Hedef Ekle'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : AppColors.textPrimaryLight,
                    side: BorderSide(color: isDark ? Colors.white30 : AppColors.pastelMint.withOpacity(0.4)),
                    backgroundColor: isDark ? Colors.transparent : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryReminderBanner(
    BuildContext context,
    ThemeProvider themeProvider,
    GoalProvider goalProvider,
    bool isDark,
  ) {
    final today = DateTime.now().day;
    final salaryDay = themeProvider.salaryDay;
    final daysToSalary = (salaryDay - today);

    String title;
    String subtitle;
    IconData icon;

    if (daysToSalary == 0) {
      title = '🎉 Bugün Maaş / Gelir Günü!';
      subtitle = 'Tasarruflarını hedeflerine tahsis ederek birikim hedeflerine bir adım daha yaklaş.';
      icon = Icons.paid_rounded;
    } else if (daysToSalary > 0 && daysToSalary <= 4) {
      title = '⏳ Maaş Gününe $daysToSalary Gün Kaldı';
      subtitle = 'Bu ayki hedefin için birikim bütçeni hazırlamayı unutma.';
      icon = Icons.event_available_rounded;
    } else {
      title = '💡 Düzenli Birikim Hatırlatıcısı';
      subtitle = 'Her ayın ${salaryDay}. günü için belirlediğin birikim planına sadık kal!';
      icon = Icons.tips_and_updates_rounded;
    }

    return CustomCard(
      gradient: isDark
          ? const LinearGradient(colors: [Color(0xFF23332B), Color(0xFF14241C)], begin: Alignment.topLeft, end: Alignment.bottomRight)
          : const LinearGradient(colors: [Color(0xFFE6F7F0), Color(0xFFD3F2E4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderColor: AppColors.pastelMint.withOpacity(0.5),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.pastelMint.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.pastelMint, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimaryLight),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 18),
            tooltip: 'Maaş Gününü Değiştir',
            onPressed: () => _showSalarySettingsDialog(context, themeProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryGoalCard({
    required BuildContext context,
    required dynamic goal,
    required GoalProgressInfo progressInfo,
    required bool isDark,
    required bool isPrivacy,
  }) {
    final remaining = progressInfo.remainingAmount;
    final percent = progressInfo.progressPercent;
    final isCompleted = progressInfo.isReached;

    return CustomCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GoalDetailScreen(goalId: goal.id),
          ),
        );
      },
      gradient: isDark
          ? const LinearGradient(
              colors: [Color(0xFF1E2837), Color(0xFF141D29)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      borderColor: AppColors.gold.withOpacity(0.4),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(goal.colorValue).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(goal.iconData, color: Color(goal.colorValue), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'ÖNCELİKLİ HEDEF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            goal.category,
                            style: const TextStyle(fontSize: 10, color: AppColors.gold, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      goal.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              ProgressRing(
                progress: percent / 100,
                size: 58,
                strokeWidth: 6,
                progressColor: Color(goal.colorValue),
                centerChild: Text(
                  '%${percent.toInt()}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // REMAINING AMOUNT HERO CALLOUT WITH QUICK DEPOSIT (+)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCompleted ? 'Hedefe Ulaşıldı! 🎉' : 'HEDEFE KALAN TUTAR',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? AppColors.profit : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          isCompleted ? 'Tebrikler!' : CurrencyFormatter.format(remaining, currencyCode: goal.currency, isPrivacy: isPrivacy),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isCompleted ? AppColors.profit : AppColors.gold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showQuickDepositDialog(context, goal),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Para Ekle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pastelMint,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ROADMAP / MILESTONES
          MilestoneProgressBar(
            progress: percent / 100,
            activeColor: Color(goal.colorValue),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioDistributionCard({
    required PortfolioProvider portfolio,
    required double totalGoalCash,
    required bool isDark,
    required bool isPrivacy,
  }) {
    final rawDistribution = portfolio.categoryDistribution;
    final distribution = Map<AssetCategory, double>.from(rawDistribution);
    if (totalGoalCash > 0) {
      distribution[AssetCategory.cash] = (distribution[AssetCategory.cash] ?? 0.0) + totalGoalCash;
    }
    final total = portfolio.totalPortfolioValue + totalGoalCash;
    final totalItemCount = portfolio.assets.length + (totalGoalCash > 0 ? 1 : 0);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Varlık Dağılımı',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$totalItemCount Varlık Kalemi',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (total == 0 || distribution.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Icon(Icons.pie_chart_outline_rounded, size: 40, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                    const SizedBox(height: 8),
                    const Text('Henüz portföyünüzde varlık yok', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Altın, döviz, kripto veya nakit ekleyerek varlık dağılımınızı görün.',
                      style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _openAddAssetModal(context),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('İlk Varlığımı Ekle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pastelMint,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 320;
                final pieWidget = SizedBox(
                  height: isNarrow ? 110 : 125,
                  width: isNarrow ? 110 : 125,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: isNarrow ? 30 : 34,
                      sections: distribution.entries.map((entry) {
                        final cat = entry.key;
                        final val = entry.value;
                        final color = _getCategoryColor(cat);
                        return PieChartSectionData(
                          value: val,
                          color: color,
                          title: '',
                          radius: 15,
                        );
                      }).toList(),
                    ),
                  ),
                );

                final legendWidget = Column(
                  children: distribution.entries.map((entry) {
                    final cat = entry.key;
                    final val = entry.value;
                    final percent = (val / total) * 100;
                    final color = _getCategoryColor(cat);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              cat.displayName,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '%${percent.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(width: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '(${CurrencyFormatter.formatCompact(val, isPrivacy: isPrivacy)})',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );

                if (isNarrow) {
                  return Column(
                    children: [
                      Center(child: pieWidget),
                      const SizedBox(height: 14),
                      legendWidget,
                    ],
                  );
                }

                return Row(
                  children: [
                    pieWidget,
                    const SizedBox(width: 14),
                    Expanded(child: legendWidget),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveGoalsSection({
    required BuildContext context,
    required List<dynamic> goals,
    required PortfolioProvider portfolio,
    required GoalProvider goalProvider,
    required bool isDark,
    required bool isPrivacy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tüm Hedeflerim',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (goals.isNotEmpty)
              TextButton(
                onPressed: () => widget.onNavigateTab(1), // Go to Goals tab
                child: const Text('Tümünü Gör →'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (goals.isEmpty)
          CustomCard(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.flag_outlined, size: 40, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                  const SizedBox(height: 10),
                  const Text('Henüz bir hedef oluşturmadınız', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    'Hayalinizdeki birikim için ilk hedefinizi belirleyin.',
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () => _openAddGoalModal(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('İlk Hedefimi Oluştur'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pastelMint,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...goals.take(3).map((goal) {
            final progress = goalProvider.calculateGoalProgress(goal, portfolio);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: CustomCard(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GoalDetailScreen(goalId: goal.id),
                    ),
                  );
                },
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(goal.colorValue).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(goal.iconData, color: Color(goal.colorValue), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Kalan: ${CurrencyFormatter.format(progress.remainingAmount, currencyCode: goal.currency, isPrivacy: isPrivacy)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: progress.isReached ? AppColors.profit : AppColors.gold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '• ${progress.daysLeft} gün',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Hızlı Para Ekle Butonu (+)
                    IconButton(
                      tooltip: 'Hızlı Birikim Ekle',
                      icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.pastelMint),
                      onPressed: () => _showQuickDepositDialog(context, goal),
                    ),
                    const SizedBox(width: 4),
                    ProgressRing(
                      progress: progress.progressPercent / 100,
                      size: 42,
                      strokeWidth: 4,
                      progressColor: Color(goal.colorValue),
                      centerChild: Text(
                        '%${progress.progressPercent.toInt()}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildSimulatorBanner({required bool isDark}) {
    return CustomCard(
      onTap: () => widget.onNavigateTab(3), // Navigate to simulator tab
      gradient: LinearGradient(
        colors: isDark
            ? [const Color(0xFF2E1A47), const Color(0xFF171328)]
            : [const Color(0xFFF4EFFB), const Color(0xFFE8DEFA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: isDark ? AppColors.borderDark : const Color(0xFFD8C7F5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.15) : AppColors.pastelPurple.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.calculate_rounded, color: isDark ? Colors.white : AppColors.pastelPurple, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Akıllı Birikim Simülatörü',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Aylık X TL veya gram altın biriktirirsem hedefime ne zaman ulaşırım?',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: isDark ? Colors.white70 : AppColors.pastelPurple, size: 16),
        ],
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

  void _openAddAssetModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddEditAssetDialog(),
    );
  }

  void _openAddGoalModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddEditGoalDialog(),
    );
  }

  void _showQuickDepositDialog(BuildContext context, dynamic goal) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${goal.title} Hedefine Birikim Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kenara koyduğunuz nakit tutarı girin:'),
            const SizedBox(height: 14),
            const Text('Eklenecek Tutar (₺)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              inputFormatters: [
                ThousandsSeparatorInputFormatter(),
              ],
              decoration: const InputDecoration(
                hintText: 'örn. 5.000',
                prefixIcon: Icon(Icons.attach_money_rounded),
                suffixText: '₺',
                suffixStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              final amount = CurrencyFormatter.parse(controller.text);
              if (amount > 0) {
                context.read<GoalProvider>().addDepositToGoal(goal.id, amount);
                Navigator.pop(ctx);
                _confettiController.play();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${CurrencyFormatter.format(amount)} hedefe eklendi! 🎉')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.pastelMint, foregroundColor: Colors.white),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showSalarySettingsDialog(BuildContext context, ThemeProvider themeProvider) {
    int tempDay = themeProvider.salaryDay;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Maaş / Gelir Günü Ayarı'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Her ay hangi gün maaş alıyorsunuz veya birikim yapıyorsunuz?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    onPressed: () {
                      if (tempDay > 1) {
                        setDialogState(() => tempDay--);
                      }
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.pastelMint.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Her ayın $tempDay. günü',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.pastelMint),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    onPressed: () {
                      if (tempDay < 31) {
                        setDialogState(() => tempDay++);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
            ElevatedButton(
              onPressed: () {
                themeProvider.setSalaryDay(tempDay);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Maaş günü ayın $tempDay. günü olarak kaydedildi!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.pastelMint, foregroundColor: Colors.white),
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBackupRestoreModal(BuildContext context, bool isDark) {
    final restoreController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          top: 20,
          left: 20,
          right: 20,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text('Yedekleme & Geri Yükleme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Birikimlerinizi ve hedeflerinizi kaybetmemek için kendinize tek dokunuşla e-posta veya mesaj olarak gönderebilirsiniz.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 18),

              // YEDEK AL BUTONLARI
              ElevatedButton.icon(
                onPressed: () async {
                  await BackupService.copyBackupToClipboard();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Yedek Kodu Kopyalandı! E-Postanıza veya WhatsApp\'a yapıştırıp saklayabilirsiniz 📋'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Yedek Kodunu Kopyala (WhatsApp / Notlar)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pastelMint,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),

              const SizedBox(height: 20),
              Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              const SizedBox(height: 12),

              // YEDEKTEN GERİ YÜKLE
              const Text('Yedekten Geri Yükle', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Daha önce aldığınız yedek kodunu buraya yapıştırın:', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              TextField(
                controller: restoreController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'HEDEFBIRIKIM-YEDEK-V1:... veya kodunuzu yapıştırın',
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final text = restoreController.text.trim();
                    if (text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lütfen bir yedek kodu girin!')),
                      );
                      return;
                    }
                    final result = await BackupService.restoreFromBackupString(text);
                    if (result['success'] == true) {
                      await context.read<PortfolioProvider>().loadData();
                      await context.read<GoalProvider>().loadGoals();
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result['message'] as String)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result['message'] as String)),
                      );
                    }
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Verileri Geri Yükle'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.pastelMint,
                    side: const BorderSide(color: AppColors.pastelMint),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
