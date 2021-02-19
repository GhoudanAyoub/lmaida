import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lmaida/sidebar/sidebar_layout.dart';

class HomePage extends StatefulWidget {
  final position;

  const HomePage({Key key, this.position}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: SideBarLayout(),
    );
  }
}
