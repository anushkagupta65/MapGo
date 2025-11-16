import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_assessment/src/utils/app_colors.dart';

class LocationService {
  Future<LatLng?> getCurrentLocation(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      final bool? enabled = await _showLocationServiceDialog(context);
      if (enabled != true) {
        throw Exception("Location services are disabled.");
      }
      // Re-check
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Location services are disabled.");
      }
    }
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        final bool? retry = await _showPermissionDeniedDialog(context);
        if (retry == true) {
          return await getCurrentLocation(context);
        } else {
          throw Exception("Location permission denied by user.");
        }
      }
    }

    if (permission == LocationPermission.deniedForever) {
      final bool? openSettings = await _showPermanentlyDeniedDialog(context);
      if (openSettings == true) {
        await Geolocator.openAppSettings();

        return await getCurrentLocation(context);
      } else {
        throw Exception("Location permission permanently denied.");
      }
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      try {
        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        return LatLng(position.latitude, position.longitude);
      } catch (e) {
        throw Exception("Failed to retrieve location: $e");
      }
    }

    throw Exception("Location access not granted.");
  }

  Future<bool?> _showLocationServiceDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              "Location Services Disabled",
              style: TextStyle(color: Colors.black),
            ),
            content: const Text(
              "Please enable location services in settings.",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: AppColors.bluePrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context, true);
                  await Geolocator.openLocationSettings();
                },
                child: const Text(
                  "Open Settings",
                  style: TextStyle(
                    color: AppColors.bluePrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // Shown only AFTER user denies system dialog
  Future<bool?> _showPermissionDeniedDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text(
              "Permission Required",
              style: TextStyle(color: Colors.black),
            ),
            content: const Text(
              "We need your location to show nearby services. Would you like to grant permission?",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "No Thanks",
                  style: TextStyle(
                    color: AppColors.bluePrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Allow",
                  style: TextStyle(
                    color: AppColors.bluePrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<bool?> _showPermanentlyDeniedDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text("Permission Denied"),
            content: const Text(
              "Location access is disabled. Please enable it in app settings.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Open Settings"),
              ),
            ],
          ),
    );
  }
}
