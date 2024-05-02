import 'package:flutter/material.dart';
import 'package:warung_mini_tab/ui/main/home/home.dart';

import '../../../common/helper.dart';
import '../../../common/my_colors.dart';

typedef GetOffsetMethod = double Function();
typedef SetOffsetMethod = void Function(double offset);

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NotificationPageState();
  }
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  double listViewOffset = 0.0;
  int _tabIndex = 0;
  int qtyNotif = 0;
  int qtyMsg = 0;

  @override
  void initState() {
    _setSession();
    _controller = TabController(length: 2, vsync: this);
    _controller.addListener(() {
      setState(() {
        _tabIndex = _controller.index;
        if (_tabIndex == 0) {
          // _getData("notif");
        } else {
          // _getData("message");
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // pr = new ProgressDialog(context,
    //     type: ProgressDialogType.normal, isDismissible: false, showLogs: true);
    // pr.style(message: 'Please wait...');

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: colorText),
        title: const Text(
          "Notifikasi",
          style: TextStyle(
            color: colorText,
          ),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false);
          },
          child: const Icon(Icons.arrow_back),
        ),
        automaticallyImplyLeading: true,
        backgroundColor: colorWhite,
      ),
      backgroundColor: colorWhite,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          // Container(
          //   child: backgroundHeader(),
          // ),
          Column(
            children: <Widget>[
              const SizedBox(
                height: 0,
              ),
              TabBar(
                labelColor: colorPrimary,
                unselectedLabelColor: colorText,
                indicatorColor: colorPrimary,
                controller: _controller,
                tabs: [
                  Tab(
                    text: qtyNotif > 0 ? "Transaksi" : "Transaksi",
                  ),
                  Tab(
                    text: qtyMsg > 0 ? "Pesan" : "Pesan",
                  )
                ],
              ),
            ],
          ),
        ],
      ),
      // SingleChildScrollView(
      //   child: NotifList(
      //     items: notifListItem,
      //   ),
      // )
    );
  }

  _setSession() async {
    var login = await openSession();
    login.get("key");
  }

  Future<void> hideMe() async {
    // await pr.hide();
  }
}

Widget backgroundHeader() {
  return Container(
    transform: Matrix4.translationValues(-95.0, -170.0, 0.0),
    padding: const EdgeInsets.only(top: 10),
    height: 300.0,
    width: 350.0,
    decoration: const BoxDecoration(
      color: colorPrimary,
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
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                Text(
                  "NOTIFICATION",
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// class SlideTransitionX extends AnimatedWidget {
//   late final direction = AxisDirection.down;
//   late final Widget child;
//   late bool transformHitTests = true;

//   // final bool transformHitTests;
//   // final Widget child;
//   // final AxisDirection direction;

//   late Tween<Offset> _tween;

//   SlideTransitionX({
//     Key? key,
//     required Animation<double> position,
//     transformHitTests = true,
//     direction = AxisDirection.down,
//     child,
//   })  : assert(position != null),
//         super(key: key, listenable: position) {
//     switch (direction) {
//       case AxisDirection.up:
//         _tween = Tween(begin: const Offset(0, 1), end: const Offset(0, 0));
//         break;
//       case AxisDirection.right:
//         _tween = Tween(begin: const Offset(-1, 0), end: const Offset(0, 0));
//         break;
//       case AxisDirection.down:
//         _tween = Tween(begin: const Offset(0, -1), end: const Offset(0, 0));
//         break;
//       case AxisDirection.left:
//         _tween = Tween(begin: const Offset(1, 0), end: const Offset(0, 0));
//         break;
//     }
//   }

//   // Listenable get position => listenable;
//   Animation<double>? get position => listenable;

//   @override
//   Widget build(BuildContext context) {
//     Offset offset = _tween.evaluate(position);
//     if (position!.status == AnimationStatus.reverse) {
//       switch (direction) {
//         case AxisDirection.up:
//           offset = Offset(offset.dx, -offset.dy);
//           break;
//         case AxisDirection.right:
//           offset = Offset(-offset.dx, offset.dy);
//           break;
//         case AxisDirection.down:
//           offset = Offset(offset.dx, -offset.dy);
//           break;
//         case AxisDirection.left:
//           offset = Offset(-offset.dx, offset.dy);
//           break;
//       }
//     }
//     return FractionalTranslation(
//       translation: offset,
//       transformHitTests: transformHitTests,
//       child: child,
//     );
//   }
// }
