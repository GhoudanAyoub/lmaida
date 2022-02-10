import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lmaida/SignUp/sign_up_screen.dart';
import 'package:lmaida/components/custom_surfix_icon.dart';
import 'package:lmaida/components/default_button.dart';
import 'package:lmaida/components/form_error.dart';
import 'package:lmaida/helper/keyboard.dart';
import 'package:lmaida/service/remote_service.dart';
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

  var submitted = false;
  var buttonText = "Continue";
  String _token;

  Position position;

  @override
  void initState() {
    getLastLocation();
    super.initState();
  }

  getLastLocation() async {
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
              if (_formKey.currentState.validate()) {
                submitted = true;
                KeyboardUtil.hideKeyboard(context);
                var success;
                var Token;
                var cc;
                try {
                  success = await RemoteService.loginUser(
                      email: _emailContoller.text,
                      password: _passwordController.text);
                  Token = await RemoteService.userLog(
                      email: _emailContoller.text,
                      password: _passwordController.text);

                  if (Token != null && success == null) {
                    var res = await firebaseAuth.createUserWithEmailAndPassword(
                        email: _emailContoller.text,
                        password: _passwordController.text);
                    cc = await RemoteService.getProfile();
                    try {
                      await usersRef.doc(firebaseAuth.currentUser.uid).set({
                        'username': cc['name'],
                        'email': _emailContoller.text,
                        'id': firebaseAuth.currentUser.uid,
                        'contact': "",
                        'photoUrl': firebaseAuth.currentUser.photoURL,
                        'password': _passwordController.text
                      });
                    } catch (e) {
                      print(e);
                    }
                    RemoteService.getProfile().then((value) =>
                        RemoteService.addToken(Token, value['id'], _token));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Welcome Back'),
                      duration: Duration(seconds: 2),
                    ));
                  } else if (success != null && Token != null) {
                    RemoteService.getProfile().then((value) =>
                        RemoteService.addToken(Token, value['id'], _token));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Welcome Back'),
                        duration: Duration(seconds: 2)));
                  } else if (Token == null && success == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("You Don't Have Account Yet"),
                        duration: Duration(seconds: 2)));
                    Navigator.pushNamed(context, SignUpScreen.routeName);
                  } else if (success != null && Token == null) {
                    RemoteService.getProfile().then((value) =>
                        RemoteService.addToken(Token, value['id'], _token));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Welcome Back'),
                        duration: Duration(seconds: 2)));
                  } else {
                    addError(error: success);
                    submitted = false;
                  }
                } catch (e) {
                  submitted = false;
                  addError(error: success);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          "${RemoteService.handleFirebaseAuthError(e.toString())}"),
                      duration: Duration(seconds: 2)));
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
