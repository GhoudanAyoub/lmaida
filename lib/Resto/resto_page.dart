import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmaida/bloc.navigation_bloc/navigation_bloc.dart';
import 'package:lmaida/components/LmaidaCard.dart';
import 'package:lmaida/components/indicators.dart';
import 'package:lmaida/models/restau_model.dart';
import 'package:lmaida/utils/SizeConfig.dart';
import 'package:lmaida/utils/StringConst.dart';

import 'componant/RestaurantDetailsScreen.dart';

List<RestoModel> _restau = new List<RestoModel>();

class RestaurantPage extends StatefulWidget with NavigationStates {
  @override
  _RestaurantState createState() => _RestaurantState();
}

class _RestaurantState extends State<RestaurantPage> {
  final String apiUrl = StringConst.URI_RESTAU + 'all';

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
                    bottomLeft: const Radius.circular(200),
                    bottomRight: const Radius.circular(200),
                  ),
                ),
              ),
            ),
            Container(
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
                                    builder: (context) =>
                                        RestaurantDetailsScreen(
                                          restoModel: restoModel,
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
                            rating: '4.5',
                            //ratings[index],
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
}

/**/
