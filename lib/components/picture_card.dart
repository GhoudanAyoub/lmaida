import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lmaida/models/restau_model.dart';
import 'package:lmaida/utils/SizeConfig.dart';

class PictureCard extends StatelessWidget {
  final RestoModel restoModel;

  const PictureCard({Key key, this.restoModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(30.0),
                ),
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: getProportionateScreenHeight(300),
                      width: getProportionateScreenWidth(330),
                      child: CachedNetworkImage(
                        imageUrl: restoModel.pictures == null
                            ? "https://media-cdn.tripadvisor.com/media/photo-s/12/47/f3/8c/oko-restaurant.jpg"
                            : restoModel.pictures,
                        fit: BoxFit.cover,
                        fadeInDuration: Duration(milliseconds: 500),
                        fadeInCurve: Curves.easeIn,
                        placeholder: (context, progressText) =>
                            Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    Positioned(
                      left: 10.0,
                      bottom: 15.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            restoModel.name,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14.0),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            restoModel.address,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14.0),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                "Opening from " +
                                                restoModel.opening_hours_from ==
                                            null ||
                                        restoModel.opening_hours_from == ''
                                    ? " "
                                    : restoModel.opening_hours_from +
                                        " to " +
                                        restoModel.opening_hours_to,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14.0),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Positioned(
                        right: 10.0,
                        bottom: 15.0,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10.0,
                            ),
                            SvgPicture.asset(
                              "assets/icons/Chat bubble Icon.svg",
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 2.0,
                            ),
                            Text(
                              'Comments',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.0),
                            ),
                          ],
                        ))
                  ],
                ),
              )
            ],
          ),
        ));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<RestoModel>('live', restoModel));
  }
}
