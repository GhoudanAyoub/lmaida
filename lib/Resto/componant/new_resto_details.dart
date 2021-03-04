import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lmaida/Resto/componant/booked_screen.dart';
import 'package:lmaida/Resto/componant/menu_page.dart';
import 'package:lmaida/components/indicators.dart';
import 'package:lmaida/components/rater.dart';
import 'package:lmaida/models/restau_model.dart';
import 'package:lmaida/utils/SizeConfig.dart';
import 'package:lmaida/values/values.dart';

class NewRestoDetails extends StatefulWidget {
  final RestoModel restoModel;
  final dropdownValue;
  final selectedDateTxt;
  final selectedTimeTxt;
  final int locationId;

  const NewRestoDetails(
      {Key key,
      this.restoModel,
      this.dropdownValue,
      this.selectedDateTxt,
      this.selectedTimeTxt,
      @required this.locationId})
      : super(key: key);

  @override
  _NewRestoDetailsState createState() => _NewRestoDetailsState();
}

class _NewRestoDetailsState extends State<NewRestoDetails> {
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
            SingleChildScrollView(
                child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 30, 0, 10),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Column(
                      children: [
                        SizedBox(height: 50),
                        Container(
                          child: Card(
                            elevation: 8.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: Stack(
                              children: [
                                Positioned(
                                    child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: CachedNetworkImage(
                                        imageUrl: widget.restoModel.pictures ==
                                                null
                                            ? "https://media-cdn.tripadvisor.com/media/photo-s/12/47/f3/8c/oko-restaurant.jpg"
                                            : "https://lmaida.com/storage/gallery/" +
                                                widget.restoModel.pictures,
                                        fit: BoxFit.cover,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 200,
                                        fadeInDuration:
                                            Duration(milliseconds: 500),
                                        fadeInCurve: Curves.easeIn,
                                        placeholder: (context, progressText) =>
                                            Center(
                                                child:
                                                    CircularProgressIndicator()),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Container(
                                                  child: Text(
                                                    widget.restoModel.address,
                                                    textAlign: TextAlign.left,
                                                    style: Styles
                                                        .customNormalTextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Rater(
                                            rate: widget.restoModel.rating ?? 1,
                                          ),
                                          SizedBox(height: 10.0),
                                          Row(
                                            children: <Widget>[
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Container(
                                                  child: Text(
                                                    widget.restoModel
                                                                    .opening_hours_from ==
                                                                null ||
                                                            widget.restoModel
                                                                    .opening_hours_from ==
                                                                ''
                                                        ? " "
                                                        : "Opening from " +
                                                            widget.restoModel
                                                                .opening_hours_from +
                                                            " to " +
                                                            widget.restoModel
                                                                .opening_hours_to,
                                                    textAlign: TextAlign.left,
                                                    style: Styles
                                                        .customNormalTextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ))
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: SizeConfig.screenHeight * 0.01),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: buildOffer(),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MenuPage(
                                restoModel: widget.restoModel,
                                data: widget.restoModel.menus,
                                index: widget.restoModel.id,
                                locationId: widget.locationId,
                              )),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Container(
                        margin: EdgeInsets.fromLTRB(0, 500, 0, 0),
                        height: 100.0,
                        child: Card(
                          elevation: 10.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: Container(
                            margin: EdgeInsets.fromLTRB(20, 0, 0, 10),
                            width: SizeConfig.screenWidth - 50,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(width: 10),
                                Text(
                                  "Chef's Suggestions",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20.0,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  "See The Full Menu ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Container(
                      margin: EdgeInsets.fromLTRB(0, 600, 0, 0),
                      child: buildImages()),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  buildOffer() {
    if (widget.restoModel.special_offer.length == 0) {
      return Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Container(
            margin: EdgeInsets.fromLTRB(0, 400, 0, 0),
            height: 80.0,
            child: Card(
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Container(
                margin: EdgeInsets.fromLTRB(10, 10, 0, 10),
                width: SizeConfig.screenWidth - 50,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "Book Without a Special offer",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15.0,
                        color: Colors.blue[900],
                      ),
                    ),
                    FloatingActionButton(
                      shape: CircleBorder(),
                      heroTag: 'book',
                      mini: true,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BookedScreen(
                                    restoModel: widget.restoModel,
                                    offer: "0",
                                    dropdownValue: widget.dropdownValue,
                                    selectedTimeTxt: widget.selectedTimeTxt,
                                    selectedDateTxt: widget.selectedDateTxt,
                                  )),
                        );
                      },
                      backgroundColor: Colors.red[900],
                      child: Icon(Icons.arrow_forward_ios,
                          size: 25, color: Colors.white),
                    )
                  ],
                ),
              ),
            )),
      );
    } else {
      return Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Container(
            margin: EdgeInsets.fromLTRB(0, 400, 0, 0),
            height: 80.0,
            child: Card(
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Container(
                margin: EdgeInsets.fromLTRB(10, 10, 0, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.card_giftcard_outlined,
                        size: 30, color: Colors.blue[800]),
                    Text(
                      widget.restoModel.special_offer[0]["name"] +
                          " off the " +
                          widget.restoModel.name +
                          " menu!",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15.0,
                        color: Colors.blue[900],
                      ),
                    ),
                    FloatingActionButton(
                      shape: CircleBorder(),
                      heroTag: 'book',
                      mini: true,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BookedScreen(
                                    restoModel: widget.restoModel,
                                    offer: widget.restoModel.special_offer[0]
                                        ["name"],
                                    dropdownValue: widget.dropdownValue,
                                    selectedTimeTxt: widget.selectedTimeTxt,
                                    selectedDateTxt: widget.selectedDateTxt,
                                  )),
                        );
                      },
                      backgroundColor: Colors.red[900],
                      child: Icon(Icons.arrow_forward_ios,
                          size: 25, color: Colors.white),
                    )
                  ],
                ),
              ),
            )),
      );
    }
  }

  buildImages() {
    if (widget.restoModel.itemphotos.length != 0) {
      return Card(
        elevation: 10.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          margin: EdgeInsets.fromLTRB(20, 10, 10, 10),
          width: SizeConfig.screenWidth - 50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                widget.restoModel.itemphotos.length.toString() +
                    " Photos of Dishes ",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 25.0,
                  color: Colors.black,
                ),
              ),
              Text(
                "Picture From Community Members",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14.0,
                  color: Colors.black,
                ),
              ),
              Container(
                height: 120,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.restoModel.itemphotos.length,
                    itemBuilder: (context, index) {
                      print('++' + widget.restoModel.name.toString());
                      if (widget.restoModel.itemphotos == null) {
                        return Container(
                          child: Center(
                            child: Text("No Photos For the Moment "),
                          ),
                        );
                      } else {
                        return Container(
                          margin: EdgeInsets.only(right: 1.0),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: GestureDetector(
                              onTap: () {
                                showpage(
                                    context,
                                    "https://lmaida.com/storage/gallery/" +
                                            widget.restoModel.itemphotos[index]
                                                ['name'] ??
                                        "https://media-cdn.tripadvisor.com/media/photo-s/12/47/f3/8c/oko-restaurant.jpg");
                              },
                              child: CachedNetworkImage(
                                imageUrl: "https://lmaida.com/storage/gallery/" +
                                        widget.restoModel.itemphotos[index]
                                            ['name'] ??
                                    "https://media-cdn.tripadvisor.com/media/photo-s/12/47/f3/8c/oko-restaurant.jpg",
                                fit: BoxFit.cover,
                                width: 100,
                                fadeInDuration: Duration(milliseconds: 500),
                                fadeInCurve: Curves.easeIn,
                                placeholder: (context, progressText) =>
                                    Center(child: circularProgress(context)),
                              )),
                        );
                      }
                    }),
              ),
            ],
          ),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
            height: 80.0,
            child: Card(
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "No Pictures For The Moment",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20.0,
                        color: Colors.blue[900],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      );
    }
  }

  showpage(BuildContext parentContext, image) {
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
                  Positioned(
                      top: 100,
                      child: Image.network(image, width: 500, height: 500))
                ],
              ));
        });
  }
}
