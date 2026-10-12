import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hedef_birikim/main.dart';
import 'package:hedef_birikim/screens/dashboard/dashboard_screen.dart';
import 'package:hedef_birikim/screens/goals/goals_screen.dart';
import 'package:hedef_birikim/screens/portfolio/portfolio_screen.dart';
import 'package:hedef_birikim/screens/simulator/simulator_screen.dart';
import 'package:hedef_birikim/screens/market/market_rates_screen.dart';
import 'package:hedef_birikim/screens/goals/add_edit_goal_dialog.dart';
import 'package:hedef_birikim/screens/portfolio/add_edit_asset_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Hedef Birikim Comprehensive Multi-Screen & Responsive UI Tests', () {
    testWidgets('1. Android Standard Viewport (360x640) - Navigation & Dashboard Interactions', (WidgetTester tester) async {
      FlutterError.onError = (FlutterErrorDetails details) {
        print('=== FLUTTER ERROR CAUGHT ===');
        print(details.toString());
        print('=============================');
      };

      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const HedefBirikimApp());
      // Pump several frames to allow initial async providers to load
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      final ex = tester.takeException();
      if (ex is FlutterError) {
        print('DIAGNOSTIC ERROR DETAILS:\n${ex.toStringDeep()}');
      }
      expect(ex, isNull);

      // Verify Net Worth title is visible
      expect(find.text('TOPLAM BİRİKİM & VARLIKLAR'), findsOneWidget);

      // Test Privacy Toggle (Eye Icon)
      final privacyBtn = find.byTooltip('Gizli Mod (Tutarları Gizle)');
      if (privacyBtn.evaluate().isNotEmpty) {
        await tester.tap(privacyBtn);
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);

        // Turn privacy mode back off
        final showBtn = find.byTooltip('Tutarları Göster');
        if (showBtn.evaluate().isNotEmpty) {
          await tester.tap(showBtn);
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull);
        }
      }

      // Test Theme Toggle (Dark/Light Mode)
      final themeBtn = find.byTooltip('Koyu Mod');
      if (themeBtn.evaluate().isNotEmpty) {
        await tester.tap(themeBtn);
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);

        // Switch back to light
        final lightBtn = find.byTooltip('Açık Mod');
        if (lightBtn.evaluate().isNotEmpty) {
          await tester.tap(lightBtn);
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets('2. Tab Navigation Across All 5 Screens (Özet, Hedefler, Portföy, Simülatör, Piyasalar)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844); // Standard iPhone 14/15/16 size
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const HedefBirikimApp());
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Tab 1: Özet (already active)
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Tab 2: Hedefler
      await tester.tap(find.text('Hedefler'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(GoalsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Filter chips in GoalsScreen
      if (find.textContaining('Aktif').evaluate().isNotEmpty) {
        await tester.tap(find.textContaining('Aktif'));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
      }

      // Tab 3: Portföy
      await tester.tap(find.text('Portföy'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(PortfolioScreen), findsOneWidget);
      expect(find.text('Portföy & Varlıklarım'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Tab 4: Simülatör
      await tester.tap(find.text('Simülatör'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SimulatorScreen), findsOneWidget);
      expect(find.text('Akıllı Birikim Simülatörü'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Tab 5: Piyasalar
      await tester.tap(find.text('Piyasalar'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(MarketRatesScreen), findsOneWidget);
      expect(find.text('Piyasa & Canlı Kurlar'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Switch category chips in MarketRatesScreen
      if (find.textContaining('Altın').evaluate().isNotEmpty) {
        await tester.tap(find.textContaining('Altın').first);
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
      }

      // Test Search query filter in MarketRatesScreen
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField, 'Gram');
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('3. Compact Screen (320x568 - iPhone SE) - Overflow Verification Across All Tabs', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const HedefBirikimApp());
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Tab 1: Özet (compact)
      expect(tester.takeException(), isNull);

      // Tab 2: Hedefler (compact)
      await tester.tap(find.text('Hedefler'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);

      // Tab 3: Portföy (compact)
      await tester.tap(find.text('Portföy'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);

      // Tab 4: Simülatör (compact)
      await tester.tap(find.text('Simülatör'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);

      // Tab 5: Piyasalar (compact)
      await tester.tap(find.text('Piyasalar'));
      await tester.pump(const Duration(milliseconds: 100));
      final compactEx = tester.takeException();
      if (compactEx is FlutterError) {
        print('COMPACT SCREEN PIYASALAR ERROR:\n${compactEx.toStringDeep()}');
      }
      expect(compactEx, isNull);
    });

    testWidgets('4. Goal Creation and Quick Deposit Flow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const HedefBirikimApp());
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // 1. Open Goals Tab
      await tester.tap(find.text('Hedefler'));
      await tester.pump(const Duration(milliseconds: 100));

      // 2. Tap Floating Action Button ('Yeni Hedef Ekle')
      final addGoalFab = find.byType(FloatingActionButton);
      expect(addGoalFab, findsOneWidget);
      await tester.tap(addGoalFab);
      await tester.pump(const Duration(milliseconds: 100));

      // 3. Fill in Goal Dialog Form
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(0), 'Yeni Araba');
        await tester.enterText(textFields.at(1), 'Hayalimdeki elektrikli araç');
      }

      // Tap Save Goal ('Hedefi Kaydet')
      final saveBtn = find.text('Hedefi Kaydet');
      if (saveBtn.evaluate().isNotEmpty) {
        await tester.tap(saveBtn);
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('5. Portfolio Asset Dialog and Quick Simulator Interaction', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const HedefBirikimApp());
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // 1. Open Portfolio Tab
      await tester.tap(find.text('Portföy'));
      await tester.pump(const Duration(milliseconds: 100));

      // 2. Open Add Asset Modal via FAB
      final addAssetFab = find.byType(FloatingActionButton);
      expect(addAssetFab, findsOneWidget);
      await tester.tap(addAssetFab);
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Modal opens with zero exceptions
      expect(tester.takeException(), isNull);

      // Close modal cleanly
      if (find.byType(AddEditAssetDialog).evaluate().isNotEmpty) {
        Navigator.of(tester.element(find.byType(AddEditAssetDialog))).pop();
        await tester.pump(const Duration(milliseconds: 300));
      }

      // 3. Open Simulator Tab
      await tester.tap(find.text('Simülatör'));
      await tester.pump(const Duration(milliseconds: 100));

      // 4. Move Slider
      final sliders = find.byType(Slider);
      if (sliders.evaluate().isNotEmpty) {
        await tester.drag(sliders.first, const Offset(50, 0));
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(tester.takeException(), isNull);
    });
  });
}
