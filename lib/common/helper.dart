// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:math';
import 'dart:developer' as d;
import 'package:crypto/crypto.dart' show md5;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

String nF(String source, {bool useSymbol = false, bool denom = false}) {
  if (useSymbol) {
    return "Rp. ${NumberFormat.decimalPattern().format(double.parse(source)).replaceAll(",", ".")}";
  } else if (denom) {
    return NumberFormat.decimalPattern()
        .format(double.parse(source) / 1000)
        .replaceAll(",", ".");
  } else {
    return NumberFormat.decimalPattern()
        .format(double.parse(source))
        .replaceAll(",", ".");
  }
}

String toFirstCaps(String words) {
  return '${words[0].toUpperCase()}${words.substring(1).toLowerCase()}';
}

String allInCaps(String value) => value.toUpperCase();

String capitalizeFirstofEach(String value) {
  List<String> words = value.split(" ");
  if (words.length > 1) {
    String combine = words[0] + words[1];
    if (combine.toLowerCase() == "dkijakarta" ||
        combine.toLowerCase() == "diyogyakarta") {
      return '${words[0].toUpperCase()} ${toFirstCaps(words[1])}';
    }
  }
  return value.split(" ").map((str) => toFirstCaps(str)).join(" ");
}

int getUniq() {
  return DateTime.now().toUtc().millisecondsSinceEpoch;
}

String getUniqueId() {
  return DateTime.now().millisecondsSinceEpoch.toString();
}

int getUniqInt() {
  var random = Random();
  return random.nextInt(pow(2, 31).toInt() - 1);
}

String getCurrentDate() {
  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-MM-dd', 'id_ID');
  return formatter.format(now);
}

String getCurrentDateTime() {
  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss', 'id_ID');
  return formatter.format(now);
}

String getCurrentChatTime() {
  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('dd MMM, HH:mm', 'id_ID');
  return formatter.format(now);
}

int dateDiff(String startDate, String endDate) {
  DateTime date1 = DateTime.parse(startDate);
  DateTime date2;
  if (endDate.isEmpty) {
    date2 = DateTime.now();
  } else {
    date2 = DateTime.parse(endDate);
  }
  final difference = date2.difference(date1).inDays;
  return difference;
}

String dateCustomFormat(String date, String origin, String patern) {
  final ff = DateFormat(origin, 'id_ID');
  DateTime dates = ff.parse(date);
  DateFormat formatter = DateFormat(patern, 'id_ID');
  return formatter.format(dates);
}

String dateFormat(String date, String patern) {
  final ff = DateFormat('yyyy-MM-dd', 'id_ID');
  DateTime dates = ff.parse(date);
  DateFormat formatter = DateFormat(patern, 'id_ID');
  return formatter.format(dates);
}

String dateTimeFormat(String date, String patern) {
  final ff = DateFormat('yyyy-MM-dd hh:mm:ss', 'id_ID');
  DateTime dates = ff.parse(date);
  DateFormat formatter = DateFormat(patern, 'id_ID');
  return formatter.format(dates);
}

String dateToString(DateTime date, String patern) {
  DateFormat formatter = DateFormat(patern, 'id_ID');
  return formatter.format(date);
}

String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}

String getInitials(String words) {
  if (words.isNotEmpty) {
    return words.trim().split(' ').map((l) => l[0]).take(2).join();
  } else {
    return '';
  }
}

String getFirstName(String words) {
  if (words.isNotEmpty) {
    return words.trim().split(' ')[0];
  } else {
    return '';
  }
}

String getFirsSecondName(String words) {
  String newName = '';
  if (words.isNotEmpty) {
    List<String> name = words.trim().split(' ');
    if (name.length > 1) {
      newName = "${words.trim().split(' ')[0]} ${words.trim().split(' ')[1]}";
    } else {
      newName = words.trim().split(' ')[0];
    }
  }
  return newName.replaceAll(",", "");
}

String getGreeting(String name) {
  var message = '';
  DateTime date = DateTime.now();
  var timeNow = int.parse(DateFormat('kk').format(date));
  if (timeNow <= 12) {
    message = 'Selamat Pagi, ';
  } else if ((timeNow > 12) && (timeNow <= 16)) {
    message = 'Selamat Siang, ';
  } else if ((timeNow > 16) && (timeNow <= 20)) {
    message = 'Selamat Sore, ';
  } else {
    message = 'Selamat Malam, ';
  }
  return message + name;
}

// terOutput (String value) {
//   Flutterter fmf = Flutterter(
//     amount: double.parse(value),
//     settings:
//         terSettings(thousandSeparator: ".", decimalSeparator: ","),
//   );
//   terOutput fo = fmf.output;
//   return fo;
// }

String utf8convert(String text) {
  var encode = utf8.encode(text);
  return utf8.decode(encode);
}

String stringWithNewLine(List readLines) {
  StringBuffer sb = StringBuffer();
  for (String line in readLines) {
    sb.write("$line\n");
  }
  return sb.toString();
}

removeFocus(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode()); //remove focus
}

void fieldFocusChange(
    BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}

void preCachePngAssets(BuildContext context, String asset) {
  final image = Image.asset("assets/images/logo_sop_white.png");
  precacheImage(image.image, context);
}

Widget placeholderImageSquare(double height, double width, BoxFit fit) {
  return Image.asset(
    "assets/images/empty_image_square.png",
    height: height,
    width: width,
    fit: fit,
  );
}

//fixed size for banner
Widget placeholderImageBanner() {
  return Image.asset(
    "assets/images/empty_banner_image.png",
    fit: BoxFit.cover,
  );
}

Future setCookieList(String keys, List<dynamic> value) async {
  List<String> myList = value.map((e) => json.encode(e)).toList();
  var login = await openSession();
  login.put(keys, myList);
}

Future setCookie(String keys, dynamic value) async {
  var login = await openSession();
  login.put(keys, value);
}

Future<bool> cookiesExist(String key) async {
  var s = await openSession();
  return s.containsKey(key);
}

Future<String> getCookies(String key) async {
  var login = await openSession();
  String result = login.get(key).toString();
  return result;
}

wLog(dynamic message) {
  d.log(message.toString());
}

Future<Box<dynamic>> openSession() async {
  var session = await Hive.openBox("login");
  return session;
}

// Future<String> extractVideoUrl(String videoId) async {
//   final extractor = YoutubeExplode();
//   final streamManifest =
//       await extractor.videos.streamsClient.getManifest(videoId);
//   final streamInfo = streamManifest.muxed.withHighestBitrate();
//   extractor.close();
//   return streamInfo.url.toString();
// }

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

Future<String?> convertToBase64(String url) async {
  http.Response response = await http.get(Uri.parse(url));
  final bytes = response.bodyBytes;
  return (bytes.isNotEmpty ? base64Encode(bytes) : "");
}

String formatDateTime(String source, {String patern = "dd MMMM yyyy"}) {
  DateTime datetime =
      DateFormat("yyyy-MM-dd HH:mm:ss", 'id').parse(source).toLocal();
  var tanggal = DateFormat(patern, 'id').format(datetime);
  return tanggal;
}
