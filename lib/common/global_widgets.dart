// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:warung_mini_tab/ui/main/home/pages/orders_list_screen.dart';

import '../auth/auth.dart';
import '../core/routes.dart';
import '../ui/main/home/home.dart';
import '../ui/main/home/pages/products.dart';
import '../ui/main/more/more.dart';
import 'constant.dart';
import 'helper.dart';
import 'my_colors.dart';

enum TPosition {
  TOP,
  BOTTOM,
  CENTER,
  TOP_LEFT,
  TOP_RIGHT,
  BOTTOM_LEFT,
  BOTTOM_RIGHT,
  CENTER_LEFT,
  CENTER_RIGHT,
  SNACKBAR
}

dynamic showToast(
  String message, {
  required BuildContext context,
  TPosition position = TPosition.BOTTOM,
}) {
  FToast fToast = FToast().init(context);
  ToastGravity poss = ToastGravity.BOTTOM;
  if (position == TPosition.BOTTOM) {
    poss = ToastGravity.BOTTOM;
  } else if (position == TPosition.CENTER) {
    poss = ToastGravity.CENTER;
  } else if (position == TPosition.TOP) {
    poss = ToastGravity.TOP;
  }
  fToast.showToast(child: content(context, message), gravity: poss);
}

Widget content(BuildContext context, String message) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    decoration: const BoxDecoration(
      color: colorBlack70,
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    child: Text(
      message,
      style: const TextStyle(color: colorWhite, fontWeight: FontWeight.bold),
    ),
  );
}

Widget loadingWidget(BuildContext context, {double width = 0}) {
  if (width == 0) {
    width = MediaQuery.of(context).size.width - 100;
  }
  return Align(
    alignment: Alignment.center,
    child: Container(
      height: double.infinity,
      width: double.infinity,
      color: colorBlack30,
      child: Center(
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            height: 70,
            width: width,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      backgroundColor: colorWhite,
                      valueColor: AlwaysStoppedAnimation<Color>(colorPrimary),
                    ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    "Please Wait ...",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget textFieldBuild(String title, String hintText,
    TextEditingController controller, TextInputType textType, bool isReadOnly) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 5),
        child: Text(title, style: TextStyles.txtBody),
      ),
      TextFormField(
        readOnly: isReadOnly,
        controller: controller,
        cursorColor: colorPrimary,
        keyboardType: textType,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          focusedBorder: BorderStyles.focusBorder,
          border: BorderStyles.textFieldBorder,
          hintText: hintText,
          contentPadding: const EdgeInsets.all(
            14.0,
          ),
        ),
        style: TextStyles.txtBody,
        validator: (value) {
          if (value!.isEmpty) {
            return '$title tidak boleh kosong !';
          }
          return null;
        },
      )
    ],
  );
}

class RoundedWidget extends StatelessWidget {
  late final BuildContext context;
  final String title = "";
  late final TextEditingController controller;
  late final FocusNode? focusNode;
  late final TextInputType? inputType;
  late final TextInputAction? inputAction;
  late final TextCapitalization? capital;
  late final FocusNode? nextFocus;
  final bool enabled = true;

  // ignore: prefer_const_constructors_in_immutables
  RoundedWidget({
    Key? key,
    required context,
    required title,
    required controller,
    focusNode,
    nextFocus,
    inputType = TextInputType.text,
    inputAction = TextInputAction.next,
    capital = TextCapitalization.none,
    enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text("aa");
  }
}

Widget roundedTextField(String title, TextEditingController controller,
    FocusNode focusNode, TextInputType textType, TextInputAction textAction,
    {TextCapitalization capital = TextCapitalization.none,
    BuildContext? context,
    FocusNode? nextFocus,
    bool readOnly = false,
    bool? enabled,
    bool borderLess = false,
    bool showTitle = true,
    TextAlign textAlign = TextAlign.start}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      if (showTitle)
        Padding(
          padding: const EdgeInsets.only(bottom: 5, top: 15),
          child: Text(
            title,
            style: const TextStyle(color: colorDark),
          ),
        ),
      TextFormField(
        enabled: enabled,
        controller: controller,
        cursorColor: colorPrimary,
        textCapitalization: capital,
        focusNode: focusNode,
        textInputAction: textAction,
        keyboardType: textType,
        readOnly: readOnly,
        textAlign: textAlign,
        maxLines: textType == TextInputType.multiline ? 3 : 1,
        minLines: textType == TextInputType.multiline ? 3 : 1,
        onFieldSubmitted: (term) {
          if (textAction == TextInputAction.next) {
            fieldFocusChange(context!, focusNode, nextFocus!);
          }
        },
        decoration: InputDecoration(
          fillColor: colorWhite,
          filled: true,
          hintText: title.replaceAll("*", "") == "pesan"
              ? "Apa Yang Ingin Anda Sampaikan"
              : title.replaceAll("*", ""),
          hintStyle: const TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 14,
          ),
          focusedBorder: borderLess
              ? BorderStyles.textFieldNoBorder
              : textType == TextInputType.multiline
                  ? BorderStyles.focusBorderMulti
                  : BorderStyles.focusBorder,
          enabledBorder: borderLess
              ? BorderStyles.textFieldNoBorder
              : textType == TextInputType.multiline
                  ? BorderStyles.focusBorderMulti
                  : BorderStyles.focusBorder,
          border: borderLess
              ? BorderStyles.textFieldNoBorder
              : textType == TextInputType.multiline
                  ? BorderStyles.textFieldBorderMulti
                  : BorderStyles.textFieldBorder,
          contentPadding: const EdgeInsets.all(14.0),
        ),
        style: TextStyles.txtEdit,
        validator: (value) {
          if (value!.isEmpty) {
            return '$title tidak boleh kosong !';
          }
          return null;
        },
      ),
    ],
  );
}

InputDecoration roundDecoration = const InputDecoration(
  focusedBorder: BorderStyles.focusBorder,
  border: BorderStyles.textFieldBorder,
  contentPadding: EdgeInsets.only(left: 14, right: 14),
);

Widget labelText(String title, [TextStyle? styles]) {
  return Padding(
    padding: const EdgeInsets.only(top: 0.0, bottom: 5.0),
    child: Text(
      title,
      style: styles ?? const TextStyle(color: colorDark),
    ),
  );
}

Widget customCheckBox({
  required bool isChecked,
  required Function onChanged,
  required String title,
}) {
  return Container(
    height: 25,
    transform: Matrix4.translationValues(-5, 0, 0),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: 20,
          child: Checkbox(
            onChanged: (value) => onChanged(value),
            value: isChecked,
            checkColor: colorWhite,
            fillColor: MaterialStateProperty.all(colorPrimary),
            side: const BorderSide(width: 1, color: colorText),
          ),
        ),
        GestureDetector(
          onTapDown: (v) => onChanged(v),
          child: Container(
            padding: const EdgeInsets.only(left: 5),
            child: Text(title),
          ),
        ),
      ],
    ),
  );
}

Widget checkboxWithSub({
  required bool isChecked,
  required Function onChanged,
  required String title,
  required String subtitle,
  required BuildContext context,
  bool enabled = true,
}) {
  return Container(
    //height: 25,
    transform: Matrix4.translationValues(-5, 0, 0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: 25,
          child: Checkbox(
            onChanged: (value) => onChanged(value),
            value: isChecked,
            checkColor: colorWhite,
            fillColor:
                MaterialStateProperty.all(enabled ? colorPrimary : colorGrey),
            side: const BorderSide(width: 1, color: colorText),
          ),
        ),
        GestureDetector(
          onTapDown: (v) => onChanged(v),
          child: Container(
            width: MediaQuery.of(context).size.width - 60,
            padding: const EdgeInsets.only(left: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 3.0),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: colorText),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class RdCheckBox {
  final bool isChecked;
  final Function onTap;
  double? size;
  double? space;
  RdCheckBox({
    required this.isChecked,
    required this.onTap,
    this.size = 25,
    this.space = 10,
  });

  Widget build() {
    return Container(
      height: size,
      width: size,
      margin: EdgeInsets.only(right: space!),
      child: RoundCheckBox(
        size: size,
        isChecked: isChecked,
        borderColor: colorPrimary,
        checkedColor: colorPrimary,
        uncheckedColor: Colors.transparent,
        disabledColor: Colors.grey,
        animationDuration: const Duration(milliseconds: 200),
        checkedWidget: const Icon(Icons.check, color: colorWhite, size: 18),
        onTap: (value) => onTap(value),
      ),
    );
  }
}

Widget searchField(String title) {
  return TextFormField(
    cursorColor: colorPrimary,
    textInputAction: TextInputAction.search,
    keyboardType: TextInputType.text,
    onFieldSubmitted: (term) {},
    decoration: InputDecoration(
      suffixIcon: GestureDetector(
        onTap: () {},
        child: const Icon(
          Icons.search,
          color: Colors.grey,
          size: 30,
        ),
      ),
      hintText: title,
      hintStyle: const TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
      focusedBorder: BorderStyles.focusBorder,
      border: BorderStyles.textFieldBorder,
      contentPadding: const EdgeInsets.only(left: 14, right: 14),
    ),
    style: TextStyles.txtEdit,
  );
}

bool _isHidePass = true;
void _togglePassword() {
  // setState(() {
  _isHidePass = !_isHidePass;
  // });
}

Widget passwordTextField(String title, TextEditingController controller,
    FocusNode focusNode, FocusNode nextFocus,
    [BuildContext? context]) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 15),
        child: Text(
          title,
          style: const TextStyle(color: colorDark),
        ),
      ),
      TextFormField(
        controller: controller,
        cursorColor: colorPrimary,
        obscureText: _isHidePass,
        focusNode: focusNode,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        onFieldSubmitted: (term) {
          fieldFocusChange(context!, focusNode, nextFocus);
        },
        decoration: InputDecoration(
          hintText: title,
          suffixIcon: GestureDetector(
            onTap: () {
              _togglePassword();
            },
            child: Icon(
              _isHidePass ? Icons.visibility_off : Icons.visibility,
              color: _isHidePass ? Colors.grey : colorPrimary,
            ),
          ),
          hintStyle: const TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 14,
          ),
          focusedBorder: BorderStyles.focusBorder,
          border: BorderStyles.textFieldBorder,
          contentPadding: const EdgeInsets.all(14),
        ),
        style: TextStyles.txtEdit,
        validator: (value) {
          if (value!.isEmpty) {
            return '$title tidak boleh kosong !';
          }
          return null;
        },
      ),
    ],
  );
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

Widget labelPrice({
  String? price,
  required double height,
  required double width,
  bool small = false,
}) {
  return SizedBox(
    height: height,
    width: width,
    child: Stack(
      children: <Widget>[
        Positioned(
          top: small ? 70 : 20,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: price == '0' ? colorPurple : colorPrimary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
                bottomLeft: Radius.circular(50),
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Text(
                price == '0' ? 'GRATIS' : "Rp. ${nF(price.toString())}",
                style: TextStyle(
                  fontSize: small ? 10 : 13,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buttonSubmit({
  required String text,
  required Function onPressed,
  Color backgroundColor = colorPrimary,
  Color? sideColor,
  Color textColor = colorWhite,
  double width = double.infinity,
  double height = 45,
  double fontSize = 16,
  double radius = 30,
  bool withIcon = false,
  Widget? icon,
}) {
  return SizedBox(
    width: width,
    height: height,
    child: TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith(
          (state) => backgroundColor,
        ),
        overlayColor: MaterialStateColor.resolveWith(
          (states) => backgroundColor != colorWhite ? colorWhite : colorPrimary,
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            side: BorderSide(color: sideColor ?? backgroundColor),
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        backgroundColor: MaterialStateProperty.all(backgroundColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (withIcon) icon!,
            if (withIcon && text.isNotEmpty) const SizedBox(width: 10),
            Text(
              text,
              maxLines: 1,
              style: TextStyle(
                color: backgroundColor == colorWhite ? colorPrimary : textColor,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
      onPressed: () {
        onPressed();
      },
    ),
  );
}

menuItem(Function() onTap, IconData icon, String title) {
  return InkWell(
    onTap: onTap,
    child: ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      minLeadingWidth: 15,
      leading: Icon(icon, color: colorBlack100, size: 20),
      title: Text(title),
    ),
  );
}

sidebar(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey,
    String version, String nama, String level) {
  return Column(
    mainAxisSize: MainAxisSize.max,
    children: [
      Container(
        width: double.infinity,
        color: colorSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(
          children: [
            Image.asset(
              "assets/images/warung_white.png",
              height: 30,
              width: 30,
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Warung Mini",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: colorWhite,
                  ),
                ),
                Text(
                  "V $version",
                  style: TextStyle(
                    color: colorWhite,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 15),
      menuItem(
        () {
          gotoPage(context, const HomePage());
          scaffoldKey.currentState!.closeDrawer();
        },
        Icons.dashboard_outlined,
        "Dashboard",
      ),
      menuItem(
        () {
          gotoPage(context, const Products(fromPage: "home", order: []));
          scaffoldKey.currentState!.closeDrawer();
        },
        Icons.list_alt_outlined,
        "Menu",
      ),
      menuItem(
        () {
          gotoPage(context, const OrdersListScreeen());
          scaffoldKey.currentState!.closeDrawer();
        },
        Icons.book_outlined,
        "Orders",
      ),
      menuItem(
        () {
          gotoPage(context, const HomePage());
          scaffoldKey.currentState!.closeDrawer();
        },
        Icons.add_chart_outlined,
        "Report",
      ),
      menuItem(
        () {
          gotoPage(context, const MorePage());
          scaffoldKey.currentState!.closeDrawer();
        },
        Icons.settings_outlined,
        "Settings",
      ),
      Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        "assets/images/empty_image_square.png",
                        height: 30,
                        width: 30,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nama,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        Text(
                          level,
                          style: TextStyle(fontSize: 10.sp),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              menuItem(
                () => Auth.instance.doLogout(context),
                Icons.logout_outlined,
                "Keluar",
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
