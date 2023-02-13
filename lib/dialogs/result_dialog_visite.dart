import 'package:absen_rpm/style/color.dart';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

Future<bool> dialogResultVisite(BuildContext context, String message) async {
  bool shouldPop = true;
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('kk:mm:ss - EEE d MMM').format(now);
  var wScreen = MediaQuery.of(context).size.width;
  var hScreen = MediaQuery.of(context).size.height;
  bool status = true;
  if (message == "sukses") {
    status = true;
  } else {
    status = false;
  }
  return await showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
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
                        child: status == true
                            ? FittedBox(
                                child: Image.asset("assets/gif_success.gif"))
                            : FittedBox(child: Image.asset("assets/wrong.gif")),
                      ),
                      Container(
                          child: status == true
                              ? Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        "Selamat!.",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Input visite berhasil",
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
                                        "Input Gagal.",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                      GestureDetector(
                        onTap: () {
                          if (status == true) {
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
        ),
      ) ??
      false;
}
