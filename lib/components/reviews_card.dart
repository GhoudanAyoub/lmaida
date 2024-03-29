import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmaida/components/reting%20star.dart';
import 'package:lmaida/models/restau_model.dart';
import 'package:lmaida/utils/SizeConfig.dart';
import 'package:lmaida/utils/constants.dart';
import 'package:lmaida/utils/extansion.dart';
import 'package:lmaida/utils/firebase.dart';

import 'indicators.dart';

class ReviewsCard extends StatefulWidget {
  final reviews;
  final RestoModel restoModel;
  final String Token;
  final followingList;

  const ReviewsCard(
      {Key key,
      this.reviews,
      this.restoModel,
      @required this.Token,
      this.followingList})
      : super(key: key);
  @override
  _ReviewsCardState createState() => _ReviewsCardState();
}

class _ReviewsCardState extends State<ReviewsCard> {
  var fetchDetailsRes;
  String finalNegTag = "";
  Map<int, String> finaPosTag;
  String posT, negT;
  var negTL, posTL;
  var snap;
  var following = new List(200);
  var unFollowing = new List(200);

  Future<List<dynamic>> fetDetails(id) async {
    var result = await http.get("https://lmaida.com/api/resturant/$id");
    List<dynamic> t = json.decode(result.body);
    return t.reversed.toList();
  }

  Future<void> sendFollowRequest(userid) async {
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer ${widget.Token}",
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
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer  ${widget.Token}",
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

  checkFollowingList(clientId) {
    if (widget.followingList != null)
      for (var follower in widget.followingList) {
        if (follower != null &&
            follower["pivot"]["following_id"].toString() == clientId.toString())
          return true;
      }
    return false;
  }

  @override
  void initState() {
    fetchDetailsRes = fetDetails(widget.restoModel.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xfff2f3f7),
        body: Stack(
          children: <Widget>[
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
                "${widget.restoModel.name.capitalize()}",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 28.0,
                  color: Colors.white,
                ),
              )),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
                child: Card(
                  elevation: 10.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    width: SizeConfig.screenWidth - 50,
                    child: FutureBuilder(
                      future: fetchDetailsRes,
                      builder: (context, snapshot) {
                        if (snapshot != null && snapshot.data != null) {
                          return ListView.builder(
                            //new line
                            padding: EdgeInsets.all(5),
                            itemCount: widget.reviews.length,
                            itemBuilder: (context, index) {
                              List l = snapshot.data[0]["reviews"];
                              snap = l.reversed.toList()[index];
                              return card();
                            },
                          );
                        } else {
                          return Center(child: circularProgress(context));
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  card() {
    List l = [];
    if (snap['image1'] != null) {
      l.add(snap['image1']);
    }
    if (snap['image2'] != null) {
      l.add(snap['image2']);
    }
    if (snap['image3'] != null) {
      l.add(snap['image3']);
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
            "${snap["user"]["name"].toString()}",
            style: TextStyle(fontSize: 12.0, color: Colors.grey),
          ),
          subtitle: Text(
            "${snap["created_at"].toString()}",
            style: TextStyle(fontSize: 12.0, color: Colors.grey),
          ),
          trailing: setButtonType(snap),
        ),
        Padding(
          padding: EdgeInsets.all(5),
          child: double.tryParse(snap['reviews']) != null
              ? StarRating(
                  rating: double.parse(snap['reviews']),
                  color: Colors.black,
                )
              : SizedBox(
                  height: 0,
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
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
                            fontWeight: FontWeight.w400, color: Colors.green),
                      )
                    ],
                  ),
                  Container(
                    child: Wrap(
                      children: snap['positivtag']
                          .toString()
                          .split("#")
                          .map((e) => e != ""
                              ? Chip(
                                  label: Text("#${e.capitalize()}"),
                                  elevation: 4,
                                )
                              : Container())
                          .toList(),
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
                mainAxisAlignment: MainAxisAlignment.start,
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
                            fontWeight: FontWeight.w400, color: primary),
                      )
                    ],
                  ),
                  Container(
                    child: Wrap(
                      children: snap['negativetag']
                          .toString()
                          .split("#")
                          .map((e) => e != ""
                              ? Chip(
                                  label: Text("#$e"),
                                  elevation: 4,
                                )
                              : Container())
                          .toList(),
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
        Divider(
          color: Colors.grey.withOpacity(0.2),
        ),
        Card(
          elevation: 1.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                SizedBox(
                  height: 10,
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: GestureDetector(
                                onTap: () {
                                  showpage(
                                      context,
                                      "https://lmaida.com/storage/reviews/" +
                                              l[index] ??
                                          "https://media-cdn.tripadvisor.com/media/photo-s/12/47/f3/8c/oko-restaurant.jpg");
                                },
                                child: CachedNetworkImage(
                                  imageUrl: "https://lmaida.com/storage/reviews/" +
                                          l[index] ??
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
        ),
      ],
    );
  }

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
                      child: Image.network(image, width: 600, height: 600)),
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
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      child: Icon(Icons.clear, size: 25, color: Colors.white),
                    ),
                  ),
                ],
              ));
        });
  }

  setButtonType(snapshot) {
    if (firebaseAuth.currentUser != null) {
      if (checkFollowingList(snapshot["iduser"]))
        return unFollowing[snapshot["iduser"]] == true
            ? requestSent()
            : buildButton(
                text: "UnFollow",
                function: () {
                  sendUnFollowRequest(snapshot["iduser"].toString());
                });
      else
        return following[snapshot["iduser"]] == true
            ? requestSent()
            : buildButton(
                text: "Follow",
                function: () {
                  sendFollowRequest(snapshot["iduser"].toString());
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
