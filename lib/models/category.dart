enum LandmarkCategory {
  culture,
  food,
  park,
}

extension LandmarkCategoryX on LandmarkCategory {
  String get labelRu => switch (this) {
        LandmarkCategory.culture => 'Культура',
        LandmarkCategory.food => 'Еда',
        LandmarkCategory.park => 'Парк',
      };
}

