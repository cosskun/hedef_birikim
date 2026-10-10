import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/goal_model.dart';
import '../../providers/goal_provider.dart';
import '../../providers/portfolio_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/milestone_progress_bar.dart';
import 'goal_detail_screen.dart';
import 'add_edit_goal_dialog.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  int _selectedFilterIndex = 0; // 0: Aktif, 1: Tamamlananlar, 2: Tümü

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goalProvider = context.watch<GoalProvider>();
    final portfolio = context.watch<PortfolioProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isPrivacy = themeProvider.isPrivacyMode;

    final allGoals = goalProvider.goals;
    List<GoalModel> filteredGoals;
    if (_selectedFilterIndex == 0) {
      filteredGoals = allGoals.where((g) => !g.isCompleted).toList();
    } else if (_selectedFilterIndex == 1) {
      filteredGoals = allGoals.where((g) => g.isCompleted).toList();
    } else {
      filteredGoals = allGoals;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hedeflerim'),
        actions: [
          IconButton(
            tooltip: isPrivacy ? 'Tutarları Göster' : 'Tutarları Gizle',
            icon: Icon(isPrivacy ? Icons.visibility_off_rounded : Icons.visibility_rounded),
            onPressed: () => themeProvider.togglePrivacyMode(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('Aktif (${allGoals.where((g) => !g.isCompleted).length})', 0),
                const SizedBox(width: 8),
                _buildFilterChip('Tamamlanan (${allGoals.where((g) => g.isCompleted).length})', 1),
                const SizedBox(width: 8),
                _buildFilterChip('Tümü (${allGoals.length})', 2),
              ],
            ),
          ),

          // Goals List
          Expanded(
            child: filteredGoals.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredGoals.length,
                    itemBuilder: (context, index) {
                      final goal = filteredGoals[index];
                      final progress = goalProvider.calculateGoalProgress(goal, portfolio);
                      return _buildGoalCard(context, goal, progress, isDark, isPrivacy);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddGoalModal(context),
        backgroundColor: AppColors.pastelMint,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni Hedef Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilterIndex = index),
      selectedColor: AppColors.pastelMint,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    GoalModel goal,
    GoalProgressInfo progress,
    bool isDark,
    bool isPrivacy,
  ) {
    final goalColor = Color(goal.colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: CustomCard(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => GoalDetailScreen(goalId: goal.id),
            ),
          );
        },
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: goalColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(goal.iconData, color: goalColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: goalColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              goal.category,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: goalColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (progress.isReached)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.profit.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Tamamlandı! 🎉',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.profit,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.title,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (goal.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          goal.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ProgressRing(
                  progress: progress.progressPercent / 100,
                  size: 52,
                  strokeWidth: 5,
                  progressColor: goalColor,
                  centerChild: Text(
                    '%${progress.progressPercent.toInt()}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // STATS ROW: SAVED vs TARGET vs REMAINING
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mevcut Birikim',
                        style: TextStyle(fontSize: 10, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.format(progress.currentAmount, currencyCode: goal.currency, isPrivacy: isPrivacy),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Hedeflenen',
                        style: TextStyle(fontSize: 10, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.format(goal.targetAmount, currencyCode: goal.currency, isPrivacy: isPrivacy),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Kalan Tutar',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: progress.isReached ? AppColors.profit : AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        progress.isReached ? '₺0' : CurrencyFormatter.format(progress.remainingAmount, currencyCode: goal.currency, isPrivacy: isPrivacy),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: progress.isReached ? AppColors.profit : AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Milestone bar
            MilestoneProgressBar(
              progress: progress.progressPercent / 100,
              activeColor: goalColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flag_outlined, size: 64, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
          const SizedBox(height: 16),
          const Text(
            'Henüz bu kategoride hedef bulunmuyor',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Hayalindeki bir şeyi almak için hemen hedef oluştur!',
            style: TextStyle(fontSize: 13, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _openAddGoalModal(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Yeni Hedef Ekle'),
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

  void _openAddGoalModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddEditGoalDialog(),
    );
  }
}
