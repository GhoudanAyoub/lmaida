import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lmaida/bloc.navigation_bloc/navigation_bloc.dart';
import 'package:lmaida/components/LmaidaCard.dart';
import 'package:lmaida/components/indicators.dart';
import 'package:lmaida/models/restau_model.dart';
import 'package:lmaida/utils/SizeConfig.dart';
import 'package:lmaida/utils/StringConst.dart';

import 'componant/new_resto_details.dart';

List<RestoModel> _restau = new List<RestoModel>();

class RestaurantPage extends StatefulWidget with NavigationStates {
  @override
  _RestaurantState createState() => _RestaurantState();
}

class _RestaurantState extends State<RestaurantPage> {
  final String apiUrl = StringConst.URI_RESTAU + 'all';
  String dropdownValue = '2';
  var selectedDateTxt;
  var selectedTimeTxt;
  DateTime selectedDate = DateTime.now();
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  Future<List<dynamic>> fetResto() async {
    var result = await http.get(apiUrl);
    return json.decode(result.body);
  }

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
                "All restaurants",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 24.0,
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
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: FlatButton(
                    padding: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    color: Color(0xFFF5F6F9),
                    onPressed: () async {
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        buildCount(
                            "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}" ??
                                "18 Jun",
                            Icons.calendar_today_sharp),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Container(
                            height: 30.0,
                            width: 0.5,
                            color: Colors.grey,
                          ),
                        ),
                        buildCount(
                            "${selectedDate.hour} : ${selectedDate.minute}" ??
                                "20:03",
                            Icons.watch_later_outlined),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Container(
                            height: 30.0,
                            width: 0.5,
                            color: Colors.grey,
                          ),
                        ),
                        DropdownButton<String>(
                          value: dropdownValue,
                          icon: Icon(
                            Icons.person_outline,
                            color: Colors.red[900],
                            size: 20,
                          ),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.red[900]),
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
                          ].map<DropdownMenuItem<String>>((String value) {
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
            Container(
              margin: EdgeInsets.fromLTRB(0, 170, 0, 20),
              child: FutureBuilder<List<dynamic>>(
                future: fetResto(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        padding: EdgeInsets.all(20),
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          RestoModel restoModel =
                              RestoModel.fromJson(snapshot.data[index]);
                          return LmaidaCard(
                            onTap: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NewRestoDetails(
                                          restoModel: restoModel,
                                          dropdownValue: dropdownValue,
                                          selectedDateTxt: selectedDateTxt,
                                          selectedTimeTxt: selectedTimeTxt,
                                        )),
                              )
                            },
                            time: restoModel.opening_hours_from == null ||
                                    restoModel.opening_hours_from == ''
                                ? " "
                                : "Opening from " +
                                    restoModel.opening_hours_from +
                                    " to " +
                                    restoModel.opening_hours_to,
                            imagePath: restoModel.pictures,
                            status: restoModel.status,
                            cardTitle: restoModel.name,
                            category: restoModel.categories,
                            distance: "restoModel",
                            address: restoModel.address,
                          );
                        });
                  } else {
                    return Center(child: circularProgress(context));
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<TimeOfDay> _selectTime(BuildContext context) {
    final now = DateTime.now();

    return showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
    );
  }

  Future<DateTime> _selectDateTime(BuildContext context) => showDatePicker(
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
}

/**/
