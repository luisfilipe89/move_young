import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class FootballFieldMapScreen extends StatefulWidget {
  final List<Map<String, dynamic>> fields;

  const FootballFieldMapScreen({super.key, required this.fields});

  @override
  State<FootballFieldMapScreen> createState() => _FootballFieldMapScreenState();
}

class _FootballFieldMapScreenState extends State<FootballFieldMapScreen> {
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
      await Geolocator.requestPermission();
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _userPosition = position;
        _setFieldMarkers();
      });
    } catch (e) {
      setState(() {
        _userPosition = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get location: $e')),
      );
    }
  }

  void _setFieldMarkers() {
    for (var field in widget.fields) {
      final lat = field['lat'];
      final lon = field['lon'];

      // Defensive check in case lat/lon are null or wrong type
      if (lat == null || lon == null) continue;
      final double? latitude =
          lat is String ? double.tryParse(lat) : lat as double?;
      final double? longitude =
          lon is String ? double.tryParse(lon) : lon as double?;

      if (latitude == null || longitude == null) continue;

      final name = field['name'] ?? 'Unnamed Field';

      _markers.add(
        Marker(
          markerId: MarkerId(name),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(title: name),
        ),
      );
    }

    if (_userPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: LatLng(_userPosition!.latitude, _userPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'You'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Football Fields Map'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(_userPosition!.latitude, _userPosition!.longitude),
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
