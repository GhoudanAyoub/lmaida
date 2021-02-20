import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmaida/components/indicators.dart';
import 'package:lmaida/models/restau_model.dart';
import 'package:lmaida/utils/SizeConfig.dart';
import 'package:lmaida/utils/StringConst.dart';

class MenuPage extends StatefulWidget {
  final RestoModel restoModel;
  final List<dynamic> data;
  final int index;

  const MenuPage({Key key, this.restoModel, this.data, this.index})
      : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final String apiUrl = StringConst.URI_RESTAU + 'all';
  String type;

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
              margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
              height: 60.0,
              child: Center(
                  child: Text(
                "Menu",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 24.0,
                  color: Colors.white,
                ),
              )),
            ),
            Container(
                margin: EdgeInsets.fromLTRB(10, 25, 10, 20),
                height: 60.0,
                child: Center(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: FlatButton(
                        onPressed: () {
                          setState(() {
                            type = null;
                          });
                        },
                        child: Text(
                          "Clear",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                )),
            Container(
              margin: EdgeInsets.fromLTRB(0, 80, 0, 20),
              child: FutureBuilder<List<dynamic>>(
                future: fetResto(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    if (widget.data.isNotEmpty) {
                      return Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 0, 10, 30),
                            height: 60.0,
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  color: Color(0xFFF5F6F9),
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: widget.data.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return FlatButton(
                                            onPressed: () {
                                              setState(() {
                                                type = widget.data[index]
                                                    ["type"]["name"];
                                              });
                                            },
                                            child: buildCount(widget.data[index]
                                                ["type"]["name"]));
                                      }),
                                ),
                              ),
                            ),
                          ),
                          type == null
                              ? Container(
                                  margin: EdgeInsets.fromLTRB(0, 70, 0, 10),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: ListView.builder(
                                            padding: EdgeInsets.all(10),
                                            itemCount: widget.data.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              print(type);
                                              return buildcontainer(
                                                  widget.data[index]);
                                            })),
                                  ),
                                )
                              : Container(
                                  margin: EdgeInsets.fromLTRB(0, 70, 0, 10),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: ListView.builder(
                                            padding: EdgeInsets.all(10),
                                            itemCount: widget.data.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              print("===>" + type);
                                              if (type ==
                                                  widget.data[index]["type"]
                                                      ["name"])
                                                return buildcontainer(
                                                    widget.data[index]);
                                              else
                                                return Container(
                                                  width: 0.2,
                                                );
                                            })),
                                  ))
                        ],
                      );
                    } else {
                      return Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 20, 10, 30),
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
                                  onPressed: () {},
                                  child: FlatButton(
                                    padding: EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    color: Color(0xFFF5F6F9),
                                    onPressed: () {},
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        buildCount("Starter"),
                                        Divider(
                                          height: 30,
                                        ),
                                        buildCount("Main Course"),
                                        Divider(),
                                        buildCount("Dessert"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              "This Restaurant Didn't Upload There Menu Yet",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      );
                    }
                  } else {
                    return Center(child: circularProgress(context));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildcontainer(data) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Container(
          child: FittedBox(
              child: Card(
        elevation: 10.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
          width: SizeConfig.screenWidth - 30,
          child: ListTile(
            leading: CachedNetworkImage(
              imageUrl:
                  "https://media-cdn.tripadvisor.com/media/photo-s/12/47/f3/8c/oko-restaurant.jpg",
              fit: BoxFit.cover,
              width: 60,
              height: 60,
              fadeInDuration: Duration(milliseconds: 500),
              fadeInCurve: Curves.easeIn,
              placeholder: (context, progressText) =>
                  Center(child: circularProgress(context)),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  data["name"],
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
                Text(
                  data["ingredients"],
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            trailing: Text(
              data["price"].toString() + " MAD",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
                color: Colors.red[900],
              ),
            ),
          ),
        ),
      ))),
    );
  }

  buildCount(String label) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 15,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          width: 15,
        ),
      ],
    );
  }
}
