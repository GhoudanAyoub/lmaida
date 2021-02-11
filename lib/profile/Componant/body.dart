import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:lmaida/components/text_form_builder.dart';
import 'package:lmaida/models/user.dart';
import 'package:lmaida/profile/Componant/edit_profile__model_view.dart';
import 'package:lmaida/utils/SizeConfig.dart';
import 'package:lmaida/utils/firebase.dart';
import 'package:lmaida/utils/validation.dart';
import 'package:provider/provider.dart';

class Body extends StatelessWidget {
  Users user;
  bool valuesecond;

  String currentUid() {
    return firebaseAuth.currentUser.uid;
  }

  @override
  Widget build(BuildContext context) {
    EditProfileViewModel viewModel = Provider.of<EditProfileViewModel>(context);

    return Scaffold(
      key: viewModel.scaffoldKey,
      resizeToAvoidBottomPadding: false,
      backgroundColor: Color(0xfff2f3f7),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 24.0,
            color: Colors.white,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 25.0),
              child: GestureDetector(
                onTap: () => viewModel.editProfile(context),
                child: Text(
                  'EDIT',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
            height: getProportionateScreenHeight(250),
            width: MediaQuery.of(context).size.width,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red[900],
                borderRadius: BorderRadius.only(
                  bottomLeft: const Radius.circular(200),
                  bottomRight: const Radius.circular(200),
                ),
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(30)),
              child: SingleChildScrollView(
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
                                  child: viewModel.imgLink != null
                                      ? Padding(
                                          padding: const EdgeInsets.all(1.0),
                                          child: CircleAvatar(
                                            radius: 65.0,
                                            backgroundImage:
                                                NetworkImage(viewModel.imgLink),
                                          ),
                                        )
                                      : viewModel.image == null
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(1.0),
                                              child: CircleAvatar(
                                                radius: 65.0,
                                                backgroundImage: NetworkImage(
                                                    firebaseAuth.currentUser
                                                                .photoURL ==
                                                            null
                                                        ? 'assets/images/Profile Image.png'
                                                        : firebaseAuth
                                                            .currentUser
                                                            .photoURL),
                                              ),
                                            )
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.all(1.0),
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
                                'Username',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15.0,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            buildForm(viewModel, context),
                            SizedBox(height: 20.0),
                          ],
                        ))),
              )),
        ],
      ),
    );
  }

  buildForm(EditProfileViewModel viewModel, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Form(
        key: viewModel.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20.0),
            SizedBox(height: 10.0),
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
              initialValue: firebaseAuth.currentUser.phoneNumber,
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
