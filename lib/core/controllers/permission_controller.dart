import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patrol_track_mobile/core/models/permission.dart';
import 'package:patrol_track_mobile/core/services/permission_service.dart';
import 'package:patrol_track_mobile/core/utils/constant.dart';
import 'package:quickalert/quickalert.dart';

class PermissionController {

  static Future<void> createPermission(BuildContext context, Permission permission) async {
    try {
      String? token = await Constant.getToken();

      if (token != null) {
        bool success = await PermissionService.postPermission(token, permission);
        if (success) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Success!',
            text: 'Permission created successfully',
            onConfirmBtnTap: () {
              Navigator.of(context).pop();
              Get.toNamed('/menu-nav');
            },
          );
          return;
        }
      }
    } catch (error) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('$error'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
      // print('Error: $error');

      final overlay = Overlay.of(context);
      final overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 10,
          right: 10,
          child: Material(
            color: Colors.transparent,
            child: AwesomeSnackbarContent(
              title: 'Error',
              message: '$error',
              contentType: ContentType.failure,
            ),
          ),
        ),
      );

      overlay.insert(overlayEntry);
      Future.delayed(Duration(seconds: 3), () {
        overlayEntry.remove();
      });
      print('Error: $error');
    }
  }
}
