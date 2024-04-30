import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page/schedule.dart';
import 'page/history.dart';
import 'page/setting.dart';
import 'page/home.dart';

class MenuNav extends StatefulWidget {
  @override
  _MenuNavState createState() => _MenuNavState();
}

class _MenuNavState extends State<MenuNav> {
  int currentTab = 0;
  final List<Widget> screens = [
    Home(),
    Schedule(),
    History(),
    Setting(),
  ];
  Widget currentScreen = Home();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentScreen,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.qr_code_scanner),
        backgroundColor: Color(0xFF1E3B57),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        onPressed: ()=> Get.toNamed('scanner'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: BottomAppBar(
          color: Colors.white,
          shape: CircularNotchedRectangle(),
          notchMargin: 10,
          child: Container(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildTabItem(0, Icons.home, 'Home'),
                _buildTabItem(1, Icons.calendar_month, 'Schedule'),
                SizedBox(width: 40),
                _buildTabItem(2, Icons.history, 'History'),
                _buildTabItem(3, Icons.settings, 'Setting'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String text) {
    return GestureDetector(
      onTap: () => _updateTab(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: currentTab == index ? Color(0xFF356899) : Color(0xFF353840),
            ),
          SizedBox(height: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: currentTab == index ? Color(0xFF356899) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _updateTab(int index) {
    setState(() {
      currentScreen = screens[index];
      currentTab = index;
    });
  }
}
