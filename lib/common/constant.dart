import 'package:flutter/material.dart';

import 'my_colors.dart';

//* Device size
double deviceWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double deviceHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

abstract class AssetImages {}

// Text Style
class TextStyles {
  static const TextStyle txtTitle = TextStyle(
    color: colorText,
    fontWeight: FontWeight.w700,
    fontFamily: 'Roboto',
    fontSize: 18,
  );
  static const TextStyle txtBody = TextStyle(
    color: colorText,
    fontFamily: 'Roboto',
    fontSize: 12,
  );

  static const TextStyle txtEdit = TextStyle(
    color: colorText,
    fontFamily: 'Roboto',
    fontSize: 16,
  );

  Text txtBodySM(String text, double size) {
    return Text(
      text.toUpperCase(),
      style:
          TextStyle(color: Colors.grey, fontFamily: 'Roboto', fontSize: size),
    );
  }

  Text txtBodyMD(String text, double size) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
          color: Colors.black87,
          fontFamily: 'Roboto',
          fontSize: size,
          fontWeight: FontWeight.w500),
    );
  }
}

// Textfield Style
class BorderStyles {
  static const OutlineInputBorder focusBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(30.0),
    ),
    borderSide: BorderSide(color: colorTextLight, width: 1.0),
  );

  static const OutlineInputBorder textFieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(30.0),
    ),
    borderSide: BorderSide(color: colorTextLight, width: 1.0),
  );

  static const OutlineInputBorder focusBorderMulti = OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(10.0),
    ),
    borderSide: BorderSide(color: colorTextLight, width: 1.0),
  );

  static const OutlineInputBorder textFieldBorderMulti = OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(10.0),
    ),
    borderSide: BorderSide(color: colorTextLight, width: 1.0),
  );

  static const OutlineInputBorder textFieldNoBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(10.0),
    ),
    borderSide: BorderSide(color: Colors.transparent, width: 1.0),
  );
}
