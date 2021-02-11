import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lmaida/models/user_model.dart';
import 'package:lmaida/service/services.dart';
import 'package:lmaida/utils/firebase.dart';

class UserService extends Service {
  String currentUid() {
    return firebaseAuth.currentUser.uid;
  }

  updateProfile({File image, String contact, String email}) async {
    DocumentSnapshot doc = await usersRef.doc(currentUid()).get();
    var users = UserModel.fromJson(doc.data());
    users?.contact = contact;
    if (image != null) {
      users?.photoUrl = await uploadImage(profilePic, image);
    }
    await usersRef.doc(currentUid()).update({
      'contact': contact,
      'email': email,
      "photoUrl": users?.photoUrl ?? '',
    });

    return true;
  }
}
