import 'package:latlong2/latlong.dart';

import 'category.dart';

class Landmark {
  const Landmark({
    required this.id,
    required this.name,
    required this.description,
    required this.history,
    required this.coordinates,
    required this.category,
    this.imageAsset,
  });

  final String id;
  final String name;
  final String description;
  final String history;
  final LatLng coordinates;
  final LandmarkCategory category;
  final String? imageAsset;
}

