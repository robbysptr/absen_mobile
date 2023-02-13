import 'dart:convert';
import 'dart:io';

import 'package:absen_rpm/style/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = new GlobalKey<FormState>();

  final TextEditingController _nama = new TextEditingController();
  final TextEditingController _pin = new TextEditingController();

  String? name;
  String? pin;
  String? templateFace;

  File? _image;
  final picker = ImagePicker();

  File? pickedImage;
  var imageFile;

  String? base64image;

  String? base64imagesave;

  String? _retrieveDataError;

  bool button_disable = true;
  bool isfaceregistered = false;
  bool isfaceappear = false;
  FileImage? image;

  // ProgressDialog? pr;

  bool isLoading = false;

  Future updateState(
    String? image,
    String? pin,
    String? name,
    String? template,
  ) async {
    LocalStorageInterface prefs = await LocalStorage.getInstance();
    prefs.setString("base64image", image!);
    prefs.setString("name", name!);
    prefs.setString("pin", pin!);
    prefs.setString("template", template!);
    setState(() {});
  }

  Future<bool> getData() async {
    LocalStorageInterface prefs = await LocalStorage.getInstance();
    base64imagesave = prefs.getString('base64image') ?? "";
    name = prefs.getString('name') ?? "";
    pin = prefs.getString('pin') ?? "";
    templateFace = prefs.getString("template") ?? "";

    setState(() {});
    return true;
  }

  Future<File?> compressImage(File file) async {
    final directory = await getTemporaryDirectory();
    String targetPath = "${directory.path}/imagesaved.jpg";
    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, targetPath,
        // quality: 75,
        // minHeight: 400,
        // minWidth: 300,
        format: CompressFormat.jpeg);

    return result;
  }

  Future setImage(dynamic fileImage) async {
    imageFile = await fileImage.readAsBytes();
    imageFile = await decodeImageFromList(imageFile);
  }

  Future getImage() async {
    imageCache.clear();
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, maxWidth: 300);
    imageFile = await pickedFile!.readAsBytes();
    imageFile = await decodeImageFromList(imageFile);

    setState(() {
      pickedImage = File(pickedFile.path);
      isLoading = true;
      List<int> imageBytes = pickedImage!.readAsBytesSync();
      base64image = base64Encode(imageBytes);
      getTemplate();
      //   });
      // });
    });
  }

  Future decodetoimage() async {
    final directory = await getApplicationDocumentsDirectory();
    final gambar = base64Decode(base64imagesave!);
    setState(() {
      pickedImage = File("${directory.path}/imagesaved.jpg");
      pickedImage!.writeAsBytesSync(List.from(gambar));
      List<int> imageBytes = pickedImage!.readAsBytesSync();
      base64image = base64Encode(imageBytes);
    });
  }

  Future getTemplate() async {
    var url = Uri.http("202.157.184.205:5000", "/api/facematcher");
    // var url = Uri.http("118.97.147.27:8080", "/api/facematcher");

    var map = new Map<String, dynamic>();
    map['imagebase64'] = '$base64image';
    String bodySend = """
    {
      "name" : "$pin" ,  
      "imagebase64" : "$base64image"
    }
    """;

    try {
      print("base64");
      print(base64image);

      http.Response response = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: bodySend);

      var data = json.decode(response.body);
      templateFace = data['response'];
      print("template:");
      print(templateFace);
      setState(() {
        isLoading = false;
      });
      // print(data);
      // var confidence = data["confidence"];

      // return confidence.toString();
    } on SocketException catch (e) {
      print(e);
      return 0.toString();
    }
  }

  var listPinNama = [];

  Future<dynamic> getPinNama() async {
    dynamic url = Uri.http('127.0.0.1:8000', "/pin_nama");

    try {
      http.Response response = await http.get(url);

      var data = json.decode(response.body);
      listPinNama = data;
      print(listPinNama);

      return data;
    } on Exception {}
  }

  Future<dynamic> getPinNamabypin(pin) async {
    dynamic url = Uri.http('192.168.1.10:8000', "/pin_nama_bypin/" + pin);

    try {
      http.Response response = await http.get(url);

      var data = json.decode(response.body);
      //listPinNama = data;
      //print(listPinNama);
      // print(data);

      return data;
    } on Exception {}
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPinNama();
    getData().then((_) {
      print("ini template");
      print(templateFace);
      _nama.text = name!;
      _pin.text = pin!;
      if (base64imagesave == "") {
        isfaceregistered = false;
      } else {
        isfaceregistered = true;
        decodetoimage();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var wScreen = MediaQuery.of(context).size.width;
    // pr = new ProgressDialog(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Register Face"),
        actions: [
          Container(
              padding: EdgeInsets.all(10),
              child: !isLoading
                  ? ElevatedButton.icon(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.resolveWith<
                                RoundedRectangleBorder>(
                            (Set<MaterialState> states) {
                          return RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              side: BorderSide(
                                color: primaryColor,
                              ));
                        }),
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed))
                              return Colors.white;
                            return Colors.white; // Use the component's default.
                          },
                        ),
                      ),
                      // color: Colors.white,
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(25.0),
                      //     side: BorderSide(
                      //       color: primaryColor,
                      //     )),
                      // elevation: 1,
                      label: Text(
                        'Simpan',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      icon: Icon(
                        Icons.save,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          if (pickedImage == null) {
                            emptyimage(context);
                          } else {
                            updateState(
                                    base64image!, pin!, name!, templateFace!)
                                .then((value) {
                              ((_) {
                                getData().then((_) {
                                  // print(pin);
                                  // setState(() {});
                                }).then((_) {
                                  Navigator.pop(context);
                                });
                              });
                            });
                          }
                        }
                      },
                    )
                  : CircularProgressIndicator())
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isLoading = true;
                      });
                      getImage().then((value) {
                        // print(base64image);
                        // _getCurrentLocation().catchError((e) {
                        // pr.hide();
                        // getTemplate().then((value) {
                        setState(() {
                          isLoading = false;
                        });
                        // });
                      });
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
                      child: pickedImage == null
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
                                  backgroundImage: FileImage(pickedImage!)),
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
                  //   // padding: EdgeInsets.all(5),
                  //   width: 100,
                  //   height: 100,
                  //   // color: Colors.black38,
                  //   decoration: BoxDecoration(
                  //     shape: BoxShape.circle,
                  //     border: Border.all(width: 2, color: primaryColor),
                  //     color: submitButton,
                  //     // borderRadius: BorderRadius.circular(10)
                  //   ),
                  //   child: pickedImage == null
                  //       ? Container(
                  //           child: Center(child: Text('No Image Selected.')))
                  //       : CircleAvatar(
                  //           backgroundImage: FileImage(pickedImage),
                  //         ),
                  // ),
                  // Container(
                  //   child: RaisedButton.icon(
                  //     color: submitButton,
                  //     shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(10.0),
                  //         side: BorderSide(
                  //           color: submitButton,
                  //         )),
                  //     elevation: 1,
                  //     label: Text(
                  //       "Ambil Gambar",
                  //       style: TextStyle(
                  //         color: Colors.white,
                  //       ),
                  //     ),
                  //     icon: Icon(
                  //       Icons.camera_alt,
                  //       color: Colors.white,
                  //     ),
                  //     onPressed: () {
                  //       getImage();
                  //       button_disable = false;
                  //     },
                  //   ),
                  // ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Container(
                        width: wScreen * 0.54,
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _pin,
                          onSaved: (value) {
                            pin = value;
                          },
                          validator: (value) =>
                              value == "" ? 'PIN harus di isi' : null,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              labelText: "PIN",
                              prefixIcon: Icon(Icons.assignment),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0))),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        width: 140,
                        child: ElevatedButton.icon(
                          label: Text("Cek PIN",
                              style: TextStyle(color: Colors.white)),
                          icon: Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.resolveWith<
                                    RoundedRectangleBorder>(
                                (Set<MaterialState> states) {
                              return RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(
                                    color: submitButton,
                                  ));
                            }),
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
                          // shape: RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.circular(10.0),
                          //     side: BorderSide(
                          //       color: submitButton,
                          //     )),
                          onPressed: () {
                            var tempPIN = _pin.text;
                            // print(tempPIN);
                            if (_pin.text == "") {
                              errorPIN(context);
                              _nama.text = "";
                            } else {
                              // ambil pegawai berdasarkan pin pegawai
                              getPinNamabypin(tempPIN).then((value) {
                                print(value[0]['nama']);
                                setState(() {
                                  // print(value);
                                  _nama.text = value[0]['nama'];
                                });
                              });
                            }
                            // for (int index = 0;
                            //     index < listPinNama.length;
                            //     index++) {
                            //   if (_pin.text == listPinNama[index]["PIN"]) {
                            //     pin = _pin.text;
                            //     _nama.text = listPinNama[index]["NAMA"];
                            //     // break;
                            //   } else if ((_pin.text !=
                            //           listPinNama[index]["PIN"]) ||
                            //       _pin.text == "") {
                            //     errorPIN(context);
                            //     _nama.text = "";
                            //     break;
                            //   }
                            // else {
                            //   errorPIN(context);
                            //   _nama.text = "";
                            //   break;
                            // }
                            // }
                          },
                        ),
                      )
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: TextFormField(
                      readOnly: true,
                      // enabled: false,
                      controller: _nama,
                      onChanged: (v) {
                        name = v;
                      },
                      onSaved: (value) {
                        name = value;
                      },
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          labelText: "Nama",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

  Future<bool> errorPIN(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            content: Text("PIN tidak terdaftar!"),
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
}
