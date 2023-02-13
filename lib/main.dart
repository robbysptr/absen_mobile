import 'package:absen_rpm/style/color.dart';
import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:absen_rpm/ui/login_page.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:absen_rpm/splashscreen_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? base64imagesave;

  bool? isLoggedIn;

  Future<bool> getData() async {
    LocalStorageInterface prefs = await LocalStorage.getInstance();
    base64imagesave = prefs.getString('base64image') ?? "";
    setState(() {});
    return true;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData().then((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/loginPage': (context) => LoginPage()
        },
        builder: (context, child) => ResponsiveWrapper.builder(
          child,
          maxWidth: 500,
          minWidth: 400,
          breakpoints: [],
          defaultScale: true,
        ),
        theme: ThemeData(
            fontFamily: 'Poppins',
            primaryColor: primaryColor,
            primarySwatch: Colors.teal,
            bottomSheetTheme: BottomSheetThemeData(
                backgroundColor: Colors.black.withOpacity(0)),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: Colors.black.withOpacity(0))),
        home: LoginPage(),
      ),
    );
  }
}
