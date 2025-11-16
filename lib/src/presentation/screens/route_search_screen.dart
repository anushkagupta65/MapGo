// lib/presentation/screens/route_search_screen.dart
// ignore_for_file: use_build_context_synchronously, avoid_print, unused_element

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:map_assessment/src/data/directions_api.dart';
import 'package:map_assessment/src/data/places_api.dart';
import 'package:map_assessment/src/models/route_info.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_assessment/src/presentation/widgets/custom_autocomplete.dart';
import 'package:map_assessment/src/utils/app_colors.dart';
import 'dart:async';

class RouteSearchScreen extends StatefulWidget {
  final Function(RouteInfo, String, String, LatLng, LatLng) onRouteCalculated;
  final Function(LatLng, String?) onPlaceSelectedAndMoveMap;
  final String? initialSourceAddress;
  final String? initialDestinationAddress;
  final LatLng? initialSourceLatLng;
  final LatLng? initialDestinationLatLng;

  const RouteSearchScreen({
    super.key,
    required this.onRouteCalculated,
    required this.onPlaceSelectedAndMoveMap,
    this.initialSourceAddress,
    this.initialDestinationAddress,
    this.initialSourceLatLng,
    this.initialDestinationLatLng,
  });

  @override
  State<RouteSearchScreen> createState() => _RouteSearchScreenState();
}

class _RouteSearchScreenState extends State<RouteSearchScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _sourceFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();

  final PlacesApi _placesApi = PlacesApi();
  final DirectionsApi _directionsApi = DirectionsApi();

  LatLng? _sourceLatLng;
  LatLng? _destinationLatLng;
  bool _isLoadingRoute = false;

  // Suggestions state
  List<Prediction> _sourcePredictions = [];
  List<Prediction> _destinationPredictions = [];
  bool _isLoadingSource = false;
  bool _isLoadingDestination = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    print("[RouteSearchScreen] Initializing RouteSearchScreen.");
    if (widget.initialSourceAddress != null) {
      _sourceController.text = widget.initialSourceAddress!;
      _sourceLatLng = widget.initialSourceLatLng;
    }
    if (widget.initialDestinationAddress != null) {
      _destinationController.text = widget.initialDestinationAddress!;
      _destinationLatLng = widget.initialDestinationLatLng;
    }

    _sourceController.addListener(
      () => _onTextChanged(_sourceController, true),
    );
    _destinationController.addListener(
      () => _onTextChanged(_destinationController, false),
    );
    _sourceFocusNode.addListener(() => setState(() {}));
    _destinationFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _destinationController.dispose();
    _sourceFocusNode.dispose();
    _destinationFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged(TextEditingController controller, bool isSource) {
    final text = controller.text.trim();
    if (text.length < 2) {
      setState(() {
        if (isSource)
          _sourcePredictions = [];
        else
          _destinationPredictions = [];
      });
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      setState(() {
        if (isSource)
          _isLoadingSource = true;
        else
          _isLoadingDestination = true;
      });

      try {
        final predictions = await _placesApi.getPlacePredictions(
          text,
          countries: ["IN"],
        );
        if (mounted) {
          setState(() {
            if (isSource) {
              _sourcePredictions = predictions;
              _isLoadingSource = false;
            } else {
              _destinationPredictions = predictions;
              _isLoadingDestination = false;
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            if (isSource) {
              _sourcePredictions = [];
              _isLoadingSource = false;
            } else {
              _destinationPredictions = [];
              _isLoadingDestination = false;
            }
          });
        }
      }
    });
  }

  Future<void> _useCurrentLocation() async {
    print("[RouteSearchScreen] Using current location as source.");
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar("Location permission denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar("Location permission permanently denied.");
      return;
    }

    setState(() {
      _isLoadingRoute = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(position.latitude, position.longitude);
      final address = await _placesApi.reverseGeocode(latLng);

      setState(() {
        _sourceController.text = address ?? "Current Location";
        _sourceLatLng = latLng;
        _sourcePredictions = [];
      });

      widget.onPlaceSelectedAndMoveMap(latLng, "Current Location");
    } catch (e) {
      print("[RouteSearchScreen] Error getting location: $e");
    } finally {
      setState(() {
        _isLoadingRoute = false;
      });
    }
  }

  void _onPlaceSelected(Prediction prediction, bool isSource) async {
    final controller = isSource ? _sourceController : _destinationController;
    final focusNode = isSource ? _sourceFocusNode : _destinationFocusNode;

    controller.text = prediction.description ?? '';
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );

    final placeId = prediction.placeId;
    if (placeId != null) {
      try {
        final latLng = await _placesApi.getLatLngFromPlaceId(placeId);
        if (latLng != null) {
          if (isSource) {
            _sourceLatLng = latLng;
          } else {
            _destinationLatLng = latLng;
          }
          widget.onPlaceSelectedAndMoveMap(
            latLng,
            prediction.structuredFormatting?.mainText,
          );
          setState(() {
            if (isSource)
              _sourcePredictions = [];
            else
              _destinationPredictions = [];
          });
          focusNode.unfocus();
        }
      } catch (e) {
        _showSnackBar("Failed to get coordinates: ${e.toString()}");
      }
    }
  }

  Future<void> _triggerRouteCalculation() async {
    print("[RouteSearchScreen] Show Route button pressed.");
    String originAddress = _sourceController.text.trim();
    String destinationAddress = _destinationController.text.trim();

    if (originAddress.isEmpty || destinationAddress.isEmpty) {
      _showSnackBar("Please enter both starting point and destination.");
      return;
    }

    try {
      if (_sourceLatLng == null) {
        final resolved = await _placesApi.getLatLngFromAddress(originAddress);
        if (resolved == null) throw Exception("Could not resolve source.");
        _sourceLatLng = resolved;
      }
      if (_destinationLatLng == null) {
        final resolved = await _placesApi.getLatLngFromAddress(
          destinationAddress,
        );
        if (resolved == null) throw Exception("Could not resolve destination.");
        _destinationLatLng = resolved;
      }
    } catch (e) {
      _showSnackBar("Invalid location. Please select from suggestions.");
      return;
    }

    if (_sourceLatLng == null || _destinationLatLng == null) {
      _showSnackBar("Could not determine coordinates.");
      return;
    }

    setState(() => _isLoadingRoute = true);
    print("[RouteSearchScreen] Loading route...");

    try {
      final routeInfo = await _directionsApi.getDirections(
        originAddress,
        destinationAddress,
      );
      await widget.onRouteCalculated(
        routeInfo,
        originAddress,
        destinationAddress,
        _sourceLatLng!,
        _destinationLatLng!,
      );
      print("[RouteSearchScreen] Route calculated.");
    } catch (e) {
      // _showSnackBar("Failed to calculate route: ${e.toString()}");
    } finally {
      setState(() => _isLoadingRoute = false);
    }
  }

  void _swapLocations() {
    print("[RouteSearchScreen] Swapping locations.");
    setState(() {
      final tempText = _sourceController.text;
      final tempLatLng = _sourceLatLng;

      _sourceController.text = _destinationController.text;
      _sourceLatLng = _destinationLatLng;

      _destinationController.text = tempText;
      _destinationLatLng = tempLatLng;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.bgDark,
      ),
    );
  }

  Widget _buildPredictionsList(bool isSource) {
    final predictions = isSource ? _sourcePredictions : _destinationPredictions;
    final isLoading = isSource ? _isLoadingSource : _isLoadingDestination;
    final focusNode = isSource ? _sourceFocusNode : _destinationFocusNode;

    if (!focusNode.hasFocus || predictions.isEmpty && !isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      constraints: const BoxConstraints(maxHeight: 500),
      child:
          isLoading
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: AppColors.blueGlow),
                ),
              )
              : predictions.isEmpty
              ? const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    "No results found",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              )
              : ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: predictions.length,
                separatorBuilder:
                    (context, index) => const Divider(
                      height: 1,
                      color: Color(0xFFE0E0E0),
                      indent: 60,
                      endIndent: 16,
                    ),
                itemBuilder: (context, index) {
                  final prediction = predictions[index];
                  final structured = prediction.structuredFormatting;
                  final mainText =
                      structured?.mainText ?? prediction.terms?[0].value ?? '';
                  final secondaryText =
                      structured?.secondaryText ??
                      (prediction.terms
                              ?.skip(1)
                              .map((t) => t.value)
                              .join(', ') ??
                          '');

                  return ListTile(
                    leading: Icon(
                      _getIconForPrediction(prediction),
                      color: AppColors.blueGlow,
                      size: 24,
                    ),
                    title: Text(
                      mainText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    subtitle:
                        secondaryText.isNotEmpty
                            ? Text(
                              secondaryText,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                            : null,
                    onTap: () => _onPlaceSelected(prediction, isSource),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                  );
                },
              ),
    );
  }

  IconData _getIconForPrediction(Prediction prediction) {
    final types = prediction.types ?? [];
    if (types.contains('lodging') || types.contains('hotel')) {
      return Icons.hotel_rounded;
    } else if (types.contains('street_address') || types.contains('route')) {
      return Icons.location_on_rounded;
    } else if (types.contains('locality') || types.contains('sublocality')) {
      return Icons.location_city_rounded;
    } else if (types.contains('administrative_area_level_1')) {
      return Icons.map_rounded;
    } else if (types.contains('country')) {
      return Icons.public_rounded;
    }
    return Icons.location_on_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.bgCard,
      appBar: AppBar(
        shadowColor: Colors.white38,
        surfaceTintColor: AppColors.bgDark,
        elevation: 10,
        backgroundColor: AppColors.bgDark,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_sharp,
            color: AppColors.textLight,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        leadingWidth: 48,
        title: const Text(
          "Plan Your Route",
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: AppColors.textLight,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
      ),
      body: Stack(
        children: [
          // === SCROLLABLE CONTENT ===
          SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: 100, // Space for bottom button
              left: 0,
              right: 0,
              top: 0,
            ),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 14, right: 4),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 16,
                            child: Icon(
                              Icons.circle,
                              size: 12,
                              color: AppColors.bluePrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Icon(
                            Icons.more_vert,
                            size: 22,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(height: 4),
                          Icon(
                            Icons.location_on,
                            size: 28,
                            color: AppColors.redPin,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: [
                            CustomAutoCompleteTextField(
                              controller: _sourceController,
                              hintText: "Choose start location",
                              focusNode: _sourceFocusNode,
                            ),
                            const SizedBox(height: 16),
                            CustomAutoCompleteTextField(
                              controller: _destinationController,
                              hintText: "Choose destination",
                              focusNode: _destinationFocusNode,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _swapLocations,
                        child: Icon(
                          Icons.swap_vert,
                          color: AppColors.textLight,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: _useCurrentLocation,
                      icon: const Icon(Icons.my_location, size: 16),
                      label: const Text("Use current location"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),
                ),

                _buildPredictionsList(true),

                _buildPredictionsList(false),

                const SizedBox(height: 80),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoadingRoute ? null : _triggerRouteCalculation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bluePrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                  ),
                  child:
                      _isLoadingRoute
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "Show Route",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
