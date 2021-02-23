import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lmaida/bloc.navigation_bloc/navigation_bloc.dart';
import 'package:lmaida/components/LmaidaCard.dart';
import 'package:lmaida/components/indicators.dart';
import 'package:lmaida/models/categorie_model.dart';
import 'package:lmaida/models/restau_model.dart';
import 'package:lmaida/utils/SizeConfig.dart';
import 'package:lmaida/utils/StringConst.dart';
import 'package:lmaida/utils/constants.dart';

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
  TextEditingController searchController = TextEditingController();
  String Search = "";

  String categ;
  int lenght;
  Future<List<dynamic>> fetResto() async {
    var result = await http.get(apiUrl);
    return json.decode(result.body);
  }

  final String apiUrl2 = StringConst.URI_CATEGORY;
  Future<List<dynamic>> fetchCat() async {
    Map<String, String> headers = {
      "Content-type": "application/json",
    };
    var result = await http.get(apiUrl2, headers: headers);
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
              height: getProportionateScreenHeight(300),
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
              height: 200.0,
              child: Center(
                child: headerTopCategories(),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(30, 205, 30, 20),
              height: 60.0,
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: FlatButton(
                    padding: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35)),
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
              margin: EdgeInsets.fromLTRB(0, 280, 0, 20),
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
                          String resName;
                          if (restoModel.categories.length != 0)
                            resName = restoModel.categories[0]["name"];

                          if (((categ != null && resName == categ) &&
                              (restoModel.name
                                      .toLowerCase()
                                      .contains(Search.toLowerCase()) ||
                                  restoModel.locationModel["name"]
                                      .toLowerCase()
                                      .contains(Search.toLowerCase()))))
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
                              category: restoModel.categories[0]["name"],
                              distance: "restoModel",
                              address: restoModel.address,
                            );
                          else if (categ == null ||
                              searchController.text == null)
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
                              category: restoModel.categories[0]["name"],
                              distance: "restoModel",
                              address: restoModel.address,
                            );
                          else
                            return Container(
                              width: 0,
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

  Widget headerCategoryItem(String im, String name, {onPressed}) {
    return Container(
      margin: EdgeInsets.only(left: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(bottom: 10, top: 20),
              width: 55,
              height: 55,
              child: FloatingActionButton(
                shape: CircleBorder(),
                heroTag: name,
                onPressed: onPressed,
                backgroundColor: white,
                child: im != null
                    ? CachedNetworkImage(
                        imageUrl: "https://lmaida.com/storage/categories/" + im,
                        fit: BoxFit.cover,
                        width: 35,
                        fadeInDuration: Duration(milliseconds: 500),
                        fadeInCurve: Curves.easeIn,
                        placeholder: (context, progressText) =>
                            Center(child: circularProgress(context)),
                      )
                    : Icon(Icons.dinner_dining,
                        size: 35, color: Colors.black87),
              )),
          Text(name + '',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins'))
        ],
      ),
    );
  }

  Widget headerTopCategories() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          child: Padding(
            padding: EdgeInsets.only(left: 40.0, right: 40.0),
            child: Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(50.0),
              child: TextFormField(
                style: TextStyle(color: Colors.black),
                cursorColor: black,
                controller: searchController,
                onChanged: (value) {
                  Search = value;
                },
                decoration: InputDecoration(
                  hintText: 'Search For Food/Resto',
                  prefixIcon: Icon(Icons.search, color: GBottomNav, size: 20.0),
                  hintStyle: TextStyle(
                      color: Colors.black, fontFamily: 'SFProDisplay-Black'),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 130,
          child: FutureBuilder<List<dynamic>>(
            future: fetchCat(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      CategorieModel categoraiemodel =
                          CategorieModel.fromJson(snapshot.data[index]);
                      return headerCategoryItem(
                          categoraiemodel.picture, categoraiemodel.name,
                          onPressed: () {
                        setState(() {
                          categ = categoraiemodel.name;
                        });
                      });
                    });
              } else {
                return Center(child: circularProgress(context));
              }
            },
          ),
        ),
      ],
    );
  }
}

/**/
