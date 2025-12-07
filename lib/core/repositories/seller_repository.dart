import 'dart:collection';

import '../models/seller.dart';

class SellerRepository {
  final List<Seller> _sellers = [
    const Seller(
      id: 'seller-andi',
      name: 'Andi Farm',
      location: 'Medan',
      rating: 4.7,
    ),
    const Seller(
      id: 'seller-putri',
      name: 'Putri Spice House',
      location: 'Binjai',
      rating: 4.5,
    ),
    const Seller(
      id: 'seller-rani',
      name: 'Rani Craft Studio',
      location: 'Berastagi',
      rating: 4.8,
    ),
  ];

  UnmodifiableListView<Seller> get sellers => UnmodifiableListView(_sellers);

  Seller? findById(String id) {
    try {
      return _sellers.firstWhere((seller) => seller.id == id);
    } catch (_) {
      return null;
    }
  }

  void create(Seller seller) {
    _sellers.add(seller);
  }

  void update(Seller seller) {
    final index = _sellers.indexWhere((item) => item.id == seller.id);
    if (index == -1) {
      throw ArgumentError('Seller not found for id ${seller.id}');
    }
    _sellers[index] = seller;
  }

  void delete(String id) {
    _sellers.removeWhere((item) => item.id == id);
  }
}
