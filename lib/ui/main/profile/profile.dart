import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warung_mini_tab/auth/auth.dart';

import '../../../common/helper.dart';
import '../../../common/my_behavior.dart';
import '../../../common/my_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver {
  late AppLifecycleState appLifecycleState;
  String _nama = "";
  String _id = "";

  String userFileName = "";
  dynamic pickImageError;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _setSession() async {
    var login = await openSession();
    setState(() {
      _nama = login.get("login_name");
      _id = login.get("login_id");
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setSession();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // wLog("state__ " + state.toString());
    switch (state) {
      case AppLifecycleState.resumed:
        wLog("app in resumed $runtimeType");
        break;
      case AppLifecycleState.inactive:
        wLog("app in inactive");
        break;
      case AppLifecycleState.paused:
        wLog("app in paused");
        break;
      case AppLifecycleState.detached:
        wLog("app in detached");
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colorWhiteBg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            child: backgroundHeader(),
          ),
          Column(
            children: <Widget>[
              const SizedBox(
                height: 140,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: colorWhite,
                        border: Border.all(color: colorGrey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            children: [
                              Row(
                                children: [
                                  Stack(
                                    children: [
                                      userFileName != ""
                                          ? Container(
                                              width: 80.0,
                                              height: 80.0,
                                              decoration: BoxDecoration(
                                                color: colorSecondary,
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(
                                                      userFileName),
                                                ),
                                              ),
                                            )
                                          : CircleAvatar(
                                              radius: 40,
                                              backgroundColor: colorGrey,
                                              child: Text(
                                                getInitials(_nama),
                                                style: const TextStyle(
                                                    color: colorPrimary,
                                                    fontSize: 32),
                                              ),
                                            ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      alignment: Alignment.topLeft,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              Text(
                                                getFirsSecondName(_nama),
                                                style: const TextStyle(
                                                    fontSize: 22,
                                                    color: colorPrimary,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              const SizedBox(height: 10),
                                              Text(
                                                "ID MEMBER : $_id",
                                                style: const TextStyle(
                                                    color: colorPrimary),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // SvgPicture.asset(
                          //   "assets/images/arrow-ios-right.svg",
                          //   color: colorTextLight,
                          // )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: ScrollConfiguration(
                behavior: MyBehavior(),
                child: ListView(
                  padding: const EdgeInsets.only(top: 10),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 8,
                      ),
                      child: GestureDetector(
                        onTap: () => Auth.instance.doLogout(context),
                        child: Card(
                          child: Container(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                children: [
                                  const Icon(Icons.logout_outlined),
                                  const SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Keluar"),
                                      Text(
                                        "Akhiri sesi dan keluar dari aplikasi",
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }
}

Widget backgroundHeader() {
  return Container(
    transform: Matrix4.translationValues(-95.0, -170.0, 0.0),
    padding: const EdgeInsets.only(top: 10),
    height: 300.0,
    width: 350.0,
    decoration: const BoxDecoration(
      color: colorSecondary,
      shape: BoxShape.circle,
    ),
    child: Container(
      transform: Matrix4.translationValues(95.0, 170.0, 0.0),
      child: const Padding(
        padding: EdgeInsets.only(top: 50, left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Profil",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
