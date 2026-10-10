import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/goal_model.dart';
import '../../providers/goal_provider.dart';

class AddEditGoalDialog extends StatefulWidget {
  final GoalModel? goalToEdit;

  const AddEditGoalDialog({super.key, this.goalToEdit});

  @override
  State<AddEditGoalDialog> createState() => _AddEditGoalDialogState();
}

class _AddEditGoalDialogState extends State<AddEditGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _amountController;
  late TextEditingController _initialAmountController;

  late DateTime _selectedDate;
  late String _selectedCategory;
  late String _selectedIconKey;
  late int _selectedColor;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Araba', 'iconKey': 'car', 'icon': Icons.directions_car_rounded, 'color': 0xFF38B289},
    {'name': 'Ev', 'iconKey': 'home', 'icon': Icons.home_rounded, 'color': 0xFF4E9B85},
    {'name': 'Teknoloji', 'iconKey': 'tech', 'icon': Icons.laptop_mac_rounded, 'color': 0xFF4A90E2},
    {'name': 'Tatil', 'iconKey': 'vacation', 'icon': Icons.flight_takeoff_rounded, 'color': 0xFFE5A125},
    {'name': 'Yatırım', 'iconKey': 'invest', 'icon': Icons.show_chart_rounded, 'color': 0xFF8E66C7},
    {'name': 'Düğün', 'iconKey': 'wedding', 'icon': Icons.favorite_rounded, 'color': 0xFFE56A8F},
    {'name': 'Eğitim', 'iconKey': 'education', 'icon': Icons.school_rounded, 'color': 0xFF5C6BC0},
    {'name': 'Diğer', 'iconKey': 'flag', 'icon': Icons.flag_rounded, 'color': 0xFFF59E0B},
  ];

  final ScrollController _categoryScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final edit = widget.goalToEdit;
    _titleController = TextEditingController(text: edit?.title ?? '');
    _descController = TextEditingController(text: edit?.description ?? '');
    _amountController = TextEditingController(
      text: edit != null ? CurrencyFormatter.formatThousands(edit.targetAmount) : '',
    );
    _initialAmountController = TextEditingController(
      text: edit != null && edit.manualSavedAmount > 0
          ? CurrencyFormatter.formatThousands(edit.manualSavedAmount)
          : '0',
    );

    _selectedDate = edit?.targetDate ?? DateTime.now().add(const Duration(days: 90));
    _selectedCategory = edit?.category ?? 'Araba';
    _selectedIconKey = edit?.iconKey ?? 'car';
    _selectedColor = edit?.colorValue ?? 0xFF38B289;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _amountController.dispose();
    _initialAmountController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.goalToEdit != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Hedefi Düzenle' : 'Yeni Hedef Oluştur',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Selector Header with Scroll Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Hedef Kategorisi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (_categoryScrollController.hasClients) {
                            _categoryScrollController.animateTo(
                              (_categoryScrollController.offset - 130).clamp(0.0, _categoryScrollController.position.maxScrollExtent),
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                          child: const Icon(Icons.chevron_left_rounded, size: 18),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () {
                          if (_categoryScrollController.hasClients) {
                            _categoryScrollController.animateTo(
                              (_categoryScrollController.offset + 130).clamp(0.0, _categoryScrollController.position.maxScrollExtent),
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                          child: const Icon(Icons.chevron_right_rounded, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Single Row Horizontal Scroll for Categories
              SingleChildScrollView(
                controller: _categoryScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat['name'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: Icon(cat['icon'] as IconData, size: 16, color: isSelected ? Colors.white : Color(cat['color'] as int)),
                        label: Text(cat['name'] as String),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = cat['name'] as String;
                              _selectedIconKey = cat['iconKey'] as String;
                              _selectedColor = cat['color'] as int;
                            });
                          }
                        },
                        selectedColor: Color(cat['color'] as int),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : null,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Goal Title Label & Field
              Text(
                'Hedef Adı',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'örn. Yeni Araba, Ev Peşinatı, Tatil, Eğitim',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Lütfen bir başlık girin' : null,
              ),

              const SizedBox(height: 14),

              // Target Amount Label & Field with real-time Thousands Formatter
              Text(
                'Hedeflenen Tutar (₺)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  ThousandsSeparatorInputFormatter(),
                ],
                decoration: const InputDecoration(
                  hintText: '1.000.000',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                  suffixText: '₺',
                  suffixStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
                validator: (val) {
                  final amount = CurrencyFormatter.parse(val ?? '');
                  if (amount <= 0) return 'Geçerli bir tutar girin';
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // Initial Cash (only when creating)
              if (!isEditing) ...[
                Text(
                  'Şu Ana Kadar Kenara Koyulan Tutar (₺) (Opsiyonel)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _initialAmountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    ThousandsSeparatorInputFormatter(),
                  ],
                  decoration: const InputDecoration(
                    hintText: '0',
                    prefixIcon: Icon(Icons.savings_rounded),
                    suffixText: '₺',
                    suffixStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Target Date Picker Label & Tile
              Text(
                'Hedef Tarih',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickTargetDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, size: 20, color: AppColors.pastelMint),
                          const SizedBox(width: 12),
                          Text(
                            CurrencyFormatter.formatDate(_selectedDate),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Description / Note Label & Field
              Text(
                'Açıklama / Notlar (Opsiyonel)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Hedef hakkında motivasyonel notlar...',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),

              const SizedBox(height: 22),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pastelMint,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    isEditing ? 'Değişiklikleri Kaydet' : 'Hedefi Başlat 🚀',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      locale: const Locale('tr', 'TR'),
      helpText: 'Hedef Tarihini Seçin',
      cancelText: 'İptal',
      confirmText: 'Seç',
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final desc = _descController.text.trim();
      final amount = CurrencyFormatter.parse(_amountController.text);
      final initialAmount = CurrencyFormatter.parse(_initialAmountController.text);

      final goalProvider = context.read<GoalProvider>();

      if (widget.goalToEdit != null) {
        final updated = widget.goalToEdit!.copyWith(
          title: title,
          description: desc,
          targetAmount: amount,
          targetDate: _selectedDate,
          category: _selectedCategory,
          iconKey: _selectedIconKey,
          colorValue: _selectedColor,
        );
        goalProvider.updateGoal(updated);
      } else {
        goalProvider.addGoal(
          title: title,
          description: desc,
          targetAmount: amount,
          targetDate: _selectedDate,
          category: _selectedCategory,
          iconKey: _selectedIconKey,
          colorValue: _selectedColor,
          manualSavedAmount: initialAmount,
        );
      }

      Navigator.pop(context);
    }
  }
}
