import 'dart:async';
import 'dart:convert';
import 'dart:math' show cos, sqrt, asin;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:lmaida/Home/Components/map_model.dart';
import 'package:lmaida/Resto/componant/new_resto_details.dart';
import 'package:lmaida/bloc.navigation_bloc/navigation_bloc.dart';
import 'package:lmaida/models/restau_model.dart';
import 'package:lmaida/utils/StringConst.dart';
import 'package:lmaida/utils/constants.dart';
import 'package:provider/provider.dart';

class Maps extends StatefulWidget with NavigationStates {
  final position;

  const Maps({Key key, this.position}) : super(key: key);
  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController searchController = TextEditingController();
  Set<Marker> markerlist = {};
  RestoModel restoModel;
  String Search;
  Position position;
  bool submitted = false;
  static CameraPosition _myPosition;
  var resdata;
  var addresses;
  final double _infoWindowWidth = 250;
  final double _markerOffset = 170;
  bool kta3 = false;
  MyModel myModel;
  int locationId;
  double zoomVal = 5.0;
  var fetRestoAdvanceResult, fetLocationResult;

  @override
  void initState() {
    getLastLocation();
    super.initState();
  }

  Marker _createMarker(lat, lon, name, RestoModel restoModel) {
    return Marker(
      markerId: MarkerId(name),
      position: LatLng(lat, lon),
      onTap: () {
        myModel.updateInfoWindow(
            context,
            mapController,
            LatLng(lat, lon),
            _infoWindowWidth,
            _markerOffset,
            restoModel.name,
            restoModel.address);
        myModel.updateVisibility(true);
        myModel.rebuildInfoWindow();
      },
      infoWindow: InfoWindow(
          title: name,
          snippet: restoModel.address,
          onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewRestoDetails(
                            restoModel: restoModel,
                            selectedDateTxt: null,
                            selectedTimeTxt: null,
                            dropdownValue: null,
                            locationId: locationId,
                          )),
                )
              }),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueViolet,
      ),
    );
  }

  Future<List<dynamic>> fetSearch(name) async {
    var result =
        await http.get("${StringConst.URI_SEARCH}/${name != "" ? name : "i"}");
    return json.decode(result.body);
  }

  @override
  Widget build(BuildContext context) {
    myModel = Provider.of<MyModel>(context);
    return _myPosition != null
        ? Scaffold(
            body: Stack(
              children: <Widget>[
                _buildContainer2(),
                /*
                Positioned(
                  top: 75,
                  right: 0,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    height: 40,
                    child: FlatButton(
                      onPressed: () {
                        setState(() {
                          fetRestoAdvanceResult = myModel.fetResto(locationId);
                        });
                      },
                      child: Icon(
                        Icons.cleaning_services,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ),
                ),*/
                kta3 == false
                    ? Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 70.0, horizontal: 35),
                          child: Padding(
                            padding: EdgeInsets.only(left: 15.0, right: 30.0),
                            child: Material(
                              elevation: 5.0,
                              borderRadius: BorderRadius.circular(50.0),
                              child: TextFormField(
                                style: TextStyle(color: Colors.black),
                                cursorColor: black,
                                controller: searchController,
                                onChanged: (value) {
                                  setState(() {
                                    Search = value;
                                    fetRestoAdvanceResult =
                                        fetSearch(searchController.text);
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search',
                                  prefixIcon: Icon(Icons.search,
                                      color: GBottomNav, size: 30.0),
                                  hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'SFProDisplay-Black'),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                              ),
                            ),
                          ),
                        ))
                    : Container(
                        height: 0,
                      ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(40, 100, 50, 20),
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
                              SizedBox(
                                width: 120,
                                child: FlatButton(
                                  color: Colors.grey.withOpacity(0.1),
                                  onPressed: () {
                                    BlocProvider.of<NavigationBloc>(context)
                                        .add(NavigationEvents
                                            .RestaurantPageEvent);
                                  },
                                  child: buildCount(
                                      "List View", Icons.list_rounded),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 5.0, top: 5.0),
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
                                    BlocProvider.of<NavigationBloc>(context)
                                        .add(NavigationEvents
                                            .RestaurantPageEventWithParam);
                                  },
                                  child: buildCount(
                                      "Specials", Icons.offline_bolt),
                                ),
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
          )
        : Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  "assets/images/9_Location Error.png",
                  fit: BoxFit.cover,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 5),
                          blurRadius: 25,
                          color: Colors.black.withOpacity(0.17),
                        ),
                      ],
                    ),
                    child: FlatButton(
                      onPressed: () {
                        _goToMyPosition();
                        setState(() {
                          submitted = true;
                        });
                      },
                      child: Text('GET MY LOCATION'),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  buildshit(RestoModel restoModel) {
    return Container(
      child: Consumer<MyModel>(
        builder: (context, model, child) {
          return Stack(
            children: <Widget>[
              child,
              Positioned(
                left: 120,
                top: 150,
                child: Visibility(
                  visible: myModel.showInfoWindow,
                  child: (restoModel == null && !myModel.showInfoWindow)
                      ? Container()
                      : Container(
                          margin: EdgeInsets.only(
                            left: 5,
                            top: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: new LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white,
                              ],
                              end: Alignment.bottomCenter,
                              begin: Alignment.topCenter,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 1.0),
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          height: 100,
                          width: 250,
                          padding: EdgeInsets.all(15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Image.network(
                                restoModel.pictures != null
                                    ? "https://lmaida.com/storage/gallery/" +
                                        restoModel.pictures
                                    : "https://media-cdn.tripadvisor.com/media/photo-s/12/47/f3/8c/oko-restaurant.jpg",
                                height: 75,
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    myModel.Placename,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  IconTheme(
                                    data: IconThemeData(
                                      color: Colors.yellow[800],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: List.generate(
                                        5,
                                        (index) {
                                          return Icon(
                                            index < 1
                                                ? Icons.star
                                                : Icons.star_border,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          );
        },
        child: Positioned(
          child: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _myPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
            },
            markers: markerlist,
            myLocationEnabled: true,
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

  Widget _buildContainer2() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 0),
        height: MediaQuery.of(context).size.height,
        child: FutureBuilder<List<dynamic>>(
          future: fetRestoAdvanceResult,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data != null) {
              for (dynamic d in snapshot.data) {
                restoModel = RestoModel.fromJson(d);

                if (Search == null &&
                    position != null &&
                    calculateDistance(
                            position.latitude,
                            position.longitude,
                            double.tryParse(restoModel.address_lat),
                            double.tryParse(restoModel.address_lon)) <=
                        20) {
                  markerlist.add(_createMarker(
                      double.tryParse(restoModel.address_lat),
                      double.tryParse(restoModel.address_lon),
                      restoModel.name,
                      restoModel));
                } else {
                  if (Search != null &&
                      position != null &&
                      calculateDistance(
                              position.latitude,
                              position.longitude,
                              double.tryParse(restoModel.address_lat),
                              double.tryParse(restoModel.address_lon)) <=
                          20) {
                    markerlist.clear();
                    markerlist.add(_createMarker(
                        double.tryParse(restoModel.address_lat),
                        double.tryParse(restoModel.address_lon),
                        restoModel.name,
                        restoModel));
                  } else {
                    print('No DataFound');
                  }
                }
              }
              return GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _myPosition,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  mapController = controller;
                },
                markers: markerlist,
                myLocationEnabled: true,
              );
            } else {
              return GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _myPosition,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  mapController = controller;
                  setState(() {
                    kta3 = true;
                  });
                },
                myLocationEnabled: true,
              );
            }
          },
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

  Widget _boxes(
      String _image, double lat, double long, RestoModel restaurantName) {
    return GestureDetector(
      onTap: () {
        _gotoLocation(lat, long);
      },
      child: Container(
        child: new FittedBox(
          child: Material(
              color: Colors.white,
              elevation: 14.0,
              borderRadius: BorderRadius.circular(24.0),
              shadowColor: Color(0x802196F3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 90,
                    height: 100,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(24.0),
                      child: Image(
                        fit: BoxFit.fill,
                        image: NetworkImage(_image),
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: myDetailsContainer1(restaurantName),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget myDetailsContainer1(RestoModel restaurantName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
              child: Text(
            restaurantName.name,
            style: TextStyle(
                color: Color(0xff6200ee),
                fontSize: 14.0,
                fontWeight: FontWeight.bold),
          )),
        ),
        SizedBox(height: 5.0),
        Container(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
                child: Text(
              "4.1",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12.0,
              ),
            )),
            Container(
              child: Icon(
                FontAwesomeIcons.solidStar,
                color: Colors.amber,
                size: 10.0,
              ),
            ),
            Container(
              child: Icon(
                FontAwesomeIcons.solidStar,
                color: Colors.amber,
                size: 10.0,
              ),
            ),
            Container(
              child: Icon(
                FontAwesomeIcons.solidStar,
                color: Colors.amber,
                size: 10.0,
              ),
            ),
            Container(
              child: Icon(
                FontAwesomeIcons.solidStar,
                color: Colors.amber,
                size: 10.0,
              ),
            ),
            Container(
              child: Icon(
                FontAwesomeIcons.solidStarHalf,
                color: Colors.amber,
                size: 10.0,
              ),
            ),
            Container(
                child: Text(
              "(946)",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 10.0,
              ),
            )),
          ],
        )),
        SizedBox(height: 5.0),
        Container(
            child: Text(
          restaurantName.address + "re \u00B7 \u0024\u0024 \u00B7 1.6 mi",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 10.0,
          ),
        )),
        SizedBox(height: 5.0),
      ],
    );
  }

  Future<List<dynamic>> fetLocation() async {
    var result = await http.get(StringConst.URI_LOCATION);
    return json.decode(result.body);
  }

  getLastLocation() async {
    fetLocationResult = await fetLocation();
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    addresses = await Geocoder.local.findAddressesFromCoordinates(
        new Coordinates(position.latitude, position.longitude));
    print(
        " ====> ${addresses.first.addressLine} / ${addresses.first.addressLine.contains("Rabat")} ");
    for (var location in fetLocationResult) {
      print("*********${location["name"]}");
      if (addresses.first.addressLine.contains(location["name"])) {
        fetRestoAdvanceResult = myModel.fetResto(location["id"]);
        setState(() {
          locationId = location["id"];
        });
        print(" ====> done");
      }
    }

    setState(() {
      _myPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 14.5,
      );
    });
  }

  Future<void> _goToMyPosition() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_myPosition));
  }

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 20,
      tilt: 50.0,
      bearing: 45.0,
    )));
  }
}
