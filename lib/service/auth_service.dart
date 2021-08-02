import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:lmaida/profile/user_view_model.dart';
import 'package:lmaida/utils/firebase.dart';

class AuthService {
  FirebaseUser user;
  FirebaseUser getCurrentUser() {
    firebaseAuth.currentUser().then((value) {
      user = value;
    });
    return user;
  }

  Future<String> createUser(
      {String name, String email, String country, String password}) async {
    getCurrentUser();
    Future<String> token;
    await firebaseAuth
        .createUserWithEmailAndPassword(
      email: '$email',
      password: '$password',
    )
        .then((user) async {
      if (user != null) {
        await saveUserToFirestore(name, email, country, password);
        token = userReg(name, email, country, password);
      } else {
        return null;
      }
    });
    return token;
  }

  Future<String> getPorf(token) async {
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
      "Content-Type": "application/json"
    };
    var url = 'https://lmaida.com/api/profile';
    var response = await http.post(Uri.encodeFull(url), headers: header);
    var message = jsonDecode(response.body);
    print(message['name']);
    return message['name'];
  }

  Future saveUserToFirestore(
      String name, String email, String country, password) async {
    await usersRef.doc(user.uid).set({
      'username': name ?? '',
      'email': email,
      'id': user.uid,
      'contact': country,
      'photoUrl': user.photoUrl ?? '',
      'password': password
    });
  }

  Future<String> userReg(name, email, country, password) async {
    Map<String, String> header = {
      "Accept": "application/json",
      "Content-Type": "application/json"
    };
    var url = 'https://lmaida.com/api/register';
    var data = {
      'name': name,
      'email': email,
      'password': password,
      'phone_number': country
    };
    var response = await http.post(Uri.encodeFull(url),
        headers: header, body: json.encode(data));
    var message = jsonDecode(response.body);
    return message["Token"];
  }

  Future loginUser({String email, String password}) async {
    var errorType;
    var token;
    try {
      getCurrentUser();
      await firebaseAuth.signInWithEmailAndPassword(
        email: '$email',
        password: '$password',
      );
      token = userLog(email: email, password: password);
      if (token != null) {
        UserViewModel().setToken(token);
      }
    } catch (e) {
      switch (e) {
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          errorType = "No Account For This Email";

          await firebaseAuth
              .createUserWithEmailAndPassword(
            email: '$email',
            password: '$password',
          )
              .then((user) async {
            String cc = await getPorf(token);
            await saveUserToFirestore(cc, email, "", password);
          });
          break;
        case 'The password is invalid or the user does not have a password.':
          errorType = "Password Invalid";
          break;
        case 'A network error (interrupted connection or unreachable host) has occurred.':
          errorType = "Connection Error";
          break;
        // ...
        default:
          print('Case $errorType is not yet implemented');
      }
    }
    if (errorType != null) return errorType;
    return token;
  }

  Future userLog({String email, String password}) async {
    Map<String, String> header = {
      "Accept": "application/json",
      "Content-Type": "application/json"
    };
    var url = 'https://lmaida.com/api/login';
    var data = {
      'email': email,
      'password': password,
    };
    var response = await http.post(Uri.encodeFull(url),
        headers: header, body: json.encode(data));
    var res = jsonDecode(response.body);
    return res['Token'];
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
