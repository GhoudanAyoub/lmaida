import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmaida/components/rater.dart';
import 'package:lmaida/models/restau_model.dart';
import 'package:lmaida/values/values.dart';

class LmaidaCard extends StatefulWidget {
  final String status;
  final double rating;
  final String imagePath;
  final String cardTitle;
  final String category;
  final String distance;
  final String address;
  final String time;
  final GestureTapCallback onTap;
  final bool bookmark;
  final bool isThereStatus;
  final bool isThereRatings;
  final double tagRadius;
  final double width;
  final double cardHeight;
  final double imageHeight;
  final double cardElevation;
  final List<String> followersImagePath;
  final BoxDecoration decoration;

  final RestoModel restoModel;
  LmaidaCard({
    this.status,
    this.rating = 4,
    this.imagePath,
    this.cardTitle,
    this.category,
    this.distance,
    this.address,
    this.time,
    this.width = 340.0,
    this.cardHeight = 320.0,
    this.imageHeight = 180.0,
    this.tagRadius = 8.0,
    this.onTap,
    this.isThereStatus = true,
    this.isThereRatings = false,
    this.bookmark = false,
    this.cardElevation = 4.0,
    this.followersImagePath,
    this.decoration,
    this.restoModel,
  });
  @override
  _LmaidaCardState createState() => _LmaidaCardState();
}

class _LmaidaCardState extends State<LmaidaCard> {
  var fetchDetailsRes;
  double reviewsData = 0.0;
  Future<List<dynamic>> fetDetails(id) async {
    var result = await http.get("https://lmaida.com/api/resturant/$id");
    return json.decode(result.body);
  }

  @override
  void initState() {
    fetchDetailsRes = fetDetails(widget.restoModel.id);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Hero(
        tag: "hero",
        child: Container(
          child: new FittedBox(
              child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  child: Column(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImage(
                          imageUrl: widget.imagePath == null
                              ? "https://media-cdn.tripadvisor.com/media/photo-s/12/47/f3/8c/oko-restaurant.jpg"
                              : "https://lmaida.com/storage/gallery/" +
                                  widget.imagePath,
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                          height: 180,
                          fadeInDuration: Duration(milliseconds: 500),
                          fadeInCurve: Curves.easeIn,
                          placeholder: (context, progressText) =>
                              Center(child: CircularProgressIndicator()),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  widget.cardTitle ?? '',
                                  textAlign: TextAlign.left,
                                  style: Styles.customTitleTextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    child: Text(
                                      widget.address ?? '',
                                      textAlign: TextAlign.left,
                                      style: Styles.customNormalTextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    child: Text(
                                      widget.distance.toString() +
                                          " KM From You",
                                      textAlign: TextAlign.left,
                                      style: Styles.customNormalTextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            widget.restoModel.opening_hours_from != null &&
                                    widget.restoModel.opening_hours_to != null
                                ? Row(
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Container(
                                          child: Text(
                                            widget.time,
                                            textAlign: TextAlign.left,
                                            style: Styles.customNormalTextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(
                                    height: 0,
                                  ),
                            FutureBuilder(
                              future: fetchDetailsRes,
                              builder: (context, snapshot) {
                                if (snapshot != null && snapshot.data != null) {
                                  if (snapshot.data[0]["reviews"].length != 0) {
                                    for (var it in snapshot.data[0]["reviews"])
                                      reviewsData +=
                                          double.tryParse(it['reviews']);

                                    return Rater(
                                      rate: reviewsData /
                                          snapshot.data[0]["reviews"].length,
                                    );
                                  } else
                                    return Rater(
                                      rate: 1,
                                    );
                                } else {
                                  return Rater(
                                    rate: 1,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }

  @override
  Widget cardTags({String title, BoxDecoration decoration}) {
    return Container(
      child: Opacity(
        opacity: 0.8,
        child: Container(
          width: 40,
          height: 14,
          decoration: decoration,
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Styles.customNormalTextStyle(
                fontSize: Sizes.TEXT_SIZE_10,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
