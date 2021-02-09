import 'package:flutter/material.dart';

class SplashContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Spacer(),
          Image.asset(
            "assets/images/lmaida_white.png",
            height: 500,
            width: 500,
          ),
          Spacer(),
          Spacer(),
        ],
      ),
    );
  }
}
