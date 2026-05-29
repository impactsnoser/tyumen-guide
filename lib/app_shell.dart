import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/routes_screen.dart';
import 'state/app_colors.dart';
import 'state/providers.dart';
import 'widgets/aurora_background.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(selectedTabProvider);

    final pages = const [
      HomeScreen(),
      MapScreen(),
      RoutesScreen(),
    ];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Максимальная плавность: полностью статичный фон (без анимаций/blur/шума).
          // AuroraBackground красивый, но его CustomPaint обновляется каждый кадр и может
          // давать микрофризы на слабых телефонах и при 90Гц.
          const DecoratedBox(
            decoration: BoxDecoration(color: AppColors.bg),
          ),
          IndexedStack(index: tab, children: pages),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        indicatorColor: AppColors.accent.withValues(alpha: 0.20),
        onDestinationSelected: (i) => ref.read(selectedTabProvider.notifier).state = i,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Обзор'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Карта'),
          NavigationDestination(icon: Icon(Icons.route_outlined), label: 'Маршруты'),
        ],
      ),
    );
  }
}

