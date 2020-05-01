import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sennit/driver/active_order.dart';
import 'package:sennit/driver/order_history.dart';
import 'package:sennit/main.dart';
import 'package:sennit/models/models.dart';
import 'package:sennit/my_widgets/generic_order_navigation.dart';
import 'package:sennit/start_page.dart';
import 'package:sennit/user/receiveit.dart' as receiveIt;

class Delivery {
  final LatLng pickUp;
  final LatLng dropOff;
  final String customerName;
  final String driverName;
  final double cost;

  Delivery({
    this.pickUp,
    this.dropOff,
    this.customerName,
    this.driverName,
    this.cost,
  });
}

class HomeScreenDriver extends StatefulWidget {
  static const String NAME = "HOME_SCREEN_DRIVER";
  HomeScreenDriver();

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreenDriver>
    with TickerProviderStateMixin {
  TabController controller;
  Future<dynamic> initialize;
  List<String> titles = ['Orders', 'History', 'Profile'];
  int index = 0;
  Driver driver;

  initializeDriver(context) async {
    await Utils.getMyLocation();
    if (!Session.data.containsKey('driver') || Session.data['driver'] == null) {
      await FirebaseAuth.instance.currentUser().then((user) {
        String driverId = user.uid;
        Firestore.instance
            .collection('drivers')
            .document(driverId)
            .get()
            .then((dataSnapshot) {
          Driver driver = Driver.fromMap(dataSnapshot.data);
          Session.data.update('driver', (d) => driver, ifAbsent: () => driver);
          this.driver = driver;
        });
      });
      // Firestore.instance.collection('drivers').
    }
    driver = Session.data['driver'];
    await Firestore.instance
        .collection('drivers')
        .document(Session.data['driver'].driverId)
        .collection('acceptedOrders')
        .getDocuments()
        .then((snapshot) {
      if (snapshot != null &&
          (snapshot.documents != null && snapshot.documents.length > 0)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return OrderNavigationRoute(
                alreadyAccepted: true,
                data: snapshot.documents[0].data,
                verificationCode: snapshot.documents[0].data['otp'],
              );
            },
            settings: RouteSettings(name: OrderNavigationRoute.NAME),
            maintainState: false,
          ),
        );
      }
    });
    return;
  }

  @override
  void initState() {
    super.initState();
    initialize = initializeDriver(context);
    controller = TabController(length: 3, vsync: this);
    controller.addListener(() {
      setState(() {
        index = controller.index;
      });
    });
  }

  static var _willExit = false;

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
      child: FutureBuilder<dynamic>(
        future: initialize,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(
                title: Text(titles[index]),
                centerTitle: true,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => StartPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(titles[index]),
              centerTitle: true,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    try {
                      Navigator.pop(
                        context,
                      );
                    } catch (ex) {
                      print(ex);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => StartPage(),
                        settings: RouteSettings(
                          name: MyApp.startPage,
                          isInitialRoute: true,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            //TODO: fix this condition
            bottomNavigationBar: !(driver.licencePlateNumber != null &&
                    driver.licencePlateNumber.isNotEmpty)
                ? BottomAppBar(
                    elevation: 10,
                    child: TabBar(
                      labelColor: Theme.of(context).accentColor,
                      indicatorColor: Theme.of(context).accentColor,
                      indicator:
                          // BoxDecoration(
                          //   border: Border(
                          //     left: BorderSide(color: Theme.of(context).accentColor, width: 2), // provides to left side
                          //     right: BorderSide(color: Theme.of(context).accentColor, width: 2), // for right side
                          //   ),
                          // ),
                          UnderlineTabIndicator(
                        insets:
                            EdgeInsets.only(bottom: 47, left: 20, right: 20),
                        borderSide: BorderSide(
                          color: Theme.of(context).accentColor,
                          width: 2,
                        ),
                      ),
                      controller: controller,
                      tabs: [
                        Tab(
                          icon: Icon(Icons.notifications),
                          // child: Container(
                          //   child: IconButton(
                          //     icon: Center(
                          //       child: Icon(Icons.notifications),
                          //     ),
                          //     onPressed: () {},
                          //   ),
                          //   decoration: BoxDecoration(
                          //     border: Border(
                          //         right: BorderSide(color: Theme.of(context).accentColor)),
                          //   ),
                          // ),
                        ),
                        Tab(
                          icon: Icon(Icons.history),
                          // child: Container(
                          //   child: IconButton(
                          //     icon: Center(
                          //       child: Icon(Icons.history),
                          //     ),
                          //     onPressed: () {},
                          //   ),
                          //   decoration: BoxDecoration(
                          //     border: Border(
                          //         left: BorderSide(color: Theme.of(context).accentColor)),
                          //   ),
                          // ),
                        ),
                        Tab(
                          icon: Icon(Icons.person),
                        ),
                      ],
                    ),
                  )
                : null,
            body: (driver.licencePlateNumber != null &&
                    driver.licencePlateNumber.isNotEmpty)
                ? TabBarView(
                    controller: controller,
                    children: <Widget>[
                      _NotificationPage(),
                      OrderHistory(),
                      _ProfilePage(),
                    ],
                  )
                : Center(
                    child: GestureDetector(
                      onTap: () async {
                        Utils.showLoadingDialog(context);
                        FirebaseUser user =
                            await FirebaseAuth.instance.currentUser();
                        Utils.showLoadingDialog(context);
                        if (user == null) {
                          Navigator.pop(context);
                          Navigator.popAndPushNamed(context, MyApp.startPage);
                        } else {
                          Firestore.instance
                              .collection('drivers')
                              .document(user.uid)
                              .get(source: Source.server)
                              .timeout(Duration(seconds: 20), onTimeout: () {
                            Utils.showSnackBarError(
                                context, 'Request Timed out');
                            Navigator.pop(context);
                            return;
                          }).then((data) async {
                            Navigator.pop(context);
                            if (driver == null) {
                              await FirebaseAuth.instance.signOut();
                              Utils.showSnackBarWarning(
                                  context, 'Please Login Again');
                              Navigator.pushNamedAndRemoveUntil(
                                  context, MyApp.driverSignin, (c) => true);
                            } else {
                              Session.data.update('driver', (old) => driver,
                                  ifAbsent: () => driver);
                              setState(() {});
                            }
                          });
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Your Vehicle is not Registered!\nPlease contact chaseF@sennit.co.za.\n\nTap to Retry',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.title,
                          ),
                          SizedBox(height: 10),
                          Icon(
                            Icons.replay,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _NotificationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NotificationPageState();
  }
}

class _NotificationPageState extends State<_NotificationPage> {
  // Future<dynamic> initialize;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("postedOrders").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.replay),
                Text('An Error Occurred'),
              ],
            ),
          );
        }

        if ((snapshot.connectionState == ConnectionState.active ||
                snapshot.connectionState == ConnectionState.done) &&
            snapshot.data == null) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.replay),
                Text('Unable To Load'),
              ],
            ),
          );
        }

        if ((snapshot.connectionState == ConnectionState.active ||
                snapshot.connectionState == ConnectionState.done) &&
            snapshot.data.documents.isEmpty) {
          return Center(
            child: Text(
              'No Notifications',
              style: Theme.of(context)
                  .textTheme
                  .title
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          );
        }

        List<DocumentSnapshot> allDocs =
            List<DocumentSnapshot>.from(snapshot.data.documents);
        List<DocumentSnapshot> documents = [];
        allDocs.forEach((doc) {
          LatLng pickup;
          Map<String, dynamic> data = doc.data;
          if (data.containsKey('numberOfBoxes')) {
            pickup = Utils.latLngFromString(data['pickUpLatLng']);
          } else {
            double min = double.infinity;
            for (String latlng in data['pickups']) {
              LatLng pickupLatLng = Utils.latLngFromString(latlng);
              double distance = Utils.calculateDistance(
                  pickupLatLng, Utils.getLastKnowLocation());
              if (distance < min) {
                min = distance;
                pickup = pickupLatLng;
              }
            }
          }
          if (Utils.calculateDistance(pickup, Utils.getLastKnowLocation()) <=
              20) {
            documents.add(doc);
          }
        });
        List<Widget> tiles = [];

        Driver driver = Session.data['driver'];
        LatLng currLatLng = Utils.getLastKnowLocation();
        documents.sort((first, second) {
          double firstDistance = 0;
          double secondDistance = 0;
          if (first.data.containsKey('dropOffLatLng')) {
            firstDistance = Utils.calculateDistance(currLatLng,
                Utils.latLngFromString(first.data['dropOffLatLng']));
          } else {
            firstDistance = Utils.calculateDistance(
                currLatLng, Utils.latLngFromString(first.data['destination']));
          }
          if (second.data.containsKey('dropOffLatLng')) {
            secondDistance = Utils.calculateDistance(currLatLng,
                Utils.latLngFromString(second.data['dropOffLatLng']));
          } else {
            secondDistance = Utils.calculateDistance(
                currLatLng, Utils.latLngFromString(second.data['destination']));
          }
          return firstDistance.compareTo(secondDistance);
        });

        for (int index = 0; index < documents.length; index++) {
          var orderData = documents[index].data;
          orderData.update(
            'orderId',
            (old) {
              return documents[index].documentID;
            },
            ifAbsent: () => documents[index].documentID,
          );
          print(orderData);
          if ((orderData['status'] as String).toUpperCase() != 'PENDING' &&
              orderData['driverId'] != driver.driverId) {
            // return null;
          } else if (orderData.containsKey("numberOfBoxes")) {
            tiles.add(SennitNotificationTile(data: orderData));
          } else {
            tiles.add(ReceiveItNotificationTile(orderData));
          }
        }

        if (tiles.isEmpty) {
          return Center(
            child: Text(
              'No Notifications',
              style: Theme.of(context)
                  .textTheme
                  .title
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          );
        }

        return SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: tiles,
          ),
        );
      },
    );
  }
}

class SennitNotificationTile extends StatelessWidget {
  final Map<String, dynamic> data;
  SennitNotificationTile({this.data, this.isClickable = true});
  final isClickable;

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Sennit',
              style: Theme.of(context).textTheme.display1,
            ),
            SizedBox(
              height: 14.0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 4.0,
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Order ID',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(
                        height: 6.0,
                      ),
                      Text(
                        data['orderId'],
                        textAlign: TextAlign.start,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 4.0,
                ),
                Center(
                  child: Container(
                    height: 50,
                    width: 1,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 4.0,
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Price',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(
                          height: 6.0,
                        ),
                        Text(
                          "${(data['price'] as num).toDouble().toStringAsFixed(2)}R",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 4.0,
                ),
                Center(
                  child: Container(
                    height: 50,
                    width: 1,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 4.0,
                ),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '# of Boxes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(
                          height: 6.0,
                        ),
                        Text(
                          '${data['numberOfBoxes']} ${data['boxSize']} Boxes',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 4.0,
                ),
              ],
            ),
            SizedBox(
              height: 14.0,
            ),
            Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(2),
                  margin: EdgeInsets.only(left: 2, right: 4),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: Border(
                      right: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Center(
                      child: Text(
                        ' P i c k u p ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    data['pickUpAddress'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(2),
                  margin: EdgeInsets.only(left: 2, right: 4),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: Border(
                      right: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Center(
                      child: Text(
                        ' D r o p Off ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    data['dropOffAddress'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Transform.rotate(
                    angle: pi / 4,
                    child: Icon(
                      Icons.navigation,
                      size: 16,
                    ),
                  ),
                  Text(
                      ' ${Utils.calculateDistance(Utils.latLngFromString(data['pickUpLatLng']), Utils.getLastKnowLocation()).toStringAsFixed(2)} Km '),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
      elevation: 10,
    );
    return isClickable
        ? InkWell(
            child: card,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return OrderNavigationRoute(
                        alreadyAccepted: false,
                        data: data,
                        verificationCode: data['otp'],
                      );
                    },
                    maintainState: false,
                    settings: RouteSettings(name: OrderNavigationRoute.NAME),
                  ));
            },
          )
        : card;
  }
}

class ReceiveItNotificationTile extends StatelessWidget {
  final data;
  String getNearestPickup() {
    double min = double.infinity;
    for (String latlng in data['pickups']) {
      double distance = Utils.calculateDistance(
          Utils.latLngFromString(latlng), Utils.getLastKnowLocation());
      if (distance < min) {
        min = double.parse(distance.toStringAsFixed(2));
      }
    }
    return '$min';
  }

  ReceiveItNotificationTile(this.data);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        child: Container(
          margin: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Receive it',
                style: Theme.of(context).textTheme.display1,
              ),
              SizedBox(
                height: 14.0,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 4.0,
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Order ID',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(
                          height: 6.0,
                        ),
                        Text(
                          data['orderId'],
                          textAlign: TextAlign.start,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Center(
                    child: Container(
                      height: 50,
                      width: 1,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Price',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(
                            height: 6.0,
                          ),
                          Text(
                            "R${data['price']}",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Center(
                    child: Container(
                      height: 50,
                      width: 1,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(
                            height: 6.0,
                          ),
                          Text(
                            '${data['pickups'].length} ${data['pickups'].length == 1 ? 'item' : 'items'}',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                ],
              ),
              SizedBox(
                height: 14.0,
              ),
              // Row(
              //   children: <Widget>[
              // Stack(
              //   children: [
              //     Padding(
              //       padding: const EdgeInsets.only(top: 10.0),
              //       child: Icon(Icons.location_on),
              //     ),
              //     Padding(
              //       padding: const EdgeInsets.only(left: 6.0, bottom: 10.0),
              //       child: Icon(
              //         Icons.location_on,
              //       ),
              //     ),
              //     Padding(
              //       padding: const EdgeInsets.only(left: 12.0, top: 10),
              //       child: Icon(
              //         Icons.location_on,
              //       ),
              //     )
              //   ],
              // ),
              // SizedBox(
              //   width: 2,
              // ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FutureBuilder<Map<String, String>>(
                      future: getDifferentNumberOfStores(
                          data['pickups'], data['destination']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return Row(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(2),
                                margin: EdgeInsets.only(left: 2, right: 4),
                                decoration: ShapeDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: Border(
                                    right: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: RotatedBox(
                                  quarterTurns: 3,
                                  child: Center(
                                    child: Text(
                                      ' P i c k u p ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  snapshot.data['pickup'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(2),
                                margin: EdgeInsets.only(left: 2, right: 4),
                                decoration: ShapeDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: Border(
                                    right: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: RotatedBox(
                                  quarterTurns: 3,
                                  child: Center(
                                    child: Text(
                                      ' D r o p Off ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  snapshot.data['destination'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              //     Expanded(
              //       child: Text(
              //         data['pickups'][0],
              //         style: TextStyle(
              //           fontSize: 14,
              //           fontWeight: FontWeight.w500,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(
                height: 10,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Transform.rotate(
                      angle: pi / 4,
                      child: Icon(
                        Icons.navigation,
                        size: 16,
                      ),
                    ),
                    Text(' ${getNearestPickup()} Km '),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        elevation: 10,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return OrderNavigationRoute(
                alreadyAccepted: false,
                data: data,
                verificationCode: data['otp'],
              );
            },
            settings: RouteSettings(name: OrderNavigationRoute.NAME),
            maintainState: false,
          ),
        );
      },
    );
  }

  Future<Map<String, String>> getDifferentNumberOfStores(
      List<dynamic> pickups, String destLatlng) async {
    List<String> temp = List();
    LatLng destLatLngFromString = Utils.latLngFromString(destLatlng);
    final futureDestination =
        Geocoder.google(await Utils.getAPIKey()).findAddressesFromCoordinates(
      Coordinates(
        destLatLngFromString.latitude,
        destLatLngFromString.longitude,
      ),
    );
    for (String store in pickups) {
      if (!temp.contains(store)) {
        temp.add(store);
        // differentStores++;
      }
    }
    final destination = (await futureDestination)[0].addressLine;
    if (temp.length == 1) {
      LatLng latLng = Utils.latLngFromString(temp[0]);
      if (latLng == null) {
        return null;
      }
      final locationInfo = await Geocoder.google(await Utils.getAPIKey())
          .findAddressesFromCoordinates(
              Coordinates(latLng.latitude, latLng.longitude));
      return {
        'pickup': locationInfo[0].addressLine,
        'destination': destination
      };
    } else {
      return {
        'pickup': "There are ${temp.length} different stores.",
        'destination': destination
      };
    }

    // List<LatLng> done = List();
    // List<LatLng> allPoints = List.generate(
    //   pickups.length,
    //   (index) => Utils.latLngFromString(pickups[index]),
    // );
  }
}

class OrderItemRoute extends StatelessWidget {
  final List<String> items;
  final Map<String, dynamic> data;
  const OrderItemRoute({Key key, this.items, this.data}) : super(key: key);

  Future<List<StoreItem>> getItems() async {
    List<StoreItem> storeItems = [];
    var documents = await Firestore.instance.collection("items").getDocuments();
    for (DocumentSnapshot snapshot in documents.documents) {
      StoreItem item = StoreItem.fromMap(snapshot.data);
      storeItems.add(item);
    }
    return storeItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<StoreItem>>(
          future: getItems(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (!snapshot.hasData || snapshot.data.length == 0) {
              return Text('No Item Available');
            }
            var items = snapshot.data;
            return SingleChildScrollView(
                child: Column(
              children: List.generate(items.length, (index) {
                return InkWell(
                  child: receiveIt.MenuItem(
                    item: items[index],
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      data.update('storeItems', (a) {
                        return items;
                      }, ifAbsent: () {
                        return items;
                      });
                      return ActiveOrder(
                        orderData: data,
                      );
                    }));
                  },
                );
              }),
            ));
          }),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Driver driver = Session.data['driver'];

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(80),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/images/logo.png',
                image: driver.profilePicture,
                width: 200,
                height: 200,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            '${driver.fullName}',
            style: Theme.of(context).textTheme.subhead,
          ),
          SizedBox(
            height: 6,
          ),
          FutureBuilder<Driver>(
            future: refreshDriver(driver.driverId),
            initialData: Session.data['driver'],
            builder: (context, snapshot) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Tooltip(
                    child: Icon(
                      Icons.star,
                      color: Colors.grey,
                      size: 14,
                    ),
                    message: "rating",
                  ),
                  Text(
                      ' ${(snapshot.data == null || snapshot.data.rating == 0) ? 'N/A' : snapshot.data.rating}'),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    color: Colors.black,
                    width: 1,
                    child: Text(''),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Tooltip(
                    child: Icon(
                      Icons.person,
                      size: 14,
                    ),
                    message: "rated by users",
                  ),
                  Text(
                      ' ${(snapshot.data == null || snapshot.data.rating == null) ? 0 : snapshot.data.totalReviews}'),
                ],
              );
            },
          ),
          SizedBox(
            height: 40,
          ),
          Align(
            child: Text(
              'Reviews',
              style: Theme.of(context).textTheme.display1,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          FutureBuilder<QuerySnapshot>(
              future: Firestore.instance
                  .collection("drivers")
                  .document(driver.driverId)
                  .collection('reviews')
                  .getDocuments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Column(
                  children: snapshot.data.documents != null
                      ? getReviews(snapshot.data.documents)
                      : [
                          Center(
                            child: Text(
                              'No Reviews Yet',
                            ),
                          ),
                        ],
                );
              }),
        ],
      ),
    );
  }

  Future<Driver> refreshDriver(String driverId) async {
    final data =
        await Firestore.instance.collection('drivers').document(driverId).get();
    Driver driver = Driver.fromMap(data.data);
    Session.data.update('driver', (old) => driver, ifAbsent: () => driver);
    return driver;
  }

  List<Widget> getReviews(List<DocumentSnapshot> data) {
    List<Widget> reviews = List();
    // List<String> keys = data.keys;
    if (data.length <= 0) {
      return <Widget>[
        Center(
          child: Text('No Reviews Yet'),
        ),
      ];
    }
    for (var i = 0; i < data.length; i++) {
      ReviewForDriver reviewForDriver = ReviewForDriver.fromMap(
        data[i].data,
      );
      Widget review = ListTile(
        title: Text('${reviewForDriver.reviewedBy}'),
        subtitle: Text(
          '${reviewForDriver.reviewDescription}',
        ),
        trailing: Column(
          children: <Widget>[
            Icon(
              Icons.star,
              color: Colors.yellow,
            ),
            SizedBox(
              height: 2,
            ),
            Text('${reviewForDriver.rating.toStringAsFixed(1)}'),
          ],
        ),
      );
      reviews
        ..add(review)
        ..add(
          SizedBox(
            height: 10,
          ),
        );
    }
    return reviews;
  }
}
