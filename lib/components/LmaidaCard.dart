import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lmaida/components/rater.dart';
import 'package:lmaida/models/restau_model.dart';
import 'package:lmaida/values/values.dart';

class LmaidaCard extends StatelessWidget {
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
    this.rating = 1,
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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
                        imageUrl: imagePath == null
                            ? "https://media-cdn.tripadvisor.com/media/photo-s/12/47/f3/8c/oko-restaurant.jpg"
                            : "https://lmaida.com/storage/gallery/" + imagePath,
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
                                cardTitle,
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
                                    address,
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
                                    distance + " KM From You",
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
                          restoModel.special_offer != null &&
                                  DateTime.now().isBefore(DateTime.parse(
                                      restoModel.special_offer["date_to"]))
                              ? Row(
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        child: Text(
                                          restoModel.special_offer["name"],
                                          textAlign: TextAlign.left,
                                          style: Styles.customNormalTextStyle(
                                            color: Colors.red[900],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        child: Text(
                                          restoModel.special_offer["date_to"],
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
                              : SizedBox(
                                  height: 0,
                                ),
                          restoModel.opening_hours_from != null &&
                                  restoModel.opening_hours_to != null
                              ? Row(
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Container(
                                        child: Text(
                                          time,
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
                              : SizedBox(
                                  height: 0,
                                ),
                          Rater(
                            rate: rating,
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
