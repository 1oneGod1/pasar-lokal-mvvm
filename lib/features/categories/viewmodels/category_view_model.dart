import 'dart:collection';

import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../../core/models/category.dart';
import '../../../core/repositories/category_repository.dart';

class CategoryViewModel extends ChangeNotifier {
  CategoryViewModel(this._repository);

  final CategoryRepository _repository;

  UnmodifiableListView<Category> get categories => _repository.categories;

  Category? findById(String id) => _repository.findById(id);

  void addCategory(Category category) {
    _repository.create(category);
    notifyListeners();
  }

  void updateCategory(Category category) {
    _repository.update(category);
    notifyListeners();
  }

  void deleteCategory(String id) {
    _repository.delete(id);
    notifyListeners();
  }
}
