import 'package:flutter/material.dart';
import 'package:lmaida/utils/SizeConfig.dart';

import 'components/body.dart';

class SignUpScreen extends StatelessWidget {
  static String routeName = "/sign_up";
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.red[900],
      body: new WillPopScope(onWillPop: () async => false, child: Body()),
    );
  }
}
