import 'package:flutter/material.dart';
import 'package:lmaida/SignIn/sign_in_screen.dart';
import 'package:lmaida/SignUp/sign_up_screen.dart';
import 'package:lmaida/SplashScreen/splash_screen.dart';
import 'package:lmaida/forgot_password/forgot_password_screen.dart';

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  ForgotPasswordScreen.routeName: (context) => ForgotPasswordScreen(),
  SignInScreen.routeName: (context) => SignInScreen(),
  SignUpScreen.routeName: (context) => SignUpScreen()
};
