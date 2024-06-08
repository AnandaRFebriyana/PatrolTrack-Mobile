import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:patrol_track_mobile/components/button.dart';
import 'package:patrol_track_mobile/components/header.dart';

class ReportPage extends StatefulWidget {
  final String scanData;

  ReportPage({required this.scanData});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late TextEditingController _resultController;
  late TextEditingController _notesController;
  String _status = 'Aman';
  late String _currentTime;
  final ImagePicker _picker = ImagePicker();
  List<XFile> _imageFiles = [];
  bool _resultNotSelected = false;
  bool _notesNotSelected = false;
  bool _imageReportNotSelected = false;
  // bool _statusNotSlected = false;


  @override
  void initState() {
    super.initState();
    _resultController = TextEditingController(text: widget.scanData);
    _notesController = TextEditingController();
    _updateTime();
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    });
    Future.delayed(Duration(seconds: 1), _updateTime);
  }

  void _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(pickedFile);
        _imageReportNotSelected = false;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  void _submitFormPatroli() async {
    setState(() {
      _notesNotSelected =_notesController.text.isEmpty;
      _imageReportNotSelected = _imageFiles.isEmpty;
      // _statusNotSlected = _status == null || _status!.isEmpty;
    });
    if (_notesNotSelected || _imageReportNotSelected ) {
      return;
    }

    final uri = Uri.parse('http://patroltrack.my.id/report/store');
    var request = http.MultipartRequest('POST', uri)
      ..fields['location_id'] = widget.scanData
      ..fields['status'] = _status
      ..fields['description'] = _notesController.text;

    for (var imageFile in _imageFiles) {
      request.files.add(await http.MultipartFile.fromPath('attachment[]', imageFile.path));
    }

    var response = await request.send();

    if (response.statusCode == 201) {
      Get.toNamed('/menu-nav');
    } else {
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit the report. Please try again.'),
        ),
      ); 
    }
  }

  @override
  void dispose() {
    _resultController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Header(title: "Report", backButton: true),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: Text(
                          _currentTime,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: false,
                      child: SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFF5F5C5C)),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                          child: Text(
                            widget.scanData,
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      "Status Lokasi",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFF5F5C5C)),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                        child: DropdownButton<String>(
                          value: _status,
                          isExpanded: true,
                          items: <String>['Aman', 'Tidak Aman'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _status = newValue!;
                            });
                          },
                          underline: Container(),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      "Catatan Patroli",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_){
                        setState(() {
                          _notesNotSelected = false;
                        });
                      },
                    ),
                    if (_notesNotSelected)
                    Text(
                      'Please enter a reason',
                    style: TextStyle(color: Colors.red),
                    ),

                    SizedBox(height: 20),
                    Text(
                      "Unggah Bukti",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: _pickImage,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFF5F5C5C)),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt),
                            SizedBox(width: 10),
                            Text(
                              "Pilih File",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                     if (_imageReportNotSelected)
                      Text(
                        'Please select an image',
                        style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _imageFiles.map((imageFile) {
                        int index = _imageFiles.indexOf(imageFile);
                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFF5F5C5C)),
                                borderRadius: BorderRadius.circular(5.0),
                                image: DecorationImage(
                                  image: FileImage(File(imageFile.path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -10,
                              left: 25,
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeImage(index),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 30),
                    MyButton(
                      text: "Kirim",
                      onPressed: _submitFormPatroli,
                    ),
                    // Container(
                    //   margin: EdgeInsets.symmetric(horizontal: 50),
                    //   child: ElevatedButton(
                    //     onPressed: _submitFormPatroli,
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Color(0xFF305E8B),
                    //       minimumSize: Size(double.infinity, 50),
                    //       padding: EdgeInsets.symmetric(vertical: 15),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(10),
                    //       ),
                    //     ),
                        // child: Text(
                        //   "Kirim",
                        //   style: GoogleFonts.poppins(
                        //     color: Colors.white,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                    //   ),
                    // ),
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