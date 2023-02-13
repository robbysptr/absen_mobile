import 'package:flutter/material.dart';

Future<bool> error_mock_location(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(
              "Mock Location (Fake GPS) terdeteksi silakan matikan untuk dapat melakukan absensi."),
          actions: <Widget>[
            TextButton(
              child: Text('Back'),
              onPressed: () {
                return Navigator.of(context).pop(false);
              },
            )
          ],
        ),
      ) ??
      false;
}
