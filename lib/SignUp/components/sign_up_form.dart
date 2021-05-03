import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lmaida/components/custom_surfix_icon.dart';
import 'package:lmaida/components/default_button.dart';
import 'package:lmaida/components/form_error2.dart';
import 'package:lmaida/profile/user_view_model.dart';
import 'package:lmaida/service/auth_service.dart';
import 'package:lmaida/utils/SizeConfig.dart';
import 'package:lmaida/utils/constants.dart';
import 'package:lmaida/utils/theme.dart';
import 'package:provider/provider.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  var submitted = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _namentoller = TextEditingController();
  TextEditingController _countryContoller = TextEditingController();
  TextEditingController _emailContoller = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String email;
  String password;
  String conform_password;
  bool remember = false;
  AuthService authService = AuthService();
  final List<String> errors = [];

  Position position;

  @override
  void initState() {
    getLastLocation();
    super.initState();
  }

  getLastLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var lastPosition = await Geolocator.getLastKnownPosition();
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

  @override
  Widget build(BuildContext context) {
    UserViewModel viewModel = Provider.of<UserViewModel>(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              elevation: 10.0,
              child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      buildENameFormField(),
                      SizedBox(height: getProportionateScreenHeight(30)),
                      buildEContactFormField(),
                      SizedBox(height: getProportionateScreenHeight(30)),
                      buildEmailFormField(),
                      SizedBox(height: getProportionateScreenHeight(30)),
                      buildPasswordFormField(),
                      SizedBox(height: getProportionateScreenHeight(30)),
                      buildConformPassFormField(),
                      FormError2(errors: errors),
                      SizedBox(height: getProportionateScreenHeight(40)),
                    ],
                  ))),
          SizedBox(height: getProportionateScreenHeight(20)),
          DefaultButton(
            text: "SIGN UP",
            submitted: submitted,
            press: () async {
              try {
                if (_formKey.currentState.validate()) {
                  submitted = true;
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Please Wait...')));
                  String success = await authService.createUser(
                    name: _namentoller.text,
                    email: _emailContoller.text,
                    password: _passwordController.text,
                    country: _countryContoller.text,
                  );
                  print(success);
                  if (success != null) {
                    viewModel.setToken(success);
                    /*Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomePage(
                                  position: position,
                                )));*/
                    Navigator.pop(context);
                    Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text('Congratulation Your Account Created')));
                  }
                }
              } catch (e) {
                print(e);
                var r = e.toString().split(']');
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text(r[1])));
              }
            },
          ),
        ],
      ),
    );
  }

  void emailExists() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: Colors.grey[800],
              ),
              height: 190,
              child: Column(
                children: [
                  Container(
                    height: 140,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          child: Text(
                            'This Email is on Another Account',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 30, right: 25, top: 15),
                          child: Text(
                            "You can log into the account associated with that email.",
                            style: TextStyle(color: Colors.white60),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 0,
                    height: 0,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FlatButton(
                      onPressed: () {
                        Navigator.popUntil(
                            context, ModalRoute.withName('/HomeScreen'));
                      },
                      child: Text(
                        'Log in to Existing Account',
                        style: TextStyle(color: Colors.lightBlue[400]),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  TextFormField buildConformPassFormField() {
    return TextFormField(
      style: TextStyle(color: Colors.black),
      obscureText: true,
      onSaved: (newValue) => conform_password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.isNotEmpty && password == conform_password) {
          removeError(error: kMatchPassError);
        }
        conform_password = value;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if ((password != value)) {
          addError(error: kMatchPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Confirm Password",
        hintText: "Re-enter your password",
        labelStyle: textTheme().headline1,
        hintStyle: textTheme().headline1,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      style: TextStyle(color: Colors.black),
      controller: _passwordController,
      obscureText: true,
      onSaved: (newValue) => password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.length >= 8) {
          removeError(error: kShortPassError);
        }
        password = value;
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
        labelText: "Password",
        hintText: "Enter your password",
        labelStyle: textTheme().headline1,
        hintStyle: textTheme().headline1,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      style: TextStyle(color: Colors.black),
      controller: _emailContoller,
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email = newValue,
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
        labelStyle: textTheme().headline1,
        hintStyle: textTheme().headline1,
        labelText: "Email",
        hintText: "Enter your email",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
      ),
    );
  }

  TextFormField buildENameFormField() {
    return TextFormField(
      style: TextStyle(color: Colors.black),
      controller: _namentoller,
      keyboardType: TextInputType.name,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kNameNullError);
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kNameNullError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelStyle: textTheme().headline1,
        hintStyle: textTheme().headline1,
        labelText: "Name",
        hintText: "Enter your name",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }

  TextFormField buildEContactFormField() {
    return TextFormField(
      style: TextStyle(color: Colors.black),
      controller: _countryContoller,
      keyboardType: TextInputType.phone,
      onChanged: (value) {
        if (value.isNotEmpty || value.length == 13) {
          removeError(error: kPhoneNumberNullError);
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty || value.length != 13) {
          addError(error: kPhoneNumberNullError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelStyle: textTheme().headline1,
        hintStyle: textTheme().headline1,
        labelText: "Contact",
        hintText: "Enter your Contact",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }
}
