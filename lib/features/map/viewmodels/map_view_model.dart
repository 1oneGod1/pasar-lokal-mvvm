import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/models/map_location.dart';
import '../../../core/repositories/map_repository.dart';

class MapViewModel extends ChangeNotifier {
  MapViewModel(this._repository) {
    _markers = _buildMarkers();
  }

  final MapRepository _repository;
  final MapController mapController = MapController();

  late List<Marker> _markers;

  LatLng get initialCenter => const LatLng(3.5959, 98.6722);
  double get initialZoom => 15.0;
  List<MapLocation> get locations => _repository.locations;
  List<Marker> get markers => _markers;

  void focusOn(MapLocation location) {
    mapController.move(location.position, 17);
  }

  List<Marker> _buildMarkers() {
    return locations
        .map(
          (location) => Marker(
            point: location.position,
            width: 48,
            height: 48,
            child: Tooltip(
              message: '${location.name}\n${location.description}',
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        )
        .toList();
  }
}
