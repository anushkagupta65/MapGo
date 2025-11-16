// lib/presentation/screens/map_screen.dart
// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_assessment/src/models/route_info.dart';
import 'package:map_assessment/src/presentation/screens/route_search_screen.dart';
import 'package:map_assessment/src/presentation/widgets/search_bar.dart';
import 'package:map_assessment/src/services/location_service.dart';
import 'package:map_assessment/src/services/map_service.dart';
import 'package:map_assessment/src/utils/app_colors.dart';
import 'package:map_assessment/src/utils/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final LocationService _locationService = LocationService();

  LatLng? _currentLocation;
  RouteInfo? _currentRouteInfo;
  String? _currentSourceAddress;
  String? _currentDestinationAddress;
  LatLng? _currentSourceLatLng;
  LatLng? _currentDestinationLatLng;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  bool _showRouteSheet = false;

  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    print("[MapScreen] Initializing MapScreen...");
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      _currentLocation = await _locationService.getCurrentLocation(context);
      print("[MapScreen] Current location obtained: $_currentLocation");

      setState(() {
        _locationPermissionGranted = true;
      });

      await _moveToLocation(
        _currentLocation!,
        AppConstants.currentLocationZoom,
      );
      setState(() {});
    } catch (e) {
      print("[MapScreen] Error getting current location: $e");
      setState(() {
        _locationPermissionGranted = false;
      });
      _moveToDefaultLocation();
    }
  }

  Future<void> _moveToLocation(LatLng location, double zoom) async {
    final GoogleMapController controller = await _controller.future;
    print("[MapScreen] Moving camera to $location with zoom $zoom");
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: zoom),
      ),
    );
  }

  void _moveToDefaultLocation() {
    print("[MapScreen] Moving to default location.");
    _moveToLocation(
      AppConstants.defaultIndiaLocation,
      AppConstants.defaultZoom,
    );
  }

  void _onMapTap(LatLng position) {
    print("[MapScreen] Map tapped at $position");
    if (_currentRouteInfo == null) {
      Provider.of<MapService>(context, listen: false).addMarker(
        Marker(
          markerId: MarkerId(const Uuid().v4()),
          position: position,
          infoWindow: const InfoWindow(title: "Dropped Pin"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
      // _showSnackBar(
      //   "Dropped pin at ${position.latitude.toStringAsFixed(3)}, ${position.longitude.toStringAsFixed(3)}",
      // );
    }
  }

  Future<void> _handleRouteCalculated(
    RouteInfo routeInfo,
    String sourceAddress,
    String destinationAddress,
    LatLng sourceLatLng,
    LatLng destinationLatLng,
  ) async {
    print("[MapScreen] _handleRouteCalculated called.");
    setState(() {
      _currentRouteInfo = routeInfo;
      _currentSourceAddress = sourceAddress;
      _currentDestinationAddress = destinationAddress;
      _currentSourceLatLng = sourceLatLng;
      _currentDestinationLatLng = destinationLatLng;
      _showRouteSheet = true;
    });

    final mapService = Provider.of<MapService>(context, listen: false);
    mapService.clearAll();
    print("[MapScreen] Cleared existing markers and polylines.");

    mapService.addMarker(
      Marker(
        markerId: const MarkerId("origin"),
        position: sourceLatLng,
        infoWindow: InfoWindow(title: sourceAddress),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );
    mapService.addMarker(
      Marker(
        markerId: const MarkerId("destination"),
        position: destinationLatLng,
        infoWindow: InfoWindow(title: destinationAddress),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    print("[MapScreen] Added origin and destination markers.");

    mapService.addPolyline(
      Polyline(
        polylineId: const PolylineId("route"),
        color: AppColors.bluePrimary,
        width: 5,
        points: routeInfo.polylineCoordinates,
      ),
    );
    print(
      "[MapScreen] Added polyline with ${routeInfo.polylineCoordinates.length} points.",
    );

    await _zoomToFitRoute(sourceLatLng, destinationLatLng);
    print("[MapScreen] Zoomed to fit route.");

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _handlePlaceSelectedAndMoveMap(LatLng latLng, String? placeName) {
    print(
      "[MapScreen] _handlePlaceSelectedAndMoveMap called for $placeName at $latLng",
    );
    _moveToLocation(latLng, AppConstants.selectedPlaceZoom);
    final mapService = Provider.of<MapService>(context, listen: false);
    mapService.addMarker(
      Marker(
        markerId: MarkerId(const Uuid().v4()),
        position: latLng,
        infoWindow: InfoWindow(title: placeName ?? "Selected Place"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );
  }

  Future<void> _zoomToFitRoute(LatLng origin, LatLng destination) async {
    final GoogleMapController controller = await _controller.future;
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        origin.latitude < destination.latitude
            ? origin.latitude
            : destination.latitude,
        origin.longitude < destination.longitude
            ? origin.longitude
            : destination.longitude,
      ),
      northeast: LatLng(
        origin.latitude > destination.latitude
            ? origin.latitude
            : destination.latitude,
        origin.longitude > destination.longitude
            ? origin.longitude
            : destination.longitude,
      ),
    );
    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  void _clearMapAndRouteInfo() {
    print("[MapScreen] Clearing map and route info.");
    setState(() {
      _currentRouteInfo = null;
      _currentSourceAddress = null;
      _currentDestinationAddress = null;
      _currentSourceLatLng = null;
      _currentDestinationLatLng = null;
      _showRouteSheet = false;
    });
    Provider.of<MapService>(context, listen: false).clearAll();
    _showSnackBar("Map and route cleared.");
  }

  void _showSnackBar(String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        body: Stack(
          children: [
            // ===== FULL SCREEN GOOGLE MAP =====
            Consumer<MapService>(
              builder: (context, mapService, child) {
                return GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: AppConstants.defaultIndiaLocation,
                    zoom: AppConstants.defaultZoom,
                  ),
                  zoomGesturesEnabled: true,
                  compassEnabled: true,
                  rotateGesturesEnabled: true,
                  buildingsEnabled: true,
                  myLocationEnabled: _locationPermissionGranted,
                  myLocationButtonEnabled: _locationPermissionGranted,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                  markers: mapService.markers,
                  polylines: mapService.polylines,
                  onMapCreated: (GoogleMapController controller) {
                    if (!_controller.isCompleted) {
                      _controller.complete(controller);
                    }
                    print("[MapScreen] GoogleMap controller completed.");
                  },
                  onTap: _onMapTap,
                );
              },
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  toolbarHeight: 100,
                  title: CustomSearchAppBar(
                    onTap: () {
                      print(
                        "[MapScreen] Search bar tapped, navigating to RouteSearchScreen.",
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => RouteSearchScreen(
                                onRouteCalculated: _handleRouteCalculated,
                                onPlaceSelectedAndMoveMap:
                                    _handlePlaceSelectedAndMoveMap,
                                initialSourceAddress: _currentSourceAddress,
                                initialDestinationAddress:
                                    _currentDestinationAddress,
                                initialSourceLatLng: _currentSourceLatLng,
                                initialDestinationLatLng:
                                    _currentDestinationLatLng,
                              ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ===== DRAGGABLE BOTTOM SHEET (Route Info) =====
            if (_showRouteSheet && _currentRouteInfo != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: screenHeight,
                  width: screenWidth,
                  child: DraggableScrollableSheet(
                    initialChildSize: 0.2,
                    minChildSize: 0.2,
                    maxChildSize: 0.95,
                    expand: false,
                    snap: true,
                    snapSizes: const [0.2, 0.5, 0.95],
                    builder: (context, scrollController) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, -5),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Drag handle
                              Container(
                                height: 4,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.blueGlow,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Metrics Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildMetricItem(
                                    Icons.alt_route,
                                    _currentRouteInfo!.distance,
                                    "Distance",
                                  ),
                                  _buildMetricItem(
                                    Icons.timer,
                                    _currentRouteInfo!.duration,
                                    "Duration",
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Clear Route Button
                              TextButton(
                                onPressed: _clearMapAndRouteInfo,
                                child: const Text(
                                  "Clear Route",
                                  style: TextStyle(color: AppColors.redPin),
                                ),
                              ),

                              // Extra space for scroll
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: _showRouteSheet ? 160 : 16),
          child: FloatingActionButton(
            heroTag: "myLocation",
            onPressed: () async {
              print("[MapScreen] My Location FAB pressed.");

              _clearMapAndRouteInfo();
              print(
                "[MapScreen] Called _clearMapAndRouteInfo to hide route sheet.",
              );

              LatLng? freshLocation;
              try {
                freshLocation = await _locationService.getCurrentLocation(
                  context,
                );

                setState(() {
                  _locationPermissionGranted = true;
                });
              } catch (e) {
                print("[MapScreen] Failed to get fresh location: $e");
              }

              final target =
                  freshLocation ??
                  _currentLocation ??
                  AppConstants.defaultIndiaLocation;
              _currentLocation = target;

              _moveToLocation(target, AppConstants.currentLocationZoom);
              setState(() {});
            },
            backgroundColor: AppColors.bgCard,
            foregroundColor: Colors.white,
            child: const Icon(Icons.my_location),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.bluePrimary, size: 30),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.blueGlow,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.textLight)),
      ],
    );
  }
}
