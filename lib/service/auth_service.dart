import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:lmaida/utils/firebase.dart';

class AuthService {
  User getCurrentUser() {
    User user = firebaseAuth.currentUser;
    return user;
  }

  Future<bool> createUser(
      {String name,
      User user,
      String email,
      String country,
      String password}) async {
    var res = await firebaseAuth.createUserWithEmailAndPassword(
      email: '$email',
      password: '$password',
    );
    if (res.user != null) {
      await saveUserToFirestore(name, res.user, email, country, password);
      return true;
    } else {
      return false;
    }
  }

  saveUserToFirestore(
      String name, User user, String email, String country, password) async {
    await usersRef.doc(user.uid).set({
      'username': name,
      'email': email,
      'id': user.uid,
      'contact': country,
      'photoUrl': user.photoURL ?? '',
    });
    String UrL = "https://lmaida.com/api/register";

    Map<String, String> headers = {'Content-Type': 'application/json'};
    final msg = jsonEncode({
      "name": name,
      "email": email,
      "phone_number": country,
      "password": password
    });
    var res = await http.post(
      Uri.encodeFull(UrL),
      headers: headers,
      body: msg,
    );

    var resBody = json.decode(res.body);
    print("Response ==" + resBody);
  }

  Future<bool> loginUser({String email, String password}) async {
    var res = await firebaseAuth.signInWithEmailAndPassword(
      email: '$email',
      password: '$password',
    );

    if (res.user != null) {
      return true;
    } else {
      return false;
    }
  }

  forgotPassword(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  logOut() async {
    await firebaseAuth.signOut();
  }

  String handleFirebaseAuthError(String e) {
    if (e.contains("ERROR_WEAK_PASSWORD")) {
      return "Password is too weak";
    } else if (e.contains("invalid-email")) {
      return "Invalid Email";
    } else if (e.contains("ERROR_EMAIL_ALREADY_IN_USE") ||
        e.contains('email-already-in-use')) {
      return "The email address is already in use by another account.";
    } else if (e.contains("ERROR_NETWORK_REQUEST_FAILED")) {
      return "Network error occured!";
    } else if (e.contains("ERROR_USER_NOT_FOUND") ||
        e.contains('firebase_auth/user-not-found')) {
      return "Invalid credentials.";
    } else if (e.contains("ERROR_WRONG_PASSWORD") ||
        e.contains('wrong-password')) {
      return "Invalid credentials.";
    } else if (e.contains('firebase_auth/requires-recent-login')) {
      return 'This operation is sensitive and requires recent authentication.'
          ' Log in again before retrying this request.';
    } else {
      return e;
    }
  }
}
