import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'goals/goals_screen.dart';
import 'portfolio/portfolio_screen.dart';
import 'simulator/simulator_screen.dart';
import 'market/market_rates_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(onNavigateTab: _onTabSelected),
      const GoalsScreen(),
      const PortfolioScreen(),
      const SimulatorScreen(),
      const MarketRatesScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Özet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined),
            activeIcon: Icon(Icons.flag_rounded),
            label: 'Hedefler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Portföy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate_outlined),
            activeIcon: Icon(Icons.calculate_rounded),
            label: 'Simülatör',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.candlestick_chart_outlined),
            activeIcon: Icon(Icons.candlestick_chart_rounded),
            label: 'Piyasalar',
          ),
        ],
      ),
    );
  }
}
