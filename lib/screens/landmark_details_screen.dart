import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../models/category.dart';
import '../state/app_colors.dart';
import '../state/providers.dart';
import '../widgets/app_card.dart';

class LandmarkDetailsScreen extends ConsumerWidget {
  const LandmarkDetailsScreen({super.key, required this.landmarkId});

  final String landmarkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byId = ref.watch(landmarksByIdProvider);
    final landmark = byId[landmarkId];

    if (landmark == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали')),
        body: const Center(child: Text('Место не найдено')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(landmark.name),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _HeroMedia(landmarkId: landmark.id),
          const SizedBox(height: 12),
          AppCard(
            onTap: null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  landmark.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.3,
                        color: AppColors.ink,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Категория: ${landmark.category.labelRu}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            onTap: null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'История',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  landmark.history,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.35,
                        color: AppColors.ink,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              ref.read(selectedRouteIdProvider.notifier).state = null;
              ref.read(selectedTabProvider.notifier).state = 1;
              ref.read(mapCommandProvider.notifier).state = MapCommand(
                center: LatLng(
                  landmark.coordinates.latitude,
                  landmark.coordinates.longitude,
                ),
                zoom: 16,
              );
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.map_outlined),
            label: const Text('Показать на карте'),
          ),
        ],
      ),
    );
  }
}

class _HeroMedia extends ConsumerWidget {
  const _HeroMedia({required this.landmarkId});

  final String landmarkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(landmarksByIdProvider)[landmarkId];
    final asset = l?.imageAsset;
    final tint = (l?.category == null)
        ? AppColors.primary
        : (l!.category == LandmarkCategory.food
            ? AppColors.accent
            : (l.category == LandmarkCategory.park ? AppColors.secondary : AppColors.primary));

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 200,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    tint.withValues(alpha: 0.26),
                    AppColors.surface.withValues(alpha: 0.35),
                    AppColors.surface2.withValues(alpha: 0.55),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: asset == null
                  ? const SizedBox.shrink()
                  : Image.asset(
                      asset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.45),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Icon(
                      l?.category == LandmarkCategory.food
                          ? Icons.restaurant_rounded
                          : (l?.category == LandmarkCategory.park
                              ? Icons.park_rounded
                              : Icons.museum_rounded),
                      color: tint,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l?.name ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                            letterSpacing: -0.25,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

