import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:patrol_track_mobile/components/button.dart';
import 'package:patrol_track_mobile/components/header.dart';
import 'package:patrol_track_mobile/core/utils/constant.dart';

class Presensi extends StatefulWidget {
  @override
  _PresensiState createState() => _PresensiState();
}

class _PresensiState extends State<Presensi> {
  Position? _currentLocation;
  String _currentAddress = "";
  bool _isAtTargetLocation = false;
  File? _image;

  @override
  void initState() {
    super.initState();
    _image = Get.arguments as File?;
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      _currentLocation = await _getCurrentLocation();
      if (_currentLocation != null) {
        await _getAddressFromCoordinates();
        _checkIfAtTargetLocation();
      }
    } catch (e) {
      print("Error initializing location: $e");
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permissions are denied");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permissions are permanently denied");
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _getAddressFromCoordinates() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
      );
      Placemark place = placemarks.first;
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';
      });
    } catch (e) {
      print("Error getting address: $e");
    }
  }

  void _checkIfAtTargetLocation() {
    double distance = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      Constant.targetLatitude,
      Constant.targetLongitude,
    );
    setState(() {
      _isAtTargetLocation = distance <= Constant.allowedDistance;
    });
  }

  String _getFormattedDate() {
    DateTime now = DateTime.now();
    String day = DateFormat('EEEE', 'id_ID').format(now);
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);
    return '$day, $formattedDate';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Header(title: "Presensi", backButton: true),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      height: 250,
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _image == null
                          ? const Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 200,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _image!,
                                fit: BoxFit.cover,
                                height: 250,
                                width: 200,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _getFormattedDate(),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    StreamBuilder<DateTime>(
                      stream: Stream.periodic(
                          const Duration(seconds: 1), (_) => DateTime.now()),
                      builder: (context, snapshot) {
                        return Text(
                          DateFormat('HH:mm:ss').format(DateTime.now()),
                          style: GoogleFonts.poppins(fontSize: 15),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              _currentAddress.isNotEmpty
                                  ? _currentAddress
                                  : "Loading...",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                              ),
                              softWrap: true,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      _isAtTargetLocation
                          ? "You are within the allowed distance from the target location."
                          : "You are outside the allowed distance from the target location.",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: _isAtTargetLocation ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                    MyButton(text: "Simpan Presensi", onPressed: () {}),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}