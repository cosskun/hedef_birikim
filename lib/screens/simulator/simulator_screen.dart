import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/goal_model.dart';
import '../../providers/goal_provider.dart';
import '../../providers/portfolio_provider.dart';
import '../../widgets/custom_card.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  GoalModel? _selectedGoal;
  double _customTargetAmount = 250000;
  double _monthlySavings = 15000;
  double _annualReturnRate = 35.0; // %35 estimated yearly growth (gold/forex/investments)
  String _savingsVehicle = 'Altın & Yatırım Sepeti';

  final List<String> _vehicles = [
    'Altın & Yatırım Sepeti',
    'Döviz (USD/EUR)',
    'TL Mevduat & Fon',
    'Hisse & Kripto',
    'Düz Nakit Birikim',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goalProvider = context.watch<GoalProvider>();
    final portfolio = context.watch<PortfolioProvider>();

    final targetAmount = _selectedGoal != null ? _selectedGoal!.targetAmount : _customTargetAmount;
    final currentSaved = _selectedGoal != null
        ? goalProvider.calculateGoalProgress(_selectedGoal!, portfolio).currentAmount
        : 0.0;
    final remainingTarget = (targetAmount - currentSaved).clamp(0.0, double.infinity);

    // Simulation Math: Monthly compound interest / regular savings calculation
    // FV = P*(1+r)^n + PMT * [((1+r)^n - 1) / r]
    // Here we compute months n needed to reach targetAmount
    final monthlyRate = (_annualReturnRate / 100) / 12;
    int calculatedMonths = 0;
    double accumulated = currentSaved;
    double totalOutOfPocket = 0;

    if (_monthlySavings > 0 && remainingTarget > 0) {
      while (accumulated < targetAmount && calculatedMonths < 360) {
        calculatedMonths++;
        totalOutOfPocket += _monthlySavings;
        if (monthlyRate > 0) {
          accumulated = (accumulated + _monthlySavings) * (1 + monthlyRate);
        } else {
          accumulated += _monthlySavings;
        }
      }
    }

    final estimatedYears = calculatedMonths ~/ 12;
    final estimatedRemainingMonths = calculatedMonths % 12;
    final profitFromAppreciation = (accumulated - (currentSaved + totalOutOfPocket)).clamp(0.0, double.infinity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akıllı Birikim Simülatörü'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Goal Selector Header
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hedef Seçimi veya Özel Hedef',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                Text(
                  'Mevcut Bir Hedefi Simüle Et',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<GoalModel?>(
                  isExpanded: true,
                  value: _selectedGoal,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.flag_rounded, color: AppColors.primaryEmerald),
                  ),
                  items: [
                    const DropdownMenuItem<GoalModel?>(
                      value: null,
                      child: Text(
                        'Özel Tutar Belirle',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ...goalProvider.goals.map((g) => DropdownMenuItem<GoalModel?>(
                          value: g,
                          child: Text(
                            '${g.title} (${CurrencyFormatter.format(g.targetAmount)})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedGoal = val;
                      if (val != null) {
                        _customTargetAmount = val.targetAmount;
                      }
                    });
                  },
                ),
                if (_selectedGoal == null) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Hedeflenen Tutar (₺)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    initialValue: _customTargetAmount.toStringAsFixed(0),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: 'Hedef Tutar',
                      prefixIcon: Icon(Icons.monetization_on_outlined),
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val.replaceAll(',', '.'));
                      if (parsed != null && parsed > 0) {
                        setState(() => _customTargetAmount = parsed);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Sliders & Simulation Controls
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Birikim Parametreleri',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),

                Text(
                  'Tercih Edilen Birikim Aracı',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _savingsVehicle,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.pie_chart_rounded, color: AppColors.gold),
                  ),
                  items: _vehicles
                      .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(
                              v,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _savingsVehicle = val;
                        if (val.contains('Altın')) _annualReturnRate = 35.0;
                        if (val.contains('Döviz')) _annualReturnRate = 25.0;
                        if (val.contains('Mevduat')) _annualReturnRate = 45.0;
                        if (val.contains('Kripto')) _annualReturnRate = 60.0;
                        if (val.contains('Düz Nakit')) _annualReturnRate = 0.0;
                      });
                    }
                  },
                ),

                const SizedBox(height: 18),

                // Monthly Savings Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Aylık Kenara Koyulacak Tutar:', style: TextStyle(fontSize: 13)),
                    Text(
                      CurrencyFormatter.format(_monthlySavings),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryEmerald),
                    ),
                  ],
                ),
                Slider(
                  value: _monthlySavings.clamp(1000, 150000),
                  min: 1000,
                  max: 150000,
                  divisions: 149,
                  activeColor: AppColors.primaryEmerald,
                  onChanged: (val) => setState(() => _monthlySavings = val),
                ),

                const SizedBox(height: 8),

                // Estimated Annual Yield Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tahmini Yıllık Değer Artışı / Getiri:', style: TextStyle(fontSize: 13)),
                    Text(
                      '%${_annualReturnRate.toInt()}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.gold),
                    ),
                  ],
                ),
                Slider(
                  value: _annualReturnRate.clamp(0, 100),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  activeColor: AppColors.gold,
                  onChanged: (val) => setState(() => _annualReturnRate = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. RESULTS & ESTIMATED DURATION
          CustomCard(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E3A2F), const Color(0xFF11221B)]
                  : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderColor: AppColors.primaryEmerald.withOpacity(0.5),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.rocket_launch_rounded, color: AppColors.primaryEmerald, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Hedefe Ulaşma Süresi Tahmini',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Text(
                        calculatedMonths == 0
                            ? 'Zaten Ulaşıldı! 🎉'
                            : (estimatedYears > 0
                                ? '$estimatedYears Yıl $estimatedRemainingMonths Ay'
                                : '$calculatedMonths Ay'),
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.primaryEmerald : const Color(0xFF00796B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '(${calculatedMonths * 30} gün sonra hayalinize kavuşuyorsunuz)',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // Out of pocket vs Return breakdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cebinizden Çıkacak Tutar', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.format(totalOutOfPocket),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Altın/Yatırım Getirisi Katkısı', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
                        const SizedBox(height: 2),
                        Text(
                          '+${CurrencyFormatter.format(profitFromAppreciation)}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.profit),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. MICRO-SAVING MOTIVATION TIP
          CustomCard(
            borderColor: AppColors.info.withOpacity(0.3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.info, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mikro Tasarruf & Kartopu Etkisi',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.info),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Günde fazladan ₺150 (örneğin bir dışarıda kahve/atıştırmalık) tasarruf edip gram altına yatırdığınızda, hedefinize tam 3 ila 5 ay daha erken ulaşırsınız!',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
