import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:lmaida/components/text_form_builder.dart';
import 'package:lmaida/models/user.dart';
import 'package:lmaida/profile/Componant/edit_profile__model_view.dart';
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
      appBar: AppBar(
        centerTitle: true,
        title: Text("Profile"),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 25.0),
              child: GestureDetector(
                onTap: () => viewModel.editProfile(context),
                child: Text(
                  'SAVE',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15.0,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
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
                          backgroundImage: NetworkImage(viewModel.imgLink),
                        ),
                      )
                    : viewModel.image == null
                        ? Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: CircleAvatar(
                              radius: 65.0,
                              backgroundImage: NetworkImage(
                                  firebaseAuth.currentUser.photoURL == null
                                      ? 'assets/images/Profile Image.png'
                                      : firebaseAuth.currentUser.photoURL),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: CircleAvatar(
                              radius: 65.0,
                              backgroundImage: FileImage(viewModel.image),
                            ),
                          ),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          buildForm(viewModel, context)
        ],
      ),
    );
  }

  buildForm(EditProfileViewModel viewModel, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
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
              initialValue: firebaseAuth.currentUser.displayName,
              prefix: Feather.user,
              hintText: "Username",
              textInputAction: TextInputAction.next,
              validateFunction: Validations.validateName,
              onSaved: (String val) {
                viewModel.setUsername(val);
              },
            ),
            SizedBox(height: 10.0),
            TextFormBuilder(
              enabled: !viewModel.loading,
              initialValue: firebaseAuth.currentUser.email,
              prefix: Feather.mail,
              hintText: "email",
              textInputAction: TextInputAction.next,
              validateFunction: Validations.validateName,
              onSaved: (String val) {
                viewModel.setUsername(val);
              },
            ),
            SizedBox(height: 10.0),
            TextFormBuilder(
              enabled: !viewModel.loading,
              initialValue: firebaseAuth.currentUser.phoneNumber,
              prefix: Feather.phone,
              hintText: "contact",
              textInputAction: TextInputAction.next,
              validateFunction: Validations.validateName,
              onSaved: (String val) {
                viewModel.setUsername(val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
