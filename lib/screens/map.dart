import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  MapScreen({required this.onLocationSelected});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _currentLatLng = LatLng(0, 0);
  late GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sélectionnez l\'adresse'),
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: _currentLatLng,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: MarkerId('selected-location'),
            position: _currentLatLng,
            draggable: true,
            onDragEnd: (LatLng newPosition) {
              setState(() {
                _currentLatLng = newPosition;
              });
            },
          ),
        },
        onTap: (LatLng position) {
          setState(() {
            _currentLatLng = position;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          widget.onLocationSelected(_currentLatLng);
          Navigator.pop(context);
        },
      ),
    );
  }
}
