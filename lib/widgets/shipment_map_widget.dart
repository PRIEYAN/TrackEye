import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/constants.dart';
import '../services/location_service.dart';

class ShipmentMapWidget extends StatefulWidget {
  final String pickupLocation;
  final String dropLocation;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropLatitude;
  final double? dropLongitude;

  const ShipmentMapWidget({
    super.key,
    required this.pickupLocation,
    required this.dropLocation,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropLatitude,
    this.dropLongitude,
  });

  @override
  State<ShipmentMapWidget> createState() => _ShipmentMapWidgetState();
}

class _ShipmentMapWidgetState extends State<ShipmentMapWidget> {
  final LocationService _locationService = LocationService();
  double? _pickupLat;
  double? _pickupLng;
  double? _dropLat;
  double? _dropLng;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCoordinates();
  }

  Future<void> _loadCoordinates() async {
    // Use provided coordinates if available
    if (widget.pickupLatitude != null && widget.pickupLongitude != null &&
        widget.dropLatitude != null && widget.dropLongitude != null) {
      setState(() {
        _pickupLat = widget.pickupLatitude;
        _pickupLng = widget.pickupLongitude;
        _dropLat = widget.dropLatitude;
        _dropLng = widget.dropLongitude;
        _isLoading = false;
      });
      return;
    }

    // Otherwise, geocode the location names
    setState(() => _isLoading = true);

    try {
      // Geocode pickup location
      if (widget.pickupLatitude == null || widget.pickupLongitude == null) {
        final pickupResult = await _locationService.geocodeAddress(widget.pickupLocation);
        if (pickupResult != null) {
          _pickupLat = pickupResult['latitude'];
          _pickupLng = pickupResult['longitude'];
        }
      } else {
        _pickupLat = widget.pickupLatitude;
        _pickupLng = widget.pickupLongitude;
      }

      // Geocode drop location
      if (widget.dropLatitude == null || widget.dropLongitude == null) {
        final dropResult = await _locationService.geocodeAddress(widget.dropLocation);
        if (dropResult != null) {
          _dropLat = dropResult['latitude'];
          _dropLng = dropResult['longitude'];
        }
      } else {
        _dropLat = widget.dropLatitude;
        _dropLng = widget.dropLongitude;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'Failed to load map locations: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading map...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final hasCoordinates = _pickupLat != null &&
        _pickupLng != null &&
        _dropLat != null &&
        _dropLng != null;

    if (!hasCoordinates || _error != null) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                _error ?? 'Map unavailable - Could not find locations',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _loadCoordinates,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final pickupPoint = LatLng(_pickupLat!, _pickupLng!);
    final dropPoint = LatLng(_dropLat!, _dropLng!);
    
    final centerLat = (_pickupLat! + _dropLat!) / 2;
    final centerLng = (_pickupLng! + _dropLng!) / 2;
    final centerPoint = LatLng(centerLat, centerLng);
    
    final distance = const Distance();
    final distanceKm = distance.as(LengthUnit.Kilometer, pickupPoint, dropPoint);

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: centerPoint,
                initialZoom: _calculateZoom(distanceKm),
                minZoom: 3,
                maxZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.TrackEye.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [pickupPoint, dropPoint],
                      strokeWidth: 3,
                      color: AppConstants.primaryColor,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: pickupPoint,
                      width: 40,
                      height: 40,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Pickup',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Marker(
                      point: dropPoint,
                      width: 40,
                      height: 40,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Drop',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.straighten, size: 16, color: AppConstants.primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      '${distanceKm.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateZoom(double distanceKm) {
    if (distanceKm < 10) return 12.0;
    if (distanceKm < 50) return 10.0;
    if (distanceKm < 200) return 8.0;
    if (distanceKm < 1000) return 6.0;
    return 4.0;
  }
}
