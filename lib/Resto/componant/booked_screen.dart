import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:lmaida/components/default_button.dart';
import 'package:lmaida/components/text_form_builder.dart';
import 'package:lmaida/models/restau_model.dart';
import 'package:lmaida/utils/SizeConfig.dart';
import 'package:lmaida/utils/firebase.dart';
import 'package:lmaida/values/values.dart';

class BookedScreen extends StatefulWidget {
  final RestoModel restoModel;
  final String offer;

  const BookedScreen({Key key, this.restoModel, this.offer}) : super(key: key);

  @override
  _BookedScreenState createState() => _BookedScreenState();
}

class _BookedScreenState extends State<BookedScreen> {
  @override
  Widget build(BuildContext context) {
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
                          left: 0.0,
                          top: 0.0,
                          width: getProportionateScreenWidth(350),
                          height: getProportionateScreenHeight(300),
                          child: Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                  Colors.black,
                                  Colors.black.withOpacity(0.1),
                                ])),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 30, 10, 20),
                          height: 60.0,
                          child: Center(
                              child: Text(
                            widget.restoModel.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 30.0,
                              color: Colors.white,
                            ),
                          )),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 100, 10, 20),
                          height: 60.0,
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: FlatButton(
                                padding: EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                color: Color(0xFFF5F6F9),
                                onPressed: () {},
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    buildCount(
                                        "18 Jun", Icons.calendar_today_sharp),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Container(
                                        height: 30.0,
                                        width: 0.5,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    buildCount(
                                        "20:03", Icons.watch_later_outlined),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Container(
                                        height: 30.0,
                                        width: 0.5,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    buildCount("2 pers", Icons.person_outline),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: Column(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(height: 10.0),
                              Text(
                                'Table booked under the name',
                                textAlign: TextAlign.center,
                                style: Styles.customTitleTextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: Sizes.TEXT_SIZE_20,
                                ),
                              ),
                              SizedBox(height: 16.0),
                              Icon(Icons.dinner_dining,
                                  size: 80, color: Colors.black87),
                              SizedBox(height: 16.0),
                              Text(
                                'Anonymous',
                                textAlign: TextAlign.center,
                                style: Styles.customTitleTextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                firebaseAuth.currentUser.email,
                                textAlign: TextAlign.center,
                                style: Styles.customTitleTextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "+212 654544",
                                textAlign: TextAlign.center,
                                style: Styles.customTitleTextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 20.0),
                              Divider(
                                color: Colors.grey[900],
                              ),
                              SizedBox(height: 20.0),
                              TextFormBuilder(
                                enabled: true,
                                suffix: Feather.inbox,
                                hintText: "Special Requests",
                                textInputAction: TextInputAction.next,
                                onSaved: (String val) {},
                              ),
                              SizedBox(height: 16.0),
                              TextFormBuilder(
                                enabled: true,
                                suffix: Feather.code,
                                hintText: "Do you have a code?",
                                textInputAction: TextInputAction.next,
                                onSaved: (String val) {},
                              ),
                              SizedBox(height: 16.0),
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DefaultButton(
                                      text: "CONFIRM YOUR TABLE",
                                      submitted: false,
                                      press: () {},
                                    ),
                                    SizedBox(height: 15.0),
                                    Text(
                                      'Immediate confirmation + Free Service + Possibility of cancellation',
                                      textAlign: TextAlign.center,
                                      style: Styles.customTitleTextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildCount(String label, final icons) {
    return Row(
      children: <Widget>[
        Icon(
          icons,
          color: Colors.red[900],
          size: 20,
        ),
        SizedBox(width: 5.0),
        Text(
          label,
          style: TextStyle(
              fontSize: 14,
              color: Colors.red[900],
              fontWeight: FontWeight.normal,
              fontFamily: 'Ubuntu-Regular'),
        )
      ],
    );
  }
}
