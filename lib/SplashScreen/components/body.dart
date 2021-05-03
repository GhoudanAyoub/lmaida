import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lmaida/Home/HomePage.dart';

import '../components/splash_content.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int currentPage = 0;
  Position position;

  @override
  void initState() {
    new Future.delayed(Duration(seconds: 3), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: SplashContent(),
        ),
      ),
    );
  }
}
