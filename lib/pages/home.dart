import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:patrol_track_mobile/components/history_card.dart';
import 'package:patrol_track_mobile/core/controllers/attendance_controller.dart';
import 'package:patrol_track_mobile/core/controllers/report_controller.dart';
import 'package:patrol_track_mobile/core/models/attendance.dart';
import 'package:patrol_track_mobile/core/models/user.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime today = DateTime.now();
  late Future<List<Attendance>> _attendanceFuture;
  bool showAlert = true;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = AttendanceController.getAttendanceHistory(context);
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.Hm();
    return format.format(dt);
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
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Today",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/permission'),
                      child: Text("Apply for permission",
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder<List<Attendance>>(
                future: AttendanceController.getToday(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    if (snapshot.data!.isEmpty) {
                      return const SizedBox();
                    } else {
                      final start = snapshot.data![0].startTime;
                      final end = snapshot.data![0].endTime;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          twoCard("Check In", _formatTime(start), "Go to Work", FontAwesomeIcons.signIn),
                          twoCard("Check Out", _formatTime(end), "Go Home", FontAwesomeIcons.signOut),
                        ],
                      );
                    }
                  }
                },
              ),
              FutureBuilder<bool>(
                future: ReportController.checkTodayReport(context),
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
                        subtitle:
                            DateFormat('dd-MM-yyyy').format(attendance.date),
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
                        subtitle:
                            DateFormat('dd-MM-yyyy').format(attendance.date),
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
    final User user = Get.arguments as User;

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
                SizedBox(height: 20),
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
                  padding: EdgeInsets.only(left: 3, bottom: 25),
                  child: Text(
                    '${user.name}',
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

  Widget twoCard(String title, String time, String subtitle, IconData icon) {
    return GestureDetector(
      onTap: () => Get.toNamed('/presensi'),
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
                      SizedBox(width: 5),
                      Text(
                        title,
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
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

  Widget _buildPatrolCard(
      {String title = '',
      IconData icon = Icons.error,
      Color color = Colors.black}) {
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
            SizedBox(width: 10),
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
