import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patrol_track_mobile/components/header.dart';
import 'package:patrol_track_mobile/core/utils/constant.dart';

class Presensi extends StatefulWidget {
  @override
  _PresensiState createState() => _PresensiState();
}

class _PresensiState extends State<Presensi> {
  Position? _currentLocation;
  late bool servicePermission = false;
  late LocationPermission permission;
  File? _image;

  String _currentAddress = "";
  bool _isAtTargetLocation = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    _currentLocation = await _getCurrentLocation();
    if (_currentLocation != null) {
      await _getAddressFromCoordinates();
      _checkIfAtTargetLocation();
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<Position> _getCurrentLocation() async {
    servicePermission = await Geolocator.isLocationServiceEnabled();
    if (!servicePermission) {
      print("Service Disabled");
      return Future.error("Location services are disabled.");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error("Location permissions are permanently denied");
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print("Current position: ${position.latitude}, ${position.longitude}");
    return position;
  }

  Future<void> _getAddressFromCoordinates() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentLocation!.latitude, _currentLocation!.longitude);
      Placemark place = placemarks[0];
      if (mounted) {
        setState(() {
          _currentAddress =
              '${place.street}, ${place.subLocality}, ${place.locality}, '
              '${place.postalCode}, ${place.country}';
        });
      }
      print("Current address: $_currentAddress");
    } catch (e) {
      print(e);
    }
  }

  void _checkIfAtTargetLocation() {
    double distance = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      Constant.targetLatitude,
      Constant.targetLongitude,
    );
    print("Distance to target: $distance meters");

    if (mounted) {
      setState(() {
        _isAtTargetLocation = distance <= Constant.allowedDistance;
      });
    }
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (mounted) {
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Header(title: "Presensi", backButton: true),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Location Coordinates",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Latitude = ${_currentLocation?.latitude ?? 'Loading...'} ; Longitude = ${_currentLocation?.longitude ?? 'Loading...'}",
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Location Address",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _currentAddress.isNotEmpty ? _currentAddress : "Loading...",
                  ),
                  const SizedBox(height: 30),
                  Text(
                    _isAtTargetLocation
                        ? "You are within the allowed distance from the target location."
                        : "You are outside the allowed distance from the target location.",
                    style: TextStyle(
                      fontSize: 20,
                      color: _isAtTargetLocation ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _image == null
                        ? const Icon(
                            Icons.camera_alt,
                            color: Colors.grey,
                            size: 100,
                          )
                        : Image.file(
                            _image!,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt, size: 24),
                    label: const Text('Take a Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}