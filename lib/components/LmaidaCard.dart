import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lmaida/values/values.dart';

class LmaidaCard extends StatelessWidget {
  final String status;
  final String rating;
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
  final double ratingsAndStatusCardElevation;
  final List<String> followersImagePath;
  final BoxDecoration decoration;

  LmaidaCard({
    this.status,
    this.rating = "4.5",
    this.imagePath,
    this.cardTitle,
    this.category,
    this.distance,
    this.address,
    this.time,
    this.width = 340.0,
    this.cardHeight = 300.0,
    this.imageHeight = 180.0,
    this.tagRadius = 8.0,
    this.onTap,
    this.isThereStatus = true,
    this.isThereRatings = false,
    this.bookmark = false,
    this.cardElevation = 4.0,
    this.ratingsAndStatusCardElevation = 8.0,
    this.followersImagePath,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: cardHeight,
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
                            : imagePath,
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
                        horizontal: 16,
                        vertical: 16,
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
                              Spacer(
                                flex: 1,
                              ),
                              if (bookmark)
                                Container()
                              else
                                Container(
                                  width: 40,
                                  height: 20,
                                  child: Stack(
                                    alignment: Alignment.centerLeft,
                                    children: [
                                      Positioned(
                                        left: 21,
                                        child: Image.asset(
                                          ImagePath.cardImage1,
                                          fit: BoxFit.none,
                                        ),
                                      ),
                                      Positioned(
                                        left: 12,
                                        child: Image.asset(
                                          ImagePath.cardImage2,
                                          fit: BoxFit.none,
                                        ),
                                      ),
                                      Positioned(
                                        left: 0,
                                        child: Image.asset(
                                          ImagePath.cardImage1,
                                          fit: BoxFit.none,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 10.0),
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
                          SizedBox(height: 10.0),
                          Row(
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
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bookmark
                  ? Positioned(
                      top: (cardHeight / 2) + 16,
                      left: width - 60,
                      child: Container(
                        height: 60,
                        width: 60,
                        child: Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Image.asset(ImagePath.activeBookmarksIcon2),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
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
