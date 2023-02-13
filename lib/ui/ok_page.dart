import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:absen_rpm/dialogs/errordialogs.dart';
import 'package:absen_rpm/dialogs/result_dialog_absen_visite.dart';
import 'package:absen_rpm/dialogs/result_facematcher.dart';
// import 'package:absen_mobile/dialogs/result_dialog_absen_visite.dart';
import 'package:absen_rpm/ui/register_page.dart';
import 'package:absen_rpm/style/color.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
// import "package:google_maps_flutter/google_maps_flutter.dart";
import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:http/http.dart' as http;
// import 'package:progress_dialog/progress_dialog.dart';
// import 'package:get_mac/get_mac.dart';
// import 'package:get_ip/get_ip.dart';

class OkPage extends StatefulWidget {
  @override
  _OkPageState createState() => _OkPageState();
}

class _OkPageState extends State<OkPage> {
  String? base64imagesave;
  String? pin;

  String? base64image;
  String? base64imagesave2;
  bool isFaceDetected = false;

  String? templateFace;

  File? pickedImage;
  var imageFile;

  bool? isfaceregistered;
  bool? highConfidence;

  String error_limit = "";
  String mac_address = "Unknown";
  String ip_address = "Unknown";

  Uint8List? bytes;

  final picker = ImagePicker();
  File? _image;

  // ProgressDialog? pr;

  String? confidence_level;
  double? confidence_double;
  int? confindence_int;

  var listRuangOp = [];
  String? ruangOp;

  final formKey = new GlobalKey<FormState>();

  Future<bool> getData() async {
    LocalStorageInterface prefs = await LocalStorage.getInstance();
    base64imagesave = prefs.getString('base64image') ?? "";
    pin = prefs.getString('pin') ?? "";
    templateFace = prefs.getString('template') ?? "";

    setState(() {});
    return true;
  }

  Future<File> testCompressAndGetFile2(File file) async {
    final directory = await getTemporaryDirectory();
    String targetPath = "${directory.path}/image2.jpg";
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 50,
    );

    print(file.lengthSync());
    print(result!.lengthSync());

    return result;
  }

  Future getImage() async {
    imageCache.clear();
    final pickedFile =
        await picker.getImage(source: ImageSource.camera, maxWidth: 300);
    imageFile = await pickedFile!.readAsBytes();
    imageFile = await decodeImageFromList(imageFile);
    setState(() {
      _image = File(pickedFile.path);
      // pr!.show();
      // // testCompressAndGetFile2(_image).then((value) {
      // pr!.hide();
      // _image = value;
      List<int> imageBytes = _image!.readAsBytesSync();
      base64imagesave2 = base64Encode(imageBytes);
      print("saved image: " + base64imagesave2!);
      print("image compare : " + base64imagesave!);
      // });
    });
  }

  Future<dynamic> compare() async {
    dynamic url = Uri.https('api-us.faceplusplus.com', '/facepp/v3/compare');
    var map = new Map<String, dynamic>();
    map['api_key'] = 'soVlxfve5_B4v82e0RA_KA1waIiuYS-y';
    map['api_secret'] = 'FFGA6E4n8_glRfK4sSYNH8JR0pjxFqIU';
    map['image_base64_1'] = '$base64imagesave';
    map['image_base64_2'] = '$base64imagesave2';

    try {
      http.Response response = await http.post(url, body: map);

      var data = json.decode(response.body);
      print(data);
      var confidence = data["confidence"];
      print(confidence);
      error_limit = data["error_message"];

      return confidence.toString();
    } on SocketException catch (e) {
      print(e);
      return e;
    }
    // http.Response response = await http.post(url, body: map);

    // var data = json.decode(response.body);
    // print(data);
    // var confidence = data["confidence"];
    // print(confidence);
    // error_limit = data["error_message"];

    // return confidence.toString();
  }

  Future<dynamic> faceMatcher() async {
    var url = Uri.http('202.157.184.205:5000', '/api/facematcher');
    String bodySend = """{
      "name" : "$pin",
      "imagebase64" : "$base64imagesave2",
      "template" : "$templateFace"
    }""";

    try {
      http.Response response = await http.put(url,
          headers: {"Content-Type": "application/json"}, body: bodySend);
      // print(response.body.toString());
      var data = json.decode(response.body);
      print(data);
      print(data['response']);
      return data['response'];
    } on SocketException catch (e) {
      print(e);
      return 0.toString();
    }
  }

  // Future<void> getIpMac() async {
  //   String ip;
  //   String mac;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     // ip = await GetIp.ipAddress;
  //     // mac = await GetMac.macAddress;
  //   } on PlatformException {
  //     ip = 'Failed to get ipAddress.';
  //     mac = 'Failed to get MAC';
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;
  //   setState(() {
  //     ip_address = ip;
  //     mac_address = mac;
  //   });
  // }

  Future<dynamic> insertAbsen(
      String pin, String ip, int verif, String image, String mac) async {
    String message;
    int verifInt;
    int verifikasi;
    if (verif < 75) {
      verifikasi = 0;
    } else {
      verifikasi = 1;
    }

    verifInt = verif.round();
    dynamic url = Uri.http('127.0.0.1:8000', '/absen/');
    var bodySend = """ 
    {
      "pin": "$pin",
      "ip_address": "$ip",
      "verif": $verifikasi,
      "confidance":  $verif,
      "mac": "$mac",
      "is_dm": "OK",
      "lat": "",
      "long": "",
      "alt": "",
      "in_out": 0,
    }
    """;
    print(bodySend);

    try {
      Map<String, String> requestHeader = {'Content-type': 'application/json'};
      http.Response response =
          await http.post(url, body: bodySend, headers: requestHeader);
      var data = json.decode(response.body);
      print(data);
      if (data['response'][1]['message'] == "success") {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (e) {
      print('No Internet: $e');
      return e;
    } on Error catch (e) {
      print(e);
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getIpMac().then((_) {
    //   print("MAC : " + mac_address);
    //   print("IP : " + ip_address);
    // });
    getData().then((_) {
      print("image saved -->" + base64imagesave!);
      if (base64imagesave == "") {
        isfaceregistered = false;
      } else {
        isfaceregistered = true;
      }
    });
  }

  Future<bool> emptyimage(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            content: Text("Silahkan ambil foto terlebih dahulu!"),
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

  logout() async {
    LocalStorageInterface prefs = await LocalStorage.getInstance();
    prefs.setString("base64image", "");
    prefs.setString("name", "");
    prefs.setString("pin", "");
    prefs.setString("template", "");
    setState(() {});
  }

  Future<bool> logout_dialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            content: Text("Anda yakin ingin melakukan Logout?"),
            actions: <Widget>[
              TextButton(
                child: Text('Ya'),
                onPressed: () {
                  logout();
                  Navigator.pushReplacementNamed(context, '/loginPage');
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

  @override
  Widget build(BuildContext context) {
    // pr = new ProgressDialog(context, isDismissible: false);
    // pr!.style(
    //     // message: 'Please Wait',
    //     borderRadius: 10.0,
    //     backgroundColor: Colors.white,
    //     progressWidget: CircularProgressIndicator(),
    //     elevation: 10.0,
    //     insetAnimCurve: Curves.easeInOut,
    //     progress: 0.0,
    //     maxProgress: 100.0,
    //     progressTextStyle: TextStyle(
    //         color: Colors.black, fontSize: 10.0, fontWeight: FontWeight.w400),
    //     messageTextStyle: TextStyle(
    //         color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
    var wScreen = MediaQuery.of(context).size.width;
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(wScreen * 0.65, 8.0, 8.0, 8.0),
        child: ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              if (_image == null) {
                emptyimage(context);
              } else {
                // dialogResult(context, true).then((value) {
                //   print(listRuangOp);
                // });
                // pr.show();
                // compare().then((value) {
                setState(() {
                  // pr!.hide();
                  // confidence_level = value.toString();
                  confindence_int = confidence_double!.round();
                  // print(duty_manager);
                  insertAbsen(pin!, "", confindence_int!, base64imagesave2!, "")
                      .then((value) {
                    // status_lokasi = value;
                    if (value == true) {
                      setState(() {
                        // pr.hide();
                        dialogResultAbsenVisite(context, highConfidence!)
                            .then((value) {
                          // updateState(base64imagesave2);
                          return Navigator.of(context)
                              .pushReplacementNamed('/loginPage');
                        });
                      });
                    } else {
                      var textError =
                          "Gagal input absen, coba beberapa saat lagi.";
                      errordialog(context, textError);
                    }
                  }).catchError((error) {
                    // pr!.hide();
                    print(error);
                  });
                });
                // }).catchError((error) {
                //   pr.hide();
                //   errordialog(context, error_limit).then((value) {
                //     pr.hide();
                //   });
                // });
              }
            }
            // } else {
            //   error_mock_location(context);
            // }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) return submitButton;
                return submitButton; // Use the component's default.
              },
            ),
          ),
          // color: submitButton,
          // textColor: Colors.white,
          // shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(25.0),
          //     side: BorderSide(
          //       color: submitButton,
          //     )),
          child: Row(
            children: [
              Expanded(child: Text('Absen')),
              SizedBox(
                width: 20,
              ),
              Container(
                  padding: EdgeInsets.fromLTRB(0.8, 0.8, 0.8, 0.8),
                  width: 15,
                  child: Icon(
                    FontAwesomeIcons.sync,
                    size: 20,
                  )),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text("Absen OK"),
        actions: <Widget>[
          IconButton(
              icon: Icon(FontAwesomeIcons.userCog),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => RegisterPage()));
              }),
          IconButton(
              icon: Icon(FontAwesomeIcons.signOutAlt),
              onPressed: () {
                logout_dialog(context).then((value) {
                  setState(() {
                    // getRuangOperasi().then((_) {});
                  });
                });
                // Navigator.pop(context);
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (isfaceregistered == true) {
                        // pr!.show();
                        getImage().then((value) {
                          faceMatcher().then((value) {
                            setState(() {
                              confidence_level = value.toString();
                              confidence_double =
                                  double.parse(confidence_level!);
                              if (confidence_double! < 0.8) {
                                highConfidence = false;
                              } else {
                                highConfidence = true;
                              }
                              resultFaceMatcher(context, highConfidence!);
                              // pr!.hide();
                            });
                          });
                        });
                      } else {
                        emptyimage(context);
                      }
                    },
                    child: Container(
                      // padding: EdgeInsets.all(5),
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: primaryColor),
                        shape: BoxShape.circle,
                        // color: Colors.teal,
                        // borderRadius: BorderRadius.circular(10),
                      ),
                      child: _image == null
                          ? Stack(children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: secondaryColor),
                                // color: Colors.lightBlue,
                                child: Center(
                                  child: Icon(
                                    FontAwesomeIcons.user,
                                    size: 50,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              Positioned(
                                  bottom: 0,
                                  right: 0,
                                  // alignment: Alignment.bottomRight,
                                  child: CircleAvatar(
                                      backgroundColor: primaryColor,
                                      child: Icon(Icons.camera_alt))),
                            ])
                          : Stack(children: [
                              CircleAvatar(
                                  radius: 120,
                                  backgroundImage: FileImage(_image!)),
                              Positioned(
                                  bottom: 0,
                                  right: 0,
                                  // alignment: Alignment.bottomRight,
                                  child: CircleAvatar(
                                    backgroundColor: primaryColor,
                                    child: Icon(
                                      Icons.camera_alt,
                                    ),
                                  )),
                            ]),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      padding: EdgeInsets.all(8.0),
                      child: listRuangOp != []
                          ? DropdownButtonFormField(
                              isExpanded: true,
                              items: listRuangOp.map((dynamic map) {
                                return DropdownMenuItem(
                                    value: map["id_ok"],
                                    child: Text(map["id_ok"].toString()));
                              }).toList(),
                              onChanged: (value) {
                                ruangOp = value.toString();
                              },
                              onSaved: (v) {
                                ruangOp = v.toString();
                              },
                              value: ruangOp,
                              validator: (value) =>
                                  value == null ? "Ruang  harus diisi" : null,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(
                                      20.0, 15.0, 20.0, 15.0),
                                  labelText: "Ruang OP",
                                  prefixIcon: Icon(FontAwesomeIcons.bed),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0))),
                            )
                          : SizedBox()),
                  // Container(
                  //   padding: EdgeInsets.all(5),
                  //   width: 300,
                  //   height: 400,
                  //   decoration: BoxDecoration(
                  //     border: Border.all(width: 1, color: Colors.teal),
                  //     // color: Colors.teal,
                  //     borderRadius: BorderRadius.circular(10),
                  //   ),
                  //   child: Center(
                  //     child: _image == null
                  //         ? Text(
                  //             'Tidak ada foto.',
                  //           )
                  //         : Image.file(_image),
                  //   ),
                  // ),
                  // Container(
                  //   // padding: EdgeInsets.all(5),
                  //   width: 300,
                  //   height: 300,
                  //   decoration: BoxDecoration(
                  //     border: Border.all(width: 2, color: Colors.teal),
                  //     shape: BoxShape.circle,
                  //     // color: Colors.teal,
                  //     // borderRadius: BorderRadius.circular(10),
                  //   ),
                  //   child: _image == null
                  //       ? Container(
                  //           child: Center(
                  //             child: Text(
                  //               'Tidak ada foto.',
                  //             ),
                  //           ),
                  //         )
                  //       : CircleAvatar(backgroundImage: FileImage(_image)),
                  // ),
                  // SizedBox(height: 10),
                  // RaisedButton.icon(
                  //     onPressed: () {
                  //       // getImage();
                  //       if (isfaceregistered == true) {
                  //         getImage().then((value) {
                  //           // _getCurrentLocation();

                  //           // print(_currentPosition.latitude);
                  //         });
                  //       } else {
                  //         emptyimage(context);
                  //       }
                  //     },
                  //     color: Colors.white70,
                  //     shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(25.0),
                  //         side: BorderSide(
                  //           color: Colors.teal,
                  //         )),
                  //     elevation: 1,
                  //     label: Text(
                  //       "Ambil Foto",
                  //       style: TextStyle(
                  //         color: Colors.teal,
                  //       ),
                  //     ),
                  //     icon: Icon(
                  //       Icons.camera_alt,
                  //       color: Colors.teal,
                  //     )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
