
import 'package:flutter/material.dart';
import 'dart:io';

import 'vw_api.dart';
import 'login.dart';


void main() {
  //HttpOverrides.global = MyProxyHttpOverride();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    VWConnector conn = VWConnector("abs", "bcd");
    return MaterialApp(
      title: 'Ersatzlounge',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}


class MyProxyHttpOverride extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..findProxy = (uri) {
        return "PROXY 172.16.4.64:8888;";
      }
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
