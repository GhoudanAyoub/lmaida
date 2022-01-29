import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:lmaida/components/indicators.dart';
import 'package:lmaida/models/restau_model.dart';
import 'package:lmaida/utils/SizeConfig.dart';
import 'package:lmaida/utils/StringConst.dart';
import 'package:lmaida/utils/constants.dart';
import 'package:lmaida/utils/firebase.dart';

class MenuPage extends StatefulWidget {
  final RestoModel restoModel;
  final List<dynamic> data;
  final int index;
  final int locationId;

  const MenuPage(
      {Key key, this.restoModel, this.data, this.index, this.locationId})
      : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final String apiUrl = StringConst.URI_RESTAU + "all";
  String type;
  var listPos = new List(100);
  var listNeg = new List(100);

  DocumentSnapshot user1;
  int _activeTab = 0;
  Future<List<dynamic>> fetResto(id) async {
    var result = await http.get("$apiUrl/$id");
    return json.decode(result.body);
  }

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  getUsers() async {
    DocumentSnapshot snap =
        await usersRef.doc(firebaseAuth.currentUser.uid).get();
    if (snap.data()["id"] == firebaseAuth.currentUser.uid) user1 = snap;
  }

  Future<String> reviewMenu() async {
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
    return message["token"];
  }

  Future addPositiveReviewMenu(menuid) async {
    String Token = await reviewMenu();
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $Token",
      "Content-Type": "application/json"
    };
    var url = 'https://lmaida.com/api/addreviewmenu';
    var data = {'menu': menuid, 'review': 1};
    var response = await http.post(Uri.encodeFull(url),
        headers: header, body: json.encode(data));
    var message = jsonDecode(response.body);
    if (message["errors"] != null) {
      Fluttertoast.showToast(
          msg: message["errors"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: message["message"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future addNegativeReviewMenu(menuid) async {
    String Token = await reviewMenu();
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $Token",
      "Content-Type": "application/json"
    };
    var url = 'https://lmaida.com/api/addreviewmenu';
    var data = {'menu': menuid, 'review': 0};
    var response = await http.post(Uri.encodeFull(url),
        headers: header, body: json.encode(data));
    var message = jsonDecode(response.body);
    if (message["errors"] != null) {
      Fluttertoast.showToast(
          msg: message["errors"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: message["message"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xfff2f3f7),
        body: Stack(
          children: <Widget>[
            Positioned(
              bottom: 300.0,
              left: 100.0,
              child: Opacity(
                opacity: 0.1,
                child: Image.asset(
                  "assets/images/coffee2.png",
                  width: 150.0,
                ),
              ),
            ),
            Positioned(
              top: 200.0,
              right: -180.0,
              child: Image.asset(
                "assets/images/square.png",
              ),
            ),
            Positioned(
              child: Image.asset(
                "assets/images/drum.png",
              ),
              left: -70.0,
              bottom: -40.0,
            ),
            Container(
              height: getProportionateScreenHeight(250),
              width: MediaQuery.of(context).size.width,
              child: Container(
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: const Radius.circular(150),
                    bottomRight: const Radius.circular(150),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
              height: 60.0,
              child: Center(
                  child: Text(
                "Menu",
                style: TextStyle(
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500,
                  fontSize: 18.0,
                  color: Colors.white,
                ),
              )),
            ),
            Container(
                margin: EdgeInsets.fromLTRB(10, 25, 10, 20),
                height: 60.0,
                child: Center(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                        onPressed: () {
                          setState(() {
                            type = null;
                          });
                        },
                        child: Text(
                          "Clear",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                )),
            /* Container(
                margin: EdgeInsets.fromLTRB(0, 80, 0, 20),
                height: 40,
                child: ListView.builder(
                  itemCount: widget.data.length,
                  itemBuilder: (context, index) {
                    if (widget.data == null)
                      return Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 20, 10, 30),
                            height: 60.0,
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: FlatButton(
                                  padding: EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  color: Color(0xFFF5F6F9),
                                  onPressed: () {},
                                  child: FlatButton(
                                    padding: EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    color: Color(0xFFF5F6F9),
                                    onPressed: () {},
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        buildCount("Starter"),
                                        Divider(
                                          height: 30,
                                        ),
                                        buildCount("Main Course"),
                                        Divider(),
                                        buildCount("Dessert"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              "This Restaurant Didn't Upload There Menu Yet",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      );
                    if (widget.data.isNotEmpty) {
                      return Stack(
                        children: [
                          Container(
                            height: 50,
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                            child: ListView.separated(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _activeTab = index;
                                      type = widget.data[index]["type"]["name"];
                                      // CatName = categories[index].name.toLowerCase();
                                      //search(CatName);
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 450),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.0,
                                    ),
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: _activeTab == index
                                          ? Colors.grey.withOpacity(0.8)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        widget.data[index]["type"]["name"],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _activeTab == index
                                              ? Colors.white
                                              : kTextColor1,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return SizedBox(
                                  width: 15.0,
                                );
                              },
                              itemCount: widget.data.length,
                            ),
                          ),
                          type == null
                              ? Container(
                                  margin: EdgeInsets.fromLTRB(0, 70, 0, 10),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: ListView.builder(
                                            padding: EdgeInsets.all(10),
                                            itemCount: widget.data.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              print(type);
                                              return buildcontainer(
                                                  widget.data[index]);
                                            })),
                                  ),
                                )
                              : Container(
                                  margin: EdgeInsets.fromLTRB(0, 70, 0, 10),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: ListView.builder(
                                            padding: EdgeInsets.all(10),
                                            itemCount: widget.data.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              if (type ==
                                                  widget.data[index]["type"]
                                                      ["name"])
                                                return buildcontainer(
                                                    widget.data[index]);
                                              else
                                                return Container(
                                                  width: 0.2,
                                                );
                                            })),
                                  ))
                        ],
                      );
                    } else {
                      return Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 20, 10, 30),
                            height: 60.0,
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: FlatButton(
                                  padding: EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  color: Color(0xFFF5F6F9),
                                  onPressed: () {},
                                  child: FlatButton(
                                    padding: EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    color: Color(0xFFF5F6F9),
                                    onPressed: () {},
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        buildCount("Starter"),
                                        Divider(
                                          height: 30,
                                        ),
                                        buildCount("Main Course"),
                                        Divider(),
                                        buildCount("Dessert"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              "This Restaurant Didn't Upload There Menu Yet",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      );
                    }
                  },
                )),*/
            Container(
              margin: EdgeInsets.fromLTRB(0, 80, 0, 20),
              child: FutureBuilder<List<dynamic>>(
                future: fetResto(widget.locationId),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    if (widget.data == null)
                      return Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 20, 10, 30),
                            height: 60.0,
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: FlatButton(
                                  padding: EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  color: Color(0xFFF5F6F9),
                                  onPressed: () {},
                                  child: FlatButton(
                                    padding: EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    color: Color(0xFFF5F6F9),
                                    onPressed: () {},
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        buildCount("Starter"),
                                        Divider(
                                          height: 30,
                                        ),
                                        buildCount("Main Course"),
                                        Divider(),
                                        buildCount("Dessert"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              "This Restaurant Didn't Upload There Menu Yet",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      );
                    if (widget.data.isNotEmpty) {
                      return Stack(
                        children: [
                          Container(
                            height: 50,
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                            child: ListView.separated(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _activeTab = index;
                                      type = widget.data[index]["type"]["name"];
                                      // CatName = categories[index].name.toLowerCase();
                                      //search(CatName);
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 450),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.0,
                                    ),
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: _activeTab == index
                                          ? Colors.grey.withOpacity(0.8)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        widget.data[index]["type"]["name"],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _activeTab == index
                                              ? Colors.white
                                              : kTextColor1,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return SizedBox(
                                  width: 15.0,
                                );
                              },
                              itemCount: widget.data.length,
                            ),
                          ),
                          type == null
                              ? Container(
                                  margin: EdgeInsets.fromLTRB(0, 70, 0, 10),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: ListView.builder(
                                            padding: EdgeInsets.all(10),
                                            itemCount: widget.data.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return buildcontainer(
                                                  widget.data[index]);
                                            })),
                                  ),
                                )
                              : Container(
                                  margin: EdgeInsets.fromLTRB(0, 70, 0, 10),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: ListView.builder(
                                            padding: EdgeInsets.all(10),
                                            itemCount: widget.data.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              if (type ==
                                                  widget.data[index]["type"]
                                                      ["name"])
                                                return buildcontainer(
                                                    widget.data[index]);
                                              else
                                                return Container(
                                                  width: 0.2,
                                                );
                                            })),
                                  ))
                        ],
                      );
                    } else {
                      return Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 20, 10, 30),
                            height: 60.0,
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: FlatButton(
                                  padding: EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  color: Color(0xFFF5F6F9),
                                  onPressed: () {},
                                  child: FlatButton(
                                    padding: EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    color: Color(0xFFF5F6F9),
                                    onPressed: () {},
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        buildCount("Starter"),
                                        Divider(
                                          height: 30,
                                        ),
                                        buildCount("Main Course"),
                                        Divider(),
                                        buildCount("Dessert"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              "This Restaurant Didn't Upload There Menu Yet",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      );
                    }
                  } else {
                    return Center(child: circularProgress(context));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildcontainer(data) {
    return Padding(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Container(
            child: FittedBox(
                child: Card(
                    elevation: 10.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: Container(
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        width: SizeConfig.screenWidth - 30,
                        height: 90,
                        child: Stack(
                          children: [
                            Positioned(
                                left: 0,
                                right: 30,
                                child: ListTile(
                                  onTap: () {
                                    showpage(
                                        context,
                                        "https://lmaida.com/storage/menus/" +
                                                data["picture"] ??
                                            "https://media-cdn.tripadvisor.com/media/photo-s/12/47/f3/8c/oko-restaurant.jpg");
                                  },
                                  leading: CircleAvatar(
                                    radius: 30.0,
                                    backgroundImage: NetworkImage(
                                      "https://lmaida.com/storage/menus/" +
                                              data["picture"] ??
                                          "https://media-cdn.tripadvisor.com/media/photo-s/12/47/f3/8c/oko-restaurant.jpg",
                                    ),
                                  ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        data["name"],
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        data["ingredients"],
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    data["price"].toString() + " MAD",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.0,
                                      color: primary,
                                    ),
                                  ),
                                )),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  listPos.isNotEmpty &&
                                          listPos[data["id"]] == true
                                      ? Container(
                                          height: 0,
                                          width: 0,
                                        )
                                      : IconButton(
                                          icon: const Icon(CupertinoIcons
                                              .arrowtriangle_up_fill),
                                          onPressed: () {
                                            setState(() {
                                              listPos[data["id"]] = true;
                                            });
                                            addPositiveReviewMenu(data["id"]);
                                          }),
                                  listNeg.isNotEmpty &&
                                          listNeg[data["id"]] == true
                                      ? Container(
                                          height: 0,
                                          width: 0,
                                        )
                                      : IconButton(
                                          icon: const Icon(CupertinoIcons
                                              .arrowtriangle_down_fill),
                                          onPressed: () {
                                            setState(() {
                                              listNeg[data["id"]] = true;
                                            });
                                            addNegativeReviewMenu(data["id"]);
                                          }),
                                ],
                              ),
                            )
                          ],
                        ))))));
  }
  /*
  *
  *

  * */

  showpage(BuildContext parentContext, image) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(10),
              child: Stack(
                overflow: Overflow.visible,
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned(
                      top: 100,
                      child: Image.network(image, width: 450, height: 500))
                ],
              ));
        });
  }

  buildCount(String label) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 15,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          width: 15,
        ),
      ],
    );
  }
}
