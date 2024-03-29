import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmaida/Resto/componant/booked_screen.dart';
import 'package:lmaida/SignIn/sign_in_screen.dart';
import 'package:lmaida/SignUp/sign_up_screen.dart';
import 'package:lmaida/components/indicators.dart';
import 'package:lmaida/components/rater.dart';
import 'package:lmaida/components/reting%20star.dart';
import 'package:lmaida/components/reviews_card.dart';
import 'package:lmaida/models/restau_model.dart';
import 'package:lmaida/utils/SizeConfig.dart';
import 'package:lmaida/utils/StringConst.dart';
import 'package:lmaida/utils/constants.dart';
import 'package:lmaida/utils/extansion.dart';
import 'package:lmaida/utils/firebase.dart';
import 'package:lmaida/values/values.dart';

import 'menu_page.dart';

class NewRestoDetails extends StatefulWidget {
  final RestoModel restoModel;
  final dropdownValue;
  final selectedDateTxt;
  final selectedTimeTxt;
  final int locationId;

  const NewRestoDetails(
      {Key key,
      this.restoModel,
      this.dropdownValue,
      this.selectedDateTxt,
      this.selectedTimeTxt,
      @required this.locationId})
      : super(key: key);

  @override
  _NewRestoDetailsState createState() => _NewRestoDetailsState();
}

class _NewRestoDetailsState extends State<NewRestoDetails> {
  DocumentSnapshot user1;
  var fetchDetailsRes;
  String finalNegTag = "";
  String finaPosTag = "";
  double reviewsData = 0.0;
  List<CachedNetworkImage> images = [];
  var followingList = new List(200);
  String Token;
  var following = new List(200);
  var unFollowing = new List(200);

  String MyID;

  Future<DocumentSnapshot> getUsers() async {
    DocumentSnapshot snap =
        await usersRef.doc(firebaseAuth.currentUser.uid).get();
    if (snap.data()["id"] == firebaseAuth.currentUser.uid)
      setState(() {
        user1 = snap;
      });
    return user1;
  }

  Future<String> getToken() async {
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
    setState(() {
      Token = message["token"];
    });
    return message["token"];
  }

  Future<void> sendFollowRequest(userid) async {
    String Token = await getToken();
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $Token",
      "Content-Type": "application/json"
    };
    var url = 'https://lmaida.com/api/addfollower';
    var data = {'following_id': userid};
    var response = await http.post(Uri.encodeFull(url),
        headers: header, body: json.encode(data));
    setState(() {
      following[int.parse(userid)] = true;
    });
  }

  Future<void> sendUnFollowRequest(userid) async {
    String Token = await getToken();
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $Token",
      "Content-Type": "application/json"
    };
    var url = 'https://lmaida.com/api/defollow';
    var data = {'following_id': userid};
    var response = await http.post(Uri.encodeFull(url),
        headers: header, body: json.encode(data));
    setState(() {
      unFollowing[int.parse(userid)] = true;
    });
  }

  static Future<List<dynamic>> fetDetails(id) async {
    var result = await http.get(StringConst.URI_RESTAU1 + "$id");
    return json.decode(result.body);
  }

  Future getPorf() async {
    String Token = await getToken();
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $Token",
      "Content-Type": "application/json"
    };
    var url = 'https://lmaida.com/api/profile';
    var response = await http.post(Uri.encodeFull(url), headers: header);
    var message = jsonDecode(response.body);
    setState(() {
      followingList = message[0]["following"];
      MyID = message[0]["id"].toString();
    });
  }

  checkFollowingList(clientId) {
    if (followingList != null)
      for (var follower in followingList) {
        if (follower != null &&
            follower["pivot"]["following_id"].toString() == clientId.toString())
          return true;
      }
    return false;
  }

  @override
  void initState() {
    getPorf();
    fetchDetailsRes = fetDetails(widget.restoModel.id);
    getImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
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
                    bottomLeft: const Radius.circular(80),
                    bottomRight: const Radius.circular(80),
                  ),
                ),
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.01),
            Container(
              margin: EdgeInsets.fromLTRB(10, 30, 10, 20),
              height: 60.0,
              child: Center(
                  child: Text(
                widget.restoModel.name.capitalize(),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 28.0,
                  color: Colors.white,
                ),
              )),
            ),
            Container(
              height: SizeConfig.screenHeight,
              padding: EdgeInsets.fromLTRB(20, 80, 20, 20),
              child: ListView(
                children: [
                  Container(
                    child: Card(
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Stack(
                        children: [
                          Positioned(
                              child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                                child: CachedNetworkImage(
                                  imageUrl: widget.restoModel.pictures == null
                                      ? "https://media-cdn.tripadvisor.com/media/photo-s/12/47/f3/8c/oko-restaurant.jpg"
                                      : "https://lmaida.com/storage/gallery/" +
                                          widget.restoModel.pictures,
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width,
                                  height: 200,
                                  fadeInDuration: Duration(milliseconds: 500),
                                  fadeInCurve: Curves.easeIn,
                                  placeholder: (context, progressText) =>
                                      Center(
                                          child: CircularProgressIndicator()),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: SizeConfig.screenWidth,
                                      child: Text(
                                        widget.restoModel.address.capitalize(),
                                        textAlign: TextAlign.left,
                                        overflow: TextOverflow.ellipsis,
                                        style: Styles.customNormalTextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    FutureBuilder(
                                      future: fetchDetailsRes,
                                      builder: (context, snapshot) {
                                        if (snapshot != null &&
                                            snapshot.data != null) {
                                          if (snapshot
                                                  .data[0]["reviews"].length !=
                                              0) {
                                            for (var it in snapshot.data[0]
                                                ["reviews"])
                                              reviewsData += double.tryParse(
                                                  it['reviews']);

                                            return Row(
                                              children: [
                                                Rater(
                                                  rate: reviewsData /
                                                      snapshot
                                                          .data[0]["reviews"]
                                                          .length,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "(${(reviewsData / snapshot.data[0]["reviews"].length).toStringAsFixed(1)})",
                                                  textAlign: TextAlign.left,
                                                  style: Styles
                                                      .customNormalTextStyle(
                                                    color: Colors.grey[600],
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            );
                                          } else
                                            return Row(
                                              children: [
                                                Rater(
                                                  rate: 0,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "(NaN)",
                                                  textAlign: TextAlign.left,
                                                  style: Styles
                                                      .customNormalTextStyle(
                                                    color: Colors.grey[600],
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            );
                                        } else {
                                          return Row(
                                            children: [
                                              Rater(
                                                rate: 0,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "(NaN)",
                                                textAlign: TextAlign.left,
                                                style: Styles
                                                    .customNormalTextStyle(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                    SizedBox(height: 5.0),
                                    widget.restoModel.opening_hours_from !=
                                                null &&
                                            widget.restoModel.opening_hours_to !=
                                                null &&
                                            widget.restoModel
                                                    .opening_hours_from !=
                                                "" &&
                                            widget.restoModel
                                                    .opening_hours_to !=
                                                ""
                                        ? Container(
                                            child: Text(
                                              "Opening from " +
                                                  widget.restoModel
                                                      .opening_hours_from +
                                                  " to " +
                                                  widget.restoModel
                                                      .opening_hours_to,
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  Styles.customNormalTextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                              ),
                                            ),
                                            width: 300,
                                          )
                                        : Container(
                                            height: 0,
                                          )
                                  ],
                                ),
                              ),
                            ],
                          ))
                        ],
                      ),
                    ),
                  ),
                  buildOffer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MenuPage(
                                  restoModel: widget.restoModel,
                                  data: widget.restoModel.menus,
                                  index: widget.restoModel.id,
                                  locationId: widget.locationId,
                                )),
                      );
                    },
                    child: Container(
                        child: Card(
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: Container(
                        margin: EdgeInsets.fromLTRB(20, 0, 0, 5),
                        padding: EdgeInsets.all(10),
                        width: SizeConfig.screenWidth - 50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Text(
                              "Chef's Suggestions",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 20.0,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "See The Full Menu ",
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                  ),
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Container(
                        child: Card(
                          elevation: 10.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: Container(
                            margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                            width: SizeConfig.screenWidth - 50,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                buildComments(),
                              ],
                            ),
                          ),
                        ),
                      )),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                    child: Container(child: buildImages()),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  buildOffer() {
    if (widget.restoModel.special_offer.length == 0) {
      return Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Container(
            height: 80.0,
            child: Card(
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Container(
                margin: EdgeInsets.fromLTRB(10, 10, 0, 10),
                width: SizeConfig.screenWidth - 50,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "Book Without a Special offer",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15.0,
                        color: Colors.blue[900],
                      ),
                    ),
                    FloatingActionButton(
                      shape: CircleBorder(),
                      heroTag: 'book',
                      mini: true,
                      onPressed: () {
                        firebaseAuth.currentUser == null
                            ? logIn(context)
                            : Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BookedScreen(
                                          restoModel: widget.restoModel,
                                          offer: null,
                                          dropdownValue: widget.dropdownValue,
                                          selectedTimeTxt:
                                              widget.selectedTimeTxt,
                                          selectedDateTxt:
                                              widget.selectedDateTxt,
                                        )),
                              );
                      },
                      backgroundColor: primary,
                      child: Icon(Icons.arrow_forward_ios,
                          size: 25, color: Colors.white),
                    )
                  ],
                ),
              ),
            )),
      );
    } else {
      if (DateTime.now().isBefore(
          DateTime.parse(widget.restoModel.special_offer[0]["date_to"])))
        return Padding(
          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Container(
              height: 80.0,
              child: Card(
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 0, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.card_giftcard_outlined,
                          size: 30, color: Colors.blue[800]),
                      Container(
                        width: 250,
                        child: Text(
                          "Check Our Offers Before you Reserve ",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15.0,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                      FloatingActionButton(
                        shape: CircleBorder(),
                        heroTag: 'book',
                        mini: true,
                        onPressed: () {
                          firebaseAuth.currentUser == null
                              ? logIn(context)
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BookedScreen(
                                            restoModel: widget.restoModel,
                                            offer:
                                                widget.restoModel.special_offer,
                                            dropdownValue: widget.dropdownValue,
                                            selectedTimeTxt:
                                                widget.selectedTimeTxt,
                                            selectedDateTxt:
                                                widget.selectedDateTxt,
                                          )),
                                );
                        },
                        backgroundColor: primary,
                        child: Icon(Icons.arrow_forward_ios,
                            size: 25, color: Colors.white),
                      )
                    ],
                  ),
                ),
              )),
        );
      else
        return Padding(
          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Container(
              height: 80.0,
              child: Card(
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 0, 10),
                  width: SizeConfig.screenWidth - 50,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        "Book Without a Special offer",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15.0,
                          color: Colors.blue[900],
                        ),
                      ),
                      FloatingActionButton(
                        shape: CircleBorder(),
                        heroTag: 'book',
                        mini: true,
                        onPressed: () {
                          firebaseAuth.currentUser == null
                              ? logIn(context)
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BookedScreen(
                                            restoModel: widget.restoModel,
                                            offer: null,
                                            dropdownValue: widget.dropdownValue,
                                            selectedTimeTxt:
                                                widget.selectedTimeTxt,
                                            selectedDateTxt:
                                                widget.selectedDateTxt,
                                          )),
                                );
                        },
                        backgroundColor: primary,
                        child: Icon(Icons.arrow_forward_ios,
                            size: 25, color: Colors.white),
                      )
                    ],
                  ),
                ),
              )),
        );
    }
  }

  buildReviewImages() {
    if (widget.restoModel.itemphotos.length != 0) {
      return Card(
        elevation: 10.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          margin: EdgeInsets.fromLTRB(20, 10, 10, 10),
          width: SizeConfig.screenWidth - 50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                widget.restoModel.itemphotos.length.toString() +
                    " Photos of Dishes ",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 25.0,
                  color: Colors.black,
                ),
              ),
              Text(
                "Picture From Community Members",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14.0,
                  color: Colors.black,
                ),
              ),
              Container(
                height: 120,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.restoModel.itemphotos.length,
                    itemBuilder: (context, index) {
                      print('++' + widget.restoModel.name.toString());
                      if (widget.restoModel.itemphotos == null) {
                        return Container(
                          child: Center(
                            child: Text("No Photos For the Moment "),
                          ),
                        );
                      } else {
                        return Container(
                          margin: EdgeInsets.only(right: 1.0),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: GestureDetector(
                              onTap: () {
                                showpage(
                                    context,
                                    "https://lmaida.com/storage/gallery/" +
                                            widget.restoModel.itemphotos[index]
                                                ['name'] ??
                                        "https://media-cdn.tripadvisor.com/media/photo-s/12/47/f3/8c/oko-restaurant.jpg");
                              },
                              child: CachedNetworkImage(
                                imageUrl: "https://lmaida.com/storage/gallery/" +
                                        widget.restoModel.itemphotos[index]
                                            ['name'] ??
                                    "https://media-cdn.tripadvisor.com/media/photo-s/12/47/f3/8c/oko-restaurant.jpg",
                                fit: BoxFit.cover,
                                width: 100,
                                fadeInDuration: Duration(milliseconds: 500),
                                fadeInCurve: Curves.easeIn,
                                placeholder: (context, progressText) =>
                                    Center(child: circularProgress(context)),
                              )),
                        );
                      }
                    }),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          height: 80.0,
          child: Card(
            elevation: 10.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "No Pictures For The Moment",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20.0,
                      color: Colors.blue[900],
                    ),
                  ),
                ],
              ),
            ),
          ));
    }
  }

  buildImages() {
    if (widget.restoModel.itemphotos.length != 0) {
      return Card(
        elevation: 10.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          padding: EdgeInsets.all(10),
          width: SizeConfig.screenWidth - 50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                widget.restoModel.itemphotos.length.toString() +
                    " Photos of Dishes ",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 25.0,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Picture From Community Members",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14.0,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 120,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.restoModel.itemphotos.length,
                    itemBuilder: (context, index) {
                      if (widget.restoModel.itemphotos == null) {
                        return Container(
                          child: Center(
                            child: Text("No Photos For the Moment "),
                          ),
                        );
                      } else {
                        return Container(
                          margin: EdgeInsets.only(right: 1.0),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: GestureDetector(
                              onTap: () {
                                showpage(
                                    context,
                                    "https://lmaida.com/storage/gallery/" +
                                            widget.restoModel.itemphotos[index]
                                                ['name'] ??
                                        "https://media-cdn.tripadvisor.com/media/photo-s/12/47/f3/8c/oko-restaurant.jpg");
                              },
                              child: CachedNetworkImage(
                                imageUrl: "https://lmaida.com/storage/gallery/" +
                                        widget.restoModel.itemphotos[index]
                                            ['name'] ??
                                    "https://media-cdn.tripadvisor.com/media/photo-s/12/47/f3/8c/oko-restaurant.jpg",
                                fit: BoxFit.cover,
                                width: 100,
                                fadeInDuration: Duration(milliseconds: 500),
                                fadeInCurve: Curves.easeIn,
                                placeholder: (context, progressText) =>
                                    Center(child: circularProgress(context)),
                              )),
                        );
                      }
                    }),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          height: 80.0,
          child: Card(
            elevation: 10.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "No Pictures For The Moment",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20.0,
                      color: Colors.blue[900],
                    ),
                  ),
                ],
              ),
            ),
          ));
    }
  }

  showpage(BuildContext parentContext, image) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(10),
            child: ListWheelScrollView(itemExtent: 250, children: images),
          );
        });
  }

  showPage2(BuildContext parentContext, image) {
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
                      child: InteractiveViewer(
                        child: Image.network(image, width: 600, height: 600),
                      )),
                  Positioned(
                    top: 100,
                    right: 10,
                    child: FloatingActionButton(
                      shape: CircleBorder(),
                      heroTag: 'book',
                      mini: true,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      backgroundColor: Colors.red,
                      child: Icon(Icons.clear, size: 25, color: Colors.white),
                    ),
                  ),
                ],
              ));
        });
  }

  buildComments() {
    return FutureBuilder(
      future: fetchDetailsRes,
      builder: (context, snapshot) {
        if (snapshot != null && snapshot.data != null) {
          if (snapshot.data[0]["reviews"].length != 0) {
            List l = [];
            if (snapshot.data[0]["reviews"][0]['image1'] != null) {
              l.add(snapshot.data[0]["reviews"][0]['image1']);
            }
            if (snapshot.data[0]["reviews"][0]['image2'] != null) {
              l.add(snapshot.data[0]["reviews"][0]['image2']);
            }
            if (snapshot.data[0]["reviews"][0]['image3'] != null) {
              l.add(snapshot.data[0]["reviews"][0]['image3']);
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 0),
                  leading: Opacity(
                    opacity: 1.0,
                    child: Image.asset(
                      "assets/images/proim.png",
                      width: 50.0,
                    ),
                  ),
                  title: Text(
                    "${snapshot.data[0]["reviews"][0]["user"]["name"].toString()}",
                    style: TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                  subtitle: Text(
                    "${snapshot.data[0]["reviews"][0]["created_at"].toString()}",
                    style: TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                  trailing: setButtonType(snapshot),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: double.tryParse(
                              snapshot.data[0]["reviews"][0]['reviews']) !=
                          null
                      ? StarRating(
                          rating: double.parse(
                              snapshot.data[0]["reviews"][0]['reviews']),
                          color: Colors.black,
                        )
                      : SizedBox(
                          height: 0,
                        ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.thumb_up,
                                color: Colors.green,
                                size: 20,
                              ),
                              SizedBox(width: 5.0),
                              Text(
                                "POSITIVE",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.green),
                              )
                            ],
                          ),
                          Container(
                            child: Wrap(
                              children:
                                  snapshot.data[0]["reviews"][0]['positivtag']
                                      .toString()
                                      .split("#")
                                      .map((e) => e != ""
                                          ? Chip(
                                              label: Text("#${e.capitalize()}"),
                                              elevation: 4,
                                            )
                                          : Container())
                                      .toList()
                                      .sublist(0, 2),
                              spacing: 2,
                              alignment: WrapAlignment.start,
                            ),
                            width: 150,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.thumb_down,
                                color: primary,
                                size: 20,
                              ),
                              SizedBox(width: 5.0),
                              Text(
                                "NEGATIVE",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: primary),
                              )
                            ],
                          ),
                          Container(
                            child: Wrap(
                              children:
                                  snapshot.data[0]["reviews"][0]['negativetag']
                                      .toString()
                                      .split("#")
                                      .map((e) => e != ""
                                          ? Chip(
                                              label: Text("#$e"),
                                              elevation: 4,
                                            )
                                          : Container())
                                      .toList()
                                      .sublist(0, 2),
                              spacing: 2,
                              alignment: WrapAlignment.start,
                            ),
                            width: 150,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Card(
                  elevation: 1.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: Container(
                    margin: EdgeInsets.fromLTRB(20, 10, 10, 10),
                    width: SizeConfig.screenWidth - 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "Picture From Community Members",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                        ),
                        Container(
                          height: 120,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: l.length,
                              itemBuilder: (context, index) {
                                if (l.length == 0) {
                                  return Container(
                                    child: Center(
                                      child: Text("No Photos For the Moment "),
                                    ),
                                  );
                                } else {
                                  return Container(
                                    margin: EdgeInsets.only(right: 1.0),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    child: GestureDetector(
                                        onTap: () {
                                          showPage2(
                                              context,
                                              "https://lmaida.com/storage/reviews/" +
                                                      l[index] ??
                                                  "https://media-cdn.tripadvisor.com/media/photo-s/12/47/f3/8c/oko-restaurant.jpg");
                                        },
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              "https://lmaida.com/storage/reviews/" +
                                                      l[index] ??
                                                  "https://media-cdn.tripadvisor.com/media/photo-s/12/47/f3/8c/oko-restaurant.jpg",
                                          fit: BoxFit.cover,
                                          width: 100,
                                          fadeInDuration:
                                              Duration(milliseconds: 500),
                                          fadeInCurve: Curves.easeIn,
                                          placeholder:
                                              (context, progressText) => Center(
                                                  child: circularProgress(
                                                      context)),
                                        )),
                                  );
                                }
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: Colors.grey.withOpacity(0.2),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    snapshot.data[0]["reviews"].length > 0
                        ? GestureDetector(
                            child: Text(
                                'SEE The ${snapshot.data[0]["reviews"].length} reviews',
                                style: TextStyle(
                                    fontSize: 12.0,
                                    fontFamily: 'Quicksand',
                                    fontWeight: FontWeight.bold,
                                    color: primary)),
                            onTap: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ReviewsCard(
                                          restoModel: widget.restoModel,
                                          reviews: snapshot.data[0]["reviews"],
                                          Token: Token,
                                          followingList: followingList,
                                        )),
                              )
                            },
                          )
                        : Container(
                            height: 0,
                          )
                  ],
                ),
              ],
            );
          } else
            return Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Container(
                  height: 50.0,
                  child: Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "No Reviews For The Moment",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20.0,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                  )),
            );
        } else {
          return Padding(
            padding: EdgeInsets.all(10),
            child: Center(child: circularProgress(context)),
          );
        }
      },
    );
  }

  setButtonType(snapshot) {
    if (firebaseAuth.currentUser != null) {
      if (checkFollowingList(snapshot.data[0]["reviews"][0]["iduser"]))
        return unFollowing[snapshot.data[0]["reviews"][0]["iduser"]] == true
            ? requestSent()
            : buildButton(
                text: "UnFollow",
                function: () {
                  sendUnFollowRequest(
                      snapshot.data[0]["reviews"][0]["iduser"].toString());
                });
      else
        return following[snapshot.data[0]["reviews"][0]["iduser"]] == true
            ? requestSent()
            : buildButton(
                text: "Follow",
                function: () {
                  sendFollowRequest(
                      snapshot.data[0]["reviews"][0]["iduser"].toString());
                });
    } else
      return Container(
        width: 0,
        height: 0,
      );
  }

  buildButton({String text, Function function}) {
    return GestureDetector(
      onTap: function,
      child: Container(
        height: 40.0,
        width: 80.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.red,
              Colors.redAccent,
            ],
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  logIn(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            children: [
              Icon(
                CupertinoIcons.info,
                color: Colors.redAccent,
                size: 50,
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: Text(
                  "You Must login before Order",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, SignInScreen.routeName);
                },
                child: Center(
                  child: Text(
                    'Log In',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Divider(),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, SignUpScreen.routeName);
                },
                child: Center(
                  child:
                      Text('Register', style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          );
        });
  }

  void getImages() {
    for (var i in widget.restoModel.itemphotos)
      images.add(CachedNetworkImage(
        imageUrl: "https://lmaida.com/storage/gallery/" + i['name'],
        fit: BoxFit.fill,
        fadeInDuration: Duration(milliseconds: 500),
        fadeInCurve: Curves.easeIn,
        placeholder: (context, progressText) =>
            Center(child: circularProgress(context)),
      ));
  }

  requestSent() {
    return GestureDetector(
      child: Container(
        height: 40.0,
        width: 100.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.grey,
              Colors.grey,
            ],
          ),
        ),
        child: Center(
          child: Text(
            "Processing",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
