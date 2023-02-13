import 'package:flutter/material.dart';

Future<bool> error_lokasi(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("Anda berada diluar area Kantor"),
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
