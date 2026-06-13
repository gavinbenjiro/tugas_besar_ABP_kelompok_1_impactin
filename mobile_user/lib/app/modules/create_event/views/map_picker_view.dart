import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerView extends StatefulWidget {
  const MapPickerView({super.key});

  @override
  State<MapPickerView> createState() => _MapPickerViewState();
}

class _MapPickerViewState extends State<MapPickerView> {
  final MapController mapController = MapController();

  LatLng selectedLocation = const LatLng(
    -6.2088,
    106.8456,
  );

  bool isLoadingLocation = false;

  Future<void> goToCurrentLocation() async {
    try {
      setState(() {
        isLoadingLocation = true;
      });

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission denied',
            ),
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final currentLocation = LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        selectedLocation = currentLocation;
      });

      mapController.move(
        currentLocation,
        16,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to get location: $e',
          ),
        ),
      );
    } finally {
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Pick Event Location',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          /// MAP
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: selectedLocation,
              initialZoom: 13,
              onTap: (tapPosition, point) {
                setState(() {
                  selectedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mobile_user',
              ),
            ],
          ),

          /// CENTER PIN
          IgnorePointer(
            child: Center(
              child: Transform.translate(
                offset: const Offset(
                  0,
                  -20,
                ),
                child: const Icon(
                  Icons.location_pin,
                  size: 55,
                  color: Color(
                    0xFF0B5D51,
                  ),
                ),
              ),
            ),
          ),

          /// TOP HINT
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  18,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      0.08,
                    ),
                    blurRadius: 15,
                    offset: const Offset(
                      0,
                      4,
                    ),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.touch_app,
                    color: Color(
                      0xFF0B5D51,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      'Tap anywhere on map to choose event location',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// BOTTOM BUTTONS
          Positioned(
            bottom: 25,
            left: 20,
            right: 20,
            child: Row(
              children: [
                /// LOCATION BUTTON
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          0.12,
                        ),
                        blurRadius: 12,
                        offset: const Offset(
                          0,
                          4,
                        ),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: isLoadingLocation ? null : goToCurrentLocation,
                    icon: isLoadingLocation
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Icon(
                            Icons.my_location,
                            color: Color(
                              0xFF0B5D51,
                            ),
                          ),
                  ),
                ),

                const SizedBox(
                  width: 14,
                ),

                /// SELECT BUTTON
                Expanded(
                  child: SizedBox(
                    height: 58,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          selectedLocation,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(
                          0xFF0B5D51,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            18,
                          ),
                        ),
                      ),
                      icon: const Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Select Location',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
