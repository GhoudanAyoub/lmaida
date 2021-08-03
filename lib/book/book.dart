import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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
  int _activeTab = 0;
  String CatName = "";
  String id;

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
      var f = userLog();
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
    setState(() {
      id = message[0]['id'].toString();
    });
    List<dynamic> t = message[0]["bookings"];
    return t.reversed.toList();
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
                                      ? Colors.grey.withOpacity(0.8)
                                      : Colors.white,
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
                      Container(
                        height: SizeConfig.screenHeight - 180,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: FutureBuilder<List<dynamic>>(
                          future: userLog(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData)
                              return ListView.builder(
                                  padding: EdgeInsets.all(5),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    BookModel bookmodel = BookModel.fromJson(
                                        snapshot.data[index]);
                                    var color;
                                    bookmodel.statut.contains("canceled")
                                        ? color = primary
                                        : bookmodel.statut.contains("accept")
                                            ? color = Colors.green
                                            : color = Colors.deepOrangeAccent;
                                    if (snapshot.data != null && CatName == "")
                                      return Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 5, 0, 5),
                                        child: Container(
                                            child: Card(
                                          elevation: 4.0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Container(
                                            child: FutureBuilder(
                                              future:
                                                  fetResto(bookmodel.iditem),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  RestoModel restoModel =
                                                      RestoModel.fromJson(
                                                          snapshot.data[0]);
                                                  return OrderCard(
                                                    restoModel: restoModel,
                                                    bookmodel: bookmodel,
                                                    color: color,
                                                    user1: user1,
                                                    id: id,
                                                  );
                                                } else {
                                                  return Center(
                                                      child: Text(
                                                          "You Booked restaurant will appear here ",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color:
                                                                Colors.red[900],
                                                          )));
                                                }
                                              },
                                            ),
                                          ),
                                        )),
                                      );
                                    else if (snapshot.data != null &&
                                        bookmodel.statut.contains(CatName))
                                      return Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 5, 0, 5),
                                        child: Container(
                                            child: Card(
                                          elevation: 4.0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Container(
                                            child: FutureBuilder(
                                              future:
                                                  fetResto(bookmodel.iditem),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  RestoModel restoModel =
                                                      RestoModel.fromJson(
                                                          snapshot.data[0]);
                                                  return OrderCard(
                                                    restoModel: restoModel,
                                                    bookmodel: bookmodel,
                                                    color: color,
                                                    user1: user1,
                                                    id: id,
                                                  );
                                                } else {
                                                  return Center(
                                                      child: Text(
                                                          "You Booked restaurant will appear here ",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color:
                                                                Colors.red[900],
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
                              return Center(child: circularProgress(context));
                            }
                          },
                        ),
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
}

class OrderCard extends StatefulWidget {
  final RestoModel restoModel;
  final BookModel bookmodel;
  final Color color;
  final DocumentSnapshot user1;
  final String id;

  const OrderCard(
      {Key key,
      this.restoModel,
      this.bookmodel,
      this.color,
      this.user1,
      this.id})
      : super(key: key);
  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool submitted = false;
  bool show = false;

  Future<List<dynamic>> userLog2(id) async {
    setState(() {
      submitted = true;
    });
    Map<String, String> header = {
      "Accept": "application/json",
      "Content-Type": "application/json"
    };
    var url = 'https://lmaida.com/api/login';
    var data = {
      'email': firebaseAuth.currentUser.email,
      'password': widget.user1.data()["password"],
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
      });
    }
    return json.decode(result.body);
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(CupertinoIcons.checkmark_seal_fill),
              SizedBox(
                width: 5,
              ),
              Text(
                "Order No : ${widget.bookmodel.id}",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.0,
                  letterSpacing: 2,
                  color: Colors.black,
                ),
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.topRight,
                      child: widget.bookmodel.statut.contains("accept")
                          ? GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Review()));
                              },
                              child: Icon(
                                  CupertinoIcons.square_favorites_alt_fill),
                            )
                          : Container(
                              height: 0,
                              width: 0,
                            ))),
              Expanded(
                  child: Align(
                      alignment: Alignment.topRight,
                      child: widget.bookmodel.statut.contains("canceled")
                          ? Container(
                              height: 0,
                            )
                          : GestureDetector(
                              onTap: () {
                                setState(() {
                                  submitted = true;
                                });
                                userLog2(widget.bookmodel.id);
                              },
                              child: submitted
                                  ? circularProgress(context)
                                  : Icon(CupertinoIcons.delete_simple),
                            ))),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Divider(
            color: Colors.grey.withOpacity(0.4),
            height: 2,
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Number of Person :",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 15.0,
                  letterSpacing: 1,
                  color: Colors.black,
                ),
              ),
              Text(
                "${widget.bookmodel.person}",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15.0,
                  color: Colors.orangeAccent,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Client Name :",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 15.0,
                  letterSpacing: 1,
                  color: Colors.black,
                ),
              ),
              Flexible(
                child: Text(
                  "${widget.user1.data()["username"]}",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15.0,
                    color: Colors.orangeAccent,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Client Contact :",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 15.0,
                  letterSpacing: 1,
                  color: Colors.black,
                ),
              ),
              Text(
                "${widget.user1.data()["contact"]}",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15.0,
                  color: Colors.orangeAccent,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Status :",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 15.0,
                  letterSpacing: 1,
                  color: Colors.black,
                ),
              ),
              Chip(
                label: Text(
                  "${widget.bookmodel.statut}",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15.0,
                    color: widget.color,
                  ),
                ),
                backgroundColor: widget.color.withOpacity(0.2),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Special Offer :",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 15.0,
                  letterSpacing: 1,
                  color: Colors.black,
                ),
              ),
              Flexible(
                child: Text(
                  widget.bookmodel.offer != null
                      ? '${widget.bookmodel.offer}'
                      : 'No Special Offer',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14.0,
                    color: widget.bookmodel.offer != null
                        ? Colors.black
                        : Colors.grey,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Special Request :",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 15.0,
                  letterSpacing: 1,
                  color: Colors.black,
                ),
              ),
              Flexible(
                child: Text(
                  widget.bookmodel.specialrequest != '' &&
                          widget.bookmodel.specialrequest != null
                      ? '${widget.bookmodel.specialrequest}'
                      : 'No Special Request',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14.0,
                    color: widget.bookmodel.specialrequest != '' &&
                            widget.bookmodel.specialrequest != null
                        ? Colors.black
                        : Colors.grey,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Booked On:",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 15.0,
                  letterSpacing: 1,
                  color: Colors.black,
                ),
              ),
              Wrap(
                children: widget.bookmodel.dates
                    .split("/")
                    .map(
                      (e) => Text(
                        "$e",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15.0,
                          color: Colors.black,
                        ),
                      ),
                    )
                    .toList(),
              )
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
