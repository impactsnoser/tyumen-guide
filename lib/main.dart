import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_shell.dart';
import 'screens/onboarding_screen.dart';
import 'state/app_colors.dart';
import 'state/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tile cache init: делает карту заметно стабильнее и быстрее на повторных открытиях.
  // Если по какой-то причине backend не поднялся — приложение всё равно стартует.
  try {
    await FMTCObjectBoxBackend().initialise();
    await FMTCStore('mapStore').manage.create();
  } catch (_) {
    // ignore
  }

  runApp(const ProviderScope(child: DubleVudApp()));
}

class DubleVudApp extends StatelessWidget {
  const DubleVudApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
      ),
    );

    return MaterialApp(
      title: 'ДубльВуд',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: AppColors.bg,
        splashFactory: InkSparkle.splashFactory,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.ink,
          elevation: 0,
          centerTitle: false,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.ink,
          size: 22,
          opticalSize: 24,
          weight: 700,
        ),
        dividerColor: AppColors.outline,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface.withValues(alpha: 0.70),
          hintStyle: const TextStyle(
            color: AppColors.muted,
            fontWeight: FontWeight.w700,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.70)),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surface.withValues(alpha: 0.92),
          indicatorColor: AppColors.primary.withValues(alpha: 0.22),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
          ),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? AppColors.ink : AppColors.muted,
            );
          }),
        ),
        textTheme: GoogleFonts.montserratTextTheme(base.textTheme).copyWith(
          displayLarge: base.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.9,
            height: 1.05,
          ),
          displayMedium: base.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
            height: 1.08,
          ),
          headlineSmall: base.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            height: 1.12,
          ),
          titleLarge: base.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.25,
          ),
          titleMedium: base.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.15,
          ),
          bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.35),
          bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.35),
          bodySmall: base.textTheme.bodySmall?.copyWith(
            height: 1.30,
            color: AppColors.muted,
            fontWeight: FontWeight.w700,
          ),
        ).apply(
          bodyColor: AppColors.ink,
          displayColor: AppColors.ink,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: const Color(0xFF0B1020),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.ink,
            side: BorderSide(color: AppColors.outline),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surface.withValues(alpha: 0.65),
          selectedColor: AppColors.primary.withValues(alpha: 0.22),
          labelStyle: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w900,
          ),
          secondaryLabelStyle: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w900,
          ),
          side: BorderSide(color: AppColors.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      ),
      home: const _RootGate(),
    );
  }
}

class _RootGate extends ConsumerWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seen = ref.watch(onboardingSeenProvider);
    return seen.when(
      data: (v) => v ? const AppShell() : const OnboardingScreen(),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const AppShell(),
    );
  }
}
