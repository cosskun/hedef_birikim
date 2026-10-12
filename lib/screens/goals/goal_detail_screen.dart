import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/goal_model.dart';
import '../../models/asset_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/goal_provider.dart';
import '../../providers/portfolio_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/milestone_progress_bar.dart';
import 'add_edit_goal_dialog.dart';
import '../portfolio/add_edit_asset_dialog.dart';

class GoalDetailScreen extends StatefulWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goalProvider = context.watch<GoalProvider>();
    final portfolio = context.watch<PortfolioProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isPrivacy = themeProvider.isPrivacyMode;

    final goal = goalProvider.goals.where((g) => g.id == widget.goalId).firstOrNull;

    if (goal == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Hedef bulunamadı veya silindi.')),
      );
    }

    final progress = goalProvider.calculateGoalProgress(goal, portfolio);
    final assignedAssets = portfolio.getAssetsForGoal(goal.id);
    final goalColor = Color(goal.colorValue);

    // Filter transactions associated with this goal
    final goalTransactions = portfolio.transactions.where((t) => t.goalId == goal.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.title),
        actions: [
          IconButton(
            tooltip: isPrivacy ? 'Tutarları Göster' : 'Tutarları Gizle',
            icon: Icon(isPrivacy ? Icons.visibility_off_rounded : Icons.visibility_rounded),
            onPressed: () => themeProvider.togglePrivacyMode(),
          ),
          IconButton(
            tooltip: 'Düzenle',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _openEditGoal(context, goal),
          ),
          IconButton(
            tooltip: 'Hedefi Sil',
            icon: const Icon(Icons.delete_outline, color: AppColors.loss),
            onPressed: () => _confirmDelete(context, goal.id),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. HERO PROGRESS CARD
              _buildHeroProgressCard(goal, progress, goalColor, isDark, isPrivacy),

              const SizedBox(height: 16),

              // 2. MILESTONE BADGES (%25, %50, %75, %100)
              _buildMilestoneBadgesCard(progress, goal, goalColor, isDark, isPrivacy),

              const SizedBox(height: 16),

              // 3. SAVINGS RATE & PACE RECOMMENDATION
              _buildPaceRecommendationCard(progress, goal, isDark, isPrivacy),

              const SizedBox(height: 16),

              // 4. ACTION BUTTONS: DIRECT CASH DEPOSIT & ASSET ALLOCATION
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showQuickDepositDialog(context, goal),
                      icon: const Icon(Icons.add_card_rounded, size: 18),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Para Ekle'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryEmerald,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openAddAssetForThisGoal(context, goal.id),
                      icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Varlık Tahsis Et'),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 5. BAŞARI ZAMAN TÜNELİ (CHRONOLOGICAL TIMELINE / LOG)
              _buildTimelineSection(goal, goalTransactions, assignedAssets, isDark, isPrivacy, goalColor),

              const SizedBox(height: 24),

              // 6. ASSIGNED ASSETS LIST
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bu Hedefe Bağlı Varlıklar (${assignedAssets.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => _openLinkExistingAssetsModal(context, goal, portfolio),
                    icon: const Icon(Icons.link_rounded, size: 16),
                    label: const Text('Varlık Bağla'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (goal.manualSavedAmount > 0) ...[
                _buildManualCashTile(goal, isDark, isPrivacy),
                const SizedBox(height: 8),
              ],

              if (assignedAssets.isEmpty && goal.manualSavedAmount == 0) ...[
                _buildNoAssetsCard(isDark, goal),
              ] else ...[
                ...assignedAssets.map((asset) => _buildAssetTile(asset, portfolio, isDark, isPrivacy)),
              ],

              const SizedBox(height: 24),

              // 7. GOAL STATUS TOGGLE
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    goalProvider.toggleGoalCompleted(goal.id);
                    if (!goal.isCompleted) {
                      _confettiController.play();
                    }
                  },
                  icon: Icon(
                    goal.isCompleted ? Icons.restart_alt_rounded : Icons.check_circle_rounded,
                    color: goal.isCompleted ? AppColors.gold : AppColors.profit,
                  ),
                  label: Text(
                    goal.isCompleted ? 'Hedefi Yeniden Aktif Et' : 'Hedefi Tamamlandı Olarak İşaretle 🎉',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: goal.isCompleted ? AppColors.gold : AppColors.profit,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),

          // Confetti overlay
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

  Widget _buildHeroProgressCard(
    GoalModel goal,
    GoalProgressInfo progress,
    Color goalColor,
    bool isDark,
    bool isPrivacy,
  ) {
    return CustomCard(
      borderColor: goalColor.withOpacity(0.5),
      gradient: isDark
          ? LinearGradient(
              colors: [Color(goal.colorValue).withOpacity(0.15), const Color(0xFF131D2A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: goalColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  goal.category,
                  style: TextStyle(color: goalColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Text(
                'Hedef Tarih: ${_formatDate(goal.targetDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ProgressRing(
            progress: progress.progressPercent / 100,
            size: 110,
            strokeWidth: 10,
            progressColor: goalColor,
            centerChild: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '%${progress.progressPercent.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const Text('Ulaşıldı', style: TextStyle(fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            progress.isReached ? 'Hedefine Başarıyla Ulaştın! 🏆' : 'HEDEFE KALAN TUTAR',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.1,
              fontWeight: FontWeight.bold,
              color: progress.isReached ? AppColors.profit : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              progress.isReached
                  ? 'Tebrikler!'
                  : CurrencyFormatter.format(progress.remainingAmount, currencyCode: goal.currency, isPrivacy: isPrivacy),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: progress.isReached ? AppColors.profit : AppColors.gold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              'Mevcut: ${CurrencyFormatter.format(progress.currentAmount, currencyCode: goal.currency, isPrivacy: isPrivacy)} / Hedef: ${CurrencyFormatter.format(goal.targetAmount, currencyCode: goal.currency, isPrivacy: isPrivacy)}',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
          ),
          const SizedBox(height: 16),
          MilestoneProgressBar(
            progress: progress.progressPercent / 100,
            activeColor: goalColor,
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneBadgesCard(
    GoalProgressInfo progress,
    GoalModel goal,
    Color goalColor,
    bool isDark,
    bool isPrivacy,
  ) {
    final milestones = [
      {'percent': 25, 'label': 'Çeyrek Yol', 'icon': Icons.bolt_rounded, 'emoji': '🎯'},
      {'percent': 50, 'label': 'Yarı Yol', 'icon': Icons.speed_rounded, 'emoji': '⚡'},
      {'percent': 75, 'label': 'Büyük Başarı', 'icon': Icons.trending_up_rounded, 'emoji': '🚀'},
      {'percent': 100, 'label': 'Hedef Tamam', 'icon': Icons.emoji_events_rounded, 'emoji': '🏆'},
    ];

    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.military_tech_rounded, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Aşama Rozetleri & Kademeler',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '%${progress.progressPercent.toStringAsFixed(0)} Kat Edildi',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: goalColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: milestones.map((m) {
              final mPercent = m['percent'] as int;
              final isReached = progress.progressPercent >= mPercent;
              final stageAmount = goal.targetAmount * (mPercent / 100);

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isReached
                        ? (isDark ? AppColors.primaryEmerald.withOpacity(0.2) : const Color(0xFFD4F3E6))
                        : (isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isReached ? AppColors.primaryEmerald : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        m['emoji'] as String,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '%$mPercent',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isReached ? AppColors.primaryEmerald : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        m['label'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: isReached ? FontWeight.bold : FontWeight.normal,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatCompact(stageAmount, isPrivacy: isPrivacy),
                        style: TextStyle(
                          fontSize: 9,
                          color: isReached ? (isDark ? Colors.white : Colors.black87) : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaceRecommendationCard(
    GoalProgressInfo progress,
    GoalModel goal,
    bool isDark,
    bool isPrivacy,
  ) {
    final dailyNeeded = progress.dailyNeededRate;
    final monthlyNeeded = dailyNeeded * 30;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph_rounded, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Akıllı Hedef Analizi & Kalan Süre',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kalan Gün',
                        style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${progress.daysLeft} Gün',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Önerilen Aylık Birikim',
                        style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          progress.isReached
                              ? '₺0'
                              : CurrencyFormatter.format(monthlyNeeded, currencyCode: goal.currency, isPrivacy: isPrivacy),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryEmerald),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            progress.isReached
                ? 'Hedef tamamlandı. Yeni bir hayal için birikimlerine devam edebilirsin!'
                : '🎯 Hedeflediğin tarihe ulaşmak için günde yaklaşık ${CurrencyFormatter.format(dailyNeeded, currencyCode: goal.currency, isPrivacy: isPrivacy)} kenara koymalısın.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(
    GoalModel goal,
    List<TransactionModel> transactions,
    List<AssetModel> assignedAssets,
    bool isDark,
    bool isPrivacy,
    Color goalColor,
  ) {
    // Construct all timeline items
    final timelineItems = <_TimelineItem>[];

    // 1. Transactions logged to this goal
    for (final tx in transactions) {
      timelineItems.add(
        _TimelineItem(
          date: tx.date,
          title: tx.note.isNotEmpty ? tx.note : (tx.type == TransactionType.deposit ? 'Nakit Birikim Eklendi' : '${tx.assetName} Eklendi'),
          subtitle: tx.type == TransactionType.deposit
              ? '+${CurrencyFormatter.format(tx.totalTRY, isPrivacy: isPrivacy)} Nakit'
              : '+${CurrencyFormatter.formatQuantity(tx.amount, '')} ${tx.assetName} (${CurrencyFormatter.format(tx.totalTRY, isPrivacy: isPrivacy)})',
          icon: tx.type == TransactionType.deposit ? Icons.add_circle_outline_rounded : Icons.account_balance_wallet_rounded,
          color: AppColors.primaryEmerald,
        ),
      );
    }

    // 2. Linked Assets without duplicate tx
    for (final asset in assignedAssets) {
      final hasTx = transactions.any((t) => t.assetId == asset.id);
      if (!hasTx) {
        timelineItems.add(
          _TimelineItem(
            date: asset.updatedAt,
            title: '${asset.name} Varlık Tahsisi',
            subtitle: '${CurrencyFormatter.formatQuantity(asset.amount, asset.unit)} • Güncel: ${CurrencyFormatter.format(asset.totalCurrentValue, isPrivacy: isPrivacy)}',
            icon: asset.category.icon,
            color: AppColors.gold,
          ),
        );
      }
    }

    // 3. Goal Creation Base Item
    timelineItems.add(
      _TimelineItem(
        date: goal.createdAt,
        title: '🎯 Hedef Belirlendi',
        subtitle: 'Hedeflenen Tutar: ${CurrencyFormatter.format(goal.targetAmount, currencyCode: goal.currency, isPrivacy: isPrivacy)}',
        icon: Icons.flag_rounded,
        color: goalColor,
      ),
    );

    // Sort descending by date (newest on top)
    timelineItems.sort((a, b) => b.date.compareTo(a.date));

    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.history_edu_rounded, color: AppColors.pastelMint, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    '📜 Başarı Zaman Tüneli',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _showQuickDepositDialog(context, goal),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.pastelMint.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 14, color: AppColors.pastelMint),
                      SizedBox(width: 2),
                      Text('+ Giriş Ekle', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.pastelMint)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Bu hedefe giden yolda attığın tüm adımlar ve birikim günlüğün.',
            style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: timelineItems.length,
            separatorBuilder: (c, i) => Padding(
              padding: const EdgeInsets.only(left: 17),
              child: Container(
                height: 16,
                width: 2,
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            itemBuilder: (context, index) {
              final item = timelineItems[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: item.color.withOpacity(0.6), width: 1.5),
                    ),
                    child: Icon(item.icon, size: 18, color: item.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                _formatDate(item.date),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildManualCashTile(GoalModel goal, bool isDark, bool isPrivacy) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cashAsset.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.cashAsset.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.cashAsset, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Doğrudan Eklenen Nakit Birikim',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bu hedefe özel biriktirilen nakit',
                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(goal.manualSavedAmount, currencyCode: goal.currency, isPrivacy: isPrivacy),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.profit),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetTile(AssetModel asset, PortfolioProvider portfolio, bool isDark, bool isPrivacy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(asset.category.icon, color: AppColors.gold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  '${CurrencyFormatter.formatQuantity(asset.amount, asset.unit)} • Anlık: ${CurrencyFormatter.format(asset.currentPrice, isPrivacy: isPrivacy)}/${asset.unit}',
                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(asset.totalCurrentValue, isPrivacy: isPrivacy),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              InkWell(
                onTap: () => portfolio.linkAssetToGoal(asset.id, null),
                child: const Text(
                  'Bağlantıyı Kaldır',
                  style: TextStyle(fontSize: 11, color: AppColors.loss),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoAssetsCard(bool isDark, GoalModel goal) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 36, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
            const SizedBox(height: 8),
            const Text(
              'Bu hedefe henüz varlık atanmadı',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Mevcut altın, döviz veya hisselerinizi bu hedefe tahsis edebilirsiniz.',
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickDepositDialog(BuildContext context, GoalModel goal) {
    final amountController = TextEditingController();
    final noteController = TextEditingController(text: 'Maaş Birikimi');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.savings_rounded, color: AppColors.pastelMint),
            const SizedBox(width: 8),
            const Text('Birikim / Para Ekle'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${goal.title} hedefinize eklemek istediğiniz tutar ve not:'),
              const SizedBox(height: 14),
              const Text('Eklenecek Tutar (₺)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                inputFormatters: [
                  ThousandsSeparatorInputFormatter(),
                ],
                decoration: const InputDecoration(
                  hintText: '50.000',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                  suffixText: '₺',
                  suffixStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Açıklama / Not (İsteğe Bağlı)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  hintText: 'örn: Kasım Maaş Birikimi',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              final amount = CurrencyFormatter.parse(amountController.text);
              if (amount > 0) {
                final note = noteController.text.trim();
                context.read<GoalProvider>().addDepositToGoal(
                  goal.id,
                  amount,
                  note: note.isNotEmpty ? note : 'Nakit Birikimi',
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${CurrencyFormatter.format(amount)} hedefe eklendi! 🎉')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryEmerald,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openEditGoal(BuildContext context, GoalModel goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditGoalDialog(goalToEdit: goal),
    );
  }

  void _confirmDelete(BuildContext context, String goalId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hedefi Sil'),
        content: const Text('Bu hedefi silmek istediğinizden emin misiniz? (Bağlı varlıklar portföyünüzde kalır).'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          ElevatedButton(
            onPressed: () {
              context.read<GoalProvider>().deleteGoal(goalId);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back to goals list
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.loss, foregroundColor: Colors.white),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _openAddAssetForThisGoal(BuildContext context, String goalId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditAssetDialog(preselectedGoalId: goalId),
    );
  }

  void _openLinkExistingAssetsModal(BuildContext context, GoalModel goal, PortfolioProvider portfolio) {
    final unlinkedAssets = portfolio.assets.where((a) => a.linkedGoalId != goal.id).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Portföyden Varlık Bağla', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Seçtiğiniz varlık bu hedefin toplam birikim hesabına dahil edilecektir.', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 14),
              if (unlinkedAssets.isEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('Bağlanabilecek başka varlık bulunmuyor.')),
                ),
              ] else ...[
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: unlinkedAssets.length,
                    itemBuilder: (c, idx) {
                      final asset = unlinkedAssets[idx];
                      return ListTile(
                        leading: Icon(asset.category.icon, color: AppColors.gold),
                        title: Text(asset.name),
                        subtitle: Text('${CurrencyFormatter.formatQuantity(asset.amount, asset.unit)} • ${CurrencyFormatter.format(asset.totalCurrentValue)}'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            portfolio.linkAssetToGoal(asset.id, goal.id);
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryEmerald, foregroundColor: Colors.black),
                          child: const Text('Bağla'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TimelineItem {
  final DateTime date;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  _TimelineItem({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
