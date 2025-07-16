import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GenericMapScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> locations;

  const GenericMapScreen({
    super.key,
    required this.title,
    required this.locations,
  });

  @override
  State<GenericMapScreen> createState() => _GenericMapScreenState();
}

class _GenericMapScreenState extends State<GenericMapScreen> {
  GoogleMapController? _mapController;
  Position? _userPosition;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      final locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
      );

      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      setState(() {
        _userPosition = position;
      });
      _setLocationMarkers();
    } catch (e) {
      debugPrint("Failed to get location: $e");
    }
  }

  void _setLocationMarkers() {
    final markers = <Marker>{};

    for (var loc in widget.locations) {
      final lat = double.tryParse(loc['lat'].toString());
      final lon = double.tryParse(loc['lon'].toString());
      if (lat == null || lon == null) continue;

      final name = loc['name'] ?? '';
      final title = name.toString().trim().isEmpty ? '$lat, $lon' : name;
      final surface = loc['surface'] ?? 'Unknown';
      final lit = loc['lit'] == 'yes';

      markers.add(
        Marker(
          markerId: MarkerId('$lat-$lon'),
          position: LatLng(lat, lon),
          infoWindow: InfoWindow(
            title: title,
            snippet: '$surface | ${lit ? "Lit" : "Unlit"}',
          ),
        ),
      );
    }

    if (_userPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: LatLng(_userPosition!.latitude, _userPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'You'),
        ),
      );
    }

    setState(() {
      _markers.clear();
      _markers.addAll(markers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _userPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _userPosition!.latitude,
                  _userPosition!.longitude,
                ),
                zoom: 13,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: _markers,
              onMapCreated: (controller) => _mapController = controller,
            ),
    );
  }
}