import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../../core/models/seller.dart';
import '../../../core/repositories/seller_repository.dart';

class SellerViewModel extends ChangeNotifier {
  SellerViewModel(this._repository);

  final SellerRepository _repository;

  UnmodifiableListView<Seller> get sellers => _repository.sellers;

  Seller? findById(String id) => _repository.findById(id);

  void addSeller(Seller seller) {
    _repository.create(seller);
    notifyListeners();
  }

  void updateSeller(Seller seller) {
    _repository.update(seller);
    notifyListeners();
  }

  void deleteSeller(String id) {
    _repository.delete(id);
    notifyListeners();
  }
}
