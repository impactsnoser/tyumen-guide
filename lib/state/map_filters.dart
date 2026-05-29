import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';

final mapShowCultureProvider = StateProvider<bool>((ref) => true);
final mapShowParksProvider = StateProvider<bool>((ref) => true);
final mapShowFoodProvider = StateProvider<bool>((ref) => true);
final mapFavoritesOnlyProvider = StateProvider<bool>((ref) => false);

bool categoryAllowed({
  required LandmarkCategory category,
  required bool showCulture,
  required bool showParks,
  required bool showFood,
}) {
  return switch (category) {
    LandmarkCategory.culture => showCulture,
    LandmarkCategory.park => showParks,
    LandmarkCategory.food => showFood,
  };
}

