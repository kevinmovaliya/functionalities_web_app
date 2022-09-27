import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:functionalities_web_app/utils/appRoutes.dart';
import 'package:functionalities_web_app/utils/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: HomePage(),
      initialRoute: AppRoutes().homePage,
      routes: routes,
    );
  }
}
