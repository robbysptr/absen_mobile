// ignore: depend_on_referenced_packages
import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:flutter/material.dart';
import 'package:absen_rpm/ui/login_page.dart';

Future<bool> logout_dialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("Anda yakin ingin melakukan Logout?"),
          actions: <Widget>[
            TextButton(
              child: Text('Ya'),
              onPressed: () {
                Logout();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => LoginPage()));
              },
            ),
            TextButton(
              child: Text('Tidak'),
              onPressed: () {
                return Navigator.of(context).pop(false);
              },
            )
          ],
        ),
      ) ??
      false;
}

Logout() async {
  LocalStorageInterface prefs = await LocalStorage.getInstance();
  prefs.setString("base64image", "");
  prefs.setString("name", "");
  // prefs.setString("nip", "");
  prefs.setString("pin", "");
  // setState(() {});
}
