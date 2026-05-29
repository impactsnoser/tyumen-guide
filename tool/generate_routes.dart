import 'dart:convert';
import 'dart:io';

import 'package:latlong2/latlong.dart';

/// Генератор Polyline (OSM/OSRM) для офлайн-хранения в mock_data.dart.
///
/// ВАЖНО:
/// - Этот скрипт используется ТОЛЬКО на этапе разработки.
/// - В рантайме приложения никаких внешних роутинг-API не используется.
///
/// Источник маршрутов: public OSRM demo server.
/// Можно заменить на свой OSRM/Valhalla сервер при необходимости.
void main() async {
  final landmarks = <String, LatLng>{
    'embankment': const LatLng(57.1549, 65.5419),
    'lovers_bridge': const LatLng(57.1556, 65.5401),
    'historic_square': const LatLng(57.1568, 65.5409),
    'fine_arts_museum': const LatLng(57.1560, 65.5459),
    'tsvetnoy_boulevard': const LatLng(57.1520, 65.5336),
    'wooden_architecture': const LatLng(57.1563, 65.5562),
    'holy_trinity_monastery': const LatLng(57.1692, 65.5436),
    'slovtsov_museum': const LatLng(57.1531, 65.5607),
    'drama_theater': const LatLng(57.1505, 65.5350),
    'zatyumensky_park': const LatLng(57.1645, 65.4917),
    'gagarin_park': const LatLng(57.1968, 65.5368),
    'central_market': const LatLng(57.1471, 65.5358),
    'coffee_old_town': const LatLng(57.1550, 65.5488),
    'siberian_bistro': const LatLng(57.1527, 65.5480),
    'restaurant_tura_view': const LatLng(57.1542, 65.5438),
  };

  final routes = <String, List<String>>{
    'route_embankment': [
      'embankment',
      'lovers_bridge',
      'historic_square',
      'fine_arts_museum',
      'tsvetnoy_boulevard',
    ],
    'route_wooden': [
      'wooden_architecture',
      'holy_trinity_monastery',
      'historic_square',
      'fine_arts_museum',
    ],
    'route_culture_day': [
      'slovtsov_museum',
      'fine_arts_museum',
      'drama_theater',
      'historic_square',
    ],
    'route_parks': [
      'zatyumensky_park',
      'tsvetnoy_boulevard',
      'embankment',
      'gagarin_park',
    ],
    'route_gastro': [
      'central_market',
      'coffee_old_town',
      'siberian_bistro',
      'restaurant_tura_view',
      'embankment',
    ],
  };

  for (final entry in routes.entries) {
    final id = entry.key;
    final stopIds = entry.value;
    final coords = stopIds.map((sid) => landmarks[sid]!).toList(growable: false);

    final geometry = await _routeByOsrmFootGeometry(coords);
    stdout.writeln('### $id');
    stdout.writeln("encodedPathPolyline6: '$geometry',");
    stdout.writeln();
  }
}

Future<String> _routeByOsrmFootGeometry(List<LatLng> stops) async {
  final coords = stops
      .map((p) => '${p.longitude.toStringAsFixed(6)},${p.latitude.toStringAsFixed(6)}')
      .join(';');

  final uri = Uri.parse(
    'https://router.project-osrm.org/route/v1/foot/$coords'
    '?overview=full&geometries=polyline6&steps=false',
  );

  final client = HttpClient();
  try {
    final req = await client.getUrl(uri);
    req.headers.set(HttpHeaders.acceptHeader, 'application/json');
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    if (res.statusCode != 200) {
      throw StateError('OSRM HTTP ${res.statusCode}: $body');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    final routes = json['routes'] as List<dynamic>;
    if (routes.isEmpty) throw StateError('OSRM: no routes');

    final geometry = (routes.first as Map<String, dynamic>)['geometry'] as String;
    return geometry;
  } finally {
    client.close(force: true);
  }
}

