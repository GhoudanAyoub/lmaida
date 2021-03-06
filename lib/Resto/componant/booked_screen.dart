import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lmaida/bloc.navigation_bloc/navigation_bloc.dart';
import 'package:lmaida/components/default_button.dart';
import 'package:lmaida/components/text_form_builder.dart';
import 'package:lmaida/models/restau_model.dart';
import 'package:lmaida/utils/SizeConfig.dart';
import 'package:lmaida/utils/firebase.dart';
import 'package:lmaida/values/values.dart';

class BookedScreen extends StatefulWidget with NavigationStates {
  final RestoModel restoModel;
  final String offer;
  final dropdownValue;
  final selectedDateTxt;
  final selectedTimeTxt;

  const BookedScreen(
      {Key key,
      this.restoModel,
      this.offer,
      this.dropdownValue,
      this.selectedDateTxt,
      this.selectedTimeTxt})
      : super(key: key);

  @override
  _BookedScreenState createState() => _BookedScreenState();
}

class _BookedScreenState extends State<BookedScreen> {
  TextEditingController Controller = TextEditingController();
  final String apiUrl = StringConst.URI_RESTAU + 'all';
  String dropdownValue;
  var selectedDateTxt;
  var selectedTimeTxt;
  DateTime selectedDate = DateTime.now();
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  DocumentSnapshot user1;
  bool loading = true;
  bool sub = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    getUsers();
  }

  void showInSnackBar(String value) {
    scaffoldKey.currentState.removeCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  getUsers() async {
    DocumentSnapshot snap =
        await usersRef.doc(firebaseAuth.currentUser.uid).get();
    if (snap.data()["id"] == firebaseAuth.currentUser.uid) user1 = snap;
    setState(() {
      loading = false;
    });
  }

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
                                : "https://lmaida.com/storage/gallery/" +
                                    widget.restoModel.pictures,
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
                          width: MediaQuery.of(context).size.width,
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
                        GestureDetector(
                          onTap: () async {
                            selectedDateTxt = await _selectDateTime(context);
                            if (selectedDateTxt == null) return;

                            print(selectedDateTxt);

                            selectedTimeTxt = await _selectTime(context);
                            if (selectedTimeTxt == null) return;
                            print(selectedTimeTxt);

                            setState(() {
                              this.selectedDate = DateTime(
                                selectedDateTxt.year,
                                selectedDateTxt.month,
                                selectedDateTxt.day,
                                selectedTimeTxt.hour,
                                selectedTimeTxt.minute,
                              );
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.fromLTRB(10, 100, 10, 20),
                            height: 60.0,
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: FlatButton(
                                  padding: EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  color: Color(0xFFF5F6F9),
                                  onPressed: () async {
                                    selectedDateTxt =
                                        await _selectDateTime(context);
                                    if (selectedDateTxt == null) return;

                                    print(selectedDateTxt);

                                    selectedTimeTxt =
                                        await _selectTime(context);
                                    if (selectedTimeTxt == null) return;
                                    print(selectedTimeTxt);

                                    setState(() {
                                      this.selectedDate = DateTime(
                                        selectedDateTxt.year,
                                        selectedDateTxt.month,
                                        selectedDateTxt.day,
                                        selectedTimeTxt.hour,
                                        selectedTimeTxt.minute,
                                      );
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      buildCount(
                                          widget.selectedDateTxt != null
                                              ? "${widget.selectedDateTxt.year}-${widget.selectedDateTxt.month}-${widget.selectedDateTxt.day}"
                                              : "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",
                                          Icons.calendar_today_sharp),
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
                                          widget.selectedTimeTxt != null
                                              ? "${widget.selectedTimeTxt.hour} : ${widget.selectedTimeTxt.minute}"
                                              : "${selectedDate.hour} : ${selectedDate.minute}",
                                          Icons.watch_later_outlined),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5.0),
                                        child: Container(
                                          height: 30.0,
                                          width: 0.5,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      DropdownButton<String>(
                                        value: dropdownValue ??
                                            widget.dropdownValue,
                                        icon: Icon(
                                          Icons.person_outline,
                                          color: Colors.red[900],
                                          size: 20,
                                        ),
                                        iconSize: 24,
                                        elevation: 16,
                                        style:
                                            TextStyle(color: Colors.red[900]),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            dropdownValue = newValue;
                                          });
                                        },
                                        items: <String>[
                                          '1',
                                          '2',
                                          '3',
                                          '4',
                                          '5',
                                          '6',
                                          '7',
                                          '8',
                                          '9',
                                          '10'
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value + " pers"),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
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
                          buildbody(context),
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

  Future book() async {
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
    print(message["token"]);
    getPorf(message["token"]);
  }

  Future getPorf(Token) async {
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $Token",
      "Content-Type": "application/json"
    };
    var url = 'https://lmaida.com/api/profile';
    var response = await http.post(Uri.encodeFull(url), headers: header);
    var message = jsonDecode(response.body);
    print(message[0]["name"]);
    AddBook(Token, message[0]["id"], widget.restoModel.id,
        widget.dropdownValue ?? dropdownValue, widget.offer);
  }

  Future AddBook(Token, userid, itemid, person, offer) async {
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $Token",
      "Content-Type": "application/json"
    };
    var url = 'https://lmaida.com/api/booking';
    var data = {
      'iduser': userid,
      'iditem': itemid,
      'dates':
          "${widget.selectedDateTxt != null ? "${widget.selectedDateTxt.year}-${widget.selectedDateTxt.month}-${widget.selectedDateTxt.day}" : "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"}" +
              " / " +
              "${widget.selectedTimeTxt != null ? "${widget.selectedTimeTxt.hour} : ${widget.selectedTimeTxt.minute}" : "${selectedDate.hour} : ${selectedDate.minute}"}",
      'person': person != null ? int.parse(person) : 1,
      'offre': offer,
      'specialrequest': Controller.text != null ? Controller.text : ""
    };
    var response = await http.post(Uri.encodeFull(url),
        headers: header, body: json.encode(data));
    var message = jsonDecode(response.body);
    print(message);
    if (message["errors"] != null) {
      Fluttertoast.showToast(
          msg: message["errors"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red[900],
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        sub = false;
      });
    } else {
      Fluttertoast.showToast(
          msg: message["message"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

      setState(() {
        sub = false;
      });
    }
  }

  Future<TimeOfDay> _selectTime(BuildContext context) {
    final now = DateTime.now();
    return widget.selectedTimeTxt != null
        ? showTimePicker(
            context: context,
            initialTime: TimeOfDay(
                hour: widget.selectedTimeTxt.hour,
                minute: widget.selectedTimeTxt.minute),
          )
        : showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
          );
  }

  Future<DateTime> _selectDateTime(BuildContext context) =>
      widget.selectedDateTxt != null
          ? showDatePicker(
              context: context,
              initialDate: widget.selectedDateTxt.add(Duration(seconds: 1)),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            )
          : showDatePicker(
              context: context,
              initialDate: DateTime.now().add(Duration(seconds: 1)),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );

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

  buildbody(context) {
    if (!loading && user1 != null) {
      return Column(
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
          Icon(Icons.dinner_dining, size: 80, color: Colors.black87),
          SizedBox(height: 16.0),
          Text(
            user1.data()["username"],
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
            user1.data()["contact"],
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
          SizedBox(height: 16.0),
          TextFormBuilder(
            controller: Controller,
            enabled: true,
            suffix: Feather.inbox,
            hintText: "Special Requests",
            textInputAction: TextInputAction.next,
            onSaved: (String val) {},
          ),
          SizedBox(height: 16.0),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultButton(
                  text: "CONFIRM YOUR TABLE",
                  submitted: sub,
                  press: () {
                    setState(() {
                      sub = true;
                    });
                    book();
                  },
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
      );
    } else {
      return Column(
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
          Icon(Icons.dinner_dining, size: 80, color: Colors.black87),
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
            firebaseAuth.currentUser.email ?? "",
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
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultButton(
                  text: "CONFIRM YOUR TABLE",
                  submitted: sub,
                  press: () {
                    book();
                    BlocProvider.of<NavigationBloc>(context)
                        .add(NavigationEvents.MyOrdersClickedEvent);
                  },
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
      );
    }
  }
}
