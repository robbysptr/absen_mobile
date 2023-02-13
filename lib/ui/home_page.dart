import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
// import 'package:absen_mobile/dialogs/error_lokasi.dart';
import 'package:absen_rpm/dialogs/error_mock_location.dart';
import 'package:absen_rpm/dialogs/errordialogs.dart';
import 'package:absen_rpm/dialogs/result_dialog.dart';
import 'package:absen_rpm/dialogs/result_facematcher.dart';
import 'package:absen_rpm/ui/login_page.dart';
import 'package:absen_rpm/model/profile.dart';
import 'package:absen_rpm/ui/register_page.dart';
import 'package:absen_rpm/style/color.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/src/widgets/basic.dart';
// import 'package:flutter/src/widgets/container.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// import "package:google_maps_flutter/google_maps_flutter.dart";
import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:http/http.dart' as http;
// import 'package:progress_dialog/progress_dialog.dart';
// import 'package:get_mac/get_mac.dart';
// import 'package:get_ip/get_ip.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity/connectivity.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'package:absen_rpm/splashscreen_view.dart';
import '../style/color.dart';

// class Shift {
//   String? kodeShift;
//   String? namaShift;
//   String? milik;

//   Shift({this.kodeShift, this.namaShift, this.milik});

//   factory Shift.fromJson(Map<String, dynamic> json) => new Shift(
//       kodeShift: json["KODE_SHIFT"],
//       namaShift: json["SHIFT"],
//       milik: json["MILIK"]);

//   // Map<String, dynamic> toJson() =>
//   //     {"KODE_SHIFT": kodeShift, "SHIFT": namaShift, "MILIK": milik};
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['KODE_SHIFT'] = this.kodeShift;
//     data['SHIFT'] = this.namaShift;
//     data['MILIK'] = this.milik;

//     return data;
//   }

//   @override
//   toString() => '{KODE_SHIFT: $kodeShift, SHIFT: $namaShift, MILIK: $milik}]';
// }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final formKey = new GlobalKey<FormState>();
  String shift = "0";
  String? duty_manager;
  bool is_dm = false;
  bool is_normal = true;
  List<Profile> profile = <Profile>[];
  File? _image;
  final picker = ImagePicker();
  String? status_lokasi;

  File? pickedImage;
  var imageFile;

  bool? isfaceregistered;
  bool? highConfidence;

  // List<Rect> rect = new List<Rect>();
  bool isFaceDetected = false;

  String? base64image;
  String? base64imagesave;
  String? base64imagesave2;

  String? templateFace;

  String confidence_level = "";
  double confidence_double = 0;
  int? confindence_int;

  String? name, nip, pin;
  // ProgressDialog? pr;
  int? pin_int;

  // List listShift = [];
  // List<Shift> listShiftFilter = [];
  // List listDropdown = [];

  String error_limit = "";

  Position? _currentPosition;

  String? latitude;
  String? longitude;
  String? altitude;
  bool? ismocklocation;

  String mac_address = "Unknown";
  String ip_address = "Unknown";

  bool? statusIstirahat;

  // LatLng myLocation;

  Uint8List? bytes;

  bool ignoreAbsen = true;

  String radioButtonText = "";
  int radioButtonValue = 1;

  String radioInOutText = "";
  int? radioInOutValue;

  String? statusPegawai;

  String? ssidName;

  List jenisPgw = ['Regular'];
  int selectedJenisPgw = 0;

  String? network;

  List jenisAbsen = ['Masuk', 'Pulang'];
  int selectedJenisAbsen = 0;

  bool isLoading = false;

  Future<File?> compressImage(File file) async {
    final directory = await getTemporaryDirectory();
    String targetPath = "${directory.path}/image2.jpg";
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 50,
    );

    return result;
  }

  Future getImage() async {
    imageCache.clear();
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, maxWidth: 300);
    imageFile = await pickedFile!.readAsBytes();
    imageFile = await decodeImageFromList(imageFile);

    setState(() {
      _image = File(pickedFile.path);
      // pr.show();
      isLoading = true;
      // compressImage(_image).then((value) {
      // pr.hide();
      // _image = value;
      List<int> imageBytes = _image!.readAsBytesSync();
      base64imagesave2 = base64Encode(imageBytes);
      // });
    });
  }

  Future<dynamic> insertAbsen(
      String pin,
      // String lat,
      // String long,
      String ip,
      int verif,
      String image,
      // String alt,
      // String shift,
      // String mac,
      String dm,
      int inOut) async {
    String message;
    int verif_int;
    // int alt_int = double.parse(alt).round();
    int verifikasi;
    if (verif < 75) {
      verifikasi = 0;
    } else {
      verifikasi = 1;
    }

    verif_int = verif.round();
    var body_send = """ 
    {
      "pin": "$pin",
      "ip_address": "$ip",
      "verif": $verifikasi,
      "is_dm": "$dm",
      "image": "$image",
      "confidance":  $verif,
      "in_out": ${inOut.toString()}
    }
    """;
    // print(body_send);
    // return;
    dynamic url = Uri.http('192.168.1.10:8000', '/absen_mobile/');

    setState(() {
      isLoading = true;
    });

    try {
      Map<String, String> requestHeader = {'Content-type': 'application/json'};
      http.Response response = await http
          .post(url, body: body_send, headers: requestHeader)
          .timeout(Duration(seconds: 25));
      var data = json.decode(response.body);
      print(data);
      return data;
    } on SocketException catch (e) {
      isLoading = false;
      return e;
    } on TimeoutException catch (e) {
      isLoading = false;
      return e;
    }
  }

  // Future<dynamic> getShift() async {
  //   dynamic url = Uri.http('147.118.97.27:8001', '/get_waktu_kerja');

  //   try {
  //     http.Response response = await http.get(url);
  //     // final request = await client.
  //     var data = json.decode(response.body);
  //     // print(data);
  //     listShift = data;
  //     print("LIST SHIFT: $listShift");
  //     return;
  //   } on SocketException catch (e) {
  //     return e;
  //   }
  // }

  Future cekLokasi(String lat, String long) async {
    // await Future.wait(_getCurrentLocation());
    Future.delayed(new Duration(seconds: 3));

    dynamic url = Uri.http('118.97.147.27:8001', '/ceklokasi');

    var body_send = """ 
    {
      "lat": "$lat",
      "long": "$long"
    }
    """;

    try {
      Map<String, String> requestHeader = {'Content-type': 'application/json'};
      http.Response response = await http
          .post(url, body: body_send, headers: requestHeader)
          .timeout(Duration(seconds: 20));
      // final request = await client.
      var data = json.decode(response.body);
      print(data);
      status_lokasi = data["location"];
      return data["message"];
    } on SocketException catch (e) {
      return e;
    } on Error catch (e) {
      return e;
    } on TimeoutException catch (e) {
      return e;
    }
  }

  Future decodetoimage() async {
    final directory = await getApplicationDocumentsDirectory();
    final gambar = base64Decode(base64imagesave!);
    setState(() {
      pickedImage = File("${directory.path}/imagesaved.jpg");
      pickedImage!.writeAsBytesSync(List.from(gambar));
    });
  }

  updateState(String image) async {
    LocalStorageInterface prefs = await LocalStorage.getInstance();
    prefs.setString("base64image", image);
    setState(() {});
  }

  Future<bool> getData() async {
    LocalStorageInterface prefs = await LocalStorage.getInstance();
    base64imagesave = prefs.getString('base64image') ?? "";
    name = prefs.getString('name') ?? "";
    nip = prefs.getString('nip') ?? "";
    pin = prefs.getString('pin') ?? "";
    templateFace = prefs.getString('template') ?? "";

    setState(() {});
    return true;
  }

  Future<dynamic> faceMatcher() async {
    var url = Uri.http('202.157.184.205:5000', '/api/facematcher');
    print('facematcher');
    // var url = Uri.http('118.97.147.27:8080', '/api/facematcher');
    String body_send = """{
      "name" : "$pin",
      "imagebase64" : "$base64imagesave2",
      "template" : "$templateFace"
    }""";

    try {
      http.Response response = await http.put(url,
          headers: {"Content-Type": "application/json"}, body: body_send);
      // print(response.body.toString());
      var data = json.decode(response.body);
      print(data);
      print(data['response']);
      return data['response'];
    } on SocketException catch (e) {
      print(e);
      return 0.toString();
    } on TimeoutException catch (e) {
      // timeoutDialog(context, e);
      print(e);
      return 0.toString();
    }
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
      var confidence = data["confidence"];
      error_limit = data["error_message"];

      return confidence.toString();
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
  //     ip = await GetIp.ipAddress;
  //     mac = await GetMac.macAddress;
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

  Future<dynamic> checkConnectivity() async {
    String? result;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network.
      result = "mobile";
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
      result = "wifi";
    }
    return result;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    radioInOutValue = 0;
    statusIstirahat = false;
    checkConnectivity().then((value) async {
      if (value == "wifi") {
        network = value;
        var wifiBSSID = await WifiInfo().getWifiBSSID();
        var wifiIP = await WifiInfo().getWifiIP();
        var wifiName = await WifiInfo().getWifiName();
        ip_address = wifiIP!;
        ssidName = wifiName;
        print(wifiIP.toString());
        print(wifiName.toString());
        print(wifiBSSID.toString());
      } else {
        network = value;
        ip_address = "mobile";
        ssidName = "mobile";
        print(ip_address);
      }
    });
    // getIpMac().then((_) {});

    getData().then((_) {
      if (templateFace == "") {
        isfaceregistered = false;
      } else {
        isfaceregistered = true;
        print("template : " + templateFace!);
      }
      // getShift().then((value) {
      //   // listShiftFilter = listShift;
      //   setState(() {
      //     listDropdown = listShift
      //         .where((element) => element["MILIK"] == "REGULER")
      //         .toList();
      //   });

      //   print("listdropdown:");
      //   print(listDropdown);
      // });
    });

    duty_manager = "ABSEN";
    statusPegawai = "regular";
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
    // prefs.setString("nip", "");
    prefs.setString("pin", "");
    prefs.setString("template", "");
    prefs.setString("on_progres_visite", "");
    prefs.setString("jenisVisit", "");
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

  // Future _getCurrentLocation() async {
  //   Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
  //       .then((Position position) {
  //     setState(() {
  //       _currentPosition = position;
  //       latitude = _currentPosition!.latitude.toString();
  //       longitude = _currentPosition!.longitude.toString();
  //       altitude = _currentPosition!.altitude.toString();
  //       ismocklocation = _currentPosition!.isMocked;
  //       print(latitude);
  //       // print(latitude);
  //       cekLokasi(latitude!, longitude!).then((value) {
  //         // pr.hide();
  //         isLoading = false;
  //         // status_lokasi = "DIDALAM";
  //         print('->' + value);
  //         if (value == "success") {
  //           if (status_lokasi == "DIDALAM") {
  //             setState(() {
  //               ignoreAbsen = false;
  //             });
  //           } else {}
  //         } else {
  //           String e = "Anda berada di luar area kantor";
  //           errordialog(context, e);
  //         }
  //         return value;
  //       }).catchError((e) {
  //         print(e.toString());
  //         errordialog(context, e.toString());
  //       });
  //     });
  //   }).catchError((e) {
  //     print(e);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var list_dropdown;
    // if (statusPegawai == "regular") {
    //   list_dropdown = [
    //     DropdownMenuItem(value: "0", child: new Text("Shift 1")),
    // }
    // if (statusPegawai == "dm") {
    //   list_dropdown = [
    //     DropdownMenuItem(value: "0", child: new Text("Shift")),
    //     DropdownMenuItem(value: "003", child: new Text("Shift 1")),
    //     DropdownMenuItem(
    //         value: "013", child: new Text("Shift 1")),
    //     DropdownMenuItem(
    //         value: "014", child: new Text("Shift 1")),
    //     DropdownMenuItem(
    //         value: "015", child: new Text("Shift 1")),
    //     DropdownMenuItem(
    //         value: "016", child: new Text("Shift 1")),
    //     DropdownMenuItem(value: "017", child: new Text("Shift 1")),
    //     DropdownMenuItem(value: "018", child: new Text("Shift 1")),
    //     DropdownMenuItem(value: "019", child: new Text("Shift 1")),
    //     DropdownMenuItem(value: "020", child: new Text("Shift 1")),
    //     DropdownMenuItem(value: "021", child: new Text("Shift 1")),
    //     DropdownMenuItem(
    //         value: "022", child: new Text("Onsite Obgyn-Bedah-Anastesi")),
    //   ];
    // }
    // if (statusPegawai == "shift") {
    //   list_dropdown = [
    //     DropdownMenuItem(value: "0", child: new Text("Pilih Shift")),
    //     DropdownMenuItem(value: "006", child: new Text("Shift 1")),
    //     DropdownMenuItem(value: "007", child: new Text("Shift 1")),
    //     DropdownMenuItem(value: "008", child: new Text("Shift 1")),
    //     DropdownMenuItem(value: "009", child: new Text("Shift 1")),
    //     DropdownMenuItem(
    //         value: "010", child: new Text("Shift Ahli Gizi Jum'at")),
    //     DropdownMenuItem(value: "011", child: new Text("Shift 1")),
    //     DropdownMenuItem(value: "002", child: new Text("Shuft 1")),
    //     DropdownMenuItem(value: "001", child: new Text("Shift 1")),
    //     DropdownMenuItem(value: "004", child: new Text("Shift 1")),
    //     DropdownMenuItem(value: "005", child: new Text("Shift 1")),
    //   ];
    // }
    // pr = new ProgressDialog(context, isDismissible: false);
    // pr!.style(
    //     message: 'Mohon Tunggu...',
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
    var w_screen = MediaQuery.of(context).size.width;
    return Scaffold(
      bottomSheet: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        // child: IgnorePointer(
        //   ignoring: ignoreAbsen,
        child: Container(
          child: !isLoading
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: w_screen * 0.6,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            if (_image == null) {
                              // var alert = "Silakan Foto terlebih dahulu";
                              emptyimage(context);
                            } else {
                              // isLoading = true;
                              setState(() {
                                pin_int = int.parse(pin!);
                                // print(pin_int);
                                // return;
                                // confidence_level = value.toString();
                                confidence_double =
                                    double.parse(confidence_level);
                                // print(confidence_double);
                                // return;
                                if (confidence_double < 0.75) {
                                  highConfidence = false;
                                } else {
                                  highConfidence = true;
                                }
                                confindence_int = confidence_double.round();

                                insertAbsen(
                                        pin!,
                                        // latitude!,
                                        // longitude!,
                                        ip_address,
                                        confindence_int!,
                                        base64imagesave2!,
                                        // altitude!,
                                        shift,
                                        // mac_address,
                                        // duty_manager!,
                                        radioInOutValue!)
                                    .then((value) {
                                  // return;
                                  setState(() {
                                    print(value);
                                    if (value["response"][0]["code"] == "200") {
                                      isLoading = false;
                                      // pr.hide();
                                      dialogResult(context, highConfidence!)
                                          .then((value) {
                                        isLoading = false;
                                        Navigator.pop(context);
                                      });
                                    } else {
                                      // pr!.hide();
                                      errordialog(context,
                                              value["response"][0]["message"])
                                          .then((value) {
                                        // Navigator.pop(context);
                                      });
                                    }
                                  });
                                });
                              });
                              // }
                            }
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed))
                                return submitButton;
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
                                padding:
                                    EdgeInsets.fromLTRB(0.8, 0.8, 0.8, 0.8),
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
                  ],
                )
              : CircularProgressIndicator(
                  backgroundColor: submitButton,
                ),
        ),
        // ),
      ),
      appBar: AppBar(
        title: Text("Absensi"),
        actions: [
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
                  setState(() {});
                });
                // Navigator.pop(context);
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20),
                Container(
                  // width: w_screen * 0.95,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    // color: Colors.lightBlue
                  ),
                  padding: EdgeInsets.all(8),
                  // color: Colors.lightBlue,
                  child: Column(
                    children: [
                      statusIstirahat!
                          ? SizedBox()
                          : GestureDetector(
                              onTap: () {
                                if (isfaceregistered == true) {
                                  // pr.show();
                                  isLoading = false;
                                  getImage().then((value) {
                                    print('after get image');
                                    // _getCurrentLocation().then((value) {
                                    //   // setState(() {
                                    //   //   isLoading = false;
                                    //   // });
                                    //   print('AHAHAHAHAHA');
                                    faceMatcher().then((value) {
                                      setState(() {
                                        print(longitude.toString());
                                        print(status_lokasi.toString());
                                        isLoading = false;
                                        confidence_level = value.toString();
                                        confidence_double =
                                            double.parse(confidence_level);
                                        if (confidence_double < 0.8) {
                                          highConfidence = false;
                                        } else {
                                          highConfidence = true;
                                        }
                                        confindence_int =
                                            confidence_double.round();
                                        resultFaceMatcher(
                                            context, highConfidence!);
                                      });
                                    });
                                    // }).catchError((e) {
                                    //   // pr.hide();
                                    //   print('error location');
                                    //   setState(() {});
                                    //   isLoading = false;
                                    //   print(e);
                                    // });
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
                                  border:
                                      Border.all(width: 1, color: primaryColor),
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
                                            backgroundImage:
                                                FileImage(_image!)),
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
                      // Container(
                      //   child: Text("$name", style: TextStyle(fontSize: 24)),
                      // ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  // width: w_screen * 0.95,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Text("Jenis Absen",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 20)),
                          ],
                        ),
                      ),
                      Container(
                          // width: double.infinity,
                          height: 60,
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: jenisAbsen.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedJenisAbsen = index;
                                      if (jenisAbsen[index] == "Masuk") {
                                        statusIstirahat = false;
                                        radioInOutValue = 0;
                                        print(radioInOutValue);
                                      } else if (jenisAbsen[index] ==
                                          "Pulang") {
                                        statusIstirahat = false;
                                        radioInOutValue = 1;
                                        print(radioInOutValue);
                                      }
                                      print(statusIstirahat);
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: selectedJenisAbsen == index
                                            ? selectedRadioColor
                                            : radioColor),
                                    height: 20,
                                    width: 150,
                                    child: Center(
                                      child: Text("${jenisAbsen[index]}",
                                          style: TextStyle(
                                              color: selectedJenisAbsen == index
                                                  ? Colors.white
                                                  : Colors.black)),
                                    ),
                                  ),
                                );
                              })),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Text("Pegawai",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 20)),
                          ],
                        ),
                      ),
                      Container(
                        // width: double.infinity,
                        height: 60,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: jenisPgw.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  // listDropdown.clear();
                                  selectedJenisPgw = index;
                                  if (jenisPgw[index] == "Regular") {
                                    duty_manager = "ABSEN";
                                    statusPegawai = "regular";
                                    shift = "0";
                                    // listDropdown = listShift
                                    // .where((element) =>
                                    //     element["MILIK"] == "REGULER")
                                    // .toList();
                                  } else if (jenisPgw[index] ==
                                      "Duty Manager") {
                                    duty_manager = "DM";
                                    statusPegawai = "dm";
                                    shift = "0";
                                    // listDropdown = listShift
                                    // .where((element) =>
                                    //     element["MILIK"] == "DM")
                                    // .toList();
                                  } else if (jenisPgw[index] == "Shift") {
                                    duty_manager = "ABSEN";
                                    statusPegawai = "shift";
                                    shift = "0";
                                    // listDropdown = listShift
                                    //     .where((element) =>
                                    //         element["MILIK"] == "SHIFT")
                                    //     .toList();
                                  }
                                  // else if (jenisPgw[index] ==
                                  //     "On Site Dokter") {
                                  //   listShiftFilter.clear();
                                  //   statusPegawai = "shift";
                                  //   shift = "0";
                                  // }
                                  print(statusPegawai);
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: selectedJenisPgw == index
                                        ? selectedRadioColor
                                        : radioColor),
                                height: 20,
                                width: 150,
                                child: Center(
                                  child: Text(
                                    "${jenisPgw[index]}",
                                    style: TextStyle(
                                        color: selectedJenisPgw == index
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      // Container(
                      //   padding: EdgeInsets.all(8.0),
                      //   child: listDropdown != []
                      //       ? DropdownButtonFormField(
                      //           isExpanded: true,
                      //           // key: formKey,
                      //           items: listDropdown.map((dynamic map) {
                      //             print("item : $map");
                      //             return DropdownMenuItem(
                      //                 value: map["KODE_SHIFT"],
                      //                 child: Text(map["SHIFT"].toString()));
                      //           }).toList(),
                      //           // value: shift,
                      //           validator: (x) =>
                      //               x == null ? 'Shiftnya diisi dulu!' : null,
                      //           decoration: InputDecoration(
                      //               contentPadding: EdgeInsets.fromLTRB(
                      //                   20.0, 15.0, 20.0, 15.0),
                      //               hintText: "Shift",
                      //               labelText: "Shift",
                      //               prefixIcon: Icon(Icons.access_time),
                      //               border: OutlineInputBorder(
                      //                   borderRadius:
                      //                       BorderRadius.circular(10.0))),
                      //           onSaved: (value) {
                      //             setState(() {
                      //               shift = value!.toString();
                      //             });
                      //           },
                      //           onChanged: (value) {
                      //             setState(() {
                      //               shift = value!.toString();
                      //             });
                      //           },
                      //         )
                      //       : SizedBox(),
                      // ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),

                // statusIstirahat
                //     ? SizedBox()
                //     : RaisedButton.icon(
                //         onPressed: () {
                //           // getImage();
                //           if (isfaceregistered == true) {
                //             pr.show();
                //             getImage().then((value) {
                //               _getCurrentLocation().catchError((e) {
                //                 pr.hide();
                //                 print(e);
                //               });
                //             });
                //           } else {
                //             emptyimage(context);
                //           }
                //         },
                //         color: Colors.white70,
                //         shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(25.0),
                //             side: BorderSide(
                //               color: Colors.teal,
                //             )),
                //         elevation: 1,
                //         label: Text(
                //           "Ambil Foto",
                //           style: TextStyle(
                //             color: Colors.teal,
                //           ),
                //         ),
                //         icon: Icon(
                //           Icons.camera_alt,
                //           color: Colors.teal,
                //         )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
