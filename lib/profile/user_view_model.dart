import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UserViewModel extends ChangeNotifier {
  User user;
  FirebaseAuth auth = FirebaseAuth.instance;
  String Token;

  setUser() {
    user = auth.currentUser;
  }

  setToken(var t) {
    Token = t;
  }

  getTokenString() {
    return Token;
  }
}
