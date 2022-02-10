part of values;

class Styles {
  static TextStyle customTitleTextStyle({
    Color color = AppColors.secondaryText,
    String fontFamily = "Josefin Sans",
    FontWeight fontWeight = FontWeight.w700,
    double fontSize = Sizes.TEXT_SIZE_40,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      color: color,
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle customNormalTextStyle({
    Color color = AppColors.secondaryText,
    String fontFamily = "Josefin Sans",
    FontWeight fontWeight = FontWeight.w400,
    double fontSize = Sizes.TEXT_SIZE_16,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      color: color,
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
    );
  }
}
