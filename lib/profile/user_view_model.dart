import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lmaida/utils/firebase.dart';

class UserViewModel extends ChangeNotifier {
  FirebaseUser user;
  FirebaseAuth auth = FirebaseAuth.instance;
  String token;
  DocumentSnapshot user1;

  setUser() {
    auth.currentUser().then((value) {
      user = value;
    });
    //notifyListeners();
  }

  setToken(var t) {
    token = t;
  }

  getTokenString() {
    return token;
  }

  getUsers() async {
    DocumentSnapshot snap = await usersRef.doc(user.uid).get();
    user1 = snap;
  }
}
