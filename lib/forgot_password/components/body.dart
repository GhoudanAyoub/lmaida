import 'package:flutter/material.dart';
import 'package:lmaida/components/custom_surfix_icon.dart';
import 'package:lmaida/components/default_button.dart';
import 'package:lmaida/components/form_error2.dart';
import 'package:lmaida/service/FirebaseService.dart';
import 'package:lmaida/utils/SizeConfig.dart';
import 'package:lmaida/utils/constants.dart';
import 'package:lmaida/utils/theme.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xfff2f3f7),
        body: Stack(
          children: <Widget>[
            Container(
              height: getProportionateScreenHeight(250),
              width: MediaQuery.of(context).size.width,
              child: Container(
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: const Radius.circular(80),
                    bottomRight: const Radius.circular(80),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: getProportionateScreenWidth(20)),
                child: Column(
                  children: [
                    SizedBox(height: SizeConfig.screenHeight * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: CustomSurffixIcon(
                              svgIcon: "assets/icons/Back ICon.svg",
                            )),
                        SizedBox(width: SizeConfig.screenWidth * 0.1),
                        Text(
                          "Forgot Password",
                          style: TextStyle(
                            fontSize: getProportionateScreenWidth(28),
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SizeConfig.screenHeight * 0.1),
                    Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 10.0,
                        child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: ForgotPassForm())),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

/*
* */
class ForgotPassForm extends StatefulWidget {
  @override
  _ForgotPassFormState createState() => _ForgotPassFormState();
}

class _ForgotPassFormState extends State<ForgotPassForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailContoller = TextEditingController();
  List<String> errors = [];
  String email;
  var submitted = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: getProportionateScreenHeight(30)),
          Text(
            "Forgot Password",
            style: TextStyle(
              fontSize: getProportionateScreenWidth(28),
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(5)),
          Text(
            "Please enter your email and we will send \nyou a link to reset your password",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(20)),
          TextFormField(
            controller: _emailContoller,
            style: TextStyle(color: Colors.black),
            keyboardType: TextInputType.emailAddress,
            onSaved: (newValue) => email = newValue,
            onChanged: (value) {
              if (value.isNotEmpty && errors.contains(kEmailNullError)) {
                setState(() {
                  errors.remove(kEmailNullError);
                });
                submitted = false;
              } else if (emailValidatorRegExp.hasMatch(value) &&
                  errors.contains(kInvalidEmailError)) {
                setState(() {
                  errors.remove(kInvalidEmailError);
                });
              }
              return null;
            },
            validator: (value) {
              if (value.isEmpty && !errors.contains(kEmailNullError)) {
                setState(() {
                  errors.add(kEmailNullError);
                });
                submitted = false;
              } else if (!emailValidatorRegExp.hasMatch(value) &&
                  !errors.contains(kInvalidEmailError)) {
                setState(() {
                  errors.add(kInvalidEmailError);
                });
                submitted = false;
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: "Email",
              hintText: "Enter your email",
              labelStyle: textTheme().headline1,
              hintStyle: textTheme().headline1,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(30)),
          FormError2(errors: errors),
          SizedBox(height: SizeConfig.screenHeight * 0.1),
          DefaultButton(
            text: "Next",
            submitted: submitted,
            press: () {
              if (_formKey.currentState.validate()) {
                submitted = true;
                final auth = FirebaseService();
                auth.sendPasswordResetEmail(_emailContoller.text);
                Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'A password reset link has been sent to ${_emailContoller.text}')));
              }
            },
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.03),
        ],
      ),
    );
  }
}
