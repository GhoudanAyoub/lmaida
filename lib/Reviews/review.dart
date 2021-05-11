import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lmaida/bloc.navigation_bloc/navigation_bloc.dart';
import 'package:lmaida/components/default_button.dart';
import 'package:lmaida/components/text_form_builder.dart';
import 'package:lmaida/utils/SizeConfig.dart';
import 'package:lmaida/utils/validation.dart';

class Review extends StatefulWidget with NavigationStates {
  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xfff2f3f7),
        body: Container(
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0.0,
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
                height: SizeConfig.screenHeight,
                padding: EdgeInsets.fromLTRB(20, 100, 20, 20),
                child: ListView(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Write a Review",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20.0,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Icon(
                            CupertinoIcons.clear,
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Tap To rate your experience ",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RatingBar.builder(
                      initialRating: 1,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      glowColor: Colors.white,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.black,
                      ),
                      onRatingUpdate: (rating) {
                        print(rating);
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "what was not up to the mark 🥺 ",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormBuilder(
                          prefix: Feather.inbox,
                          hintText: "Search or select from blow",
                          validateFunction: Validations.validateName,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "what did you like? 😊",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormBuilder(
                          prefix: Feather.inbox,
                          hintText: "Search or select from blow",
                          validateFunction: Validations.validateName,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextFormBuilder(
                          prefix: Feather.file_text,
                          hintText: "Write your review",
                          textInputAction: TextInputAction.next,
                          validateFunction: Validations.validateName,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Review must be at least 100 character length",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 12.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
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
}
