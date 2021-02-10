import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lmaida/Resto/componant/potbelly_button.dart';
import 'package:lmaida/models/restau_model.dart';
import 'package:lmaida/values/values.dart';

import 'card_tags.dart';
import 'heading_row.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final RestoModel restoModel;

  const RestaurantDetailsScreen({Key key, this.restoModel}) : super(key: key);

  @override
  _RestaurantDetailsScreenState createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  TextStyle addressTextStyle = Styles.customNormalTextStyle(
    color: AppColors.accentText,
    fontSize: Sizes.TEXT_SIZE_14,
  );

  TextStyle openingTimeTextStyle = Styles.customNormalTextStyle(
    color: Colors.red,
    fontSize: Sizes.TEXT_SIZE_14,
  );

  TextStyle subHeadingTextStyle = Styles.customTitleTextStyle(
    color: AppColors.headingText,
    fontWeight: FontWeight.w600,
    fontSize: Sizes.TEXT_SIZE_18,
  );

  BoxDecoration fullDecorations = Decorations.customHalfCurvedButtonDecoration(
    color: Colors.black.withOpacity(0.1),
    topleftRadius: 24,
    bottomleftRadius: 24,
    topRightRadius: 24,
    bottomRightRadius: 24,
  );
  BoxDecoration leftSideDecorations =
      Decorations.customHalfCurvedButtonDecoration(
    color: Colors.black.withOpacity(0.1),
    topleftRadius: 24,
    bottomleftRadius: 24,
  );

  BoxDecoration rightSideDecorations =
      Decorations.customHalfCurvedButtonDecoration(
    color: Colors.black.withOpacity(0.1),
    topRightRadius: 24,
    bottomRightRadius: 24,
  );

  @override
  Widget build(BuildContext context) {
//    final RestaurantDetails args = ModalRoute.of(context).settings.arguments;
    var heightOfStack = MediaQuery.of(context).size.height / 2.8;
    var aPieceOfTheHeightOfStack = heightOfStack - heightOfStack / 3.5;
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Positioned(
                          child: CachedNetworkImage(
                            imageUrl: widget.restoModel.pictures == null
                                ? "https://media-cdn.tripadvisor.com/media/photo-s/12/47/f3/8c/oko-restaurant.jpg"
                                : widget.restoModel.pictures,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            height: 180,
                            fadeInDuration: Duration(milliseconds: 500),
                            fadeInCurve: Curves.easeIn,
                            placeholder: (context, progressText) =>
                                Center(child: CircularProgressIndicator()),
                          ),
                        ),
                        Positioned(
                            top: 10,
                            right: 20,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              color: Colors.red[900],
                              disabledColor: Colors.grey[400],
                              disabledTextColor: Colors.white60,
                              onPressed: () {},
                              child: false
                                  ? SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Book Now',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                            )),
                        Positioned(
                          child: Container(
                            padding: EdgeInsets.only(
                              right: Sizes.MARGIN_16,
                              top: Sizes.MARGIN_16,
                            ),
                            child: Row(
                              children: <Widget>[
                                InkWell(
                                  onTap: () => {}, //AppRouter.navigator.pop(),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: Sizes.MARGIN_16,
                                      right: Sizes.MARGIN_16,
                                    ),
                                    child: Image.asset(ImagePath.arrowBackIcon),
                                  ),
                                ),
                                Spacer(flex: 1),
                                InkWell(
                                  child: Image.asset(ImagePath.bookmarksIcon,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: aPieceOfTheHeightOfStack,
                          left: 24,
                          right: 24 - 0.5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24.0),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 4.0),
                                decoration: fullDecorations,
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 8.0),
                                      width:
                                          (MediaQuery.of(context).size.width /
                                                  2) -
                                              24,
//                                      decoration: leftSideDecorations,
                                      child: Row(
                                        children: <Widget>[
                                          SizedBox(width: 4.0),
                                          Image.asset(ImagePath.callIcon),
                                          SizedBox(width: 8.0),
                                          Text(
                                            widget.restoModel.telephone,
                                            style: Styles.normalTextStyle,
                                          )
                                        ],
                                      ),
                                    ),
                                    IntrinsicHeight(
                                      child: VerticalDivider(
                                        width: 0.5,
                                        thickness: 3.0,
                                        color: Colors.red,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 8.0),
//                                      width:
//                                      (MediaQuery
//                                          .of(context)
//                                          .size
//                                          .width /
//                                          2) -
//                                          24,
//                                      decoration: rightSideDecorations,
                                      child: Row(
                                        children: <Widget>[
                                          SizedBox(width: 4.0),
                                          Image.asset(ImagePath.directionIcon),
                                          SizedBox(width: 8.0),
                                          Text(
                                            widget.restoModel.address,
                                            style: Styles.normalTextStyle,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: Column(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(
                                    widget.restoModel.name,
                                    //_restaurantDetails.nameRestau,
                                    textAlign: TextAlign.left,
                                    style: Styles.customTitleTextStyle(
                                      color: AppColors.headingText,
                                      fontWeight: FontWeight.w600,
                                      fontSize: Sizes.TEXT_SIZE_20,
                                    ),
                                  ),
                                  SizedBox(width: 4.0),
                                  CardTags(
                                    title: widget.restoModel.description,
                                    decoration: BoxDecoration(
                                      gradient: Gradients.secondaryGradient,
                                      boxShadow: [
                                        Shadows.secondaryShadow,
                                      ],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                widget.restoModel.address,
                                style: addressTextStyle,
                              ),
                              SizedBox(height: 8.0),
                              RichText(
                                text: TextSpan(
                                  style: openingTimeTextStyle,
                                  children: [
                                    TextSpan(text: widget.restoModel.status),
                                    TextSpan(
                                        text: " daily time ",
                                        style: addressTextStyle),
                                    TextSpan(
                                        text: widget.restoModel
                                                        .opening_hours_from ==
                                                    null ||
                                                widget.restoModel
                                                        .opening_hours_from ==
                                                    ''
                                            ? "No Daily Time For The Moments"
                                            : widget.restoModel
                                                    .opening_hours_from +
                                                " am to " +
                                                widget.restoModel
                                                    .opening_hours_to +
                                                " pm "),
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 10.0),
                          HeadingRow(
                            title: StringConst.MENU_AND_PHOTOS,
                            number: widget.restoModel.itemphotos.length == 0
                                ? widget.restoModel.itemphotos.length.toString()
                                : "See all(" +
                                    widget.restoModel.itemphotos.length
                                        .toString() +
                                    ")",
                            onTapOfNumber: () =>
                                {}, //AppRouter.navigator.pushNamed(AppRouter.menuPhotosScreen),
                          ),
                          SizedBox(height: 16.0),
                          Container(
                            height: 120,
                            width: MediaQuery.of(context).size.width,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: widget.restoModel.itemphotos.length,
                                itemBuilder: (context, index) {
                                  if (widget.restoModel.itemphotos.length ==
                                      0) {
                                    return Container(
                                      child: Center(
                                        child:
                                            Text("No Photos For the Moments "),
                                      ),
                                    );
                                  } else {
                                    return Container(
                                      margin: EdgeInsets.only(right: 12.0),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                      child: CachedNetworkImage(
                                        imageUrl: widget.restoModel
                                                .itemphotos[index]['name'] ??
                                            "https://media-cdn.tripadvisor.com/media/photo-s/12/47/f3/8c/oko-restaurant.jpg",
                                        fit: BoxFit.cover,
                                        width: 160,
                                        fadeInDuration:
                                            Duration(milliseconds: 500),
                                        fadeInCurve: Curves.easeIn,
                                        placeholder: (context, progressText) =>
                                            Center(
                                                child:
                                                    CircularProgressIndicator()),
                                      ),
                                    );
                                  }
                                }),
                          ),
                          HeadingRow(
                            title: StringConst.REVIEWS_AND_RATINGS,
                            number: StringConst.SEE_ALL_32,
                            onTapOfNumber: () =>
                                {}, // AppRouter.navigator.pushNamed(AppRouter.reviewRatingScreen),
                          ),
                          SizedBox(height: 16.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: createUserListTiles(numberOfUsers: 5),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              PotbellyButton(
                'Rate Your Experience ',
                onTap: () => {},
                // AppRouter.navigator.pushNamed(AppRouter.addRatingsScreen),
                buttonHeight: 65,
                buttonWidth: MediaQuery.of(context).size.width,
                decoration: Decorations.customHalfCurvedButtonDecoration(
                  topleftRadius: Sizes.RADIUS_24,
                  topRightRadius: Sizes.RADIUS_24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> menuPhotosImagePaths = [
    ImagePath.doughnuts,
    ImagePath.cake_slice,
    ImagePath.avocado,
    ImagePath.black_berries,
    ImagePath.strawberries,
    ImagePath.cake_small,
    ImagePath.cake_big,
  ];

  List<Widget> createUserListTiles({@required numberOfUsers}) {
    List<Widget> userListTiles = [];
    List<String> imagePaths = [
      "assets/images/Profile Image.png",
      "assets/images/Profile Image.png",
      "assets/images/Profile Image.png",
      "assets/images/Profile Image.png",
      "assets/images/Profile Image.png",
    ];
    List<String> userNames = [
      "Collin Fields",
      "Sherita Burns",
      "Bill Sacks",
      "Romeo Folie",
      "Pauline Cobbina",
    ];
    List<String> description = [
      "Lorem Ipsum baga fada",
      "Lorem Ipsum baga fada",
      "Lorem Ipsum baga fada",
      "Lorem Ipsum baga fada",
      "Lorem Ipsum baga fada",
    ];
    List<String> ratings = [
      "4.0",
      "3.0",
      "5.0",
      "2.0",
      "4.0",
    ];

    List<int> list = List<int>.generate(numberOfUsers, (i) => i + 1);

    list.forEach((i) {
      userListTiles.add(ListTile(
        leading: Image.asset(imagePaths[i - 1]),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              userNames[i - 1],
              style: subHeadingTextStyle,
            ),
            // Ratings(ratings[i - 1]),
          ],
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 0),
        subtitle: Text(
          description[i - 1],
          style: addressTextStyle,
        ),
      ));
    });
    return userListTiles;
  }
}
