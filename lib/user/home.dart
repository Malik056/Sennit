import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sennit/main.dart';
import 'package:sennit/models/models.dart';
import 'package:sennit/user/receiveit.dart';

class UserHomeRoute extends StatelessWidget {
  static bool _willExit = false;
  final bool initializeCart;
  final user = Session.data['user'];

  static const String NAME = 'UserHomeRoute';

  initializeNotifications() async {
    final snapshots = await Firestore.instance
        .collection('users')
        .document(user.userId)
        .collection('notifications')
        .limit(20)
        .getDocuments();
    final notifications = <Map<String, dynamic>>[];
    snapshots.documents.forEach((document) {
      document.data.update('notificationId', (old) => document.documentID,
          ifAbsent: () => document.documentID);
      notifications.add(document.data);
    });
    Session.data.update('notifications', (old) => notifications,
        ifAbsent: () => notifications);
  }

  UserHomeRoute({Key key, this.initializeCart = false}) : super(key: key) {
    initializeNotifications();
    if (initializeCart) {
      FirebaseAuth.instance.currentUser().then((user) async {
        String userId = user.uid;
        final snapshot =
            await Firestore.instance.collection('carts').document(userId).get();
        final cart = UserCart.fromMap(snapshot.data);
        Session.data.update('cart', (data) {
          return cart;
        }, ifAbsent: () {
          return cart;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_willExit) {
          SystemNavigator.pop();
        } else {
          BotToast.showText(text: 'Press Again to Exit');
          _willExit = true;
          Future.delayed(Duration(seconds: 3)).then((value) {
            _willExit = false;
          });
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('User Home'),
          centerTitle: true,
          actions: <Widget>[
            InkWell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Tooltip(
                  child: Icon(FontAwesomeIcons.signOutAlt),
                  message: "Sign out",
                ),
              ),
              onTap: () async {
                Utils.signOutUser(context);
              },
            ),
          ],
        ),
        body: UserHomeBody(MediaQuery.of(context).size),
        backgroundColor: Colors.white,
      ),
    );
  }
}

class UserHomeBody extends StatefulWidget {
  final topLeftBorder = Radius.circular(20);
  final topRightBorder = Radius.circular(20);
  final Size screenWidth;

  UserHomeBody(this.screenWidth);

  @override
  State<StatefulWidget> createState() {
    return UserHomeState();
  }
}

class UserHomeState extends State<UserHomeBody> {
  bool sendItClickable = true;
  bool receiveItClickable = true;
  double defaultSize;
  double currentSizeSendIt;
  double currentSizeReceiveIt;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  saveDeviceToken() async {
    String uid = (await FirebaseAuth.instance.currentUser()).uid;
    String fcmToken = await _fcm.getToken();
    if (fcmToken != null) {
      Firestore.instance
          .collection('users')
          .document(uid)
          .collection('tokens')
          .document('$fcmToken')
          .setData({
        'token': fcmToken,
      });
    }
  }

  @override
  void initState() {
    defaultSize = widget.screenWidth.width * 0.4;
    currentSizeReceiveIt = defaultSize;
    currentSizeSendIt = defaultSize;
    super.initState();
    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }
    saveDeviceToken();

    _fcm.configure(
      onMessage: (data) async {
        print(data);
        // BotToast.showNotification(
        //   align: Alignment.topCenter,
        //   contentPadding: EdgeInsets.all(8),
        //   leading: (_) => Icon(
        //     FontAwesomeIcons.store,
        //     color: Theme.of(context).primaryColor,
        //   ),
        // );
        MyAppState.showNotificationWithDefaultSound(data['notification']);
      },
      onBackgroundMessage:
          Platform.isIOS ? null : Utils.backgroundMessageHandler,
      onResume: Utils.onResume,
      onLaunch: Utils.onLaunch,
    );
  }

  // Future<dynamic> _onResume(payload) async {
  //   final uid = (await FirebaseAuth.instance.currentUser()).uid;
  //   final data = Platform.isIOS ? payload : payload['data'];
  //   if (uid == data['userId']) {
  //     await Firestore.instance.collection('users').document(uid).get().then(
  //       (userData) async {
  //         if (userData == null ||
  //             !userData.exists ||
  //             userData.data == null ||
  //             userData.data.length <= 0) {
  //           Navigator.pop(context);
  //           Utils.showSnackBarError(
  //             context,
  //             "User not found",
  //           );
  //           return;
  //         }
  //         User user = User.fromMap(userData.data);
  //         user.userId = uid;
  //         Session.data.update(
  //           'user',
  //           (a) {
  //             return user;
  //           },
  //           ifAbsent: () {
  //             return user;
  //           },
  //         );
  //         MyAppState?.navigatorKey?.currentState?.push(
  //           MaterialPageRoute(
  //             builder: (context) {
  //               print(data);
  //               return ReviewWidget(
  //                 orderId: data['orderId'],
  //                 user: user,
  //                 itemId: null,
  //                 isDriver: true,
  //                 driverId: data['driverId'],
  //                 userId: uid,
  //               );
  //             },
  //           ),
  //         );
  //       },
  //     );
  //   }
  // }

  // Future<dynamic> _onLaunch(payload) async {
  //   final uid = (await FirebaseAuth.instance.currentUser()).uid;
  //   final data = Platform.isIOS ? payload : payload['data'];
  //   BotToast.showText(text: 'onLaunch: $data');
  //   if (uid == data['userId']) {
  //     Firestore.instance.collection('users').document(uid).get().then(
  //       (userData) async {
  //         if (userData == null ||
  //             !userData.exists ||
  //             userData.data == null ||
  //             userData.data.length <= 0) {
  //           Utils.showSnackBarError(
  //             context,
  //             "User not found",
  //           );
  //           return;
  //         }
  //         User user = User.fromMap(userData.data);
  //         user.userId = uid;
  //         Session.data.update(
  //           'user',
  //           (a) {
  //             return user;
  //           },
  //           ifAbsent: () {
  //             return user;
  //           },
  //         );
  //         MyAppState.navigatorKey?.currentState
  //             ?.push(MaterialPageRoute(builder: (ctx) {
  //           return ReviewWidget(
  //             orderId: data['orderId'],
  //             isDriver: true,
  //             driverId: data['driverId'],
  //             fromNotification: true,
  //             userId: uid,
  //             user: user,
  //             itemId: null,
  //             comment: "",
  //           );
  //         }));
  //       },
  //     );
  //   }
  // }

  // static Future<dynamic> _backgroundMessageHandler(
  //     Map<String, dynamic> message) async {
  //   print(message);
  //   MyAppState.showNotificationWithDefaultSound(message);
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          children: [
            Spacer(),
            Icon(
              FontAwesomeIcons.userCog,
              // 'assets/images/logo.png',
              size: widget.screenWidth.width * 0.3,
              color: Theme.of(context).accentColor,
            ),
            Spacer(
              flex: 2,
            ),
            Text(
              'Choose a Service',
              style: Theme.of(context).textTheme.headline5,
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          width: currentSizeReceiveIt,
                          duration: Duration(milliseconds: 100),
                          child: Card(
                            // onPressed: (){},
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: widget.topLeftBorder,
                                  topRight: widget.topRightBorder),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: widget.topLeftBorder,
                                topRight: widget.topRightBorder,
                              ),
                              child: Container(
                                color: Colors.white,
                                padding: EdgeInsets.all(5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topLeft: widget.topLeftBorder,
                                          topRight: widget.topRightBorder),
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        color:
                                            Color.fromARGB(255, 235, 235, 235),

                                        // child: Icon(
                                        //   FontAwesomeIcons.shippingFast,
                                        //   color: Theme.of(context).accentColor,
                                        //   size: currentSizeReceiveIt-40,
                                        // ),

                                        child: Image.asset(
                                          'assets/images/delivery.png',
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            child: Text(
                                              'Receive It',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .accentColor,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          // Tooltip(
                                          //   child: IconButton(
                                          //     icon: Icon(Icons.help),
                                          //     onPressed: () {},
                                          //   ),
                                          //   message:
                                          //       "This Feature Allow user to buy things from our partner stores.",
                                          // ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTapDown: (tap) {
                    setState(() {
                      currentSizeReceiveIt = defaultSize - 20;
                    });
                  },
                  onTapUp: (tap) {
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ReceiveItRoute(
                              demo: false,
                              tabController: null,
                            );
                          },
                          settings: RouteSettings(name: 'receiveIt'),
                        ),
                      );
                      currentSizeReceiveIt = defaultSize;
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      currentSizeReceiveIt = defaultSize;
                    });
                  },
                  onTap: () {},
                  onLongPress: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        fullscreenDialog: false,
                        maintainState: true,
                        builder: (context) {
                          return HelpScreenReceiveIt();
                        },
                      ),
                    );
                  },
                ),
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          width: currentSizeSendIt,
                          duration: Duration(milliseconds: 100),
                          child: Card(
                            elevation: 10,
                            // padding: EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: widget.topLeftBorder,
                                  topRight: widget.topRightBorder),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: widget.topLeftBorder,
                                topRight: widget.topRightBorder,
                              ),
                              child: Container(
                                color: Colors.white,
                                padding: EdgeInsets.all(5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topLeft: widget.topLeftBorder,
                                          topRight: widget.topRightBorder),
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        color:
                                            Color.fromARGB(255, 235, 235, 235),
                                        child: Image.asset(
                                          'assets/images/delivery.png',
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            child: Text(
                                              'Sennit',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .accentColor),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTapDown: (TapDownDetails tap) {
                    setState(() {
                      currentSizeSendIt = defaultSize - 20;
                    });
                  },
                  onTapUp: (tap) {
                    setState(() {
                      currentSizeSendIt = defaultSize;
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      currentSizeSendIt = defaultSize;
                    });
                  },
                  onTap: () {
                    Navigator.of(context).pushNamed(MyApp.selectFromAddress);
                  },
                  onLongPress: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        fullscreenDialog: false,
                        maintainState: true,
                        builder: (context) {
                          return HelpScreenSennit();
                        }));
                  },
                ),
              ],
            ),
            Spacer(
              flex: 2,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Hold down a button to see Help',
                    style: Theme.of(context).textTheme.subtitle1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class HelpScreenSennit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help'),
      ),
      body: SafeArea(
        minimum: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Center(
              child: Icon(
                Icons.help,
                size: 80,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'This Feature helps you to send anything, anywhere to anyone with no effort. We are responsible for picking the package from your door and delivering it to your friend\'s door. Just Follow the Instruction below and Leave everything to Us.',
                    style: Theme.of(context).textTheme.subtitle2,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Instructions',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).accentColor,
                    shape: CircleBorder(
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  child: Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // color: Theme.of(context).accentColor,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Pick a pickup point',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).accentColor,
                    shape: CircleBorder(
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  child: Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // color: Theme.of(context).accentColor,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Provide delivery Location',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).accentColor,
                    shape: CircleBorder(
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // color: Theme.of(context).accentColor,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Provide Details of your package',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).accentColor,
                    shape: CircleBorder(
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  child: Text(
                    '5',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // color: Theme.of(context).accentColor,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Click Done',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
            SizedBox(height: 30),
            SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).accentColor,
                    shape: CircleBorder(
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  child: Text(
                    '4',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // color: Theme.of(context).accentColor,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Make Payment',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'Our Delivery Guy will be at your door step in a flash.',
              style: Theme.of(context).textTheme.subtitle2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class HelpScreenReceiveIt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help'),
      ),
      body: SafeArea(
        minimum: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Center(
              child: Icon(
                Icons.help,
                size: 80,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'This Feature helps you to order anything, anywhere from our partner stores. We are responsible for delivering the product to your door step. Just Follow the Instruction below and Leave everything to Us.',
                    style: Theme.of(context).textTheme.subtitle2,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Instructions',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).accentColor,
                    shape: CircleBorder(
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  child: Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // color: Theme.of(context).accentColor,
                ),
                SizedBox(
                  width: 6,
                ),
                Expanded(
                  child: Text(
                    'Select a product from any of our partner store',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).accentColor,
                    shape: CircleBorder(
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  child: Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // color: Theme.of(context).accentColor,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Select the product quantity',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).accentColor,
                    shape: CircleBorder(
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // color: Theme.of(context).accentColor,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Enter the delivery location',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).accentColor,
                    shape: CircleBorder(
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  child: Text(
                    '5',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // color: Theme.of(context).accentColor,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Click Done',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).accentColor,
                    shape: CircleBorder(
                      side: BorderSide(
                        style: BorderStyle.solid,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  child: Text(
                    '4',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // color: Theme.of(context).accentColor,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Make Payment',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'Our Delivery Guy will be at your door step in a flash.',
              style: Theme.of(context).textTheme.subtitle2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
