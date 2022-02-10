import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart' as http;
import 'package:lmaida/components/indicators.dart';
import 'package:lmaida/components/text_form_builder.dart';
import 'package:lmaida/models/user.dart';
import 'package:lmaida/profile/Componant/edit_profile__model_view.dart';
import 'package:lmaida/service/remote_service.dart';
import 'package:lmaida/utils/SizeConfig.dart';
import 'package:lmaida/utils/StringConst.dart';
import 'package:lmaida/utils/constants.dart';
import 'package:lmaida/utils/firebase.dart';
import 'package:lmaida/utils/validation.dart';
import 'package:provider/provider.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Users user;
  bool valuesecond;
  DocumentSnapshot user1;
  List<DocumentSnapshot> filteredUsers = [];
  bool loading = true;
  var following = new List(200);
  var followers = new List(200);

  Future getPorf() async {
    String Token = await RemoteService.getToken();
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $Token",
      "Content-Type": "application/json"
    };
    var response = await http.post(Uri.encodeFull(StringConst.URI_PROFILE),
        headers: header);
    var message = jsonDecode(response.body);
    setState(() {
      following = message[0]["following"];
      followers = message[0]["followers"];
      loading = false;
    });
  }

  @override
  void initState() {
    getPorf();
    getUsers();
  }

  Future getUsers() async {
    DocumentSnapshot snap =
        await usersRef.doc(firebaseAuth.currentUser.uid).get();
    if (snap.data()["id"] == firebaseAuth.currentUser.uid) user1 = snap;
  }

  @override
  Widget build(BuildContext context) {
    EditProfileViewModel viewModel = Provider.of<EditProfileViewModel>(context);

    return Scaffold(
      key: viewModel.scaffoldKey,
      backgroundColor: Color(0xfff2f3f7),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 3,
        backgroundColor: primary,
        title: Text(
          "Profile",
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18.0,
              color: Colors.white,
              letterSpacing: 2),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: GestureDetector(
                  onTap: () => viewModel.editProfile(context),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.pencil_outline),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'EDIT',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0,
                            color: Colors.white,
                            letterSpacing: 2),
                      ),
                    ],
                  )),
            ),
          ),
        ],
      ),
      body: buildBody(viewModel),
    );
  }

  buildBody(viewModel) {
    if (!loading) {
      return Stack(
        children: <Widget>[
          Positioned(
            bottom: 100.0,
            left: 100.0,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                "assets/images/coffee2.png",
                width: 150.0,
              ),
            ),
          ),
          Positioned(
            bottom: 200.0,
            right: -180.0,
            child: Image.asset(
              "assets/images/square.png",
            ),
          ),
          Positioned(
            child: Image.asset(
              "assets/images/drum.png",
            ),
            left: -70.0,
            bottom: -40.0,
          ),
          Container(
            height: getProportionateScreenHeight(250),
            width: MediaQuery.of(context).size.width,
            child: Container(
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: const Radius.circular(200),
                  bottomRight: const Radius.circular(200),
                ),
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.fromLTRB(getProportionateScreenWidth(30), 40,
                  getProportionateScreenWidth(30), 40),
              child: Card(
                  margin: EdgeInsets.fromLTRB(0, 40, 0, 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 10.0,
                  child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Column(
                        children: [
                          SizedBox(height: 20.0),
                          Center(
                            child: GestureDetector(
                              onTap: () => viewModel.pickImage(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.transparent,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      offset: new Offset(0.0, 0.0),
                                      blurRadius: 2.0,
                                      spreadRadius: 0.0,
                                    ),
                                  ],
                                ),
                                child: viewModel.image == null
                                    ? Padding(
                                        padding: const EdgeInsets.all(1.0),
                                        child: user1.data()["photoUrl"] !=
                                                    null &&
                                                user1.data()["photoUrl"] != ""
                                            ? CircleAvatar(
                                                radius: 65.0,
                                                backgroundImage: NetworkImage(
                                                    user1.data()["photoUrl"]))
                                            : Opacity(
                                                opacity: 1.0,
                                                child: Image.asset(
                                                  "assets/images/proim.png",
                                                  width: 120.0,
                                                ),
                                              ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(1.0),
                                        child: CircleAvatar(
                                          radius: 65.0,
                                          backgroundImage:
                                              FileImage(viewModel.image),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Center(
                            child: Text(
                              user1.data()['username'],
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Container(
                            height: 60.0,
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: FlatButton(
                                  padding: EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  color: Color(0xFFF5F6F9),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      following != null &&
                                              following.length != 200
                                          ? buildCount(
                                              "FOLLOWING ", following.length)
                                          : buildCount("FOLLOWING", 0),
                                      followers != null &&
                                              followers.length != 200
                                          ? buildCount(
                                              "FOLLOWERS", followers.length)
                                          : buildCount("FOLLOWERS", 0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          buildForm(viewModel, context),
                          SizedBox(height: 20.0),
                        ],
                      )))),
        ],
      );
    } else {
      return Center(
        child: circularProgress(context),
      );
    }
  }

  buildCount(String label, int count) {
    return Column(
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w900,
              fontFamily: 'Ubuntu-Regular'),
        ),
        SizedBox(height: 3.0),
        Text(
          label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'Ubuntu-Regular'),
        )
      ],
    );
  }

  buildForm(EditProfileViewModel viewModel, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Form(
        key: viewModel.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20.0),
            TextFormBuilder(
              enabled: !viewModel.loading,
              initialValue: firebaseAuth.currentUser.email,
              prefix: Feather.mail,
              hintText: "email",
              textInputAction: TextInputAction.next,
              validateFunction: Validations.validateEmail,
              onSaved: (String val) {
                viewModel.setemail(val);
              },
            ),
            SizedBox(height: 10.0),
            TextFormBuilder(
              enabled: !viewModel.loading,
              initialValue: user1.data()["contact"],
              prefix: Feather.phone,
              hintText: "contact",
              textInputAction: TextInputAction.next,
              validateFunction: Validations.validatephone,
              onSaved: (String val) {
                viewModel.setcontact(val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
