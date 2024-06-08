import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:patrol_track_mobile/components/button.dart';
import 'package:patrol_track_mobile/components/header.dart';
import 'package:patrol_track_mobile/components/snackbar.dart';
import 'package:patrol_track_mobile/core/controllers/report_controller.dart';
import 'package:patrol_track_mobile/core/models/report.dart';

class ReportPage extends StatefulWidget {
  final String scanResult;

  ReportPage({required this.scanResult});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late TextEditingController _result;
  String _status = 'Aman';
  final TextEditingController _desc = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _attachments = [];

  @override
  void initState() {
    super.initState();
    _result = TextEditingController(text: widget.scanResult);
  }

  Future<void> _saveReport() async {
    try {
      if (_attachments.isNotEmpty && _desc.text.isNotEmpty) {
        final report = Report(
          locationId: int.parse(_result.text),
          locationName: "Location Name",
          status: _status,
          description: _desc.text,
          attachments: _attachments,
          createdAt: DateTime.now(),
        );

        await ReportController.createReport(context, report);
      } else {
        MySnackbar.warning(context, 'Lengkapi semua kolom dan pilih lampiran.');
      }
    } catch (e) {
      MySnackbar.failure(context, 'Gagal mengirim laporan: $e');
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
    File compressedFile = File('$tempPath/compressed_${imageFile.path.split('/').last}');
    await compressedFile.writeAsBytes(img.encodeJpg(resizedImage, quality: 50));

    return compressedFile;
  }

  Future<void> _pickImage() async {
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: StreamBuilder<DateTime>(
                        stream: Stream.periodic(
                            const Duration(seconds: 1), (_) => DateTime.now()),
                        builder: (context, snapshot) {
                          return Text(
                            DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now()),
                            style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Status Lokasi",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFF5F5C5C)),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: DropdownButton<String>(
                              value: _status,
                              isExpanded: true,
                              items: <String>['Aman', 'Tidak Aman']
                                  .map((String value) {
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Catatan Patroli",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _desc,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.camera_alt),
                                  const SizedBox(width: 10),
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
                        ],
                      ),
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
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeImage(index),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
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