import 'dart:convert';
import 'dart:io';

import 'package:absen_rpm/style/color.dart';
import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:absen_rpm/dialogs/login_alert.dart';
import 'package:absen_rpm/ui/home_page.dart';
import 'package:absen_rpm/ui/ok_page.dart';
import 'package:absen_rpm/ui/register_page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:progress_dialog/progress_dialog.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _pin = new TextEditingController();

  // ProgressDialog? pr;
  String? pin;
  String? password;

  String? templateFace;

  String? base64imagesave;

  bool isfaceregistered = false;

  File? pickedImage;

  String? radioButtonText;
  int radioButtonValue = 1;

  final formKey = new GlobalKey<FormState>();

  List loginOption = [
    'Absen',
  ];
  int selectedLoginOption = 0;

  Future<bool> getData() async {
    LocalStorageInterface prefs = await LocalStorage.getInstance();
    base64imagesave = prefs.getString('base64image') ?? "";
    pin = prefs.getString('pin') ?? "";
    templateFace = prefs.getString('template') ?? "";

    setState(() {});
    return true;
  }

  updateState(String image) async {
    LocalStorageInterface prefs = await LocalStorage.getInstance();
    prefs.setString("base64image", image);
    setState(() {});
  }

  Future decodetoimage() async {
    final directory = await getApplicationDocumentsDirectory();
    final gambar = base64Decode(base64imagesave!);
    setState(() {
      pickedImage = File("${directory.path}/aaa2.jpg");
      pickedImage!.writeAsBytesSync(List.from(gambar));
    });
  }

  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData().then((_) {
      print(pin);
      print("template:");
      print(templateFace);
      if (templateFace != "") {
        isfaceregistered = true;
        _pin.text = pin!;
      }
      // decodetoimage();
    });
  }

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  Widget build(BuildContext context) {
    // print(MediaQuery.of(context).size.width);
    // pr = new ProgressDialog(context);
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

    final pinField = TextFormField(
      // keyboardType: TextInputType.number,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          // hintText: "PIN",
          labelText: "Nomor PIN",
          prefixIcon: Icon(Icons.assignment),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final loginButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.teal,
      child: MaterialButton(
          minWidth: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              if (pin != "") {
                if (radioButtonValue == 1) {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => HomePage()))
                      .then((value) {
                    setState(() {
                      getData().then((_) {
                        if (templateFace != "") {
                          isfaceregistered = true;
                          _pin.text = pin!;
                        } else {
                          isfaceregistered = false;
                        }
                      });
                    });
                  });
                }

                if (radioButtonValue == 2) {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => OkPage()))
                      .then((value) {
                    setState(() {
                      getData().then((_) {
                        if (templateFace != "") {
                          isfaceregistered = true;
                          _pin.text = pin!;
                        } else {
                          isfaceregistered = false;
                        }
                      });
                    });
                  });
                }
              } else {
                login_error(context);
              }
              // });
              // });
            }
          },
          child: Text(
            "Login",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color.fromARGB(255, 82, 77, 77)),
          )),
    );

    final registerButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color.fromARGB(255, 243, 3, 143),
      child: Visibility(
        visible: isfaceregistered ? false : true,
        child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            onPressed: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => RegisterPage()))
                  .then((_) {
                setState(() {
                  getData().then((_) {
                    if (templateFace != "") {
                      isfaceregistered = true;
                      _pin.text = pin!;
                    } else {
                      isfaceregistered = false;
                    }
                  });
                });
              });
            },
            child: Text(
              "Register",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color.fromARGB(92, 255, 255, 255)),
            )),
      ),
    );
    Size size = MediaQuery.of(context).size;
    var wScreen = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
            padding: EdgeInsets.all(25),
            child: Form(
              key: formKey,
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 100,
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Center(
                    child: Text(
                      'Absen Mobile'.toUpperCase(),
                      style: TextStyle(
                          color: Color(0xff3B3B3B),
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      'PT Rekayasa Prima Mandiri'.toUpperCase(),
                      style: TextStyle(color: Color(0xff828282), fontSize: 12),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Image.asset(
                      'assets/smile.png',
                      width: 230,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: Color(0xffF8F1F1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextFormField(
                      controller: _pin,
                      decoration: InputDecoration(
                        labelText: "PIN",
                        hintText: "PIN",
                        border: InputBorder.none,
                      ),
                      readOnly: true,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 30,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: loginOption.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedLoginOption = index;
                                if (loginOption[index] == "Absen") {
                                  radioButtonValue = 1;
                                } else if (loginOption[index] == "OK") {
                                  radioButtonValue = 2;
                                }
                                print(radioButtonValue);
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: selectedLoginOption == index
                                      ? selectedRadioLogin
                                      : radioLogin),
                              height: 20,
                              width: 60,
                              child: Center(
                                child: Text("${loginOption[index]}",
                                    style: TextStyle(
                                        color: selectedLoginOption == index
                                            ? Colors.white
                                            : Colors.black)),
                              ),
                            ),
                          );
                        }),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        if (pin != "") {
                          if (radioButtonValue == 1) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        HomePage())).then((value) {
                              setState(() {
                                getData().then((_) {
                                  if (templateFace != "") {
                                    isfaceregistered = true;
                                    _pin.text = pin!;
                                  } else {
                                    isfaceregistered = false;
                                  }
                                });
                              });
                            });
                          }
                          if (radioButtonValue == 2) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        OkPage())).then((value) {
                              setState(() {
                                getData().then((_) {
                                  if (templateFace != "") {
                                    isfaceregistered = true;
                                    _pin.text = pin!;
                                  } else {
                                    isfaceregistered = false;
                                  }
                                });
                              });
                            });
                          }
                        } else {
                          login_error(context);
                        }
                        // });
                        // });
                      }
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 234, 182, 39),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: TextButton(
                          child: Text(
                            'Login',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: null,
                          // onPressed: () {
                          //   if (formKey.currentState!.validate()) {
                          //     formKey.currentState!.save();
                          //     if (pin != "") {
                          //       if (radioButtonValue == 1) {
                          //         Navigator.push(
                          //             context,
                          //             MaterialPageRoute(
                          //                 builder: (BuildContext context) =>
                          //                     HomePage())).then((value) {
                          //           setState(() {
                          //             getData().then((_) {
                          //               if (templateFace != "") {
                          //                 isfaceregistered = true;
                          //                 _nip.text = pin!;
                          //               } else {
                          //                 isfaceregistered = false;
                          //               }
                          //             });
                          //           });
                          //         });
                          //       }
                          //       if (radioButtonValue == 2) {
                          //         if (progresVisite == 'y') {
                          //           Navigator.push(
                          //               context,
                          //               MaterialPageRoute(
                          //                   builder: (BuildContext context) =>
                          //                       VisitePage())).then((value) {
                          //             setState(() {
                          //               getData().then((_) {
                          //                 if (templateFace != "") {
                          //                   isfaceregistered = true;
                          //                   _nip.text = pin!;
                          //                 } else {
                          //                   isfaceregistered = false;
                          //                 }
                          //               });
                          //             });
                          //           });
                          //         } else {
                          //           Navigator.push(
                          //               context,
                          //               MaterialPageRoute(
                          //                   builder: (BuildContext context) =>
                          //                       AbsenVisitePage())).then(
                          //               (value) {
                          //             setState(() {
                          //               getData().then((_) {
                          //                 if (templateFace != "") {
                          //                   isfaceregistered = true;
                          //                   _nip.text = pin!;
                          //                 } else {
                          //                   isfaceregistered = false;
                          //                 }
                          //               });
                          //             });
                          //           });
                          //         }
                          //       }
                          //       if (radioButtonValue == 3) {
                          //         Navigator.push(
                          //             context,
                          //             MaterialPageRoute(
                          //                 builder: (BuildContext context) =>
                          //                     OkPage())).then((value) {
                          //           setState(() {
                          //             getData().then((_) {
                          //               if (templateFace != "") {
                          //                 isfaceregistered = true;
                          //                 _nip.text = pin!;
                          //               } else {
                          //                 isfaceregistered = false;
                          //               }
                          //             });
                          //           });
                          //         });
                          //       }
                          //     } else {
                          //       login_error(context);
                          //     }
                          //     // });
                          //     // });
                          //   }
                          // },
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: templateFace != "" ? false : true,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(color: Colors.transparent
                          // borderRadius: BorderRadius.circular(5),
                          ),
                      child: Center(
                        child: TextButton(
                          child: Text('Register'),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        RegisterPage())).then((_) {
                              setState(() {
                                getData().then((_) {
                                  if (templateFace != "") {
                                    isfaceregistered = true;
                                    _pin.text = pin!;
                                  } else {
                                    isfaceregistered = false;
                                  }
                                });
                              });
                            });
                          },
                        ),
                        // child: FlatButton(
                        //   child: Text('Register'),
                        //   onPressed: () {
                        //     Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: (BuildContext context) =>
                        //                 RegisterPage())).then((_) {
                        //       setState(() {
                        //         getData().then((_) {
                        //           if (templateFace != "") {
                        //             isfaceregistered = true;
                        //             _nip.text = pin;
                        //           } else {
                        //             isfaceregistered = false;
                        //           }
                        //         });
                        //       });
                        //     });
                        //   },
                        // ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      )),
    );
    // Scaffold(
    //   body: SingleChildScrollView(
    //     child: Center(
    //       child: Container(
    //         child: Padding(
    //           padding: const EdgeInsets.all(30.0),
    //           child: Form(
    //             key: formKey,
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.center,
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 SizedBox(
    //                   height: 200.0,
    //                   child: Image.asset(
    //                     "assets/logo.png",
    //                     height: 100.0,
    //                     width: 100.0,
    //                     fit: BoxFit.contain,
    //                   ),
    //                 ),
    //                 SizedBox(height: 10.0),
    //                 pinField,
    //                 SizedBox(height: 20.0),
    //                 Row(
    //                   children: [
    //                     Radio(
    //                       value: 1,
    //                       groupValue: radioButtonValue,
    //                       onChanged: (val) {
    //                         setState(() {
    //                           radioButtonText = "Absen";
    //                           radioButtonValue = val;
    //                         });
    //                       },
    //                     ),
    //                     Text("Absen"),
    //                     Radio(
    //                       value: 2,
    //                       groupValue: radioButtonValue,
    //                       onChanged: (val) {
    //                         setState(() {
    //                           radioButtonText = "Visit";
    //                           radioButtonValue = val;
    //                         });
    //                       },
    //                     ),
    //                     Text("Visit"),
    //                     Radio(
    //                       value: 3,
    //                       groupValue: radioButtonValue,
    //                       onChanged: (val) {
    //                         setState(() {
    //                           radioButtonText = "OK";
    //                           radioButtonValue = val;
    //                         });
    //                       },
    //                     ),
    //                     Text("OK"),
    //                   ],
    //                 ),
    //                 SizedBox(
    //                   height: 20.0,
    //                 ),
    //                 loginButton,
    //                 SizedBox(
    //                   height: 15.0,
    //                 ),
    //                 registerButton,
    //                 SizedBox(
    //                   height: 15.0,
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
