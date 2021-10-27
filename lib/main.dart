import 'package:flutter/material.dart';
import 'package:quizstar/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Quizstar",
      theme: ThemeData(
        backgroundColor: Colors.amber.shade300,
        //primarySwatch: Colors.indigo,
      ),
      home: homepage(),//splashscreen(),
    );
  }
}