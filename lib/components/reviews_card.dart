import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmaida/utils/SizeConfig.dart';

import 'indicators.dart';

class ReviewsCard extends StatefulWidget {
  final reviews;
  final restoModel;

  const ReviewsCard({Key key, this.reviews, this.restoModel}) : super(key: key);
  @override
  _ReviewsCardState createState() => _ReviewsCardState();
}

class _ReviewsCardState extends State<ReviewsCard> {
  var fetchDetailsRes;
  Future<List<dynamic>> fetDetails(id) async {
    var result = await http.get("https://lmaida.com/api/resturant/$id");
    return json.decode(result.body);
  }

  @override
  void initState() {
    fetchDetailsRes = fetDetails(widget.restoModel.id);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                    bottomLeft: const Radius.circular(80),
                    bottomRight: const Radius.circular(80),
                  ),
                ),
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.01),
            Container(
              margin: EdgeInsets.fromLTRB(10, 30, 10, 20),
              height: 60.0,
              child: Center(
                  child: Text(
                widget.restoModel.name,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 28.0,
                  color: Colors.white,
                ),
              )),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
                child: Card(
                  elevation: 10.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: Container(
                    margin: EdgeInsets.fromLTRB(20, 10, 10, 10),
                    width: SizeConfig.screenWidth - 50,
                    child: FutureBuilder(
                      future: fetchDetailsRes,
                      builder: (context, snapshot) {
                        if (snapshot != null && snapshot.data != null) {
                          return ListView.builder(
                            //new line
                            padding: EdgeInsets.all(10),
                            itemCount: widget.reviews.length,
                            itemBuilder: (context, index) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ListTile(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 0),
                                    leading: CircleAvatar(
                                      radius: 20.0,
                                      backgroundImage: NetworkImage(
                                          'assets/images/proim.png'),
                                    ),
                                    title: Text(
                                      "none",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.red[900]),
                                    ),
                                    subtitle: Text(
                                      "${snapshot.data[0]["reviews"][index]["created_at"].toString()}",
                                      style: TextStyle(
                                          fontSize: 12.0, color: Colors.grey),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.thumb_up,
                                              color: Colors.green,
                                              size: 20,
                                            ),
                                            SizedBox(width: 5.0),
                                            Text(
                                              "POSITIVE",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.green),
                                            )
                                          ],
                                        ),
                                        Text(
                                          "${snapshot.data[0]["reviews"][index]['positivtag']}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.thumb_down,
                                              color: Colors.red[900],
                                              size: 20,
                                            ),
                                            SizedBox(width: 5.0),
                                            Text(
                                              "NEGATIVE",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.red[900]),
                                            )
                                          ],
                                        ),
                                        Text(
                                          "${snapshot.data[0]["reviews"][index]['negativetag']}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0, vertical: 5),
                                    child: Text(
                                      "${snapshot.data[0]["reviews"][index]['reviews']}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black),
                                    ),
                                  ),
                                  Divider(
                                    color: Colors.grey.withOpacity(0.2),
                                  )
                                ],
                              );
                            },
                          );
                        } else {
                          return Center(child: circularProgress(context));
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
