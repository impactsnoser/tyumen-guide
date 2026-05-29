import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../state/app_colors.dart';
import '../state/providers.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageDecoration = PageDecoration(
      pageColor: AppColors.surface,
      titleTextStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
      bodyTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
            height: 1.35,
            color: AppColors.muted,
          ),
      imagePadding: const EdgeInsets.only(top: 12),
      contentMargin: const EdgeInsets.symmetric(horizontal: 22),
    );

    return IntroductionScreen(
      globalBackgroundColor: AppColors.surface,
      pages: [
        PageViewModel(
          title: 'Офлайн‑гид',
          body:
              'Все места и маршруты уже внутри приложения. Нужен интернет только для загрузки тайлов карты.',
          image: _HeroIcon(icon: Icons.offline_bolt_outlined),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: 'Маршруты',
          body:
              'Запускайте экскурсии: карта автоматически покажет путь по дорогам и сфокусируется на первой точке.',
          image: _HeroIcon(icon: Icons.route_outlined),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: 'Карта с подсказками',
          body:
              'Нажмите на метку, чтобы сразу увидеть название и мини‑историю прямо на карте.',
          image: _HeroIcon(icon: Icons.map_outlined),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: 'Геопозиция',
          body:
              'Разрешите доступ к геопозиции — так мы покажем вашу точку на карте и сортировку “ближе ко мне”.',
          image: _HeroIcon(icon: Icons.my_location_outlined),
          decoration: pageDecoration,
          footer: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: FilledButton.icon(
              onPressed: () async {
                final enabled = await Geolocator.isLocationServiceEnabled();
                if (!enabled) return;
                var p = await Geolocator.checkPermission();
                if (p == LocationPermission.denied) {
                  p = await Geolocator.requestPermission();
                }
              },
              icon: const Icon(Icons.location_on_outlined),
              label: const Text('Разрешить геопозицию'),
            ),
          ),
        ),
      ],
      done: const Text('Начать', style: TextStyle(fontWeight: FontWeight.w800)),
      onDone: () async {
        await ref.read(onboardingSeenProvider.notifier).setSeen();
      },
      next: const Text('Далее', style: TextStyle(fontWeight: FontWeight.w800)),
      skip: const Text('Пропустить', style: TextStyle(fontWeight: FontWeight.w800)),
      showSkipButton: true,
      dotsDecorator: DotsDecorator(
        activeColor: AppColors.ink,
        color: AppColors.ink.withValues(alpha: 0.16),
        size: const Size(8, 8),
        activeSize: const Size(18, 8),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      nextFlex: 0,
      skipOrBackFlex: 0,
      controlsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      controlsMargin: const EdgeInsets.all(0),
      baseBtnStyle: TextButton.styleFrom(foregroundColor: AppColors.ink),
    );
  }
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 112,
        height: 112,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 36,
              offset: const Offset(0, 18),
            ),
          ],
          border: Border.all(color: AppColors.outline),
        ),
        child: Icon(icon, size: 52, color: AppColors.ink),
      ),
    );
  }
}

