import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  static Future<List<dynamic>> fetDetails(id) async {
    var result = await http.get("https://lmaida.com/api/resturant/$id");
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
    var url = 'https://lmaida.com/api/login';
    var data = {
      'email': firebaseAuth.currentUser.email,
      'password': u.data()["password"],
    };
    var response = await http.post(Uri.encodeFull(url),
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
    var url = 'https://lmaida.com/api/profile';
    var response = await http.post(Uri.encodeFull(url), headers: header);
    var message = jsonDecode(response.body);
    return message[0];
  }

  static Future userLog({String email, String password}) async {
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
    await secureStorage.write(key: "Token", value: res['token']);
    return res['token'];
  }

  static Future addToken(Token, userid, _token) async {
    usersToken.doc(userid.toString()).set({"token": _token});
    Map<String, String> header = {
      "Authorization": "Bearer $Token",
    };
    var url = 'https://lmaida.com/api/token';
    await http.post(Uri.encodeFull(url), headers: header, body: {
      'token': _token,
      'id': userid.toString(),
    });
  }
}
