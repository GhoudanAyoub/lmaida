import 'dart:convert';
import 'dart:math' show cos, sqrt, asin;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
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
  final offers;

  const RestaurantPage({Key key, this.offers}) : super(key: key);
  @override
  _RestaurantState createState() => _RestaurantState();
}

class _RestaurantState extends State<RestaurantPage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final String apiUrl = StringConst.URI_RESTAU + 'all';
  String dropdownValue = '2';
  String FilterdropdownValue = "WIFI";
  var selectedDateTxt;
  var selectedTimeTxt;
  DateTime selectedDate = DateTime.now();
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  TextEditingController searchController = TextEditingController();
  String Search = "";

  Position position;
  String categ;

  bool filter;
  bool checkedLocationValue = false;
  List<bool> checkList = [];

  String restolenght;

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

  final String apiUrl3 = StringConst.URI_FILTERS;
  Future<List<dynamic>> fetchFilters() async {
    Map<String, String> headers = {
      "Content-type": "application/json",
    };
    var result = await http.get(apiUrl3, headers: headers);
    return json.decode(result.body);
  }

  @override
  void initState() {
    getLastLocation();
    filter = false;
    checkedLocationValue = false;
    super.initState();
  }

  getLastLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
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
            Positioned(
              top: 35,
              right: 10,
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                height: 40,
                child: FlatButton(
                  onPressed: () {
                    fl3(context);
                  },
                  child: Icon(
                    Icons.filter_alt,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 30, 80, 20),
              height: 200.0,
              child: Center(
                child: headerTopCategories(),
              ),
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
                              selectedDateTxt != null
                                  ? "${selectedDateTxt.year}-${selectedDateTxt.month}-${selectedDateTxt.day}"
                                  : "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",
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
                              selectedTimeTxt != null
                                  ? "${selectedTimeTxt.hour} : ${selectedTimeTxt.minute}"
                                  : "${selectedDate.hour} : ${selectedDate.minute}",
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
                            value: dropdownValue ?? dropdownValue,
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
            ),
            widget.offers == null
                ? Container(
                    margin: EdgeInsets.fromLTRB(10, 170, 10, 20),
                    child: FutureBuilder<List<dynamic>>(
                        future: fetResto(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            restolenght = snapshot.data.length.toString();
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(restolenght + " Restaurants In General",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ))
                              ],
                            );
                          } else
                            return Container(
                              child: Center(
                                child: Text(""),
                              ),
                            );
                        }),
                  )
                : Container(
                    margin: EdgeInsets.fromLTRB(10, 150, 10, 20),
                    child: Container(
                      child: Center(
                        child: Text("No Special Offers Found For The Moments",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                  ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 180, 10, 20),
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
                          String resName, dis;
                          if (widget.offers == null) {
                            if (restoModel.categories.length != 0)
                              resName = restoModel.categories[0]["name"];

                            if (!checkedLocationValue) if (FilterdropdownValue ==
                                "WIFI") if (((categ != null &&
                                    resName == categ) &&
                                (restoModel.name
                                        .toLowerCase()
                                        .contains(Search.toLowerCase()) ||
                                    restoModel.locationModel["name"]
                                        .toLowerCase()
                                        .contains(Search.toLowerCase())))) {
                              dis = calculateDistance(
                                      position.latitude,
                                      position.longitude,
                                      double.tryParse(restoModel.address_lat),
                                      double.tryParse(restoModel.address_lon))
                                  .toStringAsFixed(2);
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
                                restoModel: restoModel,
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
                                distance: dis,
                                address: restoModel.address,
                              );
                            } else if (position != null && categ == null ||
                                searchController.text == null) {
                              dis = calculateDistance(
                                      position.latitude,
                                      position.longitude,
                                      double.tryParse(restoModel.address_lat),
                                      double.tryParse(restoModel.address_lon))
                                  .toStringAsFixed(2);
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
                                restoModel: restoModel,
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
                                distance: dis,
                                address: restoModel.address,
                              );
                            } else
                              return Container(
                                width: 0,
                              );
                            else if (restoModel.filters[0]["name"]
                                .toLowerCase()
                                .contains(FilterdropdownValue.toLowerCase()))
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
                                restoModel: restoModel,
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
                                distance: calculateDistance(
                                        position.latitude,
                                        position.longitude,
                                        double.tryParse(restoModel.address_lat),
                                        double.tryParse(restoModel.address_lon))
                                    .toStringAsFixed(2),
                                address: restoModel.address,
                              );
                            else
                              return Container(
                                width: 0,
                              );
                            else if (calculateDistance(
                                    position.latitude,
                                    position.longitude,
                                    double.tryParse(restoModel.address_lat),
                                    double.tryParse(restoModel.address_lon)) >
                                10)
                              return Container(
                                width: 0,
                              );
                            else
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
                                restoModel: restoModel,
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
                                distance: dis,
                                address: restoModel.address,
                              );
                          } else {
                            if (restoModel.special_offer != null)
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
                                restoModel: restoModel,
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
                                distance: calculateDistance(
                                        position.latitude,
                                        position.longitude,
                                        double.tryParse(restoModel.address_lat),
                                        double.tryParse(restoModel.address_lon))
                                    .toStringAsFixed(2),
                                address: restoModel.address,
                              );
                            else {
                              return Container(
                                width: 0,
                              );
                            }
                          }
                        });
                  } else {
                    return Center(child: circularProgress(context));
                  }
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.fromLTRB(20, 100, 20, 20),
                height: 60.0,
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: Colors.blue[700],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigationEvents.MapClickedEvent);
                            },
                            child: buildCount2("Map View", Icons.map),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 5.0, top: 5.0),
                            child: Container(
                              height: 40.0,
                              width: 0.5,
                              color: Colors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigationEvents.RestaurantPageEvent);
                            },
                            child: buildCount2("List View", Icons.list_rounded),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 5.0, top: 5.0),
                            child: Container(
                              height: 40.0,
                              width: 0.5,
                              color: Colors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              BlocProvider.of<NavigationBloc>(context).add(
                                  NavigationEvents
                                      .RestaurantPageEventWithParam);
                            },
                            child: buildCount2(
                                "Special Offers", Icons.offline_bolt),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  fl3(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(10),
              child: Stack(
                overflow: Overflow.visible,
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: 300,
                    child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        child: DefaultTabController(
                          length: 1,
                          child: Scaffold(
                            appBar: AppBar(
                              automaticallyImplyLeading: false,
                              toolbarHeight: 50,
                              bottom: TabBar(
                                tabs: <Widget>[
                                  Tab(
                                    text: 'Filters',
                                  ),
                                ],
                              ),
                            ),
                            body: Column(
                              children: [
                                SizedBox(
                                  height: 100,
                                  child: FutureBuilder<List<dynamic>>(
                                    future: fetchCat(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot snapshot) {
                                      if (snapshot.hasData) {
                                        return ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                            itemCount: snapshot.data.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              CategorieModel categoraiemodel =
                                                  CategorieModel.fromJson(
                                                      snapshot.data[index]);
                                              return headerCategoryItem(
                                                  categoraiemodel.picture,
                                                  categoraiemodel.name,
                                                  onPressed: () {
                                                setState(() {
                                                  categ = categoraiemodel.name;
                                                });
                                              });
                                            });
                                      } else {
                                        return Center(
                                            child: circularProgress(context));
                                      }
                                    },
                                  ),
                                ),
                                CheckboxListTile(
                                  title: Text("Filter With Your Location",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  value: checkedLocationValue,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      checkedLocationValue = newValue;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                DropdownButton<String>(
                                  value: FilterdropdownValue ??
                                      FilterdropdownValue,
                                  icon: Icon(
                                    Icons.filter_alt,
                                    color: Colors.red[900],
                                    size: 20,
                                  ),
                                  iconSize: 24,
                                  elevation: 16,
                                  style: TextStyle(color: Colors.red[900]),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      FilterdropdownValue = newValue;
                                    });
                                    Navigator.pop(context);
                                  },
                                  items: <String>[
                                    'WIFI',
                                    'Accepte animaux',
                                    'Zone fumeur',
                                    'emporter',
                                    'Alcool',
                                    'Buffet',
                                    'Happy Hours',
                                    'Bars sportifs',
                                    'Brunch',
                                    'Terrasse',
                                    'Acc\u00e8s en fauteuil roulant',
                                    'Restauration de luxe',
                                    'Cartes de cr\u00e9dit'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text("Filter With " + value,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ),
                  Positioned(
                      top: 300,
                      left: 30,
                      width: 150,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        color: Colors.red[900],
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('APPLY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                      )),
                  Positioned(
                      top: 300,
                      right: 30,
                      width: 150,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        color: Colors.red[900],
                        onPressed: () {
                          searchController.text = null;
                          categ = null;
                          FilterdropdownValue = "WIFI";
                          checkedLocationValue = false;
                        },
                        child: Text('clean',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                      ))
                ],
              ));
        });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a;
    if (lon2 != null && lat2 != null && lat2 != "" && lon2 != "")
      a = 0.5 -
          c((lat2 - lat1) * p) / 2 +
          c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    if (a != null)
      return 12742 * asin(sqrt(a));
    else
      return 1000000;
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
  buildCount2(String label, final icons) {
    return Row(
      children: <Widget>[
        Icon(
          icons,
          color: Colors.white,
          size: 20,
        ),
        SizedBox(width: 5.0),
        Text(
          label,
          style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.normal,
              fontFamily: 'Ubuntu-Regular'),
        )
      ],
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

  Widget headerCategoryItem(String im, String name, {onPressed}) {
    return Container(
      margin: EdgeInsets.only(left: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(bottom: 5, top: 10),
              width: 55,
              height: 40,
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
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins'))
        ],
      ),
    );
  }

  Widget headerTopCategories() {
    return Column(
      children: <Widget>[
        Container(
          child: Padding(
            padding: EdgeInsets.only(left: 40.0, right: 20.0),
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
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search, color: GBottomNav, size: 20.0),
                  hintStyle: TextStyle(
                      color: Colors.black, fontFamily: 'SFProDisplay-Black'),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/**/
