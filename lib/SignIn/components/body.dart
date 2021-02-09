import 'package:flutter/material.dart';
import 'package:lmaida/components/no_account_text.dart';
import 'package:lmaida/forgot_password/forgot_password_screen.dart';
import 'package:lmaida/utils/SizeConfig.dart';

import 'sign_form.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  "assets/images/lmaida_white.png",
                  color: Colors.red,
                ),
                Text(
                  "Welcome back",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: getProportionateScreenWidth(28),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),
                SignForm(),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                      context, ForgotPasswordScreen.routeName),
                  child: Text(
                    "Forgot your Password?",
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
                SizedBox(height: 20),
                NoAccountText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
