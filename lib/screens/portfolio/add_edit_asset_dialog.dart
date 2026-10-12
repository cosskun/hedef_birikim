import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/asset_model.dart';
import '../../models/goal_model.dart';
import '../../models/market_rate_model.dart';
import '../../providers/portfolio_provider.dart';
import '../../providers/goal_provider.dart';

class AddEditAssetDialog extends StatefulWidget {
  final AssetModel? assetToEdit;
  final String? preselectedGoalId;

  const AddEditAssetDialog({super.key, this.assetToEdit, this.preselectedGoalId});

  @override
  State<AddEditAssetDialog> createState() => _AddEditAssetDialogState();
}

class _AddEditAssetDialogState extends State<AddEditAssetDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _symbolController;
  late TextEditingController _amountController;
  late TextEditingController _unitController;
  late TextEditingController _buyPriceController;
  late TextEditingController _noteController;

  late AssetCategory _selectedCategory;
  String? _selectedGoalId;

  final List<String> _cashNameSuggestions = [
    'Nakit Para / Cüzdan',
    'Vadeli Mevduat Hesabı',
    'Vadesiz Banka Hesabı',
    'Kasa / Acil Durum Fonu',
    'Döviz / Altın Bozumu Nakdi',
  ];

  final ScrollController _presetScrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final edit = widget.assetToEdit;
    _selectedCategory = edit?.category ?? AssetCategory.cash;
    _selectedGoalId = edit?.linkedGoalId ?? widget.preselectedGoalId;

    _nameController = TextEditingController(
      text: edit?.name ?? (_selectedCategory == AssetCategory.cash ? 'Nakit / TL Mevduat' : ''),
    );
    _symbolController = TextEditingController(text: edit?.symbol ?? (_selectedCategory == AssetCategory.cash ? 'TRY' : ''));
    
    if (edit != null) {
      if (edit.category == AssetCategory.cash) {
        _amountController = TextEditingController(text: CurrencyFormatter.formatThousands(edit.amount));
      } else {
        _amountController = TextEditingController(text: edit.amount.toString());
      }
    } else {
      _amountController = TextEditingController();
    }

    _unitController = TextEditingController(text: edit?.unit ?? (_selectedCategory == AssetCategory.cash ? '₺' : 'adet'));
    _buyPriceController = TextEditingController(text: edit != null ? edit.buyPrice.toString() : '1.0');
    _noteController = TextEditingController(text: edit?.note ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _amountController.dispose();
    _unitController.dispose();
    _buyPriceController.dispose();
    _noteController.dispose();
    _presetScrollController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _applyMarketRate(MarketRateModel rate) {
    setState(() {
      _nameController.text = rate.name;
      _symbolController.text = rate.symbol;
      _selectedCategory = rate.category;
      _unitController.text = rate.unit;

      if (_selectedCategory == AssetCategory.cash) {
        _buyPriceController.text = '1.0';
      } else {
        _buyPriceController.text = rate.buyPrice.toString();
      }
    });
  }

  void _openInstrumentSearchModal(BuildContext context, PortfolioProvider portfolio, bool isDark) {
    final searchCtrl = TextEditingController();
    List<MarketRateModel> results = List.from(portfolio.marketRates);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Piyasadan Varlık Seç', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Hisse, Döviz, Fon, Kripto veya Altın ara...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onChanged: (val) {
                  final q = val.toLowerCase().trim();
                  setModalState(() {
                    results = portfolio.marketRates.where((r) {
                      return r.name.toLowerCase().contains(q) ||
                          r.symbol.toLowerCase().contains(q) ||
                          r.category.displayName.toLowerCase().contains(q);
                    }).toList();
                  });
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: results.isEmpty
                    ? const Center(child: Text('Eşleşen enstrüman bulunamadı.'))
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, idx) {
                          final rate = results[idx];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                              child: Icon(rate.category.icon, size: 20, color: AppColors.primaryEmerald),
                            ),
                            title: Text(rate.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text('${rate.symbol} • ${rate.category.displayName} • ${rate.unit}', style: const TextStyle(fontSize: 12)),
                            trailing: Text(
                              CurrencyFormatter.format(rate.buyPrice),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryEmerald),
                            ),
                            onTap: () {
                              _applyMarketRate(rate);
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.assetToEdit != null;
    final portfolio = context.watch<PortfolioProvider>();
    final goalProvider = context.watch<GoalProvider>();
    final isCash = _selectedCategory == AssetCategory.cash;

    // Available instruments for currently selected category
    final categoryRates = portfolio.marketRates.where((r) => r.category == _selectedCategory).toList();

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
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        isEditing ? 'Varlığı Düzenle' : (isCash ? '💵 Nakit / TL Ekle' : 'Yeni Varlık / Birikim Ekle'),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Category Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kategori', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (_categoryScrollController.hasClients) {
                            _categoryScrollController.animateTo(
                              (_categoryScrollController.offset - 120).clamp(0.0, _categoryScrollController.position.maxScrollExtent),
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                          child: const Icon(Icons.chevron_left_rounded, size: 16),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () {
                          if (_categoryScrollController.hasClients) {
                            _categoryScrollController.animateTo(
                              (_categoryScrollController.offset + 120).clamp(0.0, _categoryScrollController.position.maxScrollExtent),
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                          child: const Icon(Icons.chevron_right_rounded, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                controller: _categoryScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: AssetCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: Icon(cat.icon, size: 16),
                        label: Text(cat.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = cat;
                              if (cat == AssetCategory.cash) {
                                if (_nameController.text.isEmpty || _nameController.text == 'Gram Altın') {
                                  _nameController.text = 'Nakit / TL Mevduat';
                                }
                                _symbolController.text = 'TRY';
                                _unitController.text = '₺';
                                _buyPriceController.text = '1.0';
                              } else {
                                _symbolController.text = '';
                                _unitController.text = cat.defaultUnit;
                                if (_nameController.text == 'Nakit / TL Mevduat') {
                                  _nameController.text = '';
                                }
                              }
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),

              // Category-Specific Presets / Instruments
              if (!isEditing) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isCash ? 'Hızlı Hesap Türleri' : '${_selectedCategory.displayName} Seçenekleri',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                      icon: const Icon(Icons.search_rounded, size: 14),
                      label: const Text('Tüm Enstrümanlar', style: TextStyle(fontSize: 11)),
                      onPressed: () => _openInstrumentSearchModal(context, portfolio, isDark),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SingleChildScrollView(
                  controller: _presetScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: isCash
                        ? _cashNameSuggestions.map((suggestion) {
                            final isSelected = _nameController.text == suggestion;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ActionChip(
                                label: Text(suggestion, style: const TextStyle(fontSize: 11)),
                                backgroundColor: isSelected ? AppColors.pastelMint.withOpacity(0.2) : null,
                                onPressed: () {
                                  setState(() {
                                    _nameController.text = suggestion;
                                    _symbolController.text = 'TRY';
                                    _unitController.text = '₺';
                                    _buyPriceController.text = '1.0';
                                  });
                                },
                              ),
                            );
                          }).toList()
                        : categoryRates.map((rate) {
                            final isSelected = _symbolController.text == rate.symbol;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ActionChip(
                                avatar: Text(
                                  rate.symbol,
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryEmerald),
                                ),
                                label: Text(
                                  '${rate.name} (${CurrencyFormatter.format(rate.buyPrice)})',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                backgroundColor: isSelected ? AppColors.primaryEmerald.withOpacity(0.2) : null,
                                onPressed: () => _applyMarketRate(rate),
                              ),
                            );
                          }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // DYNAMIC FORM: NAKIT / TL MEVDUAT SPECIAL VIEW vs STANDARD ASSET VIEW
              if (isCash) ...[
                // --- CASH / TL SIMPLIFIED FORM ---
                Text('Hesap / Varlık Adı', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'örn. Nakit Para, Garanti Vadeli, Maaş Hesabı',
                    prefixIcon: Icon(Icons.account_balance_wallet_rounded, color: AppColors.primaryEmerald),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Hesap adı girin' : null,
                ),
                const SizedBox(height: 14),

                // Cash Amount with Thousand Separator
                Text('Nakit / Birikim Tutarı (₺)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    ThousandsSeparatorInputFormatter(),
                  ],
                  decoration: const InputDecoration(
                    hintText: '50.000',
                    prefixIcon: Icon(Icons.attach_money_rounded, color: AppColors.primaryEmerald),
                    suffixText: '₺',
                    suffixStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  validator: (v) {
                    final parsed = CurrencyFormatter.parse(v ?? '');
                    if (parsed <= 0) return 'Geçerli bir TL tutarı girin';
                    return null;
                  },
                ),
              ] else ...[
                // --- STANDARD COMMODITY / FOREX / STOCK / CRYPTO / FUND VIEW ---
                // Name & Symbol Row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Varlık Adı', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(hintText: 'örn. Gram Altın, THYAO, TTE, BTC'),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Ad girin' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sembol', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _symbolController,
                            decoration: const InputDecoration(hintText: 'GA, TTE, USD'),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Sembol' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Amount & Unit Row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Miktar / Adet / Lot', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(hintText: '10.5'),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Miktar girin';
                              final val = double.tryParse(v.replaceAll(',', '.'));
                              if (val == null || val <= 0) return 'Pozitif sayı girin';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Birim', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _unitController,
                            decoration: const InputDecoration(hintText: 'gr, adet, lot'),
                            validator: (v) => v == null || v.isEmpty ? 'Birim' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Buy Price Input
                Text('Birim Alış Maliyeti (₺)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _buyPriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'Satın aldığınız birim fiyat',
                    prefixIcon: Icon(Icons.shopping_cart_checkout_rounded),
                    suffixText: '₺',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Alış fiyatı girin';
                    final val = double.tryParse(v.replaceAll(',', '.'));
                    if (val == null || val <= 0) return 'Geçerli fiyat girin';
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 14),

              // Target Goal Linkage (Optional)
              Text('Bir Hedefe Bağla (Opsiyonel)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String?>(
                value: _selectedGoalId,
                isExpanded: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.flag_rounded),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                hint: const Text('Bağımsız Varlık (Herhangi bir hedefe bağlı değil)'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Bağımsız Varlık (Genel Cüzdan)'),
                  ),
                  ...goalProvider.goals.map((g) => DropdownMenuItem<String?>(
                    value: g.id,
                    child: Row(
                      children: [
                        Icon(GoalModel.getIconFromKey(g.iconKey), size: 16, color: AppColors.primaryEmerald),
                        const SizedBox(width: 8),
                        Expanded(child: Text(g.title, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  )),
                ],
                onChanged: (val) => setState(() => _selectedGoalId = val),
              ),

              const SizedBox(height: 14),

              // Note Field
              Text('Not (Opsiyonel)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'örn. Garanti hesabı, altın sertifikası, TEFAS fonu...',
                ),
              ),

              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveAsset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryEmerald,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    isEditing ? 'Varlığı Güncelle' : (isCash ? 'Nakit Birikimi Ekle 💵' : 'Portföye Ekle 💰'),
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

  void _saveAsset() {
    if (_formKey.currentState!.validate()) {
      final isCash = _selectedCategory == AssetCategory.cash;
      final name = _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : (isCash ? 'Nakit / TL Mevduat' : 'Varlık');
      
      final symbol = isCash
          ? 'TRY'
          : (_symbolController.text.trim().isNotEmpty ? _symbolController.text.trim().toUpperCase() : 'TRY');

      final amount = isCash
          ? CurrencyFormatter.parse(_amountController.text)
          : (double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0);

      final unit = isCash
          ? '₺'
          : (_unitController.text.trim().isNotEmpty ? _unitController.text.trim() : 'adet');

      final buyPrice = isCash
          ? 1.0
          : (double.tryParse(_buyPriceController.text.replaceAll(',', '.')) ?? 1.0);

      final portfolio = context.read<PortfolioProvider>();

      double currentPrice = buyPrice;
      if (isCash) {
        currentPrice = 1.0;
      } else {
        final matchedRate = portfolio.marketRates.where((r) => r.symbol == symbol).firstOrNull;
        if (matchedRate != null && matchedRate.buyPrice > 0) {
          currentPrice = matchedRate.buyPrice;
        }
      }

      final note = _noteController.text.trim();

      if (widget.assetToEdit != null) {
        final updated = widget.assetToEdit!.copyWith(
          name: name,
          symbol: symbol,
          category: _selectedCategory,
          amount: amount,
          unit: unit,
          buyPrice: buyPrice,
          currentPrice: currentPrice,
          linkedGoalId: _selectedGoalId,
          note: note,
          updatedAt: DateTime.now(),
        );
        portfolio.updateAsset(updated);
      } else {
        portfolio.addAsset(
          name: name,
          symbol: symbol,
          category: _selectedCategory,
          amount: amount,
          unit: unit,
          buyPrice: buyPrice,
          currentPrice: currentPrice,
          linkedGoalId: _selectedGoalId,
          note: note,
        );
      }

      Navigator.pop(context);
    }
  }
}
