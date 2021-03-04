import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmaida/utils/firebase.dart';

class UserViewModel extends ChangeNotifier {
  User user;
  FirebaseAuth auth = FirebaseAuth.instance;
  String Token;
  DocumentSnapshot user1;

  setUser() {
    user = auth.currentUser;
    //notifyListeners();
  }

  setToken(var t) {
    Token = t;
  }

  getTokenString() {
    return Token;
  }

  getUsers() async {
    DocumentSnapshot snap =
        await usersRef.doc(firebaseAuth.currentUser.uid).get();
    if (snap.data()["id"] == firebaseAuth.currentUser.uid) {
      user1 = snap;
      print('0');
    }
  }

  Future<List<dynamic>> userLog() async {
    Map<String, String> header = {
      "Accept": "application/json",
      "Content-Type": "application/json"
    };
    var url = 'https://lmaida.com/api/login';
    var data = {
      'email': firebaseAuth.currentUser.email,
      'password': user1.data()["password"],
    };
    var response = await http.post(Uri.encodeFull(url),
        headers: header, body: json.encode(data));
    var message = jsonDecode(response.body);
    print('1');
    return getPorf(message["token"]);
  }

  Future<List<dynamic>> getPorf(Token) async {
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $Token",
      "Content-Type": "application/json"
    };
    var url = 'https://lmaida.com/api/profile';
    var response = await http.post(Uri.encodeFull(url), headers: header);
    var message = json.decode(response.body);
    print('2');
    return message[0]["bookings"];
  }
}
