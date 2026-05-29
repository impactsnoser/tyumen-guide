import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_colors.dart';
import '../state/providers.dart';
import '../widgets/app_card.dart';

class RoutesScreen extends ConsumerWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(routesProvider);
    final selectedId = ref.watch(selectedRouteIdProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Маршруты'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final r = items[index];
          final isSelected = selectedId == r.id;
          return AppCard(
            onTap: null,
            tint: AppColors.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        r.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: const Text(
                          'Активен',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  r.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                        height: 1.25,
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Chip(text: '${r.stopIds.length} остановок', icon: Icons.pin_drop_outlined),
                    _Chip(text: 'Polyline', icon: Icons.polyline_outlined),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    ref.read(selectedRouteIdProvider.notifier).state = r.id;
                    ref.read(currentStopIndexProvider.notifier).state = 0;
                    ref.read(selectedTabProvider.notifier).state = 1;
                    // MapScreen сам отцентрируется на первой точке маршрута.
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Запустить маршрут'),
                ),
                if (isSelected) ...[
                  const SizedBox(height: 12),
                  _ProgressControls(routeId: r.id),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProgressControls extends ConsumerWidget {
  const _ProgressControls({required this.routeId});

  final String routeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(selectedRouteProvider);
    if (route == null || route.id != routeId) return const SizedBox.shrink();

    final index = ref.watch(currentStopIndexProvider);
    final total = route.stopIds.length;
    final current = ref.watch(currentStopLandmarkProvider);

    final canPrev = index > 0;
    final canNext = index < total - 1;

    return AppCard(
      onTap: null,
      tint: AppColors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Остановка ${index + 1} / $total',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            current?.name ?? '—',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: canPrev
                      ? () {
                          ref.read(currentStopIndexProvider.notifier).state =
                              (index - 1).clamp(0, total - 1);
                          final l = ref.read(currentStopLandmarkProvider);
                          if (l != null) {
                            ref.read(mapCommandProvider.notifier).state =
                                MapCommand(center: l.coordinates, zoom: 16);
                          }
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    side: BorderSide(color: AppColors.outline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  icon: const Icon(Icons.chevron_left_rounded),
                  label: const Text('Назад'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: canNext
                      ? () {
                          ref.read(currentStopIndexProvider.notifier).state =
                              (index + 1).clamp(0, total - 1);
                          final l = ref.read(currentStopLandmarkProvider);
                          if (l != null) {
                            ref.read(mapCommandProvider.notifier).state =
                                MapCommand(center: l.coordinates, zoom: 16);
                          }
                        }
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                  label: const Text('Далее'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.muted),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

