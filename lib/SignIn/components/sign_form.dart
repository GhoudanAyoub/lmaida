import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:lmaida/SignUp/sign_up_screen.dart';
import 'package:lmaida/components/custom_surfix_icon.dart';
import 'package:lmaida/components/default_button.dart';
import 'package:lmaida/components/form_error.dart';
import 'package:lmaida/helper/keyboard.dart';
import 'package:lmaida/service/auth_service.dart';
import 'package:lmaida/utils/SizeConfig.dart';
import 'package:lmaida/utils/constants.dart';
import 'package:lmaida/utils/firebase.dart';
import 'package:lmaida/utils/theme.dart';

class SignForm extends StatefulWidget {
  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _emailContoller = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool remember = false;
  final List<String> errors = [];
  AuthService auth = AuthService();

  var submitted = false;
  var buttonText = "Continue";
  String _token;
  FirebaseUser user;

  Position position;

  @override
  void initState() {
    getLastLocation();
    super.initState();
  }

  getLastLocation() async {
    setState(() {
      firebaseAuth.currentUser().then((value) {
        setState(() {
          user = value;
        });
      });
    });
    await FirebaseMessaging.instance.getToken().then((value) {
      setState(() {
        _token = value;
      });
    });

    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    await Geolocator.getLastKnownPosition();
  }

  void addError({String error}) {
    if (!errors.contains(error))
      setState(() {
        errors.add(error);
        submitted = false;
      });
  }

  void removeError({String error}) {
    if (errors.contains(error))
      setState(() {
        errors.remove(error);
      });
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      controller: _passwordController,
      obscureText: true,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.length >= 8) {
          removeError(error: kShortPassError);
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if (value.length < 8) {
          addError(error: kShortPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelStyle: textTheme().bodyText2,
        labelText: "Password",
        hintStyle: textTheme().bodyText2,
        hintText: "Enter your password",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      controller: _emailContoller,
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kEmailNullError);
        } else if (emailValidatorRegExp.hasMatch(value)) {
          removeError(error: kInvalidEmailError);
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kEmailNullError);
          return "";
        } else if (!emailValidatorRegExp.hasMatch(value)) {
          addError(error: kInvalidEmailError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        hintStyle: textTheme().bodyText2,
        labelStyle: textTheme().bodyText2,
        labelText: "Email",
        hintText: "Enter your email",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmailFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(20)),
          DefaultButton(
            text: buttonText,
            submitted: submitted,
            press: () async {
              AuthService auth = AuthService();
              if (_formKey.currentState.validate()) {
                submitted = true;
                KeyboardUtil.hideKeyboard(context);
                var success;
                var token;
                var cc;
                try {
                  success = await loginUser(
                      email: _emailContoller.text,
                      password: _passwordController.text);
                  token = await userLog(
                      email: _emailContoller.text,
                      password: _passwordController.text);
                  if (token != null && success == null) {
                    await firebaseAuth.createUserWithEmailAndPassword(
                        email: _emailContoller.text,
                        password: _passwordController.text);
                    cc = await getPorf(token);
                    try {
                      await usersRef.doc(user.uid).set({
                        'username': cc,
                        'email': _emailContoller.text,
                        'id': user.uid,
                        'contact': "",
                        'photoUrl': user.photoUrl,
                        'password': _passwordController.text
                      });
                    } catch (e) {
                      print(e);
                    }
                    getId(token).then((value) => addToken(token, value));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Welcome Back'),
                      duration: Duration(seconds: 2),
                    ));
                  } else if (success != null && token != null) {
                    getId(token).then((value) => addToken(token, value));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Welcome Back'),
                        duration: Duration(seconds: 2)));
                  } else if (token == null && success == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("You Don't Have Account Yet"),
                        duration: Duration(seconds: 2)));
                    Navigator.pushNamed(context, SignUpScreen.routeName);
                  } else {
                    addError(error: success);
                    submitted = false;
                  }
                } catch (e) {
                  submitted = false;
                  addError(error: success);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text("${auth.handleFirebaseAuthError(e.toString())}"),
                      duration: Duration(seconds: 2)));
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future loginUser({String email, String password}) async {
    FirebaseUser result;
    var errorType;
    try {
      result = await firebaseAuth.signInWithEmailAndPassword(
        email: '$email',
        password: '$password',
      );
    } catch (e) {
      switch (e) {
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          errorType = "No Account For This Email";
          break;
        case 'The password is invalid or the user does not have a password.':
          errorType = "Password Invalid";
          break;
        case 'A network error (interrupted connection or unreachable host) has occurred.':
          errorType = "Connection Error";
          break;
        default:
          print('Case $errorType is not yet implemented');
      }
    }
    if (errorType != null) return errorType;
    if (result != null) return result.uid;
  }

  Future userLog({String email, String password}) async {
    Map<String, String> header = {
      "Accept": "application/json",
      "Content-Type": "application/json"
    };
    var url = 'https://lmaida.com/api/login';
    var data = {
      'email': email,
      'password': password,
    };
    var response = await http.post(Uri.encodeFull(url),
        headers: header, body: json.encode(data));
    var res = jsonDecode(response.body);
    return res['token'];
  }

  Future<dynamic> getPorf(token) async {
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
      "Content-Type": "application/json"
    };
    var url = 'https://lmaida.com/api/profile';
    var response = await http.post(Uri.encodeFull(url), headers: header);
    var message = jsonDecode(response.body);
    return message[0]['name'];
  }

  Future<dynamic> getId(token) async {
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
      "Content-Type": "application/json"
    };
    var url = 'https://lmaida.com/api/profile';
    var response = await http.post(Uri.encodeFull(url), headers: header);
    var message = jsonDecode(response.body);
    return message[0]['id'];
  }

  Future addToken(token, userId) async {
    var url = 'https://lmaida.com/api/token';
    var dio = Dio();
    var options = Options(validateStatus: (status) => true, headers: {
      "Authorization": "Bearer $token",
    });
    var formData = FormData.fromMap({
      'token': _token,
      'id': userId.toString(),
    });
    await dio.post(url, data: formData, options: options);
    usersToken.doc(userId.toString()).set({"token": _token});
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
