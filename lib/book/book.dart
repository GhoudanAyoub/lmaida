import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmaida/Reviews/review.dart';
import 'package:lmaida/bloc.navigation_bloc/navigation_bloc.dart';
import 'package:lmaida/components/indicators.dart';
import 'package:lmaida/models/book_model.dart';
import 'package:lmaida/models/category.dart';
import 'package:lmaida/models/restau_model.dart';
import 'package:lmaida/utils/SizeConfig.dart';
import 'package:lmaida/utils/StringConst.dart';
import 'package:lmaida/utils/constants.dart';
import 'package:lmaida/utils/firebase.dart';

class Book extends StatefulWidget with NavigationStates {
  @override
  _BookState createState() => _BookState();
}

class _BookState extends State<Book> {
  DocumentSnapshot user1;
  final String apiUrl = StringConst.URI_RESTAU1;
  var fetchUser;
  int _activeTab = 0;
  String CatName = "";

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  Future fetResto(id) async {
    var result = await http.get("${StringConst.URI_RESTAU1}$id");
    return json.decode(result.body);
  }

  getUsers() async {
    DocumentSnapshot snap =
        await usersRef.doc(firebaseAuth.currentUser.uid).get();
    if (snap.data()["id"] == firebaseAuth.currentUser.uid) {
      user1 = snap;
    }
    setState(() {
      fetchUser = userLog();
    });
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
    List<dynamic> t = message[0]["bookings"];
    return t.reversed.toList();
  }

  Future<List<dynamic>> userLog2(id) async {
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
    return deleteBook(message["token"], id);
  }

  Future<List<dynamic>> deleteBook(Token, id) async {
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $Token",
      "Content-Type": "application/json"
    };
    var result = await http
        .post(Uri.encodeFull("${StringConst.URI_DELETE}/$id"), headers: header);
    var res = json.decode(result.body);
    if (res["message"] == "Successfully canceled") {
      setState(() {
        submitted = false;
        fetchUser = userLog();
      });
    }
    return json.decode(result.body);
  }

  bool submitted = false;
  static final List<Category> categories = [
    Category(
      id: 1,
      name: "Accept",
    ),
    Category(
      id: 2,
      name: "Pending",
    ),
    Category(
      id: 3,
      name: "Canceled",
    ),
  ];

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
            SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 60.0,
                        child: Center(
                            child: Text(
                          "My Orders",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 24.0,
                            color: Colors.white,
                          ),
                        )),
                      ),
                      Container(
                        height: 50,
                        child: ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _activeTab = index;
                                  CatName =
                                      categories[index].name.toLowerCase();
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
                                      ? mainColor.withOpacity(0.7)
                                      : mainColor.withOpacity(
                                          .2,
                                        ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Center(
                                  child: Text(
                                    categories[index].name,
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
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              width: 15.0,
                            );
                          },
                          itemCount: categories.length,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      fetchUser != null
                          ? Container(
                              height: SizeConfig.screenHeight - 180,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: FutureBuilder<List<dynamic>>(
                                future: userLog(),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.data != null)
                                    return ListView.builder(
                                        padding: EdgeInsets.all(5),
                                        shrinkWrap: true,
                                        itemCount: snapshot.data.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          BookModel bookmodel =
                                              BookModel.fromJson(
                                                  snapshot.data[index]);
                                          var color;
                                          bookmodel.statut.contains("canceled")
                                              ? color = primary
                                              : bookmodel.statut
                                                      .contains("accept")
                                                  ? color = Colors.green
                                                  : color =
                                                      Colors.deepOrangeAccent;
                                          if (snapshot.data != null &&
                                              CatName == "")
                                            return Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 5, 0, 5),
                                              child: Container(
                                                  child: Card(
                                                elevation: 4.0,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Container(
                                                  child: FutureBuilder(
                                                    future: fetResto(
                                                        bookmodel.iditem),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot.hasData) {
                                                        RestoModel restoModel =
                                                            RestoModel.fromJson(
                                                                snapshot
                                                                    .data[0]);
                                                        return Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  "Your Book For ${restoModel.name} is ",
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        15.0,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  bookmodel
                                                                      .statut,
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        15.0,
                                                                    color:
                                                                        color,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 10),
                                                            Container(
                                                              height: 60.0,
                                                              child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          10.0),
                                                                  child: Card(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(15)),
                                                                    color: Color(
                                                                        0xFFF5F6F9),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceAround,
                                                                      children: <
                                                                          Widget>[
                                                                        buildCount(
                                                                            bookmodel.dates,
                                                                            Icons.calendar_today_sharp),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(bottom: 5.0),
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                40.0,
                                                                            width:
                                                                                0.5,
                                                                            color:
                                                                                Colors.grey,
                                                                          ),
                                                                        ),
                                                                        buildCount(
                                                                            bookmodel.person.toString() +
                                                                                " person(s)",
                                                                            Icons.person_outline),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                                'Table booked under the name \n ${user1.data()["username"]}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize:
                                                                      14.0,
                                                                  color: Colors
                                                                      .black,
                                                                )),
                                                            SizedBox(height: 5),
                                                            Text(
                                                              '${user1.data()["email"]}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 14.0,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                            Text(
                                                              '${user1.data()["contact"]}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 14.0,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            Container(
                                                              width: 300,
                                                              child: Text(
                                                                bookmodel.offer !=
                                                                        null
                                                                    ? 'Your Special Offer : ${bookmodel.offer}'
                                                                    : 'No Special Offer',
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize:
                                                                      14.0,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: 300,
                                                              child: Text(
                                                                bookmodel.specialrequest !=
                                                                        ''
                                                                    ? 'Your Special Request : ${bookmodel.specialrequest}'
                                                                    : 'No Special Request',
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize:
                                                                      14.0,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                            bookmodel.statut
                                                                    .contains(
                                                                        "canceled")
                                                                ? Container(
                                                                    height: 0,
                                                                  )
                                                                : FlatButton(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(20)),
                                                                    color: Colors
                                                                            .red[
                                                                        900],
                                                                    disabledColor:
                                                                        Colors.grey[
                                                                            400],
                                                                    disabledTextColor:
                                                                        Colors
                                                                            .white60,
                                                                    onPressed:
                                                                        () {
                                                                      submitted =
                                                                          true;
                                                                      userLog2(
                                                                          bookmodel
                                                                              .id);
                                                                    },
                                                                    child: submitted
                                                                        ? SizedBox(
                                                                            height:
                                                                                15,
                                                                            width:
                                                                                15,
                                                                            child:
                                                                                CircularProgressIndicator(
                                                                              strokeWidth: 2,
                                                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                                            ),
                                                                          )
                                                                        : Text(
                                                                            "Delete Your Booking",
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 16,
                                                                              color: Colors.white,
                                                                            ),
                                                                          ),
                                                                  ),
                                                            bookmodel.statut
                                                                    .contains(
                                                                        "accept")
                                                                ? FlatButton(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(20)),
                                                                    color: Colors
                                                                            .red[
                                                                        900],
                                                                    disabledColor:
                                                                        Colors.grey[
                                                                            400],
                                                                    disabledTextColor:
                                                                        Colors
                                                                            .white60,
                                                                    onPressed:
                                                                        () {
                                                                      submitted =
                                                                          true;
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => Review()));
                                                                    },
                                                                    child: submitted
                                                                        ? SizedBox(
                                                                            height:
                                                                                15,
                                                                            width:
                                                                                15,
                                                                            child:
                                                                                CircularProgressIndicator(
                                                                              strokeWidth: 2,
                                                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                                            ),
                                                                          )
                                                                        : Text(
                                                                            "Review",
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 16,
                                                                              color: Colors.white,
                                                                            ),
                                                                          ),
                                                                  )
                                                                : Container(
                                                                    height: 0,
                                                                  ),
                                                          ],
                                                        );
                                                      } else {
                                                        return Center(
                                                            child: Text(
                                                                "You Booked restaurant will appear here ",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: Colors
                                                                      .red[900],
                                                                )));
                                                      }
                                                    },
                                                  ),
                                                ),
                                              )),
                                            );
                                          else if (snapshot.data != null &&
                                              bookmodel.statut
                                                  .contains(CatName))
                                            return Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 5, 0, 5),
                                              child: Container(
                                                  child: Card(
                                                elevation: 4.0,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Container(
                                                  child: FutureBuilder(
                                                    future: fetResto(
                                                        bookmodel.iditem),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot.hasData) {
                                                        RestoModel restoModel =
                                                            RestoModel.fromJson(
                                                                snapshot
                                                                    .data[0]);
                                                        return Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  "Your Book For ${restoModel.name} is ",
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        15.0,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  bookmodel
                                                                      .statut,
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        15.0,
                                                                    color:
                                                                        color,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 10),
                                                            Container(
                                                              height: 60.0,
                                                              child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          10.0),
                                                                  child: Card(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(15)),
                                                                    color: Color(
                                                                        0xFFF5F6F9),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceAround,
                                                                      children: <
                                                                          Widget>[
                                                                        buildCount(
                                                                            bookmodel.dates,
                                                                            Icons.calendar_today_sharp),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(bottom: 5.0),
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                40.0,
                                                                            width:
                                                                                0.5,
                                                                            color:
                                                                                Colors.grey,
                                                                          ),
                                                                        ),
                                                                        buildCount(
                                                                            bookmodel.person.toString() +
                                                                                " person(s)",
                                                                            Icons.person_outline),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                                'Table booked under the name \n ${user1.data()["username"]}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize:
                                                                      14.0,
                                                                  color: Colors
                                                                      .black,
                                                                )),
                                                            SizedBox(height: 5),
                                                            Text(
                                                              '${user1.data()["email"]}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 14.0,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                            Text(
                                                              '${user1.data()["contact"]}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 14.0,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            Container(
                                                              width: 300,
                                                              child: Text(
                                                                bookmodel.offer !=
                                                                        null
                                                                    ? 'Your Special Offer : ${bookmodel.offer}'
                                                                    : 'No Special Offer',
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize:
                                                                      14.0,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: 300,
                                                              child: Text(
                                                                bookmodel.specialrequest !=
                                                                        ''
                                                                    ? 'Your Special Request : ${bookmodel.specialrequest}'
                                                                    : 'No Special Request',
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize:
                                                                      14.0,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 10),
                                                            bookmodel.statut
                                                                    .contains(
                                                                        "canceled")
                                                                ? Container(
                                                                    height: 0,
                                                                  )
                                                                : FlatButton(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(20)),
                                                                    color: Colors
                                                                            .red[
                                                                        900],
                                                                    disabledColor:
                                                                        Colors.grey[
                                                                            400],
                                                                    disabledTextColor:
                                                                        Colors
                                                                            .white60,
                                                                    onPressed:
                                                                        () {
                                                                      submitted =
                                                                          true;
                                                                      userLog2(
                                                                          bookmodel
                                                                              .id);
                                                                    },
                                                                    child: Text(
                                                                      "Delete Your Booking",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                            bookmodel.statut
                                                                    .contains(
                                                                        "accept")
                                                                ? FlatButton(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8)),
                                                                    color: Colors
                                                                            .red[
                                                                        900],
                                                                    disabledColor:
                                                                        Colors.grey[
                                                                            400],
                                                                    disabledTextColor:
                                                                        Colors
                                                                            .white60,
                                                                    onPressed:
                                                                        () {
                                                                      submitted =
                                                                          true;
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => Review(
                                                                                    idbooking: bookmodel.id,
                                                                                  )));
                                                                    },
                                                                    child: Text(
                                                                      "Review",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Container(
                                                                    height: 0,
                                                                  ),
                                                          ],
                                                        );
                                                      } else {
                                                        return Center(
                                                            child: Text(
                                                                "You Booked restaurant will appear here ",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: Colors
                                                                      .red[900],
                                                                )));
                                                      }
                                                    },
                                                  ),
                                                ),
                                              )),
                                            );
                                          else
                                            return Container(
                                              height: 0,
                                            );
                                        });
                                  else {
                                    return Center(
                                        child: circularProgress(context));
                                  }
                                },
                              ),
                            )
                          : Container(
                              child: Center(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      "You Booked restaurant will appear here... ",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: primary,
                                      )),
                                ],
                              )),
                            )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildCount(String label, final icons) {
    return Row(
      children: <Widget>[
        Icon(
          icons,
          color: Colors.black,
          size: 20,
        ),
        SizedBox(width: 5.0),
        Text(
          label,
          style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontFamily: 'Ubuntu-Regular'),
        )
      ],
    );
  }
}
