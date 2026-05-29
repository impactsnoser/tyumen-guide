class ExcursionRoute {
  const ExcursionRoute({
    required this.id,
    required this.title,
    required this.description,
    required this.stopIds,
    this.encodedPathPolyline6,
  });

  final String id;
  final String title;
  final String description;
  final List<String> stopIds;

  /// Геометрия маршрута вдоль улиц, закодированная polyline6 (precision=1e6).
  /// Если `null`, карта соединит остановки прямыми линиями.
  final String? encodedPathPolyline6;
}

