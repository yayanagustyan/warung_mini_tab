import 'package:flutter/material.dart';

Future gotoPage(BuildContext context, dynamic page) {
  return Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

Future gotoPageReplace(BuildContext context, dynamic page) {
  return Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}

Future gotoPageRemove(BuildContext context, dynamic page) {
  return Navigator.pushAndRemoveUntil(
      context, MaterialPageRoute(builder: (context) => page), (route) => false);
}

backStep(BuildContext context, {dynamic item}) {
  Navigator.pop(context, item);
}
