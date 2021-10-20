import 'dart:convert';
import 'dart:math' show cos, sqrt, asin;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lmaida/Home/Components/multiple_nutifier.dart';
import 'package:lmaida/bloc.navigation_bloc/navigation_bloc.dart';
import 'package:lmaida/components/LmaidaCard.dart';
import 'package:lmaida/components/custom_card.dart';
import 'package:lmaida/components/indicators.dart';
import 'package:lmaida/helper/lmaida_controller.dart';
import 'package:lmaida/models/restau_model.dart';
import 'package:lmaida/utils/SizeConfig.dart';
import 'package:lmaida/utils/StringConst.dart';
import 'package:lmaida/utils/constants.dart';
import 'package:provider/provider.dart';

import 'componant/new_resto_details.dart';

List<RestoModel> _restau = new List<RestoModel>();

class RestaurantPage extends StatefulWidget with NavigationStates {
  final offers;

  const RestaurantPage({Key key, this.offers}) : super(key: key);
  @override
  _RestaurantState createState() => _RestaurantState();
}

class _RestaurantState extends State<RestaurantPage> {
  final LmaidaController lmaidaController = Get.put(LmaidaController());
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
  ScrollController _controller;
  Position position;
  String categ;
  List<bool> checkList = [];
  String restolenght;
  String catId;
  bool open = false;
  String _selected;
  bool show = true;
  Set<int> selectedValues, locSelectedValues, filterSelectedValues;
  var color;
  dynamic Adv_Filter = false;
  var fetRestoAdvanceResult;
  var locationId;
  String locationName = "", SpectName = "";
  var addresses;
  double reviewsData = 0.0;

  Future<List<dynamic>> fetRestAdvance(location_id) async {
    //lmaidaController.fetchAdvRest(location_id);
    var result = await http.get(StringConst.URI_RESTAU_ADV +
        "${selectedValues != null ? selectedValues.join(",") : "1"}/${catId != null ? catId : 14}/${location_id != null ? location_id : locationId}");
    return json.decode(result.body);
  }

  Future<List<dynamic>> fetResto(id) async {
    var result = await http.get("$apiUrl/$id");
    return json.decode(result.body);
  }

  Future<List<dynamic>> fetSearch(name) async {
    var result =
        await http.get("${StringConst.URI_SEARCH}/${name != "" ? name : "r"}");
    return json.decode(result.body);
  }

  @override
  void initState() {
    color = Colors.black;
    _controller = ScrollController();
    //getLastLocation();
    super.initState();
  }

  getLastLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    await Geocoder.local
        .findAddressesFromCoordinates(
            new Coordinates(position.latitude, position.longitude))
        .then((value) {
      setState(() {
        addresses = value;
      });
    });
/*
    for (var location in fetLocationResult) {
      if (addresses.first.addressLine.contains(location["name"])) {
        setState(() {
          show = false;
          fetRestoAdvanceResult = fetResto(location["id"]);
          locationId = location["id"];
        });
      }
    }*/
  }

  void _showMultiSelect(BuildContext context) async {
    selectedValues = await showDialog<Set<int>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: lmaidaController.multiItem,
          initialSelectedValues: [
            1,
          ].toSet(),
        );
      },
    );
    setState(() {
      SpectName = selectedValues.join(",");
    });
  }

  void _showLocMultiSelect(BuildContext context) async {
    locSelectedValues = await showDialog<Set<int>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: lmaidaController.locMultiItem,
          initialSelectedValues: null,
        );
      },
    );
    setState(() {
      locationName = locSelectedValues.join(",");
    });
  }

  _showMultipleChoiceDialog(BuildContext context) => showDialog(
      context: context,
      builder: (context) {
        final _multipleNotifier = Provider.of<MultipleNotifier>(context);
        return AlertDialog(
          title: Text('Select Category'),
          content: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Obx(() {
                if (lmaidaController.isLoadingCategories.value)
                  return linearProgress(context);
                else
                  return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: lmaidaController.categoriesList
                          .map((e) => CheckboxListTile(
                                title: Row(
                                  children: <Widget>[
                                    e["picture"] != null
                                        ? CachedNetworkImage(
                                            imageUrl:
                                                "https://lmaida.com/storage/categories/" +
                                                    e["picture"],
                                            fit: BoxFit.cover,
                                            width: 20,
                                            fadeInDuration:
                                                Duration(milliseconds: 500),
                                            fadeInCurve: Curves.easeIn,
                                            placeholder:
                                                (context, progressText) =>
                                                    Container(
                                                        width: 20,
                                                        child: circularProgress(
                                                            context)),
                                          )
                                        : Icon(Icons.dinner_dining,
                                            size: 20, color: Colors.black87),
                                    Container(
                                        margin: EdgeInsets.only(left: 5),
                                        width: 100,
                                        child: Text(
                                          e["name"],
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        )),
                                  ],
                                ),
                                onChanged: (value) {
                                  value
                                      ? _multipleNotifier.addItem(e["name"])
                                      : _multipleNotifier.removeItem(e["name"]);

                                  value
                                      ? setState(() {
                                          _selected = e["name"];
                                          catId = e["id"].toString();
                                        })
                                      : setState(() {
                                          _selected = null;
                                          catId = null;
                                        });
                                },
                                value: _multipleNotifier.isHaveItem(e["name"]),
                              ))
                          .toList());
              }),
            ),
          ),
          actions: [
            FlatButton(
              child: Text('Yes'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      });
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color(0xfff2f3f7),
        body: Container(
          child: Stack(
            children: <Widget>[
              Positioned(
                bottom: 300.0,
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
                height: getProportionateScreenHeight(300),
                width: MediaQuery.of(context).size.width,
                child: Container(
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: const Radius.circular(150),
                      bottomRight: const Radius.circular(150),
                    ),
                  ),
                ),
              ),
              Container(
                height: SizeConfig.screenHeight,
                padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
                child: ListView(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          height: 20,
                          child: FlatButton(
                            onPressed: () {
                              //fl3(context);
                              setState(() {
                                open = !open;
                              });
                            },
                            child: Icon(
                              Icons.filter_alt,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
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
                        margin: EdgeInsets.fromLTRB(10, 40, 10, 20),
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
                              onPressed: () async {
                                selectedDateTxt =
                                    await _selectDateTime(context);
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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
                                      color: primary,
                                      size: 17,
                                    ),
                                    iconSize: 24,
                                    elevation: 16,
                                    style: TextStyle(color: primary),
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
                    open != false
                        ? Card(
                            elevation: 5,
                            margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Specs :",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomCard(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              child: Container(
                                                child: Theme(
                                                  data: ThemeData(
                                                    primaryColor:
                                                        Theme.of(context)
                                                            .accentColor,
                                                    accentColor:
                                                        Theme.of(context)
                                                            .accentColor,
                                                  ),
                                                  child: FlatButton(
                                                    onPressed: () {
                                                      _showMultiSelect(context);
                                                    },
                                                    child: Text(
                                                      selectedValues == null
                                                          ? 'Choose'
                                                          : SpectName,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        "Location :",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomCard(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              child: Container(
                                                child: Theme(
                                                  data: ThemeData(
                                                    primaryColor:
                                                        Theme.of(context)
                                                            .accentColor,
                                                    accentColor:
                                                        Theme.of(context)
                                                            .accentColor,
                                                  ),
                                                  child: FlatButton(
                                                    onPressed: () {
                                                      _showLocMultiSelect(
                                                          context);
                                                    },
                                                    child: Text(
                                                      locSelectedValues == null
                                                          ? 'Choose'
                                                          : locationName,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Categories :",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomCard(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              child: Container(
                                                child: Theme(
                                                  data: ThemeData(
                                                    primaryColor:
                                                        Theme.of(context)
                                                            .accentColor,
                                                    accentColor:
                                                        Theme.of(context)
                                                            .accentColor,
                                                  ),
                                                  child: FlatButton(
                                                    onPressed: () {
                                                      _showMultipleChoiceDialog(
                                                          context);
                                                    },
                                                    child: Text(
                                                      _selected == null
                                                          ? 'Select Category'
                                                          : _selected,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      FlatButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        color: Colors.redAccent,
                                        onPressed: () {
                                          setState(() {
                                            show = false;
                                            open = false;
                                            fetRestoAdvanceResult = fetRestAdvance(
                                                "${locSelectedValues != null ? locSelectedValues.join(",") : null}");
                                          });
                                        },
                                        child: Text('APPLY',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      FlatButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        color: Colors.redAccent,
                                        onPressed: () {
                                          setState(() {
                                            fetRestoAdvanceResult =
                                                lmaidaController.restList;
                                            open = false;
                                            searchController.text = null;
                                          });
                                        },
                                        child: Text('CLEAN',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            height: 2,
                          ),
                    Obx(() {
                      if (lmaidaController.isLoadingLocation.value)
                        return Center(child: circularProgress(context));
                      else if (lmaidaController.restList == null &&
                          fetRestoAdvanceResult == null)
                        return Container(
                            height: open ? 150 : 400,
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Center(
                                child: Text(
                                  'No Restaurants Near ${lmaidaController.address.first.addressLine} Yet ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ));
                      else
                        return Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                          height: SizeConfig.screenHeight - 40,
                          child: FutureBuilder<List<dynamic>>(
                            future: fetRestoAdvanceResult,
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot != null && snapshot.data != null) {
                                return RefreshIndicator(
                                    child: ListView.builder(
                                        controller: _controller, //new line
                                        padding: EdgeInsets.all(10),
                                        itemCount: snapshot.data.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          RestoModel restoModel =
                                              RestoModel.fromJson(
                                                  snapshot.data[index]);
                                          String dis;
                                          if (widget.offers == null &&
                                              position != null &&
                                              restoModel.address_lat != null &&
                                              restoModel.address_lon != null) {
                                            dis = calculateDistance(
                                                    position.latitude,
                                                    position.longitude,
                                                    double.tryParse(
                                                        restoModel.address_lat),
                                                    double.tryParse(
                                                        restoModel.address_lon))
                                                .toStringAsFixed(2);
                                            if (Search != null &&
                                                restoModel.name
                                                    .toLowerCase()
                                                    .contains(
                                                        Search.toLowerCase())) {
                                              return LmaidaCard(
                                                onTap: () => {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            NewRestoDetails(
                                                              restoModel:
                                                                  restoModel,
                                                              dropdownValue:
                                                                  dropdownValue,
                                                              selectedDateTxt:
                                                                  selectedDateTxt,
                                                              selectedTimeTxt:
                                                                  selectedTimeTxt,
                                                              locationId:
                                                                  locationId,
                                                            )),
                                                  )
                                                },
                                                restoModel: restoModel,
                                                time: restoModel.opening_hours_from ==
                                                            null ||
                                                        restoModel
                                                                .opening_hours_from ==
                                                            ''
                                                    ? " "
                                                    : "Opening from " +
                                                        restoModel
                                                            .opening_hours_from +
                                                        " to " +
                                                        restoModel
                                                            .opening_hours_to,
                                                imagePath: restoModel.pictures,
                                                status: restoModel.status,
                                                cardTitle: restoModel.name,
                                                category: restoModel.categories
                                                            .length !=
                                                        0
                                                    ? restoModel.categories[0]
                                                        ["name"]
                                                    : "",
                                                distance: dis,
                                                address: restoModel.address,
                                              );
                                            } else
                                              return LmaidaCard(
                                                onTap: () => {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            NewRestoDetails(
                                                              restoModel:
                                                                  restoModel,
                                                              dropdownValue:
                                                                  dropdownValue,
                                                              selectedDateTxt:
                                                                  selectedDateTxt,
                                                              selectedTimeTxt:
                                                                  selectedTimeTxt,
                                                              locationId:
                                                                  locationId,
                                                            )),
                                                  )
                                                },
                                                restoModel: restoModel,
                                                time: restoModel.opening_hours_from ==
                                                            null ||
                                                        restoModel
                                                                .opening_hours_from ==
                                                            ''
                                                    ? " "
                                                    : "Opening from " +
                                                        restoModel
                                                            .opening_hours_from +
                                                        " to " +
                                                        restoModel
                                                            .opening_hours_to,
                                                imagePath: restoModel.pictures,
                                                status: restoModel.status,
                                                cardTitle: restoModel.name,
                                                category: restoModel.categories
                                                            .length !=
                                                        0
                                                    ? restoModel.categories[0]
                                                        ["name"]
                                                    : "",
                                                distance: dis,
                                                address: restoModel.address,
                                              );
                                          } else {
                                            if (Search != null &&
                                                restoModel.name
                                                    .toLowerCase()
                                                    .contains(
                                                        Search.toLowerCase()))
                                              return LmaidaCard(
                                                onTap: () => {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            NewRestoDetails(
                                                              restoModel:
                                                                  restoModel,
                                                              dropdownValue:
                                                                  dropdownValue,
                                                              selectedDateTxt:
                                                                  selectedDateTxt,
                                                              selectedTimeTxt:
                                                                  selectedTimeTxt,
                                                              locationId:
                                                                  locationId,
                                                            )),
                                                  )
                                                },
                                                restoModel: restoModel,
                                                time: restoModel.opening_hours_from ==
                                                            null ||
                                                        restoModel
                                                                .opening_hours_from ==
                                                            ''
                                                    ? " "
                                                    : "Opening from " +
                                                        restoModel
                                                            .opening_hours_from +
                                                        " to " +
                                                        restoModel
                                                            .opening_hours_to,
                                                imagePath: restoModel.pictures,
                                                status: restoModel.status,
                                                cardTitle: restoModel.name,
                                                category: restoModel.categories
                                                            .length !=
                                                        0
                                                    ? restoModel.categories[0]
                                                        ["name"]
                                                    : "",
                                                distance: dis,
                                                address: restoModel.address,
                                              );
                                            else
                                              return LmaidaCard(
                                                onTap: () => {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            NewRestoDetails(
                                                              restoModel:
                                                                  restoModel,
                                                              dropdownValue:
                                                                  dropdownValue,
                                                              selectedDateTxt:
                                                                  selectedDateTxt,
                                                              selectedTimeTxt:
                                                                  selectedTimeTxt,
                                                              locationId:
                                                                  locationId,
                                                            )),
                                                  )
                                                },
                                                restoModel: restoModel,
                                                time: restoModel.opening_hours_from ==
                                                            null ||
                                                        restoModel
                                                                .opening_hours_from ==
                                                            ''
                                                    ? " "
                                                    : "Opening from " +
                                                        restoModel
                                                            .opening_hours_from +
                                                        " to " +
                                                        restoModel
                                                            .opening_hours_to,
                                                imagePath: restoModel.pictures,
                                                status: restoModel.status,
                                                cardTitle: restoModel.name,
                                                category: restoModel.categories
                                                            .length !=
                                                        0
                                                    ? restoModel.categories[0]
                                                        ["name"]
                                                    : "",
                                                distance: dis,
                                                address: restoModel.address,
                                              );
                                          }
                                        }),
                                    onRefresh: () {
                                      return getLastLocation();
                                    });
                              } else {
                                return Center(child: circularProgress(context));
                              }
                            },
                          ),
                        );
                    }),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10, 30, 80, 20),
                height: 200.0,
                child: Center(
                  child: headerTopCategories(),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 100, 5, 20),
                  height: 60.0,
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        color: Colors.blue[700],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            SizedBox(
                              width: 120,
                              child: FlatButton(
                                color: Colors.grey.withOpacity(0.1),
                                onPressed: () {
                                  BlocProvider.of<NavigationBloc>(context)
                                      .add(NavigationEvents.MapClickedEvent);
                                },
                                child: buildCount2("Map View", Icons.map),
                              ),
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
                            SizedBox(
                              width: 120,
                              child: FlatButton(
                                color: Colors.grey.withOpacity(0.1),
                                onPressed: () {
                                  BlocProvider.of<NavigationBloc>(context).add(
                                      NavigationEvents.RestaurantPageEvent);
                                },
                                child: buildCount2(
                                    "List View", Icons.list_rounded),
                              ),
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
                            SizedBox(
                              width: 120,
                              child: FlatButton(
                                color: Colors.grey.withOpacity(0.1),
                                onPressed: () {
                                  BlocProvider.of<NavigationBloc>(context).add(
                                      NavigationEvents
                                          .RestaurantPageEventWithParam);
                                },
                                child:
                                    buildCount2("Specials", Icons.offline_bolt),
                              ),
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
        ),
      ),
    );
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
          color: primary,
          size: 15,
        ),
        SizedBox(width: 5.0),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: primary,
            fontWeight: FontWeight.normal,
          ),
        )
      ],
    );
  }

  Widget headerCategoryItem(String im, String name, String id, {onPressed}) {
    return Container(
      margin: EdgeInsets.only(left: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(bottom: 5, top: 10),
              width: 60,
              height: 60,
              child: FloatingActionButton(
                elevation: 8,
                shape: CircleBorder(),
                heroTag: name,
                onPressed: () {
                  onPressed;
                  setState(() {
                    catId = id;
                    color = primary;
                  });
                },
                backgroundColor: Colors.white,
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
                  color: color,
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
            padding: EdgeInsets.only(left: 40.0, right: 10.0),
            child: Material(
              elevation: 3.0,
              borderRadius: BorderRadius.circular(30.0),
              child: TextFormField(
                style: TextStyle(color: Colors.black),
                cursorColor: black,
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    Search = value;
                    fetRestoAdvanceResult = fetSearch(searchController.text);
                    print(Search);
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search, color: GBottomNav, size: 15.0),
                  hintStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'SFProDisplay-Black'),
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

// ================== copied from stakeOverFlow

class MultiSelectDialogItem<V> {
  const MultiSelectDialogItem(this.value, this.label);

  final V value;
  final String label;
}

class MultiSelectDialog<V> extends StatefulWidget {
  MultiSelectDialog({Key key, this.items, this.initialSelectedValues})
      : super(key: key);

  final List<MultiSelectDialogItem<V>> items;
  final Set<V> initialSelectedValues;

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState<V>();
}

class _MultiSelectDialogState<V> extends State<MultiSelectDialog<V>> {
  final _selectedValues = Set<V>();

  void initState() {
    super.initState();
    if (widget.initialSelectedValues != null) {
      _selectedValues.addAll(widget.initialSelectedValues);
    }
  }

  void _onItemCheckedChange(V itemValue, bool checked) {
    setState(() {
      if (checked) {
        _selectedValues.add(itemValue);
      } else {
        _selectedValues.remove(itemValue);
      }
    });
  }

  void _onCancelTap() {
    Navigator.pop(context);
  }

  void _onSubmitTap() {
    Navigator.pop(context, _selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select :'),
      contentPadding: EdgeInsets.only(top: 5.0),
      content: SingleChildScrollView(
        child: ListTileTheme(
          child: ListBody(
            children: widget.items.map(_buildItem).toList(),
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('CANCEL'),
          onPressed: _onCancelTap,
        ),
        FlatButton(
          child: Text('OK'),
          onPressed: _onSubmitTap,
        )
      ],
    );
  }

  Widget _buildItem(MultiSelectDialogItem<V> item) {
    final checked = _selectedValues.contains(item.value);
    return CheckboxListTile(
      value: checked,
      title: Text(item.label),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) => _onItemCheckedChange(item.value, checked),
    );
  }
}
