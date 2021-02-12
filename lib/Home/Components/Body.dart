import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmaida/Resto/componant/new_resto_details.dart';
import 'package:lmaida/Resto/resto_page.dart';
import 'package:lmaida/bloc.navigation_bloc/navigation_bloc.dart';
import 'package:lmaida/components/indicators.dart';
import 'package:lmaida/components/picture_card.dart';
import 'package:lmaida/models/categorie_model.dart';
import 'package:lmaida/models/restau_model.dart';
import 'package:lmaida/utils/StringConst.dart';
import 'package:lmaida/utils/constants.dart';

class Body extends StatefulWidget with NavigationStates {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  List<CategorieModel> _categorie = new List<CategorieModel>();
  List<RestoModel> _restau = new List<RestoModel>();

  final String apiUrl = StringConst.URI_CATEGORY;
  final String apiUrl2 = StringConst.URI_RESTAU + 'all';

  Future<List<dynamic>> fetResto() async {
    var result = await http.get(apiUrl2);
    return json.decode(result.body);
  }

  Future<List<dynamic>> fetchCat() async {
    Map<String, String> headers = {
      "Content-type": "application/json",
    };
    var result = await http.get(apiUrl, headers: headers);
    return json.decode(result.body);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        headerTopCategories(),
        deals1('Nos Restaurants', onViewMore: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RestaurantPage()),
          );
        }, items: <Widget>[
          Container(
              height: 300,
              width: MediaQuery.of(context).size.width,
              child: FutureBuilder<List<dynamic>>(
                future: fetResto(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.all(5),
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          RestoModel restoModel =
                              RestoModel.fromJson(snapshot.data[index]);
                          return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NewRestoDetails(
                                            restoModel: restoModel,
                                          )),
                                );
                              },
                              child: PictureCard(
                                restoModel: restoModel,
                              ));
                        });
                  } else {
                    return Center(child: circularProgress(context));
                  }
                },
              )),
        ]),
      ],
    );
  }

  Widget deals1(String dealTitle, {onViewMore, List<Widget> items}) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          sectionHeader(dealTitle, onViewMore: onViewMore),
          SizedBox(
            height: 350,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: (items != null)
                  ? items
                  : <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 15),
                        child: Text('No items available at this moment.',
                            style: TextStyle(
                                color: Colors.grey, fontFamily: 'Poppins')),
                      )
                    ],
            ),
          )
        ],
      ),
    );
  }

  Widget sectionHeader(String headerTitle, {onViewMore}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 25, top: 10),
          child: Text(headerTitle,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins')),
        ),
        Container(
          margin: EdgeInsets.only(left: 15, top: 2),
          child: FlatButton(
            onPressed: onViewMore,
            child: Text('Voir plus ›',
                style: TextStyle(color: primaryColor, fontFamily: 'Poppins')),
          ),
        )
      ],
    );
  }

  Widget headerCategoryItem(String name, {onPressed}) {
    return Container(
      margin: EdgeInsets.only(left: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(bottom: 10),
              width: 86,
              height: 86,
              child: FloatingActionButton(
                shape: CircleBorder(),
                heroTag: name,
                onPressed: onPressed,
                backgroundColor: white,
                child:
                    Icon(Icons.dinner_dining, size: 35, color: Colors.black87),
              )),
          Text(name + '',
              style: TextStyle(
                  color: Color(0xff444444),
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
        sectionHeader('Nos Catégories', onViewMore: null),
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
                      return headerCategoryItem(categoraiemodel.name,
                          onPressed: () {});
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
