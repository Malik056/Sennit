import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart'
    as mapbox;
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sennit/main.dart';
import 'package:sennit/models/models.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

class OrderNavigationRoute extends StatefulWidget {
  static const NAME = "OrderNavigationRoute";
  final bool alreadyAccepted;
  final Map<String, dynamic> data;
  final String verificationCode;

  void onDonePressed() {
    _Body?._key?.currentState?.widget?.showDeliveryCompleteDialogue();
  }

  // Future<Map<String, dynamic>> getItems(data) async {
  //   LatLng destination = Utils.latLngFromString(data['destination']);
  //   Map<String, double> itemsData = Map<String, double>.from(data['itemsData']);
  //   List<Map<String, dynamic>> itemDetails = [];
  //   Map<String, dynamic> result = {};
  //   final keys = itemsData.keys;
  //   for (String itemKey in keys) {
  //     final result =
  //         await Firestore.instance.collection('items').document(itemKey).get();
  //     LatLng latlng = Utils.latLngFromString(result.data['latlng']);
  //     Address address = (await Geocoder.google(await Utils.getAPIKey())
  //         .findAddressesFromCoordinates(
  //             Coordinates(latlng.latitude, latlng.longitude)))[0];
  //     result.data.putIfAbsent('address', () => address.addressLine);
  //     itemDetails.add(result.data);
  //   }

  //   Address address = (await Geocoder.google(await Utils.getAPIKey())
  //       .findAddressesFromCoordinates(
  //           Coordinates(destination.latitude, destination.longitude)))[0];
  //   // itemDetails.add({'destination' : address.addressLine});
  //   result.putIfAbsent('destination', () {
  //     return address;
  //   });
  //   result.putIfAbsent('destinationLatLng', () {
  //     return destination;
  //   });

  //   result.putIfAbsent('itemDetails', () {
  //     return itemDetails;
  //   });

  //   return result;
  // }

  static GlobalKey<OrderNavigationRouteState> _key =
      GlobalKey<OrderNavigationRouteState>();

  OrderNavigationRoute({
    // @required key,
    @required this.alreadyAccepted,
    @required this.data,
    @required this.verificationCode,
  }) : super(key: _key);

  // factory OrderNavigationRoute({
  //   @required data,
  //   @required verificationCode,
  //   @required alreadyAccepted,
  // }) {
  //   _key = GlobalKey<OrderNavigationRouteState>();
  //   return OrderNavigationRoute._(
  //       alreadyAccepted: alreadyAccepted,
  //       key: _key,
  //       data: data,
  //       verificationCode: verificationCode);
  // }

  static _startNavigation(
      context, LatLng destination, LatLng myLocation) async {
    Utils.showLoadingDialog(context);
    // MapsLauncher.launchCoordinates(
    //     pickup.latitude, pickup.longitude);
    mapbox.MapboxNavigation _directions;
    // var _distanceRemaining;
    // var _durationRemaining;

    _directions = mapbox.MapboxNavigation(
      onRouteProgress: (arrived) async {
        // _distanceRemaining = await _directions.distanceRemaining;
        // _durationRemaining = await _directions.durationRemaining;
        // setState(() {
        //   _arrived = arrived;
        // });
        if (arrived) {
          await _directions.finishNavigation();
          Navigator.popUntil(
            context,
            (route) => route.settings.name == OrderNavigationRoute.NAME,
          );
          Utils.showSuccessDialog('You Have Arrived');
          await Future.delayed(Duration(seconds: 2));
          BotToast.cleanAll();
        }
      },
    );
    await _directions.startNavigation(
      origin: mapbox.Location(
        name: "",
        latitude: myLocation.latitude,
        longitude: myLocation.longitude,
      ),
      destination: mapbox.Location(
        name: "",
        longitude: destination.longitude,
        latitude: destination.latitude,
      ),
      mode: mapbox.NavigationMode.drivingWithTraffic,
      simulateRoute: false,
      language: "English",
    );
    Navigator.popUntil(
      context,
      (route) => route.settings.name == OrderNavigationRoute.NAME,
    );
  }

  @override
  State<StatefulWidget> createState() {
    return OrderNavigationRouteState();
  }
}

class OrderNavigationRouteState extends State<OrderNavigationRoute> {
  final _solidController = SolidController();

  StreamSubscription<LocationData> locationSubscription;
  StreamSubscription<DocumentSnapshot> documentStream;
  // Future<Map<String, dynamic>> items;
  LatLng myLatLng;

  double _currentDistance;
  double _currentTimestamp;
  double _lastDistance;
  double _lastTimestamp;

  @override
  void initState() {
    super.initState();
    // if (!widget.data.containsKey('numberOfSleevesNeeded') ||
    //     widget.data['numberOfSleevesNeeded'] == null) {
    //   items = widget.getItems(widget.data);
    // }
    myLatLng = Utils.getLastKnowLocation();
    if (!widget.alreadyAccepted) {
      documentStream = Firestore.instance
          .collection('postedOrders')
          .document(widget.data['orderId'])
          .snapshots()
          .listen((data) async {
        if (!data.exists) {
          documentStream?.cancel();
          Navigator.popUntil(context, ModalRoute.withName(MyApp.driverHome));
          Utils.showInfoDialog('Order has picked by another driver');
        }
        String uid = (await FirebaseAuth.instance.currentUser()).uid;
        if ((data.data['status'] as String).toLowerCase() == 'accepted' &&
            data.data['driverId'] != uid) {
          documentStream?.cancel();
          Navigator.popUntil(context, ModalRoute.withName(MyApp.driverHome));
          Utils.showInfoDialog('Order has picked by another driver');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_Popups._key?.currentState?.isOrderConfirmationVisible ?? false) {
          Navigator.pop(context);
          return false;
        }
        if (_Body._key?.currentState?.isOrderCompleteDialogueVisible ?? false) {
          _Body._key?.currentState?.hideDeliverDonePopup();
          _MyAppBar?._key?.currentState?.enableButton();
          return false;
        }
        if (_Body?._key?.currentState?.isCancelDialogVisible ?? false) {
          _Body?._key?.currentState?.hideCancelPopup();
          _MyAppBar?._key?.currentState?.enableButton();
          return false;
        } else {
          _Body?._key?.currentState?.showCancelPopup();
          _MyAppBar?._key?.currentState?.disableButton();
          return false;
        }
      },
      child: Scaffold(
        appBar: _MyAppBar(
          title:
              "R${(widget.data['price'] as num).toDouble().toStringAsFixed(2)}",
          onDonePressed: () {
            _Body._key?.currentState?.widget?.showDeliveryCompleteDialogue();
          },
        ),
        body: Stack(
          children: <Widget>[
            _Body(
              alreadyAccepted: widget.alreadyAccepted,
              onCancelPopupConfirm: () async {
                Driver driver = Session.data['driver'];
                await locationSubscription?.cancel();
                locationSubscription = null;
                widget.data.update(('status'), (old) => 'Pending',
                    ifAbsent: () => 'Accepted');
                widget.data.update(
                  ('driverId'),
                  (old) => FieldValue.delete(),
                  ifAbsent: () => FieldValue.delete(),
                );
                widget.data.update(
                  ('driverName'),
                  (old) => FieldValue.delete(),
                  ifAbsent: () => FieldValue.delete(),
                );
                widget.data.update(
                  ('driverImage'),
                  (old) => FieldValue.delete(),
                  ifAbsent: () => FieldValue.delete(),
                );

                int millisecondsAcceptedOn = widget.data['acceptedOn'];
                int canceledAt = DateTime.now().millisecondsSinceEpoch;
                int timeDifference = canceledAt - millisecondsAcceptedOn;
                double canceledAfterMinutes = timeDifference / 1000 / 60;

                final batch = Firestore.instance.batch();

                final postedOrderRef = Firestore.instance
                    .collection('postedOrders')
                    .document(widget.data['orderId']);

                final driverAcceptedOrderRef = Firestore.instance
                    .collection('drivers')
                    .document(driver.driverId)
                    .collection('acceptedOrders')
                    .document(widget.data['orderId']);

                final userOrderRef = Firestore.instance
                    .collection('users')
                    .document(widget.data['userId'])
                    .collection('orders')
                    .document(widget.data['orderId']);

                final canceledOrderRef = Firestore.instance
                    .collection("drivers")
                    .document(driver.driverId)
                    .collection('cancelledOrders')
                    .document(widget.data['orderId']);

                batch.setData(postedOrderRef, widget.data, merge: true);
                batch.delete(driverAcceptedOrderRef);
                batch.setData(
                  canceledOrderRef,
                  {
                    '${DateTime.now().millisecondsSinceEpoch}': {
                      'orderId': widget.data['orderId'],
                      'acceptedOn': millisecondsAcceptedOn,
                      'canceledAt': canceledAt,
                      'canceledAfterMinutes': canceledAfterMinutes,
                    }
                  },
                );
                batch.setData(
                  userOrderRef,
                  widget.data,
                  merge: true,
                );
                batch.commit();
              },
              onOrderComplete: () async {
                String driverId = await FirebaseAuth.instance
                    .currentUser()
                    .then((user) => user.uid);
                DateTime now = DateTime.now();
                // Firestore.instance
                //     .collection("verificationCodes")
                //     .document(data['orderId'])
                //     .delete();
                await locationSubscription?.cancel();
                locationSubscription = null;
                final batch = Firestore.instance.batch();
                var userToken = Firestore.instance
                    .collection('users')
                    .document(widget.data['userId'])
                    .collection('tokens')
                    .getDocuments();
                final userOrderRef = Firestore.instance
                    .collection('users')
                    .document(widget.data['userId'])
                    .collection('orders')
                    .document(widget.data['orderId']);

                final userNotificationRef = Firestore.instance
                    .collection('users')
                    .document(widget.data['userId'])
                    .collection('notifications')
                    .document(widget.data['orderId']);

                final orderRef = Firestore.instance
                    .collection('postedOrders')
                    .document(widget.data['orderId']);

                final acceptedOrderRef = Firestore.instance
                    .collection('drivers')
                    .document(driverId)
                    .collection('acceptedOrders')
                    .document(
                      widget.data['orderId'],
                    );

                final driverCompleteOrderRef = Firestore.instance
                    .collection('drivers')
                    .document(driverId)
                    .collection('orders')
                    .document(widget.data['orderId']);

                batch.setData(
                  userOrderRef,
                  {
                    'status': 'Delivered',
                    'deliveryDate': now.millisecondsSinceEpoch,
                  },
                  merge: true,
                );
                batch.setData(
                  userNotificationRef,
                  {
                    'title': 'Order Delivered',
                    'message':
                        '${widget.data['driverName']} has delivered your order.',
                    'seen': false,
                    'rated': false,
                    'date': now.millisecondsSinceEpoch,
                    'driverId': driverId,
                    'orderId': widget.data['orderId'],
                    'userId': widget.data['userId'],
                  },
                );
                batch.setData(
                  driverCompleteOrderRef,
                  widget.data
                    ..update(
                      'status',
                      (old) => 'Delivered',
                      ifAbsent: () => 'Delivered',
                    )
                    ..update(
                      'deliveryDate',
                      (old) => now.millisecondsSinceEpoch,
                      ifAbsent: () => now.millisecondsSinceEpoch,
                    ),
                );
                batch.delete(acceptedOrderRef);
                batch.delete(orderRef);

                if (widget.data['numberOfBoxes'] == null) {
                  List<Map<String, dynamic>> itemDetails =
                      (await ReceiveItSolidBottomSheet
                          ._key.currentState.items)['itemDetails'];
                  Map<String, Map<String, dynamic>> itemsData =
                      Map<String, Map<String, dynamic>>.from(
                          widget.data['itemsData']);
                  int index = 0;
                  final keys = itemsData.keys;
                  for (String itemKey in keys) {
                    Map<String, dynamic> item = (await Firestore.instance
                            .collection('items')
                            .document(itemKey)
                            .get())
                        .data;
                    LatLng latLng =
                        Utils.latLngFromString(widget.data['destination']);
                    String address =
                        (await Geocoder.google(await Utils.getAPIKey())
                                .findAddressesFromCoordinates(Coordinates(
                                    latLng.latitude, latLng.longitude)))[0]
                            .addressLine;
                    var storeItemRef = Firestore.instance
                        .collection('stores')
                        .document(item['storeId'])
                        .collection('orderedItems')
                        .document(item['itemId']);

                    batch.setData(
                      storeItemRef,
                      {
                        widget.data['orderId']: {
                          'orderedBy': widget.data['userId'],
                          'dateOrdered': widget.data['date'],
                          'dateDelivered': now.millisecondsSinceEpoch,
                          'deliveredTo': (widget.data['house'] == null ||
                                      widget.data['house'] == ''
                                  ? ''
                                  : widget.data['house'] + ', ') +
                              address,
                          'quantity': itemsData[itemKey]['quantity'],
                          'flavour': itemsData[itemKey]['flavour'],
                          'userEmail': widget.data['email'],
                          'price': itemDetails[index++]['price'],
                        },
                      },
                      merge: true,
                    );
                  }
                }
                await batch.commit();
                final snapshot = await userToken;
                final _fcmServerKey = await Utils.getFCMServerKey();
                final deviceTokens = <String>[];
                snapshot.documents.forEach((document) {
                  deviceTokens.add(document.documentID);
                });
                await http.post(
                  'https://fcm.googleapis.com/fcm/send',
                  headers: <String, String>{
                    'Content-Type': 'application/json',
                    'Authorization': 'key=$_fcmServerKey',
                  },
                  body: jsonEncode(
                    <String, dynamic>{
                      'notification': <String, dynamic>{
                        'body':
                            '${widget.data['driverName']} has delivered your order.',
                        'title': 'Order Delivered'
                      },
                      'priority': 'high',
                      'data': <String, dynamic>{
                        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                        'orderId': '${widget.data['orderId']}',
                        'status': 'delivered',
                        'driverId': widget.data['driverId'],
                        'userId': widget.data['userId'],
                      },
                      'registration_ids': deviceTokens,
                    },
                  ),
                );
              },
              verificationCode: widget.verificationCode,
              onOrderConfirmed: () async {
                // Utils.showLoadingDialog(context);
                Driver driver = Session.data['driver'];
                _MyAppBar._key?.currentState?.showButton();
                if (!widget.alreadyAccepted) {
                  await Firestore.instance.runTransaction((trx) async {
                    DocumentReference ref = Firestore.instance
                        .collection('postedOrders')
                        .document(widget.data['orderId']);
                    DocumentReference userOrderRef = Firestore.instance
                        .collection('users')
                        .document(widget.data['userId'])
                        .collection('orders')
                        .document(widget.data['orderId']);
                    final snapshot = await trx.get(ref);
                    Map<String, dynamic> data =
                        Map<String, dynamic>.from(snapshot.data);
                    data.update('orderId', (old) => widget.data['orderId'],
                        ifAbsent: () => widget.data['orderId']);
                    data.update('status', (old) => 'Accepted',
                        ifAbsent: () => 'Accepted');
                    data.update(('driverId'), (old) => driver.driverId,
                        ifAbsent: () => driver.driverId);
                    data.update(('driverName'), (old) => driver.fullName,
                        ifAbsent: () => driver.fullName);
                    data.update(('driverImage'), (old) => driver.profilePicture,
                        ifAbsent: () => driver.profilePicture);
                    data.update(
                        ('driverPhoneNumber'), (old) => driver.phoneNumber,
                        ifAbsent: () => driver.phoneNumber);
                    data.update(
                      ('driverLicencePlateNumber'),
                      (old) => driver.licencePlateNumber,
                      ifAbsent: () => driver.licencePlateNumber,
                    );

                    data.update(
                      'acceptedOn',
                      (old) => DateTime.now().millisecondsSinceEpoch,
                      ifAbsent: () => DateTime.now().millisecondsSinceEpoch,
                    );
                    widget.data.clear();
                    widget.data.addAll(data);
                    try {
                      print(
                          'orderId is going to be when trx set: ${widget.data['orderId']}');
                      final postedOrderUpdate = trx.set(ref, data);
                      final userOrderUpdate = trx.set(userOrderRef, data);
                      await userOrderUpdate;
                      await postedOrderUpdate;
                    } catch (ex) {
                      print(ex);
                      Navigator.pop(context);
                      Utils.showInfoDialog(
                          'The Order has already picked by other driver');
                      documentStream.cancel();
                    }
                  });
                  documentStream.cancel();
                  final batch = Firestore.instance.batch();
                  final acceptedOrderRef = Firestore.instance
                      .collection('drivers')
                      .document(driver.driverId)
                      .collection('acceptedOrders')
                      .document(widget.data['orderId']);
                  final postedOrderRef = Firestore.instance
                      .collection('postedOrders')
                      .document(widget.data['orderId']);
                  batch.setData(acceptedOrderRef, widget.data);
                  batch.delete(postedOrderRef);
                  batch.commit();
                  // .setData(widget.data);

                  // widget.data.update(('status'), (old) => 'Accepted',
                  //     ifAbsent: () => 'Accepted');
                }
                Location location = Location();
                await location.changeSettings(distanceFilter: 50);
                // locationSubscription = location.onLocationChanged();
                // Navigator.popUntil(
                //     context,
                //     (route) =>
                //         route.settings.name == OrderNavigationRoute.NAME);
                locationSubscription =
                    location.onLocationChanged().listen((locationData) {
                  myLatLng =
                      LatLng(locationData.latitude, locationData.longitude);

                  _lastDistance = _currentDistance;
                  _lastTimestamp = _currentTimestamp;
                  _currentDistance = Utils.calculateDistance(
                    Utils.latLngFromString(widget.data['destination']),
                    myLatLng,
                  );
                  _currentTimestamp =
                      DateTime.now().millisecondsSinceEpoch.toDouble();

                  Map<String, dynamic> dataToUpload = {
                    'lastDistance': _lastDistance,
                    'lastTimestamp': _lastTimestamp,
                    'currentDistance': _currentDistance,
                    'currentTimestamp': _currentTimestamp,
                    'driverLatLng':
                        '${locationData.latitude},${locationData.longitude}',
                  };

                  var batch = Firestore.instance.batch();

                  var driverRef = Firestore.instance
                      .collection('drivers')
                      .document(driver.driverId)
                      .collection('acceptedOrders')
                      .document(widget.data['orderId']);
                  var userRef = Firestore.instance
                      .collection('users')
                      .document(widget.data['userId'])
                      .collection('orders')
                      .document(widget.data['orderId']);

                  batch.setData(
                    driverRef,
                    dataToUpload,
                    merge: true,
                  );
                  batch.setData(
                    userRef,
                    dataToUpload,
                    merge: true,
                  );
                  batch.commit();
                });
                // await Firestore.instance
                //     .collection('postedOrders')
                //     .document(widget.data['orderId'])
                //     .setData(
                //       widget.data,
                //       merge: true,
                //     );
              },
              onVerifyPopupCancel: () {
                _MyAppBar._key?.currentState?.enableButton();
              },
              onCancelPopupCancel: () {
                _MyAppBar._key?.currentState?.enableButton();
              },
              data: widget.data,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _Body?._key?.currentState?.widget?.centerCamera();
            _solidController.hide();
          },
          child: Icon(Icons.my_location),
        ),
        bottomSheet: (!widget.data.containsKey('numberOfSleevesNeeded') ||
                widget.data['numberOfSleevesNeeded'] == null)
            ? ReceiveItSolidBottomSheet(
                data: widget.data,
                animateToLatLng: (latlng) =>
                    _Body?._key?.currentState?.widget?.animateToLatLng(latlng),
              )
            : SennitSolidBottomSheet(
                data: widget.data,
                onSelectItem: (latlng) {
                  _Body._key?.currentState?.widget?.animateToLatLng(latlng);
                },
              ),
      ),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    await locationSubscription?.cancel();
    documentStream?.cancel();
  }
}

class ReceiveItSolidBottomSheet extends StatefulWidget {
  // final Function(LatLng) onSelectItem;
  final data;
  final Function(LatLng) animateToLatLng;
  static GlobalKey<ReceiveItSolidBottomSheetState> _key =
      GlobalKey<ReceiveItSolidBottomSheetState>();

  ReceiveItSolidBottomSheet({
    // @required key,
    @required this.data,
    this.animateToLatLng,
  }) : super(key: _key);

  // factory ReceiveItSolidBottomSheet({
  //   data,
  //   animateToLatLng,
  // }) {
  //   _key = GlobalKey<ReceiveItSolidBottomSheetState>();
  //   return ReceiveItSolidBottomSheet._(data: data, key: _key);
  // }

  @override
  State<StatefulWidget> createState() {
    return ReceiveItSolidBottomSheetState();
  }

  show() {
    _key?.currentState?._solidController?.show();
  }

  hide() {
    _key?.currentState?._solidController?.hide();
  }
}

class ReceiveItSolidBottomSheetState extends State<ReceiveItSolidBottomSheet> {
  bool isShown = false;
  // final BottomBarIcon _icon = BottomBarIcon();
  Future<Map<String, dynamic>> items;
  var _solidController = SolidController();

  @override
  void dispose() {
    _solidController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> getItems(data) async {
    LatLng destination = Utils.latLngFromString(data['destination']);
    Map<String, Map<String, dynamic>> itemsData =
        Map<String, Map<String, dynamic>>.from(data['itemsData']);
    List<Map<String, dynamic>> itemDetails = [];
    Map<String, dynamic> finalResult = {};
    final keys = itemsData.keys;
    for (String itemKey in keys) {
      final result =
          await Firestore.instance.collection('items').document(itemKey).get();
      // LatLng latlng = Utils.latLngFromString(result.data['latlng']);
      // Address address = (await Geocoder.google(await Utils.getAPIKey())
      //     .findAddressesFromCoordinates(
      //         Coordinates(latlng.latitude, latlng.longitude)))[0];
      // result.data.putIfAbsent('address', () => result.data['storeAddress']);
      itemDetails.add(result.data);
    }

    Address address = (await Geocoder.google(await Utils.getAPIKey())
        .findAddressesFromCoordinates(
            Coordinates(destination.latitude, destination.longitude)))[0];
    // itemDetails.add({'destination' : address.addressLine});
    finalResult.putIfAbsent('destination', () {
      return address;
    });
    finalResult.putIfAbsent('destinationLatLng', () {
      return destination;
    });

    finalResult.putIfAbsent('itemDetails', () {
      return itemDetails;
    });

    return finalResult;
  }

  @override
  void initState() {
    super.initState();
    items = getItems(widget.data);
  }

  @override
  Widget build(BuildContext context) {
    return SolidBottomSheet(
      controller: _solidController..hide(),
      toggleVisibilityOnTap: true,
      onShow: () async {
        BottomBarIcon._key?.currentState?.setIconState(true);
      },
      onHide: () async {
        BottomBarIcon._key?.currentState?.setIconState(false);
      },
      // enableDrag: true,
      // backgroundColor: Color.fromARGB(0, 0, 0, 0 ),
      maxHeight: 500,
      elevation: 8.0,
      draggableBody: true,
      headerBar: InkWell(
        onTap: () {
          if (_solidController.isOpened ?? false) {
            _solidController?.hide();
          } else {
            _solidController?.show();
          }
        },
        child: Container(
          height: 40,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
          ),
          child: BottomBarIcon(),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
          future: items,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.data == null) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 10),
                  Text(
                    'OrderId: ${widget.data['shortId']}',
                    style: Theme.of(context).textTheme.subtitle1,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Container(
                    color: Theme.of(context).primaryColor,
                    padding: EdgeInsets.all(6),
                    child: Text(
                      ' P i c k u p ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    // color: Colors.black,
                    // width: MediaQuery.of(context).size.width,
                    height: 200,
                    child: ListView.builder(
                      // padding: EdgeInsets.only(right: 20),
                      scrollDirection: Axis.horizontal,
                      // dragStartBehavior: DragStartBehavior.start,
                      physics: BouncingScrollPhysics(),
                      itemCount: snapshot.data['itemDetails'].length,
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Card(
                              elevation: 8,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: InkWell(
                                  splashColor: Theme.of(context)
                                      .primaryColor
                                      .withAlpha(190),
                                  onTap: () async {
                                    widget.animateToLatLng(
                                      Utils.latLngFromString(
                                        snapshot.data['itemDetails'][index]
                                            ['latlng'],
                                      ),
                                    );
                                    _solidController.hide();
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            color: Colors.black,
                                            child: Image.network(
                                              '${snapshot.data['itemDetails'][index]['images'][0]}',
                                              height: 100,
                                              width: 100,
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Container(
                                            width: 150,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                  snapshot.data['itemDetails']
                                                      [index]['itemName'],
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle1,
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                    '${snapshot.data['itemDetails'][index]['storeAddress']}'),
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                    "Price: R${(snapshot.data['itemDetails'][index]['price'] as num).toDouble().toStringAsFixed(2)} x ${widget.data['itemsData'][snapshot.data['itemDetails'][index]['itemId']]['quantity']}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                        ],
                                      ),
                                      InkWell(
                                        splashColor: Theme.of(context)
                                            .primaryColor
                                            .withAlpha(190),
                                        onTap: () async {
                                          LatLng latlng =
                                              Utils.latLngFromString(
                                            snapshot.data['itemDetails'][index]
                                                ['latlng'],
                                          );
                                          print('Navigating to $latlng');
                                          OrderNavigationRoute._startNavigation(
                                            context,
                                            latlng,
                                            Utils.getLastKnowLocation(),
                                          );
                                        },
                                        child: Container(
                                          width: 270.0,
                                          color: Theme.of(context).primaryColor,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Navigate Here!',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // RaisedButton(
                            //   onPressed: () {},
                            //   child: Text('Open in Map',
                            //       style: TextStyle(color: Colors.white)),
                            // ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: InkWell(
                        splashColor:
                            Theme.of(context).primaryColor.withAlpha(190),
                        onTap: () {
                          LatLng latLng = snapshot.data['destinationLatLng'];
                          widget.animateToLatLng(latLng);
                          _solidController.hide();
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8.0),
                                    topRight: Radius.circular(8.0),
                                  ),
                                ),
                                color: Theme.of(context).primaryColor,
                              ),
                              padding: EdgeInsets.all(6),
                              child: Text(
                                ' D r o p o f f ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.location_on),
                                  Expanded(
                                    child: Text(
                                      '${(snapshot.data['destination'] as Address).addressLine}',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            InkWell(
                              splashColor:
                                  Theme.of(context).primaryColor.withAlpha(190),
                              onTap: () async {
                                print('Opened in maps');
                                LatLng latLng =
                                    snapshot.data['destinationLatLng'];
                                // MapsLauncher.launchCoordinates(
                                //   latLng.latitude,
                                //   latLng.longitude,
                                // );
                                OrderNavigationRoute._startNavigation(
                                  context,
                                  latLng,
                                  Utils.getLastKnowLocation(),
                                );
                              },
                              child: Container(
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(8.0),
                                      bottomRight: Radius.circular(8.0),
                                    ),
                                  ),
                                  color: Theme.of(context).primaryColor,
                                ),
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Navigate Here!',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class SennitSolidBottomSheet extends StatefulWidget {
  final Function(LatLng) onSelectItem;
  final data;
  static GlobalKey<SennitSolidBottomSheetState> _key =
      GlobalKey<SennitSolidBottomSheetState>();

  SennitSolidBottomSheet({
    // @required key,
    @required this.onSelectItem,
    @required this.data,
  }) : super(key: _key);

  // factory SennitSolidBottomSheet({
  //   @required onSelectItem,
  //   @required data,
  // }) {
  //   _key = GlobalKey<SennitSolidBottomSheetState>();

  //   return SennitSolidBottomSheet._(
  //     key: _key,
  //     data: data,
  //     onSelectItem: onSelectItem,
  //   );
  // }

  @override
  State<StatefulWidget> createState() {
    return SennitSolidBottomSheetState();
  }

  show() {
    _key?.currentState?._controller?.show();
  }

  hide() {
    _key?.currentState?._controller?.hide();
  }
}

class SennitSolidBottomSheetState extends State<SennitSolidBottomSheet> {
  bool isShown = false;
  var _controller = SolidController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SolidBottomSheet(
      controller: _controller..hide(),
      onShow: () async {
        BottomBarIcon._key?.currentState?.setIconState(true);
        print(BottomBarIcon._key);
      },

      onHide: () async {
        BottomBarIcon._key?.currentState?.setIconState(false);
      },
      // enableDrag: true,
      // backgroundColor: Color.fromARGB(0, 0, 0, 0 ),
      maxHeight: 350,
      elevation: 8.0,
      draggableBody: true,
      headerBar: InkWell(
        onTap: () {
          if (_controller.isOpened ?? false) {
            _controller?.hide();
          } else {
            _controller?.show();
          }
        },
        child: Container(
          height: 40,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
          ),
          child: BottomBarIcon(),
        ),
      ),
      body: _OrderTile(
        onSelectItem: widget.onSelectItem,
        data: widget.data,
        // return Container(child: SizedBox(height: , child: Text(""),),);
      ),
    );
  }
}

class BottomBarIcon extends StatefulWidget {
  BottomBarIcon() : super(key: _key);
  static GlobalKey<_BottomBarIconState> _key = GlobalKey<_BottomBarIconState>();

  // BottomBarIcon() {
  //   // _key = GlobalKey<_BottomBarIconState>();
  //   BottomBarIcon._(key: _key);
  // }

  @override
  _BottomBarIconState createState() => _BottomBarIconState();

  // setIconState(bool isShown) {
  //   _key?.currentState?.isShown = isShown;
  //   _key?.currentState?.refresh();
  // }
}

class _BottomBarIconState extends State<BottomBarIcon> {
  bool isShown;
  void setIconState(bool isShown) {
    this.isShown = isShown;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    isShown = false;
  }

  // void toggle() {
  //   setState(() {
  //     isShown = !isShown;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        isShown ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
      ),
    );
  }
}

class _MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Function onDonePressed;
  static GlobalKey<_MyAppBarState> _key = GlobalKey<_MyAppBarState>();

  _MyAppBar({
    // @required key,
    this.title,
    this.onDonePressed,
  }) : super(key: _key);

  // factory _MyAppBar({
  //   title,
  //   onDonePressed,
  // }) {
  //   _key = _key = GlobalKey<_MyAppBarState>();
  //   return _MyAppBar._(
  //     key: _key,
  //     title: title,
  //     onDonePressed: onDonePressed,
  //   );
  // }

  // void showButton() {
  //   _key?.currentState?.showButton();
  // }

  // void enableButton() {
  //   _key?.currentState?.enableButton();
  // }

  // void disableButton() {
  //   _key?.currentState?.disableButton();
  // }

  // void refresh() {
  //   _key?.currentState?.refresh();
  // }

  @override
  State<StatefulWidget> createState() {
    return _MyAppBarState();
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _MyAppBarState extends State<_MyAppBar> {
  bool isButtonVisible = false;
  bool isButtonEnabled = true;

  refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  showButton() {
    isButtonVisible = true;
    setState(() {});
  }

  enableButton() {
    isButtonEnabled = true;
    setState(() {});
  }

  disableButton() {
    isButtonEnabled = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(widget.title),
      actions: <Widget>[
        !isButtonVisible
            ? Opacity(
                opacity: 0,
              )
            : FlatButton(
                child: Text('Done'),
                onPressed: !isButtonEnabled
                    ? null
                    : () {
                        isButtonEnabled = false;
                        widget.onDonePressed();
                        setState(() {});
                      },
              ),
      ],
    );
  }
}

class _Body extends StatefulWidget {
  final Function onOrderConfirmed;
  final Function onCancelPopupCancel;
  final Function onVerifyPopupCancel;
  final Map<String, dynamic> data;
  final verificationCode;
  final Function onOrderComplete;
  final Function onCancelPopupConfirm;
  static GlobalKey<_BodyState> _key = GlobalKey<_BodyState>();
  final bool alreadyAccepted;

  _Body({
    // @required key,
    @required this.alreadyAccepted,
    @required this.onOrderComplete,
    @required this.data,
    @required this.onOrderConfirmed,
    @required this.onCancelPopupCancel,
    @required this.onVerifyPopupCancel,
    @required this.verificationCode,
    @required this.onCancelPopupConfirm,
  }) : super(key: _key);

  // factory _Body({
  //   @required onOrderComplete,
  //   @required data,
  //   @required onOrderConfirmed,
  //   @required onCancelPopupCancel,
  //   @required onVerifyPopupCancel,
  //   @required verificationCode,
  //   @required onCancelPopupConfirm,
  //   @required alreadyAccepted,
  // }) {
  //   _key = GlobalKey<_BodyState>();
  //   return _Body._(
  //     alreadyAccepted: alreadyAccepted,
  //     key: _key,
  //     onOrderComplete: onOrderComplete,
  //     data: data,
  //     onOrderConfirmed: onOrderConfirmed,
  //     onCancelPopupCancel: onCancelPopupCancel,
  //     onVerifyPopupCancel: onVerifyPopupCancel,
  //     verificationCode: verificationCode,
  //     onCancelPopupConfirm: onCancelPopupConfirm,
  //   );
  // }

  @override
  State<StatefulWidget> createState() {
    return _BodyState();
  }

  // bool isOrderConfirmationPopupShown() {
  //   return _key?.currentState?.isOrderConfirmationVisible;
  // }

  bool isCancelPopupShown() {
    return _key?.currentState?.isCancelDialogVisible;
  }

  bool isDeliveryCompletePopupShown() {
    return _key?.currentState?.isOrderCompleteDialogueVisible;
  }

  showCancelDialogue() {
    _key?.currentState?.showCancelPopup();
  }

  showDeliveryCompleteDialogue() {
    _key?.currentState?.showDeliveryDonePopup();
  }

  hideCancelDialogue() {
    _key?.currentState?.hideCancelPopup();
  }

  hideDeliveryCompleteDialogue() {
    _key?.currentState?.hideDeliverDonePopup();
  }

  void centerCamera() {
    (_MapWidget._key?.currentWidget as _MapWidget)?.centerCamera();
  }

  void animateToLatLng(LatLng coordinates) {
    (_MapWidget._key?.currentWidget as _MapWidget)?.animateTo(coordinates);
  }
}

class _BodyState extends State<_Body> {
  // _Popups _popups;
  // _SennitMapWidget mapWidget;

  bool get isCancelDialogVisible =>
      _Popups._key?.currentState?.isCancelDialogVisible;

  bool get isOrderCompleteDialogueVisible =>
      _Popups._key?.currentState?.isOrderCompleteDialogueVisible;

  // bool get isOrderConfirmationVisible =>
  //     _Popups._key?.currentState?.isOrderConfirmationVisible;

  @override
  void dispose() {
    super.dispose();
  }

  showCancelPopup() {
    _Popups._key?.currentState?.showCancelPopup();

    // setState(() {});
  }

  hideCancelPopup() {
    // isCancelDialogVisible = false;
    _Popups._key?.currentState?.hideCancelPopup();
    // setState(() {});
  }

  showDeliveryDonePopup() {
    // isOrderCompleteDialogueVisible = true;
    _Popups._key?.currentState?.showOrderCompletePopup();
    // setState(() {});
  }

  hideDeliverDonePopup() {
    _Popups._key?.currentState?.hideOrderCompletePopup();
    // setState(() {});
  }

  Widget getMap() {
    return _MapWidget(
      dropOff: (widget.data.containsKey('numberOfSleevesNeeded') &&
              widget.data['numberOfSleevesNeeded'] != null)
          ? Utils.latLngFromString(widget.data['dropOffLatLng'])
          : Utils.latLngFromString(widget.data['destination']),
      pickups: (!widget.data.containsKey('numberOfSleevesNeeded') ||
              widget.data['numberOfSleevesNeeded'] == null)
          ? (widget.data['pickups'] as List)
              .map((x) => Utils.latLngFromString(x))
              .toList()
          : [
              Utils.latLngFromString(widget.data['pickUpLatLng']),
            ],
    );
  }

  @override
  void initState() {
    super.initState();
  }

  Widget getBody() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              getMap(),
              _Popups(
                alreadyAccepted: widget.alreadyAccepted,
                onOrderComplete: widget.onOrderComplete,
                verificationCode: widget.verificationCode,
                onOrderConfirmed: widget.onOrderConfirmed,
                onCancelPopupCancel: widget.onCancelPopupCancel,
                onOrderCompletePopupCancel: widget.onVerifyPopupCancel,
                onCancelPopupConfirm: widget.onCancelPopupConfirm,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return getBody();
  }
}

class _MapWidget extends StatefulWidget {
  final List<LatLng> pickups;
  final LatLng dropOff;
  static GlobalKey<_MapState> _key = GlobalKey<_MapState>();

  _MapWidget({
    // @required GlobalKey<_MapState> key,
    @required this.pickups,
    @required this.dropOff,
  }) : super(key: _key);

  // factory _MapWidget({@required pickups, @required dropOff}) {
  //   _key = GlobalKey<_MapState>();
  //   return _MapWidget._(
  //     pickups: pickups,
  //     dropOff: dropOff,
  //     key: _key,
  //   );
  // }

  @override
  State<StatefulWidget> createState() {
    return _MapState();
  }

  void animateTo(LatLng position) {
    _key?.currentState?._controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15.0),
      ),
    );
  }

  void centerCamera() async {
    LatLng myLocation = await Utils.getMyLocation();
    _key?.currentState?._controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: myLocation, zoom: 15.0),
      ),
    );
  }
}

class _MapState extends State<_MapWidget> {
  GoogleMap map;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  GoogleMapController _controller;

  @override
  void initState() {
    super.initState();
  }

  Future<void> initialize() async {
    final myLocation = await Utils.getMyLocation();
    int index = -1;
    List<LatLng> tempPickups = [];
    for (LatLng pickup in widget.pickups) {
      if (!tempPickups.contains(pickup)) {
        index++;
        Marker markerPickup = Marker(
          markerId: MarkerId("marker$index"),
          infoWindow:
              InfoWindow(title: "Pick Up", snippet: "Click to Navigate here!"),
          position: pickup,
          onTap: () {},
          flat: false,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueMagenta),
        );
        tempPickups.add(pickup);
        markers.add(markerPickup);
      }
    }

    Marker markerDropOff = Marker(
      markerId: MarkerId("markerDrop"),
      infoWindow:
          InfoWindow(title: "Drop Off", snippet: "Click to Navigate here!"),
      position: widget.dropOff,
      icon: await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(
          size: Size(
            100,
            100,
          ),
        ),
        'assets/images/flag.png',
      ),
    );

    markers.add(markerDropOff);

    map = GoogleMap(
      compassEnabled: true,
      initialCameraPosition: CameraPosition(
          target: myLocation ?? LatLng(0, 0), zoom: 14, tilt: 30),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      buildingsEnabled: true,
      markers: markers,
      polylines: polylines,
      mapType: MapType.normal,
      zoomGesturesEnabled: true,
      mapToolbarEnabled: false,
      polygons: Set(),
      circles: Set(),
      onMapCreated: (controller) {
        _controller = controller;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Stack(
          children: [
            map,
          ],
        );
      },
    );
  }
}

class _Popups extends StatefulWidget {
  static var popUpHeight = 220.0;
  static var popUpWidth = 300.0;

  final Function onOrderConfirmed;
  final Function onCancelPopupCancel;
  final Function onOrderCompletePopupCancel;
  final verificationCode;
  final Function onOrderComplete;
  final Function onCancelPopupConfirm;
  final bool alreadyAccepted;
  static GlobalKey<_PopupsState> _key = GlobalKey<_PopupsState>();

  _Popups({
    // GlobalKey<_PopupsState> key,
    @required this.alreadyAccepted,
    @required this.onOrderComplete,
    @required this.onOrderConfirmed,
    @required this.onCancelPopupCancel,
    @required this.onCancelPopupConfirm,
    @required this.onOrderCompletePopupCancel,
    @required this.verificationCode,
  }) : super(key: _key);

  // factory _Popups({
  //   @required onOrderComplete,
  //   @required onOrderConfirmed,
  //   @required onCancelPopupCancel,
  //   @required onCancelPopupConfirm,
  //   @required onOrderCompletePopupCancel,
  //   @required verificationCode,
  //   @required alreadyAccepted,
  // }) {
  //   _key = GlobalKey<_PopupsState>();
  //   return _Popups._(
  //     alreadyAccepted: alreadyAccepted,
  //     key: _key,
  //     onCancelPopupCancel: onCancelPopupCancel,
  //     onCancelPopupConfirm: onCancelPopupConfirm,
  //     onOrderComplete: onOrderComplete,
  //     onOrderCompletePopupCancel: onOrderCompletePopupCancel,
  //     onOrderConfirmed: onOrderConfirmed,
  //     verificationCode: verificationCode,
  //   );
  // }

  @override
  State<StatefulWidget> createState() {
    return _PopupsState();
  }
}

class _PopupsState extends State<_Popups> with WidgetsBindingObserver {
  _OrderConfirmation _orderConfirmationPopup;
  _DeliveryDonePopUp _deliveryDonePopUp;
  _CancelOrderPopUp _cancelOrderPopUp;

  bool isOrderConfirmationVisible = true;
  bool isOrderCompleteDialogueVisible = false;
  bool isCancelDialogVisible = false;

  showCancelPopup() {
    isCancelDialogVisible = true;
    setState(() {});
    // _cancelOrderPopUp?.show();
  }

  hideCancelPopup() {
    isCancelDialogVisible = false;
    setState(() {});
    // _cancelOrderPopUp?.hide();
  }

  showOrderCompletePopup() {
    isOrderCompleteDialogueVisible = true;
    setState(() {});
    // _deliveryDonePopUp?.show();
  }

  hideOrderCompletePopup() {
    isOrderCompleteDialogueVisible = false;
    // _deliveryDonePopUp.hide();
    setState(() {});
  }

  _onOrderAccept() async {
    if (!mounted) {
      WidgetsBinding.instance.addPostFrameCallback((duration) async {
        await widget.onOrderConfirmed();
        isOrderConfirmationVisible = false;
        setState(() {});
      });
    } else {
      await widget.onOrderConfirmed();
      isOrderConfirmationVisible = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!widget.alreadyAccepted) {
      _orderConfirmationPopup = _OrderConfirmation(
        onConfirm: _onOrderAccept,
        onExit: () {
          isOrderConfirmationVisible = false;
          Navigator.of(context).pop();
        },
      );
      // _onOrderAccept();
    } else {
      Future.delayed(Duration(seconds: 2), () {
        _onOrderAccept();
      });
    }
    _cancelOrderPopUp = _CancelOrderPopUp(
      onCancel: () {
        print('on Cancel Called');
        isCancelDialogVisible = false;
        widget.onCancelPopupCancel();
        setState(() {});
      },
      onConfirm: () async {
        print('on Confirm Called');
        await widget.onCancelPopupConfirm();
        isCancelDialogVisible = false;
      },
    );
    _deliveryDonePopUp = _DeliveryDonePopUp(
      verificationCode: widget.verificationCode,
      onCancel: () {
        isOrderCompleteDialogueVisible = false;
        widget.onOrderCompletePopupCancel();
        setState(() {});
      },
      onConfirm: () async {
        isOrderCompleteDialogueVisible = false;
        Utils.showLoadingDialog(context);
        await widget.onOrderComplete();
        int count = 0;
        Navigator.popUntil(context, (route) => count++ > 1);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (!isOrderConfirmationVisible) {
          if (isCancelDialogVisible) {
            isCancelDialogVisible = false;
            setState(() {});
            widget.onCancelPopupCancel();
          } else if (isOrderCompleteDialogueVisible) {
            isOrderCompleteDialogueVisible = false;
            setState(() {});
            widget.onOrderCompletePopupCancel();
          }
        }
      },
      child: Container(
        // color: Colors.white,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: <Widget>[
            Center(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                child: _cancelOrderPopUp,
                width: isCancelDialogVisible ? _Popups.popUpWidth : 0,
                height: isCancelDialogVisible ? _Popups.popUpHeight : 0,
              ),
            ),
            Center(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                height:
                    isOrderCompleteDialogueVisible ? _Popups.popUpHeight : 0,
                width: isOrderCompleteDialogueVisible ? _Popups.popUpWidth : 0,
                child: _deliveryDonePopUp,
              ),
            ),
            widget.alreadyAccepted
                ? Opacity(
                    opacity: 0,
                  )
                : AnimatedPositioned(
                    duration: Duration(milliseconds: 500),
                    child: _orderConfirmationPopup,
                    left: 0,
                    right: 0,
                    bottom: isOrderConfirmationVisible
                        ? 60
                        : -1 * (_Popups.popUpHeight),
                  ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryDonePopUp extends StatefulWidget {
  // final width;
  // final height;
  final Function onCancel;
  final Function onConfirm;
  final String verificationCode;
  static GlobalKey<_DeliveryDonePopUpStateRevised> _key =
      GlobalKey<_DeliveryDonePopUpStateRevised>();
  _DeliveryDonePopUp({
    // @required key,
    @required this.onCancel,
    @required this.onConfirm,
    @required this.verificationCode,
  }) : super(key: _key); //@required this.width, @required this.height})

  // : super(key: key);

  // factory _DeliveryDonePopUp({
  //   @required onCancel,
  //   @required onConfirm,
  //   @required verificationCode,
  // }) {
  //   _key = GlobalKey<_DeliveryDonePopUpStateRevised>();
  //   return _DeliveryDonePopUp._(
  //       key: _key,
  //       onCancel: onCancel,
  //       onConfirm: onConfirm,
  //       verificationCode: verificationCode);
  // }

  @override
  State<StatefulWidget> createState() {
    return _DeliveryDonePopUpStateRevised();
  }

  void show() {
    // state.deliveryDonePopUpShown = true;
    // state.outerContainerShown = true;
    refresh();
  }

  void hide() {
    // state.deliveryDonePopUpShown = false;
    refresh();
  }

  void refresh() {
    // state.refresh();
  }
}

class _DeliveryDonePopUpStateRevised extends State<_DeliveryDonePopUp> {
  String confirmationKey = '';

  var _verificationCodeController = TextEditingController();

  var hasError = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(top: 8, bottom: 8, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 2,
            ),
            Text(
              'Confirmation Key',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(
              height: 3,
            ),
            Text(
              'Please Enter the Verification Key',
            ),
            SizedBox(
              height: 2,
            ),
            PinCodeTextField(
              length: 6,
              obsecureText: false,
              animationType: AnimationType.fade,
              shape: PinCodeFieldShape.box,
              animationDuration: Duration(milliseconds: 300),
              borderRadius: BorderRadius.circular(5),
              selectedColor: Theme.of(context).primaryColor,
              controller: _verificationCodeController,
              fieldHeight: 40,
              fieldWidth: 35,
              onChanged: (value) {
                confirmationKey = value;
                setState(() {});
              },
            ),
            SizedBox(
              height: 4,
            ),
            hasError
                ? Text(
                    'Invalid Code! Try Again',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(color: Colors.red),
                  )
                : Opacity(
                    opacity: 0,
                  ),
            RaisedButton(
              child: Text(
                'Verify',
                style: Theme.of(context).textTheme.button,
              ),
              onPressed: () async {
                String key = widget.verificationCode;
                if (confirmationKey == key) {
                  Utils.showSuccessDialog('Order Has been Delivered');
                  Future.delayed(Duration(seconds: 2)).then((a) {
                    BotToast.removeAll();
                  });
                  widget.onConfirm();
                } else {
                  hasError = true;
                  setState(() {
                    _verificationCodeController.clear();
                  });
                  // Utils.showSnackBarError(context, 'Invalid Verification Code');
                }
                // Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      // color: Colors.red,
      // width: widget.width,
      // height: widget.height,
    );
  }
}

class _CancelOrderPopUp extends StatefulWidget {
  // final width;
  // final height;

  final Function onConfirm;
  final Function onCancel;
  static GlobalKey<_CancelOrderPopUpStateRevised> _key =
      GlobalKey<_CancelOrderPopUpStateRevised>();

  _CancelOrderPopUp({
    @required this.onConfirm,
    @required this.onCancel,
  }) : super(key: _key); //@required this.width, @required this.height})

  // factory _CancelOrderPopUp({
  //   @required onConfirm,
  //   @required onCancel,
  // }) {
  //   _key = GlobalKey<_CancelOrderPopUpStateRevised>();
  //   return _CancelOrderPopUp._(
  //       key: _key, onConfirm: onConfirm, onCancel: onCancel);
  // }

  // : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CancelOrderPopUpStateRevised();
  }

  void show() {
    // state.cancelOrderConfirmationShown = true;
    refresh();
  }

  void hide() {
    // state.cancelOrderConfirmationShown = false;
    refresh();
  }

  void refresh() {
    // state.refresh();
  }
}

class _CancelOrderPopUpStateRevised extends State<_CancelOrderPopUp> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      // color: Colors.red,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: Center(
        child: Container(
          margin: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 8,
              ),
              Text(
                'Exit',
                style: Theme.of(context).textTheme.headline4,
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'Are you sure you wanna cancel the delivery? ',
                style: Theme.of(context).textTheme.subtitle2,
              ),
              SizedBox(
                height: 2,
              ),
              ButtonBar(
                alignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    elevation: 6,
                    color: Colors.white,
                    child: Text(
                      'Cancel',
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () {
                      widget.onCancel();
                    },
                  ),
                  RaisedButton(
                    elevation: 6,
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text(
                      'Confirm',
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () async {
                      Utils.showLoadingDialog(context);
                      await widget.onConfirm();
                      int count = 0;
                      Navigator.popUntil(context, (route) => count++ > 1);
                      // widget.parent.setState(() {});
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // width: widget.width,
      // height: widget.height,
    );
  }
}

class _OrderConfirmation extends StatefulWidget {
  final Function onConfirm;
  final Function onExit;
  static GlobalKey<_OrderConfirmationStateRevised> _key =
      GlobalKey<_OrderConfirmationStateRevised>();

  _OrderConfirmation({
    @required this.onConfirm,
    @required this.onExit,
  }) : super(key: _key);

  // factory _OrderConfirmation({
  //   @required onConfirm,
  //   @required onExit,
  // }) {
  //   _key = GlobalKey<_OrderConfirmationStateRevised>();
  //   return _OrderConfirmation._(
  //       key: _key, onConfirm: onConfirm, onExit: onExit);
  // }

  @override
  State<StatefulWidget> createState() {
    return _OrderConfirmationStateRevised();
  }

  // void show() {
  //   state.orderConfirmed = false;
  // }

  // void refresh() {
  //   state.refresh();
  // }

}

class _OrderConfirmationStateRevised extends State<_OrderConfirmation> {
  onPressAcceptOrder() async {
    Utils.showLoadingDialog(context);
    await widget.onConfirm();
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((_Body._key.currentWidget as _Body).data['driverId'] != null) {
        onPressAcceptOrder();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.blue,
      // width: MediaQuery.of(context).size.width,
      child: Card(
        margin: EdgeInsets.only(
          left: 30,
          right: 30,
          bottom: 10,
        ),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 16,
            ),
            Text(
              'Accept the order?',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Spacer(),
                Expanded(
                  flex: 4,
                  child: RaisedButton(
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.all(
                    //     Radius.circular(4),
                    //   ),
                    // ),
                    onPressed: () {
                      widget.onExit();
                    },
                    color: Colors.white,
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                Spacer(),
                Expanded(
                  flex: 4,
                  child: RaisedButton(
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.all(
                    //     Radius.circular(4),
                    //   ),
                    // ),
                    onPressed: () async {
                      await onPressAcceptOrder();
                    },
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      'Accept',
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final Location location = Location();
  final Function(LatLng) onSelectItem;

  _OrderTile({Key key, @required this.data, @required this.onSelectItem})
      : super(key: key) {
    location.changeSettings(
      accuracy: LocationAccuracy.NAVIGATION,
    );
  }

  double getDistanceFromYourLocation(LatLng source, LatLng destination) {
    return Utils.calculateDistance(source, destination);
  }

  _startNavigation(context, LatLng destination, LatLng myLocation) async {
    Utils.showLoadingDialog(context);
    // MapsLauncher.launchCoordinates(
    //     pickup.latitude, pickup.longitude);
    mapbox.MapboxNavigation _directions;
    // var _distanceRemaining;
    // var _durationRemaining;

    _directions = mapbox.MapboxNavigation(
      onRouteProgress: (arrived) async {
        // _distanceRemaining = await _directions.distanceRemaining;
        // _durationRemaining = await _directions.durationRemaining;
        // setState(() {
        //   _arrived = arrived;
        // });
        // if (arrived) {
        //   await _directions.finishNavigation();
        //   // Navigator.popUntil(
        //   //   context,
        //   //   (route) => route.settings.name == SennitOrderNavigationRoute.NAME,
        //   // );
        //   // Utils.showSuccessDialog('You Have Arrived');
        //   // await Future.delayed(Duration(seconds: 2));
        //   // BotToast.cleanAll();
        // }
      },
    );
    await _directions.startNavigation(
      origin: mapbox.Location(
        name: "",
        latitude: myLocation.latitude,
        longitude: myLocation.longitude,
      ),
      destination: mapbox.Location(
        name: "",
        longitude: destination.longitude,
        latitude: destination.latitude,
      ),
      mode: mapbox.NavigationMode.drivingWithTraffic,
      simulateRoute: true,
      language: "English",
    );
    // await Future.delayed(
    //   Duration(seconds: 2),
    // );
    Navigator.popUntil(
      context,
      (route) => route.settings.name == OrderNavigationRoute.NAME,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
      initialData: Utils.getLastKnowLocation(),
      stream: location.onLocationChanged(),
      builder: (context, snapshot) {
        LatLng myLocation = snapshot.connectionState == ConnectionState.waiting
            ? (snapshot.data is LatLng)
                ? snapshot.data
                : snapshot.data is Coordinates
                    ? LatLng(snapshot.data.latitude, snapshot.data.longitude)
                    : null
            : snapshot.connectionState == ConnectionState.active
                ? LatLng((snapshot.data as LocationData).latitude,
                    (snapshot.data as LocationData).longitude)
                : null;
        LatLng pickup = Utils.latLngFromString(data['pickUpLatLng']);
        LatLng destination = Utils.latLngFromString(data['dropOffLatLng']);

        return Card(
          margin: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 8,
              ),
              Text(
                'OrderId: ${data['shortId']}',
                style: Theme.of(context).textTheme.subtitle1,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Card(
                          elevation: 4.0,
                          child: InkWell(
                            splashColor:
                                Theme.of(context).primaryColor.withAlpha(190),
                            onTap: () async {
                              onSelectItem(pickup);
                            },
                            child: Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Container(
                                    decoration: ShapeDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            topRight: Radius.circular(4)),
                                      ),
                                    ),
                                    padding: EdgeInsets.all(4),
                                    child: Text(
                                      ' P i c k u p ',
                                      // textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('${data['pickUpAddress']}'),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  myLocation != null
                                      ? Container(
                                          child: Text.rich(
                                            TextSpan(
                                              text: 'Distance: ',
                                              children: [
                                                TextSpan(
                                                  text:
                                                      '${getDistanceFromYourLocation(myLocation, pickup).toStringAsFixed(1)} Km',
                                                  style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : Opacity(
                                          opacity: 0,
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          child: RaisedButton(
                            child: Text(
                              'Start Navigation',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              _startNavigation(
                                context,
                                pickup,
                                myLocation,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Card(
                          elevation: 4.0,
                          child: InkWell(
                            splashColor:
                                Theme.of(context).primaryColor.withAlpha(190),
                            onTap: () async {
                              onSelectItem(destination);
                            },
                            child: Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Container(
                                    decoration: ShapeDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            topRight: Radius.circular(4)),
                                      ),
                                    ),
                                    padding: EdgeInsets.all(4),
                                    child: Text(
                                      ' D r o p O f f ',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('${data['dropOffAddress']}'),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  myLocation != null
                                      ? Container(
                                          child: Text.rich(
                                            TextSpan(
                                              text: 'Distance: ',
                                              children: [
                                                TextSpan(
                                                    text:
                                                        '${getDistanceFromYourLocation(myLocation, destination).toStringAsFixed(1)} Km',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    )),
                                              ],
                                            ),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : Opacity(
                                          opacity: 0,
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          child: RaisedButton(
                            child: Text(
                              'Start Navigation',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              _startNavigation(
                                  context, destination, myLocation);
                            },
                            onLongPress: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '''${(data['numberOfBoxes'] == null || data['numberOfBoxes'] <= 0) ? '' : '${data['numberOfBoxes']} Box(s)'}
              ${(data['numberOfSleevesNeeded'] == null || data['numberOfSleevesNeeded'] <= 0) ? '' : '${(data['numberOfBoxes'] != null && data['numberOfBoxes'] > 0) ? ', ' : ''}${data['numberOfSleevesNeeded']} Sleeve(s)'}''',
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(fontSize: 18),
              ),
            ],
          ),
        );
      },
    );
  }
}
