import 'dart:async';
import 'dart:convert';
import 'dart:math' show cos, sqrt, asin;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:lmaida/Home/Components/map_model.dart';
import 'package:lmaida/Resto/componant/new_resto_details.dart';
import 'package:lmaida/bloc.navigation_bloc/navigation_bloc.dart';
import 'package:lmaida/components/LmaidaCard.dart';
import 'package:lmaida/components/indicators.dart';
import 'package:lmaida/models/restau_model.dart';
import 'package:lmaida/utils/StringConst.dart';
import 'package:lmaida/utils/constants.dart';
import 'package:provider/provider.dart';

const double PIN_VISIBLE_POSITION = 100;
const double PIN_INVISIBLE_POSITION = -220;

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
  RestoModel soloRestoModel;
  String Search;
  Position position;
  bool submitted = false;
  static CameraPosition _myPosition;
  var resdata;
  var addresses;
  final double _infoWindowWidth = 250;
  final double _markerOffset = 170;
  bool kta3 = true;
  MyModel myModel;
  int locationId;
  double zoomVal = 5.0;
  var fetRestoAdvanceResult, fetLocationResult;
  BitmapDescriptor myIcon;
  double soloPinPillPosition = PIN_INVISIBLE_POSITION;
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

        setState(() {
          this.soloPinPillPosition = PIN_VISIBLE_POSITION;
          soloRestoModel = restoModel;
        });
      },
      icon: myIcon,
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
                AnimatedPositioned(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutExpo,
                    left: 0,
                    right: 0,
                    bottom: this.soloPinPillPosition,
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        height: 200,
                        child: soloRestoModel != null
                            ? LmaidaCard(
                                onTap: () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NewRestoDetails(
                                              restoModel: soloRestoModel,
                                              selectedDateTxt: null,
                                              selectedTimeTxt: null,
                                              dropdownValue: null,
                                              locationId: locationId,
                                            )),
                                  )
                                },
                                restoModel: soloRestoModel,
                                time: soloRestoModel.opening_hours_from ==
                                            null ||
                                        soloRestoModel.opening_hours_from == ''
                                    ? " "
                                    : "Opening from " +
                                        soloRestoModel.opening_hours_from +
                                        " to " +
                                        soloRestoModel.opening_hours_to,
                                imagePath: soloRestoModel.pictures,
                                status: soloRestoModel.status,
                                cardTitle: soloRestoModel.name,
                                category: soloRestoModel.categories.length != 0
                                    ? soloRestoModel.categories[0]["name"]
                                    : "",
                                address: soloRestoModel.address,
                              )
                            : SizedBox(
                                height: 0,
                              ))),
                Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 70.0, horizontal: 35),
                      child: Padding(
                        padding: EdgeInsets.only(left: 15.0, right: 5.0),
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
                                kta3 = false;
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
                    )),
                kta3 == true && addresses != null
                    ? Container(
                        padding: EdgeInsets.fromLTRB(40, 150, 40, 20),
                        child: Text(
                          'No Restaurants Near ${addresses.first.addressLine}  Yet ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Container(
                        height: 0,
                      ),
                kta3 == true
                    ? Container(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: circularProgress(context))
                    : Container(),
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
          ),
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
                onTap: (LatLng loc) {
                  setState(() {
                    this.soloPinPillPosition = PIN_INVISIBLE_POSITION;
                    soloRestoModel = restoModel;
                  });
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

  Future<List<dynamic>> fetLocation() async {
    var result = await http.get(StringConst.URI_LOCATION);
    return json.decode(result.body);
  }

  getLastLocation() async {
    setState(() {
      myIcon = BitmapDescriptor.fromAsset("assets/images/restomarker.png");
    });
    fetLocationResult = await fetLocation();
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    addresses = await Geocoder.local.findAddressesFromCoordinates(
        new Coordinates(position.latitude, position.longitude));
    for (var location in fetLocationResult) {
      if (addresses.first.addressLine.contains(location["name"])) {
        fetRestoAdvanceResult = myModel.fetResto(location["id"]);
        setState(() {
          locationId = location["id"];
          kta3 = false;
        });
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
}
