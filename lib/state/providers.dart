import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock_data.dart';
import '../models/excursion_route.dart';
import '../models/landmark.dart';
import '../utils/polyline6.dart';
import '../utils/route_metrics.dart';
import 'map_filters.dart';
import 'prefs_keys.dart';

/// 0=Обзор, 1=Карта, 2=Маршруты
final selectedTabProvider = StateProvider<int>((ref) => 0);

/// Текущий выбранный маршрут (id) или null.
final selectedRouteIdProvider = StateProvider<String?>((ref) => null);

final routesProvider = Provider<List<ExcursionRoute>>((ref) => routes);
final landmarksProvider = Provider<List<Landmark>>((ref) => landmarks);

final landmarksByIdProvider = Provider<Map<String, Landmark>>((ref) {
  final items = ref.watch(landmarksProvider);
  return {for (final l in items) l.id: l};
});

final selectedRouteProvider = Provider<ExcursionRoute?>((ref) {
  final id = ref.watch(selectedRouteIdProvider);
  if (id == null) return null;
  return ref.watch(routesProvider).where((r) => r.id == id).firstOrNull;
});

final currentStopLandmarkProvider = Provider<Landmark?>((ref) {
  final route = ref.watch(selectedRouteProvider);
  final byId = ref.watch(landmarksByIdProvider);
  if (route == null) return null;
  final index = ref.watch(currentStopIndexProvider);
  if (route.stopIds.isEmpty) return null;
  final safeIndex = index.clamp(0, route.stopIds.length - 1);
  return byId[route.stopIds[safeIndex]];
});

/// Точки полилинии активного маршрута (если выбран).
final routePolylinePointsProvider = Provider<List<LatLng>>((ref) {
  final route = ref.watch(selectedRouteProvider);
  if (route == null) return const <LatLng>[];

  final encoded = route.encodedPathPolyline6;
  if (encoded != null) {
    return decodePolyline6(encoded);
  }

  final byId = ref.watch(landmarksByIdProvider);
  return [
    for (final id in route.stopIds)
      if (byId[id] != null) byId[id]!.coordinates,
  ];
});

final routeMetricsProvider = Provider<RouteMetrics?>((ref) {
  final pts = ref.watch(routePolylinePointsProvider);
  if (pts.length < 2) return null;
  return computeRouteMetrics(pts);
});

/// Список точек, видимых на карте с учётом фильтров.
final visibleLandmarksProvider = Provider<List<Landmark>>((ref) {
  final items = ref.watch(landmarksProvider);
  final showCulture = ref.watch(mapShowCultureProvider);
  final showParks = ref.watch(mapShowParksProvider);
  final showFood = ref.watch(mapShowFoodProvider);
  final favoritesOnly = ref.watch(mapFavoritesOnlyProvider);
  final favs = ref.watch(favoritesProvider).value ?? const <String>{};

  return items.where((l) {
    final allowed = categoryAllowed(
      category: l.category,
      showCulture: showCulture,
      showParks: showParks,
      showFood: showFood,
    );
    if (!allowed) return false;
    if (favoritesOnly) return favs.contains(l.id);
    return true;
  }).toList(growable: false);
});

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

class MapCommand {
  const MapCommand({
    required this.center,
    this.zoom = 15,
  });

  final LatLng center;
  final double zoom;
}

/// Одноразовая команда для фокуса карты (центр/зум).
final mapCommandProvider = StateProvider<MapCommand?>((ref) => null);

/// Выбранная точка (для подсветки/контекста).
final selectedLandmarkIdProvider = StateProvider<String?>((ref) => null);

final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// Показан ли онбординг.
final onboardingSeenProvider = AsyncNotifierProvider<OnboardingSeenNotifier, bool>(
  OnboardingSeenNotifier.new,
);

class OnboardingSeenNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await ref.watch(sharedPrefsProvider.future);
    return prefs.getBool(PrefsKeys.onboardingSeen) ?? false;
  }

  Future<void> setSeen() async {
    final prefs = await ref.read(sharedPrefsProvider.future);
    await prefs.setBool(PrefsKeys.onboardingSeen, true);
    state = const AsyncData(true);
  }
}

/// Избранное (set of landmark ids).
final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final prefs = await ref.watch(sharedPrefsProvider.future);
    final list = prefs.getStringList(PrefsKeys.favorites) ?? const <String>[];
    return list.toSet();
  }

  Future<void> toggle(String id) async {
    final current = {...(state.value ?? const <String>{})};
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    state = AsyncData(current);
    final prefs = await ref.read(sharedPrefsProvider.future);
    await prefs.setStringList(PrefsKeys.favorites, current.toList()..sort());
  }
}

/// Прогресс выбранного маршрута: индекс текущей остановки.
final currentStopIndexProvider = StateProvider<int>((ref) => 0);

/// Позиция пользователя (если есть разрешение). Если нет — null.
final userPositionProvider = StreamProvider<Position?>((ref) {
  final controller = StreamController<Position?>();

  Future<void> start() async {
    // На desktop (особенно Windows) у geolocator бывают особенности с потоками.
    // Для мобильного сценария (Android/iOS) используем поток, для desktop — одноразовый запрос.
    final isDesktop = !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      controller.add(null);
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      controller.add(null);
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 15,
      ),
    );
    controller.add(pos);

    if (isDesktop) return;

    final sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 15,
      ),
    ).listen(controller.add, onError: (_) => controller.add(null));

    ref.onDispose(() async {
      await sub.cancel();
    });
  }

  unawaited(start());

  ref.onDispose(() async {
    await controller.close();
  });

  return controller.stream;
});

/// Одноразовая позиция пользователя (для экранов, где не нужен live-трекинг).
///
/// Важно: поток `userPositionProvider` может триггерить частые rebuild'ы UI.
/// Для сортировки "ближе ко мне" на главном экране хватает снимка позиции.
final userPositionOnceProvider = FutureProvider<Position?>((ref) async {
  // На desktop (особенно Windows) у geolocator бывают особенности с потоками.
  final isDesktop =
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return null;

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return null;
  }

  return Geolocator.getCurrentPosition(
    locationSettings: LocationSettings(
      accuracy: isDesktop ? LocationAccuracy.medium : LocationAccuracy.best,
      distanceFilter: 50,
    ),
  );
});

