import 'package:flutter/material.dart';

class Rater extends StatelessWidget {
  final double rate;
  final double size;
  Rater({@required this.rate, this.size: 25.0}) : assert(rate != null);

  @override
  Widget build(BuildContext context) {
    return Row(
        children: List.generate(5, (i) => i + 1).map((int currentRate) {
      return Icon(currentRate <= rate ? Icons.star : Icons.star_border,
          color: Colors.yellow[700], size: size);
    }).toList());
  }
}
