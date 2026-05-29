import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/category.dart';
import '../state/app_colors.dart';
import '../state/map_filters.dart';
import '../state/providers.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with TickerProviderStateMixin {
  late final AnimatedMapController _mapController = AnimatedMapController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
    curve: Curves.easeInOutCubic,
  );

  static const _tyumenCenter = LatLng(57.1530, 65.5343);

  // Важно: провайдер тайлов должен быть создан 1 раз, не в build.
  final TileProvider _tileProvider = FMTCTileProvider(
    stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
  );

  ProviderSubscription<MapCommand?>? _mapCommandSub;
  ProviderSubscription<String?>? _selectedRouteSub;

  @override
  void initState() {
    super.initState();

    _mapCommandSub = ref.listenManual<MapCommand?>(
      mapCommandProvider,
      (prev, next) {
        if (next == null) return;
        // Анимацию карты лучше триггерить вне build, чтобы не плодить подписки на rebuild.
        _mapController.animateTo(dest: next.center, zoom: next.zoom);
        ref.read(mapCommandProvider.notifier).state = null;
      },
    );

    _selectedRouteSub = ref.listenManual<String?>(
      selectedRouteIdProvider,
      (prev, next) {
        if (next == null) return;
        ref.read(currentStopIndexProvider.notifier).state = 0;
        final route = ref.read(selectedRouteProvider);
        final byId = ref.read(landmarksByIdProvider);
        final first =
            route?.stopIds.isNotEmpty == true ? byId[route!.stopIds.first] : null;
        if (first == null) return;
        _mapController.animateTo(dest: first.coordinates, zoom: 15.5);
      },
    );
  }

  @override
  void dispose() {
    _mapCommandSub?.close();
    _selectedRouteSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final route = ref.watch(selectedRouteProvider);
    final stopIndex = ref.watch(currentStopIndexProvider);
    final currentStop = ref.watch(currentStopLandmarkProvider);

    final showCulture = ref.watch(mapShowCultureProvider);
    final showParks = ref.watch(mapShowParksProvider);
    final showFood = ref.watch(mapShowFoodProvider);
    final favoritesOnly = ref.watch(mapFavoritesOnlyProvider);

    final polylinePoints = ref.watch(routePolylinePointsProvider);
    final routeMetrics = ref.watch(routeMetricsProvider);

    // Вычисления фильтрации/избранного вынесены в провайдер, чтобы не делать это
    // при каждом rebuild карты (например, из-за позиции пользователя).
    final visible = ref.watch(visibleLandmarksProvider);

    final landmarkMarkers = <Marker>[
      for (final l in visible)
        Marker(
          point: l.coordinates,
          width: 46,
          height: 46,
          child: RepaintBoundary(
            child: GestureDetector(
              onTap: () => _showLandmarkSheet(context, l.id),
              child: _PlaceMarker(
                selected: route?.stopIds.contains(l.id) == true &&
                    currentStop?.id == l.id,
                color: l.category == LandmarkCategory.food
                    ? AppColors.markerFood
                    : AppColors.markerLandmark,
                icon: l.category == LandmarkCategory.food
                    ? Icons.restaurant_rounded
                    : Icons.place_rounded,
              ),
            ),
          ),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Карта'),
        actions: [
          IconButton(
            tooltip: 'Моё местоположение',
            onPressed: () {
              final p = ref.read(userPositionProvider).valueOrNull;
              if (p == null) return;
              _mapController.animateTo(
                dest: LatLng(p.latitude, p.longitude),
                zoom: 16,
              );
            },
            icon: const Icon(Icons.my_location_outlined),
          ),
          IconButton(
            tooltip: 'Сбросить маршрут',
            onPressed: route == null
                ? null
                : () => ref.read(selectedRouteIdProvider.notifier).state = null,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController.mapController,
            options: const MapOptions(
              initialCenter: _tyumenCenter,
              initialZoom: 13.2,
            ),
            children: [
              // Важно для скорости и стабильности:
              // - НЕ используем tileBuilder (он оборачивает каждый тайл и может тормозить)
              // - используем {s} сабдомены OSM для параллельной загрузки
              // - используем cancellable tile provider, чтобы запросы не "висли"
              ColorFiltered(
                colorFilter: const ColorFilter.matrix(<double>[
                  // Luma grayscale + затемнение + легкий холодный тинт
                  0.12, 0.12, 0.12, 0, 0,
                  0.13, 0.13, 0.13, 0, 6,
                  0.18, 0.18, 0.18, 0, 18,
                  0, 0, 0, 1, 0,
                ]),
                child: TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'tyumen_guide',
                  tileProvider: _tileProvider,
                ),
              ),
              if (polylinePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    // Soft shadow underneath
                    Polyline(
                      points: polylinePoints,
                      color: Colors.black.withValues(alpha: 0.35),
                      strokeWidth: 10,
                    ),
                    // “Aurora” highlight (fake gradient using segments)
                    ..._routeGradientPolylines(polylinePoints),
                  ],
                ),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  markers: landmarkMarkers,
                  maxClusterRadius: 42,
                  size: const Size(44, 44),
                  spiderfyCluster: true,
                  builder: (context, clusterMarkers) {
                    return _ClusterBadge(count: clusterMarkers.length);
                  },
                ),
              ),
              const _UserPositionLayer(),
              // Немного «уникальности»: лёгкая подложка-градиент поверх карты.
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.12),
                        Colors.transparent,
                        AppColors.secondary.withValues(alpha: 0.10),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Vignette for readability + cinematic look.
          IgnorePointer(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.05),
                  radius: 1.08,
                  colors: [
                    Colors.transparent,
                    Color(0xAA000000),
                  ],
                  stops: [0.60, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: SafeArea(
              bottom: false,
              child: _MapFiltersBar(
                showCulture: showCulture,
                showParks: showParks,
                showFood: showFood,
                favoritesOnly: favoritesOnly,
                onToggleCulture: () => ref
                    .read(mapShowCultureProvider.notifier)
                    .state = !showCulture,
                onToggleParks: () =>
                    ref.read(mapShowParksProvider.notifier).state = !showParks,
                onToggleFood: () =>
                    ref.read(mapShowFoodProvider.notifier).state = !showFood,
                onToggleFavorites: () => ref
                    .read(mapFavoritesOnlyProvider.notifier)
                    .state = !favoritesOnly,
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: SafeArea(
              top: false,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeOutCubic,
                transitionBuilder: (child, anim) {
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.08),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                      ),
                      child: child,
                    ),
                  );
                },
                child: route == null
                    ? const SizedBox.shrink()
                    : _ActiveRoutePanel(
                        key: ValueKey(route.id),
                        title: route.title,
                        subtitle: currentStop?.name ?? 'Остановка ${stopIndex + 1}',
                        progressText: '${stopIndex + 1} / ${route.stopIds.length}',
                        metaText: routeMetrics == null
                            ? null
                            : '${routeMetrics.kmText} • ${routeMetrics.minutesText} пешком',
                        onPrev: stopIndex > 0
                            ? () {
                                ref.read(currentStopIndexProvider.notifier).state =
                                    (stopIndex - 1)
                                        .clamp(0, route.stopIds.length - 1);
                                final l = ref.read(currentStopLandmarkProvider);
                                if (l != null) {
                                  ref.read(mapCommandProvider.notifier).state =
                                      MapCommand(center: l.coordinates, zoom: 16.2);
                                }
                              }
                            : null,
                        onNext: stopIndex < route.stopIds.length - 1
                            ? () {
                                ref.read(currentStopIndexProvider.notifier).state =
                                    (stopIndex + 1)
                                        .clamp(0, route.stopIds.length - 1);
                                final l = ref.read(currentStopLandmarkProvider);
                                if (l != null) {
                                  ref.read(mapCommandProvider.notifier).state =
                                      MapCommand(center: l.coordinates, zoom: 16.2);
                                }
                              }
                            : null,
                        onStop: () =>
                            ref.read(selectedRouteIdProvider.notifier).state = null,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLandmarkSheet(BuildContext context, String landmarkId) {
    final byId = ref.read(landmarksByIdProvider);
    final l = byId[landmarkId];
    if (l == null) return;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: AppColors.outline),
                gradient: LinearGradient(
                  colors: [
                    AppColors.surface.withValues(alpha: 0.96),
                    AppColors.surface2.withValues(alpha: 0.92),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.55),
                    blurRadius: 40,
                    offset: const Offset(0, 22),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                child: DefaultTextStyle(
                  style: Theme.of(ctx).textTheme.bodyMedium!.copyWith(
                        color: AppColors.ink,
                      ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: const [
                            _MiniTag(icon: Icons.history_edu_outlined, text: 'История', tint: AppColors.primary),
                            SizedBox(width: 8),
                            _MiniTag(icon: Icons.photo_camera_outlined, text: 'Фото‑точка', tint: AppColors.secondary),
                            SizedBox(width: 8),
                            _MiniTag(icon: Icons.directions_walk_outlined, text: 'Пешком', tint: AppColors.accent),
                            SizedBox(width: 8),
                            _MiniTag(icon: Icons.star_border_rounded, text: 'Топ', tint: Colors.white),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l.name,
                        style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink,
                              letterSpacing: -0.2,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l.history,
                        maxLines: 7,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                              color: AppColors.muted,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                ref.read(mapCommandProvider.notifier).state =
                                    MapCommand(center: l.coordinates, zoom: 16.2);
                                Navigator.of(ctx).pop();
                              },
                              icon: const Icon(Icons.center_focus_strong_outlined),
                              label: const Text('К точке'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ref.read(selectedRouteIdProvider.notifier).state = null;
                                ref.read(selectedTabProvider.notifier).state = 0;
                                Navigator.of(ctx).pop();
                              },
                              icon: const Icon(Icons.open_in_new_outlined),
                              label: const Text('В списке'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UserPositionLayer extends ConsumerWidget {
  const _UserPositionLayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posAsync = ref.watch(userPositionProvider);
    final userLatLng = posAsync.when<LatLng?>(
      data: (Position? p) => p == null ? null : LatLng(p.latitude, p.longitude),
      loading: () => null,
      error: (_, __) => null,
    );

    if (userLatLng == null) return const SizedBox.shrink();

    return MarkerLayer(
      markers: [
        Marker(
          point: userLatLng,
          width: 42,
          height: 42,
          child: const RepaintBoundary(child: _UserMarker()),
        ),
      ],
    );
  }
}

class _ClusterBadge extends StatelessWidget {
  const _ClusterBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$count',
          style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _MapFiltersBar extends StatelessWidget {
  const _MapFiltersBar({
    required this.showCulture,
    required this.showParks,
    required this.showFood,
    required this.favoritesOnly,
    required this.onToggleCulture,
    required this.onToggleParks,
    required this.onToggleFood,
    required this.onToggleFavorites,
  });

  final bool showCulture;
  final bool showParks;
  final bool showFood;
  final bool favoritesOnly;
  final VoidCallback onToggleCulture;
  final VoidCallback onToggleParks;
  final VoidCallback onToggleFood;
  final VoidCallback onToggleFavorites;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'Культура',
            selected: showCulture,
            onTap: onToggleCulture,
            color: AppColors.primary,
            icon: Icons.museum_outlined,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Парки',
            selected: showParks,
            onTap: onToggleParks,
            color: AppColors.secondary,
            icon: Icons.park_outlined,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Еда',
            selected: showFood,
            onTap: onToggleFood,
            color: AppColors.accent,
            icon: Icons.restaurant_outlined,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Избранное',
            selected: favoritesOnly,
            onTap: onToggleFavorites,
            color: Colors.white,
            icon: Icons.favorite_border_rounded,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
    required this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface.withValues(alpha: 0.70);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.22) : bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? color : AppColors.muted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: selected ? AppColors.ink : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.icon, required this.text, required this.tint});

  final IconData icon;
  final String text;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tint),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

class _PlaceMarker extends StatelessWidget {
  const _PlaceMarker({
    required this.color,
    required this.icon,
    this.selected = false,
  });

  final Color color;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    // Критично для FPS: НЕ анимируем все маркеры всегда.
    // Анимация включается только у выбранного (selected=true).
    final markerBody = Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.outline,
            width: selected ? 2 : 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (selected) const Positioned.fill(child: _Pulse()),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (selected ? AppColors.accent : color).withValues(alpha: 0.24),
                    AppColors.surface.withValues(alpha: 0.10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            Icon(icon, color: selected ? AppColors.accent : color, size: 22),
            Positioned(
              bottom: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color:
                        (selected ? AppColors.ink : color).withValues(alpha: 0.9),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

    if (!selected) return markerBody;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      builder: (context, v, child) {
        final dy = lerpDouble(0, -5.5, v)!;
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(
            scale: lerpDouble(1.0, 1.05, v)!,
            child: child,
          ),
        );
      },
      child: markerBody,
    );
  }
}

List<Polyline> _routeGradientPolylines(List<LatLng> pts) {
  if (pts.length < 2) return const <Polyline>[];
  const seg = 14; // keep it cheap
  final step = (pts.length / seg).clamp(2, pts.length).floor();
  final polylines = <Polyline>[];

  Color mix(Color a, Color b, double t) {
    return Color.lerp(a, b, t)!;
  }

  final start = AppColors.secondary.withValues(alpha: 0.78);
  final mid = AppColors.primary.withValues(alpha: 0.86);
  final end = AppColors.accent.withValues(alpha: 0.86);

  var i = 0;
  var k = 0;
  while (i < pts.length - 1) {
    final j = (i + step).clamp(i + 1, pts.length - 1);
    final t = (k / (seg - 1)).clamp(0.0, 1.0);
    final c = t < 0.5 ? mix(start, mid, t * 2) : mix(mid, end, (t - 0.5) * 2);
    polylines.add(
      Polyline(
        points: pts.sublist(i, j + 1),
        color: c,
        strokeWidth: 6,
      ),
    );
    i = j;
    k++;
  }
  return polylines;
}

class _Pulse extends StatefulWidget {
  const _Pulse();

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        final scale = 0.90 + t * 0.50;
        final opacity = (1 - t).clamp(0.0, 1.0) * 0.18;
        return Center(
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: opacity),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActiveRoutePanel extends StatelessWidget {
  const _ActiveRoutePanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progressText,
    this.metaText,
    required this.onPrev,
    required this.onNext,
    required this.onStop,
  });

  final String title;
  final String subtitle;
  final String progressText;
  final String? metaText;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
          ],
          border: Border.all(color: AppColors.outline),
          gradient: LinearGradient(
            colors: [
              AppColors.card,
              AppColors.card2,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                        ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Text(
                    progressText,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Сбросить маршрут',
                  onPressed: onStop,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
            if (metaText != null) ...[
              const SizedBox(height: 4),
              Text(
                metaText!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.muted.withValues(alpha: 0.90),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPrev,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      side: BorderSide(color: AppColors.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    icon: const Icon(Icons.chevron_left_rounded),
                    label: const Text('Назад'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onNext,
                    icon: const Icon(Icons.chevron_right_rounded),
                    label: const Text('Далее'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UserMarker extends StatelessWidget {
  const _UserMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.markerUser,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 3),
      ),
      child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 20),
    );
  }
}

