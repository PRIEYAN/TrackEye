import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  
  Future<Map<String, dynamic>?> geocodeAddress(String address) async {
    try {
      final uri = Uri.parse('$_nominatimBaseUrl/search')
          .replace(queryParameters: {
        'q': address,
        'format': 'json',
        'limit': '1',
      });
      
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'TrackEyeAI/1.0',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        if (results.isNotEmpty) {
          final result = results[0];
          return {
            'latitude': double.parse(result['lat']),
            'longitude': double.parse(result['lon']),
            'display_name': result['display_name'],
            'address': result['display_name'],
          };
        }
      }
      return null;
    } catch (e) {
      print('Geocoding error: $e');
      return null;
    }
  }
  
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    try {
      final uri = Uri.parse('$_nominatimBaseUrl/reverse')
          .replace(queryParameters: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'format': 'json',
      });
      
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'TrackEyeAI/1.0',
        },
      );
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['display_name'];
      }
      return null;
    } catch (e) {
      print('Reverse geocoding error: $e');
      return null;
    }
  }
  
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return null;
      }
      
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Get location error: $e');
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> searchLocation(String query) async {
    try {
      final uri = Uri.parse('$_nominatimBaseUrl/search')
          .replace(queryParameters: {
        'q': query,
        'format': 'json',
        'limit': '5',
      });
      
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'TrackEyeAI/1.0',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        return {
          'results': results.map((r) => {
            'latitude': double.parse(r['lat']),
            'longitude': double.parse(r['lon']),
            'display_name': r['display_name'],
            'address': r['display_name'],
          }).toList(),
        };
      }
      return null;
    } catch (e) {
      print('Search location error: $e');
      return null;
    }
  }
}

