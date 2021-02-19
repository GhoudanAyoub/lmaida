import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:lmaida/Resto/componant/new_resto_details.dart';
import 'package:lmaida/bloc.navigation_bloc/navigation_bloc.dart';
import 'package:lmaida/components/indicators.dart';
import 'package:lmaida/models/restau_model.dart';
import 'package:lmaida/utils/StringConst.dart';
import 'package:lmaida/utils/constants.dart';

class Maps extends StatefulWidget with NavigationStates {
  final position;

  const Maps({Key key, this.position}) : super(key: key);
  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController searchController = TextEditingController();
  Set<Marker> markerlist = {};
  final String apiUrl2 = StringConst.URI_RESTAU + 'all';
  RestoModel restoModel;
  String Search = "";
  Position position;
  Future<List<dynamic>> fetResto() async {
    var result = await http.get(apiUrl2);
    return json.decode(result.body);
  }

  double zoomVal = 5.0;
  @override
  void initState() {
    getLastLocation();
    if (restoModel != null) {
      if (position != null) {
        markerlist.add(Marker(
          markerId: MarkerId("MyPlace"),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(title: 'Your Current Position'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        ));
      }
      if (restoModel.address_lat != null || restoModel.address_lon != null) {
        markerlist.add(Marker(
          markerId: MarkerId(restoModel.name),
          position: LatLng(double.tryParse(restoModel.address_lat),
              double.tryParse(restoModel.address_lon)),
          infoWindow: InfoWindow(title: restoModel.name),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        ));
      }
    }
    Timer.periodic(Duration(milliseconds: 500), (_) {
      if (restoModel != null) reloadData(restoModel);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildGoogleMap(context),
          Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 70.0, horizontal: 35),
                child: Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
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
                        prefixIcon:
                            Icon(Icons.search, color: GBottomNav, size: 30.0),
                        hintStyle: TextStyle(
                            color: Colors.black,
                            fontFamily: 'SFProDisplay-Black'),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                    ),
                  ),
                ),
              )),
          _buildContainer(),
        ],
      ),
    );
  }

  Widget _buildContainer() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 150.0,
        child: FutureBuilder<List<dynamic>>(
          future: fetResto(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.all(5),
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    restoModel = RestoModel.fromJson(snapshot.data[index]);

                    if (restoModel.address_lat != null ||
                        restoModel.address_lon != null) {
                      if (Search == "") {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 10.0),
                          child: _boxes(
                              restoModel.pictures == null
                                  ? "https://media-cdn.tripadvisor.com/media/photo-s/12/47/f3/8c/oko-restaurant.jpg"
                                  : restoModel.pictures,
                              double.tryParse(restoModel.address_lat),
                              double.tryParse(restoModel.address_lon),
                              restoModel),
                        );
                      } else {
                        if (restoModel.name
                            .toLowerCase()
                            .contains(Search.toLowerCase()))
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 10.0),
                            child: _boxes(
                                restoModel.pictures == null
                                    ? "https://media-cdn.tripadvisor.com/media/photo-s/12/47/f3/8c/oko-restaurant.jpg"
                                    : restoModel.pictures,
                                double.tryParse(restoModel.address_lat),
                                double.tryParse(restoModel.address_lon),
                                restoModel),
                          );
                        else
                          return Container(
                            width: 0.1,
                          );
                      }
                    } else {
                      return Divider();
                    }
                  });
            } else {
              return Center(child: circularProgress(context));
            }
          },
        ),
      ),
    );
  }

  reloadData(RestoModel restoModel) {
    setState(() {
      markerlist.add(Marker(
        markerId: MarkerId(restoModel.name),
        position: LatLng(double.tryParse(restoModel.address_lat),
            double.tryParse(restoModel.address_lon)),
        infoWindow: InfoWindow(
            title: restoModel.name,
            onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewRestoDetails(
                              restoModel: restoModel,
                              selectedDateTxt: null,
                              selectedTimeTxt: null,
                              dropdownValue: null,
                            )),
                  )
                }),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        ),
      ));
    });
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
                    width: 180,
                    height: 200,
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
                fontSize: 24.0,
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
                fontSize: 18.0,
              ),
            )),
            Container(
              child: Icon(
                FontAwesomeIcons.solidStar,
                color: Colors.amber,
                size: 15.0,
              ),
            ),
            Container(
              child: Icon(
                FontAwesomeIcons.solidStar,
                color: Colors.amber,
                size: 15.0,
              ),
            ),
            Container(
              child: Icon(
                FontAwesomeIcons.solidStar,
                color: Colors.amber,
                size: 15.0,
              ),
            ),
            Container(
              child: Icon(
                FontAwesomeIcons.solidStar,
                color: Colors.amber,
                size: 15.0,
              ),
            ),
            Container(
              child: Icon(
                FontAwesomeIcons.solidStarHalf,
                color: Colors.amber,
                size: 15.0,
              ),
            ),
            Container(
                child: Text(
              "(946)",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 18.0,
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
            fontSize: 18.0,
          ),
        )),
        SizedBox(height: 5.0),
        Container(
            child: Text(
          restaurantName.status +
              " \u00B7 Opens at" +
              restaurantName.opening_hours_from,
          style: TextStyle(
              color: Colors.black54,
              fontSize: 18.0,
              fontWeight: FontWeight.bold),
        )),
      ],
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    return position != null
        ? Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 10),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: markerlist,
            ),
          )
        : Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                  target: LatLng(34.0211418, -6.837584399999969), zoom: 12),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: markerlist,
            ),
          );
  }

  getLastLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var lastPosition = await Geolocator.getLastKnownPosition();
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
