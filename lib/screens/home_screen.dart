import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import '../models/category.dart';
import '../models/landmark.dart';
import '../state/app_colors.dart';
import '../state/providers.dart';
import '../widgets/app_card.dart';
import '../widgets/appear.dart';
import 'landmark_details_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(landmarksProvider);
    final favoritesAsync = ref.watch(favoritesProvider);
    final positionAsync = ref.watch(userPositionOnceProvider);
    final totalRoutes = ref.watch(routesProvider).length;

    final favorites = favoritesAsync.value ?? const <String>{};
    final userLatLng = positionAsync.valueOrNull == null
        ? null
        : LatLng(
            positionAsync.valueOrNull!.latitude,
            positionAsync.valueOrNull!.longitude,
          );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Tyumen Guide'),
      ),
      body: _HomeBody(
        all: all,
        favorites: favorites,
        userLatLng: userLatLng,
        totalRoutes: totalRoutes,
      ),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody({
    required this.all,
    required this.favorites,
    required this.userLatLng,
    required this.totalRoutes,
  });

  final List<Landmark> all;
  final Set<String> favorites;
  final LatLng? userLatLng;
  final int totalRoutes;

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  String _query = '';
  LandmarkCategory? _category;
  bool _nearMe = false;
  Timer? _debounce;

  late List<Landmark> _filtered = const <Landmark>[];
  late List<Landmark> _favTop = const <Landmark>[];
  String _lastQuery = '';
  LandmarkCategory? _lastCategory;
  bool _lastNearMe = false;
  LatLng? _lastUserLatLng;
  Set<String> _lastFavorites = const <String>{};
  List<Landmark> _lastAll = const <Landmark>[];

  void _recomputeIfNeeded() {
    final q = _query.trim().toLowerCase();
    final needs =
        q != _lastQuery ||
        _category != _lastCategory ||
        _nearMe != _lastNearMe ||
        widget.userLatLng != _lastUserLatLng ||
        !identical(widget.all, _lastAll) ||
        widget.favorites.length != _lastFavorites.length ||
        // быстрый хак: если длина такая же, но элементы поменялись — пересчитаем
        (widget.favorites.length == _lastFavorites.length &&
            !widget.favorites.containsAll(_lastFavorites));

    if (!needs) return;

    _lastQuery = q;
    _lastCategory = _category;
    _lastNearMe = _nearMe;
    _lastUserLatLng = widget.userLatLng;
    _lastFavorites = widget.favorites;
    _lastAll = widget.all;

    final distance = const Distance();

    var filtered = widget.all.where((l) {
      final matchesQuery = q.isEmpty ||
          l.name.toLowerCase().contains(q) ||
          l.description.toLowerCase().contains(q);
      final matchesCategory = _category == null || l.category == _category;
      return matchesQuery && matchesCategory;
    }).toList(growable: false);

    if (_nearMe && widget.userLatLng != null) {
      filtered = [...filtered];
      filtered.sort((a, b) {
        final da = distance(widget.userLatLng!, a.coordinates);
        final db = distance(widget.userLatLng!, b.coordinates);
        return da.compareTo(db);
      });
    }

    _filtered = filtered;
    _favTop = filtered
        .where((l) => widget.favorites.contains(l.id))
        .take(5)
        .toList(growable: false);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String v) {
    // Чтобы главный экран не "дергался" на каждый символ — легкий debounce.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 140), () {
      if (!mounted) return;
      if (v == _query) return;
      setState(() => _query = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    _recomputeIfNeeded();

    return CustomScrollView(
      cacheExtent: 800,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                RepaintBoundary(
                  child: _HeroBanner(
                    totalPlaces: widget.all.length,
                    totalRoutes: widget.totalRoutes,
                    favoritesCount: widget.favorites.length,
                  ),
                ),
                const SizedBox(height: 14),
                _SearchBar(
                  value: _query,
                  onChanged: _onQueryChanged,
                ),
                const SizedBox(height: 10),
                _FiltersRow(
                  selected: _category,
                  nearMe: _nearMe,
                  nearMeEnabled: widget.userLatLng != null,
                  onCategory: (c) => setState(() => _category = c),
                  onNearMe: (v) => setState(() => _nearMe = v),
                ),
                const SizedBox(height: 16),
                _SectionTitle(title: 'Сегодня в Тюмени'),
                const SizedBox(height: 10),
                _TodayPicks(all: widget.all),
                if (_favTop.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _SectionTitle(title: 'Сохранено'),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
        if (_favTop.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final l = _favTop[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LandmarkCard(landmark: l),
                  );
                },
                childCount: _favTop.length,
                addAutomaticKeepAlives: false,
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
          sliver: const SliverToBoxAdapter(
            child: _SectionTitle(title: 'Все места'),
          ),
        ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
          sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final l = _filtered[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _LandmarkCard(landmark: l),
                );
              },
              childCount: _filtered.length,
              addAutomaticKeepAlives: false,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Поиск мест, музеев, парков…',
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted),
      ),
    );
  }
}

class _FiltersRow extends StatelessWidget {
  const _FiltersRow({
    required this.selected,
    required this.nearMe,
    required this.nearMeEnabled,
    required this.onCategory,
    required this.onNearMe,
  });

  final LandmarkCategory? selected;
  final bool nearMe;
  final bool nearMeEnabled;
  final ValueChanged<LandmarkCategory?> onCategory;
  final ValueChanged<bool> onNearMe;

  @override
  Widget build(BuildContext context) {
    Widget chip({
      required String label,
      required bool selected,
      required VoidCallback onTap,
      IconData? icon,
      bool enabled = true,
    }) {
      return InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: enabled ? AppColors.outline : AppColors.outline.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: enabled
                      ? (selected ? AppColors.ink : AppColors.ink)
                      : AppColors.muted,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: enabled
                      ? (selected ? AppColors.ink : AppColors.ink)
                      : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip(
            label: 'Все',
            selected: selected == null,
            onTap: () => onCategory(null),
          ),
          const SizedBox(width: 8),
          chip(
            label: 'Культура',
            selected: selected == LandmarkCategory.culture,
            onTap: () => onCategory(LandmarkCategory.culture),
            icon: Icons.museum_outlined,
          ),
          const SizedBox(width: 8),
          chip(
            label: 'Парк',
            selected: selected == LandmarkCategory.park,
            onTap: () => onCategory(LandmarkCategory.park),
            icon: Icons.park_outlined,
          ),
          const SizedBox(width: 8),
          chip(
            label: 'Еда',
            selected: selected == LandmarkCategory.food,
            onTap: () => onCategory(LandmarkCategory.food),
            icon: Icons.restaurant_outlined,
          ),
          const SizedBox(width: 8),
          chip(
            label: 'Ближе ко мне',
            selected: nearMe,
            enabled: nearMeEnabled,
            onTap: () => onNearMe(!nearMe),
            icon: Icons.near_me_outlined,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
          ),
        ),
      ],
    );
  }
}

class _TodayPicks extends StatelessWidget {
  const _TodayPicks({required this.all});

  final List<Landmark> all;

  List<Landmark> _byIds(List<String> ids) {
    final map = {for (final l in all) l.id: l};
    return [for (final id in ids) if (map[id] != null) map[id]!];
  }

  @override
  Widget build(BuildContext context) {
    // Локальные подборки (без API).
    final top = _byIds([
      'embankment',
      'lovers_bridge',
      'tsvetnoy_boulevard',
      'slovtsov_museum',
      'holy_trinity_monastery',
    ]);

    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: top.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final l = top[i];
          return SizedBox(
            width: 260,
            child: AppCard(
              tint: AppColors.card,
              lowMotion: true,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LandmarkDetailsScreen(landmarkId: l.id),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: const Icon(Icons.auto_awesome_outlined, color: AppColors.ink),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.ink,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.muted,
                          height: 1.25,
                        ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      l.category.labelRu,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.totalPlaces,
    required this.totalRoutes,
    required this.favoritesCount,
  });

  final int totalPlaces;
  final int totalRoutes;
  final int favoritesCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0B1020),
            Color(0xFF15224A),
            Color(0xFF0B1020),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -50,
            child: _GlowCircle(size: 180, opacity: 0.12),
          ),
          Positioned(
            left: -30,
            bottom: -60,
            child: _GlowCircle(size: 220, opacity: 0.10),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Мать городов сибирских',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Тюмень — один из первых русских городов в Сибири. Здесь удобно начать путешествие: '
                'исторический центр компактный, набережная красивая, а город умеет удивлять.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.25,
                    ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _Pill(text: 'Офлайн', icon: Icons.offline_bolt_outlined),
                  _Pill(text: 'Маршруты', icon: Icons.route_outlined),
                  _Pill(text: 'Карта', icon: Icons.map_outlined),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Stat(text: '$totalPlaces мест', icon: Icons.pin_drop_outlined),
                  _Stat(text: '$totalRoutes маршрутов', icon: Icons.polyline_outlined),
                  _Stat(
                    text: '$favoritesCount сохранено',
                    icon: Icons.favorite_border_rounded,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.secondary.withValues(alpha: opacity),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 150),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.95)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.95)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LandmarkCard extends StatelessWidget {
  const _LandmarkCard({
    required this.landmark,
  });

  final Landmark landmark;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        // Важно для плавности: карточка должна пересобираться только если
        // изменился флаг избранного именно для ЭТОГО id.
        final isFav = ref.watch(
          favoritesProvider.select(
            (v) => v.value?.contains(landmark.id) ?? false,
          ),
        );
        return AppCard(
          tint: AppColors.card,
          lowMotion: true,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LandmarkDetailsScreen(landmarkId: landmark.id),
              ),
            );
          },
          child: Row(
            children: [
              _PlaceThumb(landmark: landmark),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      landmark.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      landmark.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.muted,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'В избранное',
                onPressed: () => ref.read(favoritesProvider.notifier).toggle(landmark.id),
                icon: TweenAnimationBuilder<double>(
                  key: ValueKey(isFav),
                  tween: Tween(begin: 0.92, end: 1.0),
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) => Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                  child: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? AppColors.accent : AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlaceThumb extends StatelessWidget {
  const _PlaceThumb({required this.landmark});

  final Landmark landmark;

  @override
  Widget build(BuildContext context) {
    final dotColor = landmark.category == LandmarkCategory.food
        ? AppColors.markerFood
        : (landmark.category == LandmarkCategory.park
            ? AppColors.secondary
            : AppColors.markerLandmark);

    final icon = switch (landmark.category) {
      LandmarkCategory.food => Icons.restaurant_rounded,
      LandmarkCategory.park => Icons.park_rounded,
      LandmarkCategory.culture => Icons.museum_rounded,
    };

    final img = landmark.imageAsset;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 46,
        height: 46,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.outline),
            gradient: LinearGradient(
              colors: [
                dotColor.withValues(alpha: 0.30),
                AppColors.surface.withValues(alpha: 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (img != null)
                Image.asset(
                  img,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.18),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.25),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Icon(icon, color: dotColor, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

