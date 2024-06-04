import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:patrol_track_mobile/components/history_card.dart';
import 'package:patrol_track_mobile/core/controllers/attendance_controller.dart';
import 'package:patrol_track_mobile/core/controllers/report_controller.dart';
import 'package:patrol_track_mobile/core/models/attendance.dart';
import 'package:patrol_track_mobile/core/models/user.dart';
import 'package:patrol_track_mobile/core/services/attendance_service.dart';
import 'package:patrol_track_mobile/core/services/auth_service.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late User user = User(name: '', email: '');
  late Attendance attendance = Attendance(
      id: 1,
      date: DateTime(2024),
      startTime: const TimeOfDay(hour: 00, minute: 00),
      endTime: const TimeOfDay(hour: 00, minute: 00));
  DateTime today = DateTime.now();
  late Future<bool> _todayReportFuture;
  late Future<List<Attendance>> _attendanceFuture;

  @override
  void initState() {
    super.initState();
    fetchUser();
    fetchToday();
    _todayReportFuture = ReportController.checkTodayReport(context);
    _attendanceFuture = AttendanceController.getAttendanceHistory(context);
  }

  Future<void> fetchUser() async {
    try {
      User getUser = await AuthService.getUser();
      setState(() {
        user = getUser;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchToday() async {
    try {
      Attendance getToday = await AttendanceService.getToday();
      setState(() {
        attendance = getToday;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _saveCheckOut() async {
    try {
      int id = attendance.id;
      await AttendanceController.saveCheckOut(
        context,
        id: id,
        checkOut: TimeOfDay.now(),
      );
      print("Attendance ID: $id");
      print('Checked out successfully.');
    } catch (error) {
      print('Failed to check out: $error');
    }
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.Hm();
    return format.format(dt);
  }

  Future<File> compressImage(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(Uint8List.fromList(imageBytes));
    img.Image resizedImage = img.copyResize(image!, width: 800);
    List<int> compressedBytes = img.encodeJpg(resizedImage, quality: 50);

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File compressedFile =
        File('$tempPath/compressed_${imageFile.path.split('/').last}')
          ..writeAsBytesSync(compressedBytes);

    return compressedFile;
  }

  void _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File image = File(pickedFile.path);
      print('Photo Size: ${image.lengthSync()} bytes');

      if (image.lengthSync() > 2048 * 1024) {
        image = await compressImage(image);
        print('Compressed Photo Size: ${image.lengthSync()} bytes');
      }
      final attendance = await AttendanceService.getToday();
      int id = attendance.id;
      print("Attendance ID: $id");

      Get.toNamed('/presensi', arguments: {'id': id, 'image': image});
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _headerHome(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/permission'),
                      child: Text(
                        "Apply for permission",
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  twoCard(
                      () => _pickImage(context),
                      "Check In",
                      _formatTime(attendance.checkIn ?? attendance.startTime),
                      attendance.checkIn != null ? "Done" : "Go to Work",
                      FontAwesomeIcons.signIn),
                  twoCard(
                      () => _saveCheckOut(),
                      "Check Out",
                      _formatTime(attendance.checkOut ?? attendance.endTime),
                      attendance.checkOut != null ? "Done" : "Go Home",
                      FontAwesomeIcons.signOut)
                ],
              ),
              FutureBuilder<bool>(
                future: _todayReportFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    if (snapshot.data == false) {
                      return _buildPatrolCard(
                        title: 'You have not patrolled today.',
                        icon: Icons.warning,
                        color: Colors.red,
                      );
                    } else {
                      return SizedBox();
                    }
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "History Presence",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/history-presence'),
                      child: Text(
                        "See all",
                        style: GoogleFonts.poppins(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          FutureBuilder<List<Attendance>>(
            future: _attendanceFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No history attendance data available.'),
                );
              } else {
                List<Attendance> attendances = snapshot.data!;
                List<Widget> cards = [];
                int limit = 5;
                int counter = 0;

                for (var attendance in attendances) {
                  if (counter >= limit) {
                    break;
                  }
                  if (attendance.checkIn != null) {
                    cards.add(
                      MyCard(
                        icon: IconType.CheckIn,
                        title: "Check In",
                        subtitle: DateFormat('dd-MM-yyyy').format(attendance.date),
                        time: _formatTime(attendance.checkIn!),
                        status: attendance.status ?? '',
                      ),
                    );
                    counter++;
                  }
                  if (attendance.checkOut != null && counter < limit) {
                    cards.add(
                      MyCard(
                        icon: IconType.CheckOut,
                        title: "Check Out",
                        subtitle: DateFormat('dd-MM-yyyy').format(attendance.date),
                        time: _formatTime(attendance.checkOut!),
                        status: attendance.status ?? '',
                      ),
                    );
                    counter++;
                  }
                }

                return Expanded(
                  child: ListView(
                    children: cards,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _headerHome() {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 15, right: 15, bottom: 5),
      decoration: const BoxDecoration(
        color: Color(0xFF356899),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 3, bottom: 3),
                  child: Text(
                    "Welcome Back!",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                      wordSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 3, bottom: 25),
                  child: Text('${user.name}',
                    // child: Text('Fanidiya Tasya',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      wordSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10),
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/images/user_profile.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget twoCard(Function() onTap, String title, String time, String subtitle, IconData icon) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 165,
        height: 134,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFF3085FE).withOpacity(0.1),
                        ),
                        child: Icon(icon),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        title,
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    time,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatrolCard({String title = '', IconData icon = Icons.error, Color color = Colors.black}) {
    return Card(
      margin: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 30,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}