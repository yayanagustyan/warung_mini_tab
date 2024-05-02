import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:warung_mini_tab/common/bottom_navigation_bar/curved_navigation_bar.dart';
import 'package:warung_mini_tab/common/global_widgets.dart';
import 'package:warung_mini_tab/common/helper.dart';
import 'package:warung_mini_tab/common/my_colors.dart';

import 'ui/main/home/home.dart';
import 'ui/main/more/more.dart';
// import 'ui/main/notif/notification.dart';
import 'ui/main/profile/profile.dart';

class BottomNavBar1 extends StatefulWidget {
  const BottomNavBar1({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar1> {
  // String _userCode = "";
  // String _userId = "";
  // bool _hasNotif = false;
  // static String memberType = "REG";
  late int _page;
  GlobalKey bottomNavigationKey = GlobalKey();

  final List<Widget> _children = [
    const ProfilePage(),
    const HomePage(),
    // const NotificationPage(),
    const MorePage(),
  ];

  _cekHomeState() async {
    var login = await openSession();
    if (login.containsKey("open_profile")) {
      setState(() {
        _page = 0;
      });
      login.delete("open_profile");
    } else {
      _page = 1;
    }
  }

  @override
  void initState() {
    _cekHomeState();
    _page = 1;
    super.initState();
  }

  List<Widget> _tabs() {
    List<Widget> ele = [];
    ele.add(Tab(
      icon: SvgPicture.asset(
        "assets/icons/user.svg",
        fit: BoxFit.cover,
        height: 30,
        colorFilter: ColorFilter.mode(
          _page == 0 ? colorWhite : colorSecondary,
          BlendMode.srcIn,
        ),
      ),
    ));
    ele.add(
      Tab(
        icon: SvgPicture.asset(
          "assets/icons/dashboard.svg",
          fit: BoxFit.cover,
          height: 30,
          colorFilter: ColorFilter.mode(
            _page == 1 ? colorWhite : colorSecondary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
    // ele.add(
    //   Tab(
    //     icon: Stack(
    //       children: <Widget>[
    //         SvgPicture.asset(
    //           "assets/icons/trans.svg",
    //           fit: BoxFit.cover,
    //           height: 30,
    //           colorFilter: ColorFilter.mode(
    //             _page == 2 ? colorWhite : colorSecondary,
    //             BlendMode.srcIn,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
    ele.add(
      Tab(
        icon: SvgPicture.asset(
          "assets/icons/setting.svg",
          fit: BoxFit.cover,
          height: 30,
          colorFilter: ColorFilter.mode(
            _page == 2 ? colorWhite : colorSecondary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
    return ele;
  }

  DateTime currentBackPressTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: CurvedNavigationBar(
          key: bottomNavigationKey,
          index: _page,
          height: 60.0,
          items: _tabs(),
          color: colorWhite,
          buttonBackgroundColor: colorPrimary,
          backgroundColor: colorWhiteBg,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 600),
          onTap: (index) {
            setState(() {
              _page = index;
              if (index == 2) {}
            });
          },
        ),
        body: _children[_page],
      ),
    );
  }

  Future<bool> _onBackPressed() {
    DateTime now = DateTime.now();
    CurvedNavigationBarState navBarState =
        bottomNavigationKey.currentState as CurvedNavigationBarState;
    if (_page != 1) {
      navBarState.setPage(1);
      return Future.value(false);
    } else {
      if (now.difference(currentBackPressTime) > const Duration(seconds: 2)) {
        currentBackPressTime = now;
        showToast("Please click back again to exit", context: context);
        return Future.value(false);
      }
    }
    return Future.value(true);
  }
}
