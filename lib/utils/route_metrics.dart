import 'package:latlong2/latlong.dart';

class RouteMetrics {
  const RouteMetrics({
    required this.meters,
    required this.minutesWalking,
  });

  final double meters;
  final int minutesWalking;

  String get kmText => '${(meters / 1000).toStringAsFixed(1)} км';
  String get minutesText => '$minutesWalking мин';
}

RouteMetrics computeRouteMetrics(List<LatLng> points) {
  if (points.length < 2) {
    return const RouteMetrics(meters: 0, minutesWalking: 0);
  }
  final distance = const Distance();
  var meters = 0.0;
  for (var i = 1; i < points.length; i++) {
    meters += distance(points[i - 1], points[i]);
  }

  // Средняя пешая скорость ~4.8 км/ч.
  final minutes = (meters / 1000 / 4.8 * 60).round().clamp(1, 9999);
  return RouteMetrics(meters: meters, minutesWalking: minutes);
}

