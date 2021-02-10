import 'package:flutter/material.dart';
import 'package:lmaida/SignIn/sign_in_screen.dart';

class GotAccountText extends StatelessWidget {
  GotAccountText({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "I have an account ",
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, SignInScreen.routeName),
          child: Text(
            "Sign In",
            style: TextStyle(fontSize: 14, color: Colors.red[900]),
          ),
        ),
      ],
    );
  }
}
