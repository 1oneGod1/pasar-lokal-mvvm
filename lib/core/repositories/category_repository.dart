import 'dart:collection';

import '../models/category.dart';

class CategoryRepository {
  final List<Category> _categories = [
    const Category(
      id: 'cat-produce',
      name: 'Fresh Produce',
      description: 'Seasonal fruits and vegetables from local farmers.',
    ),
    const Category(
      id: 'cat-spices',
      name: 'Spices',
      description: 'Dry ingredients and traditional spices.',
    ),
    const Category(
      id: 'cat-handicraft',
      name: 'Handicrafts',
      description: 'Handmade crafts created by local artisans.',
    ),
  ];

  UnmodifiableListView<Category> get categories =>
      UnmodifiableListView(_categories);

  Category? findById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (_) {
      return null;
    }
  }

  void create(Category category) {
    _categories.add(category);
  }

  void update(Category category) {
    final index = _categories.indexWhere((item) => item.id == category.id);
    if (index == -1) {
      throw ArgumentError('Category not found for id ${category.id}');
    }
    _categories[index] = category;
  }

  void delete(String id) {
    _categories.removeWhere((item) => item.id == id);
  }
}
