import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lmaida/utils/constants.dart';

Center circularProgress(context) {
  return Center(
    child: SpinKitFadingCircle(
      size: 40.0,
      color: mainColor,
    ),
  );
}

Container linearProgress(context) {
  return Container(
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Theme.of(context).accentColor),
    ),
  );
}
