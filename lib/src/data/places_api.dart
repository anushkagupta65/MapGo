// lib/api/places_api.dart
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:google_places_flutter/model/prediction.dart';
import 'package:map_assessment/src/utils/app_constants.dart';

class PlacesApi {
  /// Get place predictions (autocomplete) based on user input
  Future<List<Prediction>> getPlacePredictions(
    String input, {
    List<String> countries = const [],
  }) async {
    if (input.trim().isEmpty) return [];

    final String countryParam =
        countries.isNotEmpty
            ? '&components=${countries.map((c) => 'country:$c').join('|')}'
            : '';

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=${AppConstants.googleApiKey}$countryParam';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' || data['status'] == 'ZERO_RESULTS') {
          final List predictionsJson = data['predictions'];
          return predictionsJson
              .map((json) => Prediction.fromJson(json))
              .toList();
        }
      }
      print('[PlacesApi] Autocomplete error: ${response.body}');
      return [];
    } catch (e) {
      print('[PlacesApi] Exception in getPlacePredictions: $e');
      return [];
    }
  }

  /// Get LatLng from Place ID (from autocomplete selection)
  Future<LatLng?> getLatLngFromPlaceId(String placeId) async {
    if (placeId.isEmpty) return null;

    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=${AppConstants.googleApiKey}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          return LatLng(location['lat'], location['lng']);
        }
      }
      print('[PlacesApi] Place details error: ${response.body}');
      return null;
    } catch (e) {
      print('[PlacesApi] Exception in getLatLngFromPlaceId: $e');
      return null;
    }
  }

  /// Get LatLng from raw address string (geocoding)
  Future<LatLng?> getLatLngFromAddress(String address) async {
    if (address.trim().isEmpty) return null;

    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=${AppConstants.googleApiKey}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return LatLng(location['lat'], location['lng']);
        }
      }
      print('[PlacesApi] Geocoding error: ${response.body}');
      return null;
    } catch (e) {
      print('[PlacesApi] Exception in getLatLngFromAddress: $e');
      return null;
    }
  }

  /// Reverse geocode: Convert LatLng → Human-readable address
  Future<String?> reverseGeocode(LatLng latLng) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=${AppConstants.googleApiKey}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
      print('[PlacesApi] Reverse geocoding error: ${response.body}');
      return null;
    } catch (e) {
      print('[PlacesApi] Exception in reverseGeocode: $e');
      return null;
    }
  }
}
