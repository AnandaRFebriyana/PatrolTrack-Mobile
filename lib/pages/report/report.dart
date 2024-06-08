import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:patrol_track_mobile/components/snackbar.dart';
import 'package:patrol_track_mobile/core/controllers/report_controller.dart';
import 'package:patrol_track_mobile/core/models/report.dart';
import 'package:patrol_track_mobile/components/button.dart';
import 'package:patrol_track_mobile/components/header.dart';

class ReportPage extends StatefulWidget {
  final String scanResult;

  ReportPage({required this.scanResult});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late TextEditingController _result;
  String _status = 'Aman';
  late String _currentTime;
  final TextEditingController _desc = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _attachments = [];
  bool _notesNotSelected = false;
  bool _imageReportNotSelected = false;
  // bool _statusNotSlected = false;


  @override
  void initState() {
    super.initState();
    _result = TextEditingController(text: widget.scanResult);
    _updateTime();
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    });
    Future.delayed(Duration(seconds: 1), _updateTime);
  }

  Future<void> _saveReport() async {
    setState(() {
      _notesNotSelected = _desc.text.isEmpty;
      _imageReportNotSelected = _attachments.isEmpty;
      // _statusNotSelected = _status.isEmpty;
    });

    // if(!_notesNotSelected && !_imageReportNotSelected && !_statusNotSelected) {
    if(!_notesNotSelected && !_imageReportNotSelected ) {
    try {
        final report = Report(
          locationId: int.parse(_result.text),
          locationName: "Location Name",
          status: _status,
          description: _desc.text,
          attachments: _attachments,
          createdAt: DateTime.now(),
        );
        await ReportController.createReport(context, report);
    } catch (e) {
      MySnackbar.failure(context, 'Gagal mengirim laporan: $e');
    }
  }
  }

  Future<File> compressImage(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(Uint8List.fromList(imageBytes));
    if (image == null) {
      throw Exception('Failed to decode image.');
    }
    int maxWidth = 800;
    if (image.width <= maxWidth) {
      return imageFile;
    }
    img.Image resizedImage = img.copyResize(image, width: maxWidth);
    Directory tempDir = await Directory.systemTemp;
    String tempPath = tempDir.path;
    File compressedFile =
        File('$tempPath/compressed_${imageFile.path.split('/').last}');
    await compressedFile.writeAsBytes(img.encodeJpg(resizedImage, quality: 50));

    return compressedFile;
  }

  void _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      File attachment = File(pickedFile.path);
      int fileSizeInBytes = attachment.lengthSync();
      print('Photo Size: $fileSizeInBytes bytes');

      if (fileSizeInBytes > 2048 * 1024) {
        attachment = await compressImage(attachment);
        fileSizeInBytes = attachment.lengthSync();
        print('Compressed Photo Size: $fileSizeInBytes bytes');
      }
      setState(() {
        _attachments.add(attachment);
        _imageReportNotSelected = false;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  @override
  void dispose() {
    _result.dispose();
    _desc.dispose();
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
                            widget.scanResult,
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
                              // _statusNotSlected = false;
                            });
                          },
                          underline: Container(),
                        ),
                      ),
                    ),
                    // if (_statusNotSelected)
                    //   Text(
                    //     'Please select a status',
                    //     style: TextStyle(color: Colors.red),
                    //   ),

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
                      controller: _desc,
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
                      children: _attachments.map((imageFile) {
                        int index = _attachments.indexOf(imageFile);
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
                      onPressed: _saveReport,
                    ),
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