import 'package:absen_rpm/style/color.dart';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

Future<bool> dialogResult(BuildContext context, bool confidence) async {
  // var confidence = true;
  bool shouldPop = true;
  var verification;
  var wScreen = MediaQuery.of(context).size.width;
  var hScreen = MediaQuery.of(context).size.height;
  // String verification;
  // int _pin;
  // String _ip = ip;
  // String _image = image;
  // String _lat = lat;
  // String _long = long;
  // String _alt = alt;
  // int _ver;
  // int _is_dm;
  // String status_lokasi;
  // if (lokasi == "DIDALAM") {
  //   status_lokasi = "Anda berada di dalam area RS";
  // }
  // if (lokasi == "DILUAR") {
  //   status_lokasi = "Anda berada di luar area RS";
  // }
  // if (lokasi == "DILUAR FAKE") {
  //   status_lokasi = "Anda menggunakan fake gps";
  // }
  return await showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            confidence == true ? verification = "1" : verification = "0";
            return WillPopScope(
              onWillPop: () async {
                return shouldPop;
              },
              child: Container(
                width: wScreen * 0.7,
                height: hScreen * 0.45,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: confidence == true
                            ? FittedBox(
                                child: Image.asset("assets/gif_success.gif")
                                //    Icon(
                                //   Icons.check_circle,
                                //   size: 25,
                                //   color: Colors.teal,
                                // )
                                )
                            : FittedBox(child: Image.asset("assets/wrong.gif")),
                      ),
                      Container(
                          child: confidence == true
                              ? Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        "Selamat!",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Input absen berhasil",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        "Wajah tidak sesuai.",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                      SizedBox(
                        height: 30,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (confidence == true) {
                            return Navigator.of(context).pop(false);
                          } else {
                            return Navigator.of(context).pop(false);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: submitButton,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text('Kembali',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          // actions: <Widget>[
          //   FlatButton(
          //     child: confidence == true
          //         ? Text('Ok')
          //         : Text('Kembali, silahkan foto ulang'),
          //     onPressed: () {
          //       if (confidence == true) {
          //         return Navigator.of(context).pop(false);
          //       } else {
          //         return Navigator.of(context).pop(false);
          //       }
          //     },
          //   )
          // ],
        ),
      ) ??
      false;
}
