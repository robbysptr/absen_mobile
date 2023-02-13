import 'package:flutter/material.dart';

Future<bool> errordialog(BuildContext context, String error) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("Error Message: " + error),
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

Future<bool> timeoutDialog(BuildContext context, String error) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("Error Message: " + error),
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
