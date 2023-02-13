import 'package:flutter/material.dart';

Future<bool> login_error(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(
              "PIN dan Wajah tidak terdaftar silakan melakukan Registrasi"),
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
