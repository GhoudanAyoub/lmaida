import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lmaida/utils/SizeConfig.dart';

class CustomSurffixIcon extends StatelessWidget {
  const CustomSurffixIcon({
    Key key,
    @required this.svgIcon,
  }) : super(key: key);

  final String svgIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        0,
        getProportionateScreenWidth(20),
        getProportionateScreenWidth(20),
        getProportionateScreenWidth(20),
      ),
      child: SvgPicture.asset(
        svgIcon,
        color: Colors.white,
        height: getProportionateScreenWidth(18),
      ),
    );
  }
}
