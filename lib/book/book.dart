import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmaida/bloc.navigation_bloc/navigation_bloc.dart';
import 'package:lmaida/components/indicators.dart';
import 'package:lmaida/models/book_model.dart';
import 'package:lmaida/utils/SizeConfig.dart';
import 'package:lmaida/utils/firebase.dart';

class Book extends StatefulWidget with NavigationStates {
  @override
  _BookState createState() => _BookState();
}

class _BookState extends State<Book> {
  getbook() async {
    var result = await http
        .get("https://lmaida.com/api/booking/" + firebaseAuth.currentUser.uid);
    return json.decode(result.body);
  }

  bool submitted = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Color(0xfff2f3f7),
        body: Stack(
          children: <Widget>[
            Container(
              height: getProportionateScreenHeight(250),
              width: MediaQuery.of(context).size.width,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red[900],
                  borderRadius: BorderRadius.only(
                    bottomLeft: const Radius.circular(150),
                    bottomRight: const Radius.circular(150),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 30, 10, 20),
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
              margin: EdgeInsets.fromLTRB(0, 100, 0, 20),
              child: FutureBuilder(
                future: getbook(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        padding: EdgeInsets.all(20),
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int index) {
                          BookModel bookmodel =
                              BookModel.fromJson(snapshot.data);
                          if (bookmodel != null)
                            return Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: Container(
                                  child: Card(
                                elevation: 10.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(5, 5, 0, 5),
                                  width: SizeConfig.screenWidth - 50,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Your Book For " +
                                                bookmodel.restoModel['name'] +
                                                " is ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            bookmodel.statut,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15.0,
                                              color: Colors.red[900],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Container(
                                        height: 60.0,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0),
                                            child: FlatButton(
                                              padding: EdgeInsets.all(10),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              color: Color(0xFFF5F6F9),
                                              onPressed: () {},
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: <Widget>[
                                                  buildCount(
                                                      bookmodel.dates,
                                                      Icons
                                                          .calendar_today_sharp),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 5.0),
                                                    child: Container(
                                                      height: 30.0,
                                                      width: 0.5,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  buildCount(
                                                      bookmodel.person
                                                              .toString() +
                                                          " person(s)",
                                                      Icons.person_outline),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(
                                          'Table booked under the name ' +
                                              bookmodel.user["name"],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14.0,
                                            color: Colors.black,
                                          )),
                                      SizedBox(height: 5),
                                      Text(
                                        bookmodel.user["email"],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        bookmodel.user["phone_number"],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      FlatButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        color: Colors.red[900],
                                        disabledColor: Colors.grey[400],
                                        disabledTextColor: Colors.white60,
                                        onPressed: () {
                                          submitted = true;
                                        },
                                        child: submitted
                                            ? SizedBox(
                                                height: 15,
                                                width: 15,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              )
                                            : Text(
                                                "Delete Your Booking",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                            );
                          else
                            return Center(child: circularProgress(context));
                        });
                  } else {
                    return Center(
                        child: Text("You Booked restaurant will appear here ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.red[900],
                            )));
                  }
                },
              ),
            )
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
