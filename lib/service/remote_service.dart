import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:lmaida/utils/StringConst.dart';
import 'package:lmaida/utils/firebase.dart';

class RemoteService {
  static var client = http.Client();

  static Future<List<dynamic>> fetFilters() async {
    var result = await http.get(StringConst.URI_FILTERS);
    return json.decode(result.body);
  }

  static Future<List<dynamic>> fetLocation() async {
    var result = await http.get(StringConst.URI_LOCATION);
    return json.decode(result.body);
  }

  static Future<List<dynamic>> fetchCat() async {
    var result = await http.get(StringConst.URI_CATEGORY);
    return json.decode(result.body);
  }

  static Future<List<dynamic>> fetRestAdvance(
      location_id, selectedValues, catId, locationId) async {
    var result = await http.get(StringConst.URI_RESTAU_ADV +
        "${selectedValues != null ? selectedValues.join(",") : "1"}/${catId != null ? catId : 14}/${location_id != null ? location_id : locationId}");
    return json.decode(result.body);
  }

  static Future<List<dynamic>> fetRest(id) async {
    var result = await http.get("${StringConst.URI_RESTAU + 'all'}/$id");
    return json.decode(result.body);
  }

  static Future<List<dynamic>> fetSearch(name) async {
    var result =
        await http.get("${StringConst.URI_SEARCH}/${name != "" ? name : "r"}");
    return json.decode(result.body);
  }

  static Future fetDetails(id) async {
    var result = await http.get(StringConst.URI_RESTAU1 + "$id");
    return json.decode(result.body);
  }

  static Future<DocumentSnapshot> getUsers() async {
    DocumentSnapshot snap =
        await usersRef.doc(firebaseAuth.currentUser.uid).get();
    if (snap.data()["id"] == firebaseAuth.currentUser.uid) return snap;
    return null;
  }

  static Future<String> getToken() async {
    var u = await getUsers();
    Map<String, String> header = {
      "Accept": "application/json",
      "Content-Type": "application/json"
    };
    var data = {
      'email': firebaseAuth.currentUser.email,
      'password': u.data()["password"],
    };
    var response = await http.post(Uri.encodeFull(StringConst.URI_LOGIN),
        headers: header, body: json.encode(data));
    var message = jsonDecode(response.body);
    return message["token"];
  }

  static Future<dynamic> getProfile() async {
    String Token = await getToken();
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $Token",
      "Content-Type": "application/json"
    };
    var response = await http.post(Uri.encodeFull(StringConst.URI_PROFILE),
        headers: header);
    var message = jsonDecode(response.body);
    return message[0];
  }

  static Future userLog({String email, String password}) async {
    Map<String, String> header = {
      "Accept": "application/json",
      "Content-Type": "application/json"
    };
    var data = {
      'email': email,
      'password': password,
    };
    var response = await http.post(Uri.encodeFull(StringConst.URI_LOGIN),
        headers: header, body: json.encode(data));
    var res = jsonDecode(response.body);
    return res['token'];
  }

  static Future addToken(Token, userid, _token) async {
    usersToken.doc(userid.toString()).set({"token": _token});
    await secureStorage.write(key: "Token", value: Token);
    Map<String, String> header = {
      "Authorization": "Bearer $Token",
    };
    await http
        .post(Uri.encodeFull(StringConst.URI_TOKEN), headers: header, body: {
      'token': _token,
      'id': userid.toString(),
    });
  }

  static Future<String> createUser(
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
      Future<String> token = userReg(name, email, country, password);
      return token;
    } else {
      return null;
    }
  }

  static Future saveUserToFirestore(
      String name, User user, String email, String country, password) async {
    await usersRef.doc(user.uid).set({
      'username': name ?? '',
      'email': email,
      'id': user.uid,
      'contact': country,
      'photoUrl': user.photoURL ?? '',
      'password': password
    });
  }

  static Future<String> userReg(name, email, country, password) async {
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
    var response = await http.post(Uri.encodeFull(StringConst.URI_REGISTER),
        headers: header, body: json.encode(data));
    var message = jsonDecode(response.body);
    return message["token"];
  }

  static String handleFirebaseAuthError(String e) {
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

  static Future loginUser({String email, String password}) async {
    UserCredential result;
    var errorType;
    try {
      result = await firebaseAuth.signInWithEmailAndPassword(
        email: '$email',
        password: '$password',
      );
    } catch (e) {
      switch (e) {
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          errorType = "No Account For This Email";
          break;
        case 'The password is invalid or the user does not have a password.':
          errorType = "Password Invalid";
          break;
        case 'A network error (interrupted connection or unreachable host) has occurred.':
          errorType = "Connection Error";
          break;
        default:
          print('Case ${errorType} is not yet implemented');
      }
    }
    if (errorType != null) return null;
    if (result != null) return result.user.uid;
  }
}
