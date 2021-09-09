import 'dart:convert';

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
    Map<String, String> headers = {
      "Content-type": "application/json",
    };
    var result = await http.get(StringConst.URI_CATEGORY, headers: headers);
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

  static Future getProfileData(user1) async {
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
    getProfile(message["token"]);
  }

  static Future getProfile(token) async {
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
      "Content-Type": "application/json"
    };
    var url = 'https://lmaida.com/api/profile';
    var response = await http.post(Uri.encodeFull(url), headers: header);
    var message = jsonDecode(response.body);
  }
}
