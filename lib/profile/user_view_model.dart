import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserViewModel extends ChangeNotifier {
  User user;
  FirebaseAuth auth = FirebaseAuth.instance;
  String Token;
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

  Future getPorf() async {
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization":
          "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjBlNmM4ZDNlZDUwMzIxMWIxNjNjZTg5OGM4NjRmYTNhMTAwZmE0OTIwZTBmM2U1NGI3OThiYjNjMDBiN2U5YWNhNjFhODI1NTQ1MzFlMmMwIn0.eyJhdWQiOiI1IiwianRpIjoiMGU2YzhkM2VkNTAzMjExYjE2M2NlODk4Yzg2NGZhM2ExMDBmYTQ5MjBlMGYzZTU0Yjc5OGJiM2MwMGI3ZTlhY2E2MWE4MjU1NDUzMWUyYzAiLCJpYXQiOjE2MTA5NjE3MzcsIm5iZiI6MTYxMDk2MTczNywiZXhwIjoxNjQyNDk3NzM3LCJzdWIiOiIxOCIsInNjb3BlcyI6W119.Yqithu_eg-UchA3meg51OhndMeHDgokc-tz-G-egY4TbYRmE9MwfnJQjKaeJ70pqrg2F_lPIVqUFqEdIwRoTfhc6ZRWTuhTYsYmsi9fcKwktUpF0Mpo-Z5K4mfWVoHlrMvXnRpUdRvI18CKuPmLpaQNRH7L4dC8WqV2QkFEltcE8IdmNvEeW-mfv4sbJ3P6tXqsnRrQfel0zijqYnpWcvogWVYKDgP_zvfeq3lO9gsEheF39e5d7lGmS_NCrHuctl9H4u_oZUrg3UbSCtDcHdq1vWIHrAKHsKlHuGRpD_v4sL4pDvOezi-KQ42kpZplhGzg3vXxVlvyL2Y5pSI44FYvlzlcL4IDZI-_G6CLRV7B1T3C7lkWM59vqi-OOG4TKjO8xpQkdk2va2HvRBkRgTNASO0taj45bkcMHDbmQsXe1S8mzo5aR0KhkxyOTh_LXWvKBgIXFMQv6e0KybcSpx8-8WVuvg2KnVwHMPm-BfzYhgDQAN47KSMf6DksUIXxvukdYj1KuZMFylEeQ9ntPOzJ5X5X2pPoGRwg9ktrZdYjLr2IxkwWQ_-SoC3Oy1JmqPjlf5eeYBQMM80G0XY2CFCeBiEOfRYgaIliE3I4cSYXfx-RdgWE-TbyOduIyJ45sFGwfibyzBLVWWcJ34O8_GanE6aW_H897S-8AdkH69BY",
      "token": Token,
      "Content-Type": "application/json"
    };
    var url = 'https://lmaida.com/api/profile';
    var response = await http.post(Uri.encodeFull(url), headers: header);
    var message = jsonDecode(response.body);
    print(message);
  }
}
