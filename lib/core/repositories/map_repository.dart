import 'dart:collection';

import 'package:latlong2/latlong.dart';

import '../models/map_location.dart';

class MapRepository {
  MapRepository();

  final List<MapLocation> _locations = [
    MapLocation(
      id: 'loc-dapur-bu-sari',
      name: 'Dapur Bu Sari',
      description: 'Nasi uduk dan lauk rumahan.',
      position: LatLng(3.5951956, 98.6722227),
    ),
    MapLocation(
      id: 'loc-kopi-senja',
      name: 'Kopi Senja Tetangga',
      description: 'Kedai kopi kecil dengan biji lokal.',
      position: LatLng(3.5946024, 98.6710153),
    ),
    MapLocation(
      id: 'loc-warung-pak-rt',
      name: 'Warung Pak RT',
      description: 'Gorengan dan jajanan sore.',
      position: LatLng(3.5960031, 98.6731128),
    ),
  ];

  UnmodifiableListView<MapLocation> get locations =>
      UnmodifiableListView(_locations);

  MapLocation? findById(String id) {
    try {
      return _locations.firstWhere((location) => location.id == id);
    } catch (_) {
      return null;
    }
  }

  void addLocation(MapLocation location) {
    _locations.add(location);
  }
}
