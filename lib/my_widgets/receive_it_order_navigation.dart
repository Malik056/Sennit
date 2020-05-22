// import 'dart:async';
// import 'dart:convert';

// import 'package:bot_toast/bot_toast.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart'
//     as mapbox;
// import 'package:geocoder/geocoder.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:location/location.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
// import 'package:sennit/main.dart';
// import 'package:sennit/models/models.dart';
// import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

// // class SennitOrderRoute extends StatefulWidget {
// //   static var popUpHeight = 200.0;
// //   static var popUpWidth = 300.0;

// //   @override
// //   State<StatefulWidget> createState() {
// //     // return _SennitOrderRouteState();
// //   }
// // }

// class ReceiveItOrderNavigationRoute extends StatefulWidget {
//   static const NAME = "ReceiveItOrderNavigationRoute";
//   final Map<String, dynamic> data;
//   final String verificationCode;

//   void onDonePressed() {
//     _Body?._key?.currentState?.widget?.showDeliveryCompleteDialogue();
//   }

//   Future<Map<String, dynamic>> getItems(data) async {
//     LatLng destination = Utils.latLngFromString(data['destination']);
//     Map<String, double> itemsData = Map<String, double>.from(data['itemsData']);
//     List<Map<String, dynamic>> itemDetails = [];
//     Map<String, dynamic> result = {};
//     final keys = itemsData.keys;
//     for (String itemKey in keys) {
//       final result =
//           await Firestore.instance.collection('items').document(itemKey).get();
//       LatLng latlng = Utils.latLngFromString(result.data['latlng']);
//       Address address = (await Geocoder.google(await Utils.getAPIKey())
//           .findAddressesFromCoordinates(
//               Coordinates(latlng.latitude, latlng.longitude)))[0];
//       result.data.putIfAbsent('address', () => address.addressLine);
//       itemDetails.add(result.data);
//     }

//     Address address = (await Geocoder.google(await Utils.getAPIKey())
//         .findAddressesFromCoordinates(
//             Coordinates(destination.latitude, destination.longitude)))[0];
//     // itemDetails.add({'destination' : address.addressLine});
//     result.putIfAbsent('destination', () {
//       return address;
//     });
//     result.putIfAbsent('destinationLatLng', () {
//       return destination;
//     });

//     result.putIfAbsent('itemDetails', () {
//       return itemDetails;
//     });

//     return result;
//   }

//   static GlobalKey<ReceiveItOrderNavigationRouteState> _key =
//       GlobalKey<ReceiveItOrderNavigationRouteState>();
//   ReceiveItOrderNavigationRoute({
//     // @required this.body,
//     // @required this.myAppbar,
//     @required this.data,
//     @required this.verificationCode,
//   }) : super(key: _key);

//   static _startNavigation(
//       context, LatLng destination, LatLng myLocation) async {
//     Utils.showLoadingDialog(context);
//     // MapsLauncher.launchCoordinates(
//     //     pickup.latitude, pickup.longitude);
//     mapbox.MapboxNavigation _directions;
//     // var _distanceRemaining;
//     // var _durationRemaining;

//     _directions = mapbox.MapboxNavigation(
//       onRouteProgress: (arrived) async {
//         // _distanceRemaining = await _directions.distanceRemaining;
//         // _durationRemaining = await _directions.durationRemaining;
//         // setState(() {
//         //   _arrived = arrived;
//         // });
//         if (arrived) {
//           await _directions.finishNavigation();
//           Navigator.popUntil(
//             context,
//             (route) =>
//                 route.settings.name == ReceiveItOrderNavigationRoute.NAME,
//           );
//           Utils.showSuccessDialog('You Have Arrived');
//           await Future.delayed(Duration(seconds: 2));
//           BotToast.cleanAll();
//         }
//       },
//     );
//     await _directions.startNavigation(
//       origin: mapbox.Location(
//         name: "",
//         latitude: myLocation.latitude,
//         longitude: myLocation.longitude,
//       ),
//       destination: mapbox.Location(
//         name: "",
//         longitude: destination.longitude,
//         latitude: destination.latitude,
//       ),
//       mode: mapbox.NavigationMode.drivingWithTraffic,
//       simulateRoute: false,
//       language: "English",
//     );
//     Navigator.popUntil(
//       context,
//       (route) => route.settings.name == ReceiveItOrderNavigationRoute.NAME,
//     );
//   }

//   @override
//   State<StatefulWidget> createState() {
//     return ReceiveItOrderNavigationRouteState();
//   }
// }

// class ReceiveItOrderNavigationRouteState
//     extends State<ReceiveItOrderNavigationRoute> {
//   final _solidController = SolidController();

//   StreamSubscription<LocationData> locationSubscription;
//   StreamSubscription<DocumentSnapshot> documentStream;
//   Future<Map<String, dynamic>> items;
//   LatLng myLatLng;

//   double _currentDistance;
//   double _currentTimestamp;
//   double _lastDistance;
//   double _lastTimestamp;

//   @override
//   void initState() {
//     super.initState();
//     items = widget.getItems(widget.data);
//     myLatLng = Utils.getLastKnowLocation();
//     documentStream = Firestore.instance
//         .collection('postedOrders')
//         .document(widget.data['orderId'])
//         .snapshots()
//         .listen((data) async {
//       String uid = (await FirebaseAuth.instance.currentUser()).uid;
//       if ((data['status'] as String).toLowerCase() == 'accepted' &&
//           data['driverId'] != uid) {
//         Navigator.pop(context);
//         Utils.showInfoDialog('Order has picked by another driver');
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         if (_Body._key?.currentState?.isOrderConfirmationVisible ?? false) {
//           Navigator.pop(context);
//           return false;
//         }
//         if (_Body._key?.currentState?.isOrderCompleteDialogueVisible ?? false) {
//           _Body._key?.currentState?.hideDeliverDonePopup();
//           _MyAppBar?._key?.currentState?.enableButton();
//           return false;
//         }
//         if (_Body?._key?.currentState?.isCancelDialogVisible ?? false) {
//           _Body?._key?.currentState?.hideCancelPopup();
//           _MyAppBar?._key?.currentState?.enableButton();
//           return false;
//         } else {
//           _Body?._key?.currentState?.showCancelPopup();
//           _MyAppBar?._key?.currentState?.disableButton();
//           return false;
//         }
//       },
//       child: Scaffold(
//         appBar: _MyAppBar(
//           title:
//               "${(widget.data['price'] as num).toDouble().toStringAsFixed(2)}R",
//           onDonePressed: () {
//             _Body._key?.currentState?.widget?.showDeliveryCompleteDialogue();
//           },
//         ),
//         body: Stack(
//           children: <Widget>[
//             _Body(
//               onCancelPopupConfirm: () async {
//                 await locationSubscription?.cancel();
//                 locationSubscription = null;
//                 widget.data.update(('status'), (old) => 'Pending',
//                     ifAbsent: () => 'Accepted');
//                 widget.data.update(
//                   ('driverId'),
//                   (old) => FieldValue.delete(),
//                   ifAbsent: () => FieldValue.delete(),
//                 );
//                 widget.data.update(
//                   ('driverName'),
//                   (old) => FieldValue.delete(),
//                   ifAbsent: () => FieldValue.delete(),
//                 );
//                 widget.data.update(
//                   ('driverImage'),
//                   (old) => FieldValue.delete(),
//                   ifAbsent: () => FieldValue.delete(),
//                 );

//                 int millisecondsAcceptedOn = widget.data['acceptedOn'];
//                 int canceledAt = DateTime.now().millisecondsSinceEpoch;
//                 int timeDifference = canceledAt - millisecondsAcceptedOn;
//                 double canceledAfterMinutes = timeDifference / 1000 / 60;

//                 await Firestore.instance
//                     .collection('postedOrders')
//                     .document(widget.data['orderId'])
//                     .setData(
//                       widget.data,
//                       merge: true,
//                     );
//                 await Firestore.instance
//                     .collection('users')
//                     .document(widget.data['userId'])
//                     .collection('orders')
//                     .document(widget.data['orderId'])
//                     .setData(
//                       widget.data,
//                       merge: true,
//                     );
//                 await Firestore.instance
//                     .collection("canceledOrders")
//                     .document((Session.data['driver'] as Driver).driverId)
//                     .setData(
//                   {
//                     '${DateTime.now().millisecondsSinceEpoch}': {
//                       'orderId': widget.data['orderId'],
//                       'acceptedOn': millisecondsAcceptedOn,
//                       'canceledAt': canceledAt,
//                       'canceledAfterMinutes': canceledAfterMinutes,
//                     }
//                   },
//                 );
//               },
//               onOrderComplete: () async {
//                 String driverId = await FirebaseAuth.instance
//                     .currentUser()
//                     .then((user) => user.uid);
//                 DateTime now = DateTime.now();
//                 // Firestore.instance
//                 //     .collection("verificationCodes")
//                 //     .document(data['orderId'])
//                 //     .delete();
//                 await locationSubscription?.cancel();
//                 locationSubscription = null;
//                 var userToken = Firestore.instance
//                     .collection('users')
//                     .document(widget.data['userId'])
//                     .collection('tokens')
//                     .getDocuments();
//                 await Firestore.instance
//                     .collection('users')
//                     .document(widget.data['userId'])
//                     .collection('orders')
//                     .document(widget.data['orderId'])
//                     .setData(
//                   {
//                     'status': 'Delivered',
//                     'deliveryDate': now.millisecondsSinceEpoch,
//                   },
//                   merge: true,
//                 );
//                 await Firestore.instance
//                     .collection('users')
//                     .document(widget.data['userId'])
//                     .collection('notifications')
//                     .document(widget.data['orderId'])
//                     .setData(
//                   {
//                     'title': 'Order Delivered',
//                     'message':
//                         '${widget.data['driverName']} has delivered your order.',
//                     'seen': false,
//                     'rated': false,
//                     'date': now.millisecondsSinceEpoch,
//                     'driverId': driverId,
//                     'orderId': widget.data['orderId'],
//                     'userId': widget.data['userId'],
//                   },
//                 );
//                 final snapshot = await userToken;
//                 final _fcmServerKey = await Utils.getFCMServerKey();
//                 final deviceTokens = <String>[];
//                 snapshot.documents.forEach((document) {
//                   deviceTokens.add(document.documentID);
//                 });
//                 var postRequest = http.post(
//                   'https://fcm.googleapis.com/fcm/send',
//                   headers: <String, String>{
//                     'Content-Type': 'application/json',
//                     'Authorization': 'key=$_fcmServerKey',
//                   },
//                   body: jsonEncode(
//                     <String, dynamic>{
//                       'notification': <String, dynamic>{
//                         'body':
//                             '${widget.data['driverName']} has delivered your order.',
//                         'title': 'Order Delivered'
//                       },
//                       'priority': 'high',
//                       'data': <String, dynamic>{
//                         'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//                         'orderId': '${widget.data['orderId']}',
//                         'status': 'delivered',
//                         'driverId': widget.data['driverId'],
//                         'userId': widget.data['userId'],
//                       },
//                       'registration_ids': deviceTokens,
//                     },
//                   ),
//                 );
//                 await Firestore.instance
//                     .collection('postedOrders')
//                     .document(widget.data['orderId'])
//                     .delete();
//                 await Firestore.instance
//                     .collection('drivers')
//                     .document(driverId)
//                     .collection('orders')
//                     .document(widget.data['orderId'])
//                     .setData(
//                       widget.data
//                         ..update(
//                           'status',
//                           (old) => 'Delivered',
//                           ifAbsent: () => 'Delivered',
//                         )
//                         ..update(
//                           'deliveryDate',
//                           (old) => now.millisecondsSinceEpoch,
//                           ifAbsent: () => now.millisecondsSinceEpoch,
//                         ),
//                     );
//                 await postRequest;
//                 List<Map<String, dynamic>> itemDetails =
//                     (await items)['itemDetails'];
//                 Map<String, double> itemsData =
//                     Map<String, double>.from(widget.data['itemsData']);
//                 int index = 0;
//                 final keys = itemsData.keys;
//                 for (String itemKey in keys) {
//                   Map<String, dynamic> item = (await Firestore.instance
//                           .collection('items')
//                           .document(itemKey)
//                           .get())
//                       .data;
//                   LatLng latLng =
//                       Utils.latLngFromString(widget.data['destination']);
//                   String address =
//                       (await Geocoder.google(await Utils.getAPIKey())
//                               .findAddressesFromCoordinates(Coordinates(
//                                   latLng.latitude, latLng.longitude)))[0]
//                           .addressLine;
//                   await Firestore.instance
//                       .collection('stores')
//                       .document(item['storeId'])
//                       .collection('orderedItems')
//                       .document(item['itemId'])
//                       .setData(
//                     {
//                       widget.data['orderId']: {
//                         'orderedBy': widget.data['userId'],
//                         'dateOrdered': widget.data['date'],
//                         'dateDelivered': now.millisecondsSinceEpoch,
//                         'deliveredTo': (widget.data['house'] == null ||
//                                     widget.data['house'] == ''
//                                 ? ''
//                                 : widget.data['house'] + ', ') +
//                             address,
//                         'quantity': itemsData[itemKey],
//                         'userEmail': widget.data['email'],
//                         'price': itemDetails[index++]['price'],
//                       },
//                     },
//                     merge: true,
//                   );
//                 }
//               },
//               verificationCode: widget.verificationCode,
//               onOrderConfirmed: () async {
//                 Driver driver = Session.data['driver'];
//                 _MyAppBar._key?.currentState?.showButton();
//                 await Firestore.instance.runTransaction((trx) async {
//                   DocumentReference ref = Firestore.instance
//                       .collection('postedOrders')
//                       .document(widget.data['orderId']);
//                   DocumentReference userOrderRef = Firestore.instance
//                       .collection('users')
//                       .document(widget.data['userId'])
//                       .collection('orders')
//                       .document(widget.data['orderId']);
//                   final snapshot = await trx.get(ref);
//                   Map<String, dynamic> data =
//                       Map<String, dynamic>.from(snapshot.data);
//                   data.update('orderId', (old) => widget.data['orderId'],
//                       ifAbsent: () => widget.data['orderId']);
//                   data.update('status', (old) => 'Accepted',
//                       ifAbsent: () => 'Accepted');
//                   data.update(('driverId'), (old) => driver.driverId,
//                       ifAbsent: () => driver.driverId);
//                   data.update(('driverName'), (old) => driver.fullName,
//                       ifAbsent: () => driver.fullName);
//                   data.update(('driverImage'), (old) => driver.profilePicture,
//                       ifAbsent: () => driver.profilePicture);
//                   data.update(
//                       ('driverPhoneNumber'), (old) => driver.phoneNumber,
//                       ifAbsent: () => driver.profilePicture);
//                   data.update(
//                     ('driverLicencePlateNumber'),
//                     (old) => driver.profilePicture,
//                     ifAbsent: () => driver.profilePicture,
//                   );

//                   data.update(
//                     'acceptedOn',
//                     (old) => DateTime.now().millisecondsSinceEpoch,
//                     ifAbsent: () => DateTime.now().millisecondsSinceEpoch,
//                   );
//                   widget.data.clear();
//                   widget.data.addAll(data);
//                   try {
//                     print(
//                         'orderId is going to be when trx set: ${widget.data['orderId']}');
//                     final postedOrderUpdate = trx.set(ref, data);
//                     final userOrderUpdate = trx.set(userOrderRef, data);
//                     await userOrderUpdate;
//                     await postedOrderUpdate;
//                   } catch (ex) {
//                     print(ex);
//                     Navigator.pop(context);
//                     Utils.showInfoDialog(
//                         'The Order has already picked by other driver');
//                     documentStream.cancel();
//                   }
//                 });
//                 documentStream.cancel();

//                 // widget.data.update(('status'), (old) => 'Accepted',
//                 //     ifAbsent: () => 'Accepted');

//                 Location location = Location();
//                 await location.changeSettings(distanceFilter: 50);
//                 // locationSubscription = location.onLocationChanged();
//                 locationSubscription =
//                     location.onLocationChanged().listen((locationData) {
//                   myLatLng =
//                       LatLng(locationData.latitude, locationData.longitude);

//                   _lastDistance = _currentDistance;
//                   _lastTimestamp = _currentTimestamp;
//                   _currentDistance = Utils.calculateDistance(
//                     Utils.latLngFromString(widget.data['destination']),
//                     myLatLng,
//                   );
//                   _currentTimestamp =
//                       DateTime.now().millisecondsSinceEpoch.toDouble();

//                   Map<String, dynamic> dataToUpload = {
//                     'lastDistance': _lastDistance,
//                     'lastTimestamp': _lastTimestamp,
//                     'currentDistance': _currentDistance,
//                     'currentTimestamp': _currentTimestamp,
//                     'driverLatLng':
//                         '${locationData.latitude},${locationData.longitude}',
//                   };

//                   Firestore.instance
//                       .collection('postedOrders')
//                       .document(widget.data['orderId'])
//                       .setData(
//                         dataToUpload,
//                         merge: true,
//                       );
//                 });
//                 // await Firestore.instance
//                 //     .collection('postedOrders')
//                 //     .document(widget.data['orderId'])
//                 //     .setData(
//                 //       widget.data,
//                 //       merge: true,
//                 //     );
//               },
//               onVerifyPopupCancel: () {
//                 _MyAppBar._key?.currentState?.enableButton();
//               },
//               onCancelPopupCancel: () {
//                 _MyAppBar._key?.currentState?.enableButton();
//               },
//               data: widget.data,
//             ),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             _Body?._key?.currentState?.widget?.centerCamera();
//             _solidController.hide();
//           },
//           child: Icon(Icons.my_location),
//         ),
//         bottomSheet: MySolidBottomSheet(
//           data: widget.data,
//           animateToLatLng: (latlng) =>
//               _Body?._key?.currentState?.widget?.animateToLatLng(latlng),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() async {
//     await locationSubscription?.cancel();
//     documentStream?.cancel();

//     super.dispose();
//   }
// }

// class MySolidBottomSheet extends StatefulWidget {
//   // final Function(LatLng) onSelectItem;
//   final data;
//   final Function(LatLng) animateToLatLng;
//   static GlobalKey<MySolidBottomSheetState> _key =
//       GlobalKey<MySolidBottomSheetState>();

//   MySolidBottomSheet({
//     this.data,
//     this.animateToLatLng,
//   }) : super(key: _key);
//   @override
//   State<StatefulWidget> createState() {
//     return MySolidBottomSheetState();
//   }

//   show() {
//     _key?.currentState?._solidController?.show();
//   }

//   hide() {
//     _key?.currentState?._solidController?.hide();
//   }
// }

// class MySolidBottomSheetState extends State<MySolidBottomSheet> {
//   bool isShown = false;
//   final BottomBarIcon _icon = BottomBarIcon();
//   Future<Map<String, dynamic>> items;
//   var _solidController = SolidController();

//   @override
//   void dispose() {
//     _solidController.dispose();
//     super.dispose();
//   }

//   Future<Map<String, dynamic>> getItems(data) async {
//     LatLng destination = Utils.latLngFromString(data['destination']);
//     Map<String, double> itemsData = Map<String, double>.from(data['itemsData']);
//     List<Map<String, dynamic>> itemDetails = [];
//     Map<String, dynamic> finalResult = {};
//     final keys = itemsData.keys;
//     for (String itemKey in keys) {
//       final result =
//           await Firestore.instance.collection('items').document(itemKey).get();
//       // LatLng latlng = Utils.latLngFromString(result.data['latlng']);
//       // Address address = (await Geocoder.google(await Utils.getAPIKey())
//       //     .findAddressesFromCoordinates(
//       //         Coordinates(latlng.latitude, latlng.longitude)))[0];
//       // result.data.putIfAbsent('address', () => result.data['storeAddress']);
//       itemDetails.add(result.data);
//     }

//     Address address = (await Geocoder.google(await Utils.getAPIKey())
//         .findAddressesFromCoordinates(
//             Coordinates(destination.latitude, destination.longitude)))[0];
//     // itemDetails.add({'destination' : address.addressLine});
//     finalResult.putIfAbsent('destination', () {
//       return address;
//     });
//     finalResult.putIfAbsent('destinationLatLng', () {
//       return destination;
//     });

//     finalResult.putIfAbsent('itemDetails', () {
//       return itemDetails;
//     });

//     return finalResult;
//   }

//   @override
//   void initState() {
//     super.initState();
//     items = getItems(widget.data);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SolidBottomSheet(
//       controller: _solidController,
//       toggleVisibilityOnTap: true,
//       onShow: () async {
//         _icon.setIconState(true);
//       },
//       onHide: () async {
//         _icon.setIconState(false);
//       },
//       // enableDrag: true,
//       // backgroundColor: Color.fromARGB(0, 0, 0, 0 ),
//       maxHeight: 500,
//       elevation: 8.0,
//       draggableBody: true,
//       headerBar: Container(
//         height: 40,
//         decoration: ShapeDecoration(
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(20), topRight: Radius.circular(20)),
//           ),
//         ),
//         child: _icon,
//       ),
//       body: FutureBuilder<Map<String, dynamic>>(
//           future: items,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting ||
//                 snapshot.data == null) {
//               return Center(
//                 child: CircularProgressIndicator(),
//               );
//             }
//             return SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: <Widget>[
//                   SizedBox(
//                     height: 40,
//                   ),
//                   Container(
//                     color: Theme.of(context).primaryColor,
//                     padding: EdgeInsets.all(6),
//                     child: Text(
//                       ' P i c k u p ',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Container(
//                     // color: Colors.black,
//                     // width: MediaQuery.of(context).size.width,
//                     height: 200,
//                     child: ListView.builder(
//                       // padding: EdgeInsets.only(right: 20),
//                       scrollDirection: Axis.horizontal,
//                       // dragStartBehavior: DragStartBehavior.start,
//                       physics: BouncingScrollPhysics(),
//                       itemCount: snapshot.data['itemDetails'].length,
//                       itemBuilder: (context, index) {
//                         return Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: <Widget>[
//                             Card(
//                               elevation: 8,
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(4),
//                                 child: InkWell(
//                                   splashColor: Theme.of(context)
//                                       .primaryColor
//                                       .withAlpha(190),
//                                   onTap: () async {
//                                     widget.animateToLatLng(
//                                       Utils.latLngFromString(
//                                         snapshot.data['itemDetails'][index]
//                                             ['latlng'],
//                                       ),
//                                     );
//                                     _solidController.hide();
//                                   },
//                                   child: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: <Widget>[
//                                       Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: <Widget>[
//                                           Container(
//                                             color: Colors.black,
//                                             child: Image.network(
//                                               '${snapshot.data['itemDetails'][index]['images'][0]}',
//                                               height: 100,
//                                               width: 100,
//                                               fit: BoxFit.fitWidth,
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             width: 8,
//                                           ),
//                                           Container(
//                                             width: 150,
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: <Widget>[
//                                                 SizedBox(
//                                                   height: 4,
//                                                 ),
//                                                 Text(
//                                                   snapshot.data['itemDetails']
//                                                       [index]['itemName'],
//                                                   style: Theme.of(context)
//                                                       .textTheme
//                                                       .subtitle1,
//                                                 ),
//                                                 SizedBox(
//                                                   height: 4,
//                                                 ),
//                                                 Text(
//                                                     '${snapshot.data['itemDetails'][index]['storeAddress']}'),
//                                                 Align(
//                                                   alignment:
//                                                       Alignment.centerRight,
//                                                   child: Text(
//                                                     "Price: R${(snapshot.data['itemDetails'][index]['price'] as num).toDouble().toStringAsFixed(2)} x ${widget.data['itemsData'][snapshot.data['itemDetails'][index]['itemId']]}",
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                     maxLines: 1,
//                                                     style: TextStyle(
//                                                       fontSize: 14,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                     ),
//                                                   ),
//                                                 )
//                                               ],
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             width: 8,
//                                           ),
//                                         ],
//                                       ),
//                                       InkWell(
//                                         splashColor: Theme.of(context)
//                                             .primaryColor
//                                             .withAlpha(190),
//                                         onTap: () async {
//                                           LatLng latlng =
//                                               Utils.latLngFromString(
//                                             snapshot.data['itemDetails'][index]
//                                                 ['latlng'],
//                                           );
//                                           print('Navigating to $latlng');
//                                           ReceiveItOrderNavigationRoute
//                                               ._startNavigation(
//                                             context,
//                                             latlng,
//                                             Utils.getLastKnowLocation(),
//                                           );
//                                         },
//                                         child: Container(
//                                           width: 270.0,
//                                           color: Theme.of(context).primaryColor,
//                                           child: Row(
//                                             children: [
//                                               Expanded(
//                                                 child: Container(
//                                                   padding:
//                                                       const EdgeInsets.all(8.0),
//                                                   child: Text(
//                                                     'Navigate Here!',
//                                                     style: TextStyle(
//                                                         color: Colors.white),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             // RaisedButton(
//                             //   onPressed: () {},
//                             //   child: Text('Open in Map',
//                             //       style: TextStyle(color: Colors.white)),
//                             // ),
//                           ],
//                         );
//                       },
//                     ),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(18.0),
//                     child: Card(
//                       elevation: 8,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                       child: InkWell(
//                         splashColor:
//                             Theme.of(context).primaryColor.withAlpha(190),
//                         onTap: () {
//                           LatLng latLng = snapshot.data['destinationLatLng'];
//                           widget.animateToLatLng(latLng);
//                           _solidController.hide();
//                         },
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                           children: <Widget>[
//                             Container(
//                               decoration: ShapeDecoration(
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.only(
//                                     topLeft: Radius.circular(8.0),
//                                     topRight: Radius.circular(8.0),
//                                   ),
//                                 ),
//                                 color: Theme.of(context).primaryColor,
//                               ),
//                               padding: EdgeInsets.all(6),
//                               child: Text(
//                                 ' D r o p o f f ',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             Container(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Row(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: <Widget>[
//                                   Icon(Icons.location_on),
//                                   Expanded(
//                                     child: Text(
//                                       '${(snapshot.data['destination'] as Address).addressLine}',
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             InkWell(
//                               splashColor:
//                                   Theme.of(context).primaryColor.withAlpha(190),
//                               onTap: () async {
//                                 print('Opened in maps');
//                                 LatLng latLng =
//                                     snapshot.data['destinationLatLng'];
//                                 // MapsLauncher.launchCoordinates(
//                                 //   latLng.latitude,
//                                 //   latLng.longitude,
//                                 // );
//                                 ReceiveItOrderNavigationRoute._startNavigation(
//                                   context,
//                                   latLng,
//                                   Utils.getLastKnowLocation(),
//                                 );
//                               },
//                               child: Container(
//                                 decoration: ShapeDecoration(
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.only(
//                                       bottomLeft: Radius.circular(8.0),
//                                       bottomRight: Radius.circular(8.0),
//                                     ),
//                                   ),
//                                   color: Theme.of(context).primaryColor,
//                                 ),
//                                 padding: EdgeInsets.all(8.0),
//                                 child: Text(
//                                   'Navigate Here!',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }),
//     );
//   }
// }

// class BottomBarIcon extends StatefulWidget {
//   BottomBarIcon({Key key}) : super(key: _key);
//   static GlobalKey<_BottomBarIconState> _key = GlobalKey<_BottomBarIconState>();
//   @override
//   _BottomBarIconState createState() => _BottomBarIconState();

//   setIconState(bool isShown) {
//     _key?.currentState?.isShown = isShown;
//     _key?.currentState?.refresh();
//   }
// }

// class _BottomBarIconState extends State<BottomBarIcon> {
//   void refresh() {
//     if (mounted) {
//       setState(() {});
//     }
//   }

//   bool isShown = false;
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Icon(
//         isShown ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
//       ),
//     );
//   }
// }

// class _MyAppBar extends StatefulWidget implements PreferredSizeWidget {
//   final String title;
//   final Function onDonePressed;
//   static GlobalKey<_MyAppBarState> _key = GlobalKey<_MyAppBarState>();

//   _MyAppBar({this.title, this.onDonePressed}) : super(key: _key);

//   void showButton() {
//     _key?.currentState?.showButton();
//   }

//   void hideButton() {}

//   void enableButton() {
//     _key?.currentState?.enableButton();
//   }

//   void disableButton() {
//     _key?.currentState?.disableButton();
//   }

//   void refresh() {
//     _key?.currentState?.refresh();
//   }

//   @override
//   State<StatefulWidget> createState() {
//     return _MyAppBarState();
//   }

//   @override
//   Size get preferredSize => Size.fromHeight(kToolbarHeight);
// }

// class _MyAppBarState extends State<_MyAppBar> {
//   bool isButtonVisible = false;
//   bool isButtonEnabled = true;

//   refresh() {
//     if (mounted) {
//       setState(() {});
//     }
//   }

//   showButton() {
//     isButtonVisible = true;
//     setState(() {});
//   }

//   enableButton() {
//     isButtonEnabled = true;
//     setState(() {});
//   }

//   disableButton() {
//     isButtonEnabled = false;
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       centerTitle: true,
//       title: Text(widget.title),
//       actions: <Widget>[
//         !isButtonVisible
//             ? Opacity(
//                 opacity: 0,
//               )
//             : FlatButton(
//                 child: Text('Done'),
//                 onPressed: !isButtonEnabled
//                     ? null
//                     : () {
//                         isButtonEnabled = false;
//                         widget.onDonePressed();
//                         setState(() {});
//                       },
//               ),
//       ],
//     );
//   }
// }

// class _Body extends StatefulWidget {
//   final Function onOrderConfirmed;
//   final Function onCancelPopupCancel;
//   final Function onVerifyPopupCancel;
//   final Map<String, dynamic> data;
//   final verificationCode;
//   final Function onOrderComplete;
//   final Function onCancelPopupConfirm;
//   static GlobalKey<_BodyState> _key = GlobalKey<_BodyState>();

//   _Body({
//     @required this.onOrderComplete,
//     @required this.data,
//     @required this.onOrderConfirmed,
//     @required this.onCancelPopupCancel,
//     @required this.onVerifyPopupCancel,
//     @required this.verificationCode,
//     @required this.onCancelPopupConfirm,
//   }) : super(key: _key);

//   @override
//   State<StatefulWidget> createState() {
//     return _BodyState();
//   }

//   bool isOrderConfirmationPopupShown() {
//     return _key?.currentState?.isOrderConfirmationVisible;
//   }

//   bool isCancelPopupShown() {
//     return _key?.currentState?.isCancelDialogVisible;
//   }

//   bool isDeliveryCompletePopupShown() {
//     return _key?.currentState?.isOrderCompleteDialogueVisible;
//   }

//   showCancelDialogue() {
//     _key?.currentState?.showCancelPopup();
//   }

//   showDeliveryCompleteDialogue() {
//     _key?.currentState?.showDeliveryDonePopup();
//   }

//   hideCancelDialogue() {
//     _key?.currentState?.hideCancelPopup();
//   }

//   hideDeliveryCompleteDialogue() {
//     _key?.currentState?.hideDeliverDonePopup();
//   }

//   void centerCamera() {
//     _key?.currentState?.mapWidget?.centerCamera();
//   }

//   void animateToLatLng(LatLng coordinates) {
//     _key?.currentState?.mapWidget?.animateTo(coordinates);
//   }
// }

// class _BodyState extends State<_Body> {
//   _Popups _popups;
//   _MapWidget mapWidget;

//   bool get isCancelDialogVisible =>
//       _Popups._key?.currentState?.isCancelDialogVisible;

//   bool get isOrderCompleteDialogueVisible =>
//       _Popups._key?.currentState?.isOrderCompleteDialogueVisible;

//   bool get isOrderConfirmationVisible =>
//       _Popups._key?.currentState?.isOrderConfirmationVisible;

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   showCancelPopup() {
//     _Popups._key?.currentState?.showCancelPopup();

//     // setState(() {});
//   }

//   hideCancelPopup() {
//     // isCancelDialogVisible = false;
//     _Popups._key?.currentState?.hideCancelPopup();
//     // setState(() {});
//   }

//   showDeliveryDonePopup() {
//     // isOrderCompleteDialogueVisible = true;
//     _Popups._key?.currentState?.showOrderCompletePopup();
//     // setState(() {});
//   }

//   hideDeliverDonePopup() {
//     _Popups._key?.currentState?.hideOrderCompletePopup();
//     // setState(() {});
//   }

//   Widget getMap() {
//     return _MapWidget(
//       dropOff: Utils.latLngFromString(widget.data['destination']),
//       pickups: (widget.data['pickups'] as List)
//           .map((x) => Utils.latLngFromString(x))
//           .toList(),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _popups = _Popups(
//       onOrderComplete: widget.onOrderComplete,
//       verificationCode: widget.verificationCode,
//       onOrderConfirmed: widget.onOrderConfirmed,
//       onCancelPopupCancel: widget.onCancelPopupCancel,
//       onOrderCompletePopupCancel: widget.onVerifyPopupCancel,
//       onCancelPopupConfirm: widget.onCancelPopupConfirm,
//     );
//   }

//   Widget getBody() {
//     mapWidget = getMap();

//     return Column(
//       children: [
//         Expanded(
//           child: Stack(
//             fit: StackFit.expand,
//             children: <Widget>[
//               mapWidget,
//               _popups,
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return getBody();
//   }
// }

// class _MapWidget extends StatefulWidget {
//   final _MapState state = _MapState();
//   final List<LatLng> pickups;
//   final LatLng dropOff;

//   _MapWidget({Key key, @required this.pickups, @required this.dropOff})
//       : super(key: key);
//   @override
//   State<StatefulWidget> createState() {
//     return state;
//   }

//   void animateTo(LatLng position) {
//     state._controller.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(target: position, zoom: 15.0),
//       ),
//     );
//   }

//   void centerCamera() async {
//     LatLng myLocation = await Utils.getMyLocation();
//     state._controller.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(target: myLocation, zoom: 15.0),
//       ),
//     );
//   }
// }

// class _MapState extends State<_MapWidget> {
//   GoogleMap map;
//   Set<Marker> markers = {};
//   Set<Polyline> polylines = {};

//   GoogleMapController _controller;

//   @override
//   void initState() {
//     super.initState();
//   }

//   Future<void> initialize() async {
//     final myLocation = await Utils.getMyLocation();
//     int index = -1;
//     List<LatLng> tempPickups = [];
//     for (LatLng pickup in widget.pickups) {
//       if (!tempPickups.contains(pickup)) {
//         index++;
//         Marker markerPickup = Marker(
//           markerId: MarkerId("marker$index"),
//           infoWindow:
//               InfoWindow(title: "Pick Up", snippet: "Click to Navigate here!"),
//           position: pickup,
//           onTap: () {},
//           flat: false,
//           icon: BitmapDescriptor.defaultMarkerWithHue(
//               BitmapDescriptor.hueMagenta),
//         );
//         tempPickups.add(pickup);
//         markers.add(markerPickup);
//       }
//     }

//     Marker markerDropOff = Marker(
//       markerId: MarkerId("markerDrop"),
//       infoWindow:
//           InfoWindow(title: "Drop Off", snippet: "Click to Navigate here!"),
//       position: widget.dropOff,
//       icon: await BitmapDescriptor.fromAssetImage(
//         ImageConfiguration(
//           size: Size(
//             100,
//             100,
//           ),
//         ),
//         'assets/images/flag.png',
//       ),
//     );

//     markers.add(markerDropOff);

//     map = GoogleMap(
//       compassEnabled: true,
//       initialCameraPosition:
//           CameraPosition(target: myLocation, zoom: 14, tilt: 30),
//       myLocationEnabled: true,
//       myLocationButtonEnabled: false,
//       buildingsEnabled: true,
//       markers: markers,
//       polylines: polylines,
//       mapType: MapType.normal,
//       zoomGesturesEnabled: true,
//       mapToolbarEnabled: false,
//       polygons: Set(),
//       circles: Set(),
//       onMapCreated: (controller) {
//         _controller = controller;
//       },
//       onTap: (latlng) async {},
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: initialize(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         }
//         return Stack(
//           children: [map],
//         );
//       },
//     );
//   }
// }

// class _Popups extends StatefulWidget {
//   static var popUpHeight = 220.0;
//   static var popUpWidth = 300.0;

//   final Function onOrderConfirmed;
//   final Function onCancelPopupCancel;
//   final Function onOrderCompletePopupCancel;
//   final verificationCode;
//   final Function onOrderComplete;
//   final Function onCancelPopupConfirm;
//   static GlobalKey<_PopupsState> _key = GlobalKey<_PopupsState>();
//   _Popups(
//       {@required this.onOrderComplete,
//       @required this.onOrderConfirmed,
//       @required this.onCancelPopupCancel,
//       @required this.onCancelPopupConfirm,
//       @required this.onOrderCompletePopupCancel,
//       @required this.verificationCode})
//       : super(key: _key);

//   @override
//   State<StatefulWidget> createState() {
//     return _PopupsState();
//   }
// }

// class _PopupsState extends State<_Popups> {
//   _OrderConfirmation _orderConfirmationPopup;
//   _DeliveryDonePopUp _deliveryDonePopUp;
//   _CancelOrderPopUp _cancelOrderPopUp;

//   bool isOrderConfirmationVisible = true;
//   bool isOrderCompleteDialogueVisible = false;
//   bool isCancelDialogVisible = false;

//   showCancelPopup() {
//     isCancelDialogVisible = true;
//     setState(() {});
//     // _cancelOrderPopUp?.show();
//   }

//   hideCancelPopup() {
//     isCancelDialogVisible = false;
//     setState(() {});
//     // _cancelOrderPopUp?.hide();
//   }

//   showOrderCompletePopup() {
//     isOrderCompleteDialogueVisible = true;
//     setState(() {});
//     // _deliveryDonePopUp?.show();
//   }

//   hideOrderCompletePopup() {
//     isOrderCompleteDialogueVisible = false;
//     // _deliveryDonePopUp.hide();
//     setState(() {});
//   }

//   @override
//   void initState() {
//     super.initState();
//     _orderConfirmationPopup = _OrderConfirmation(
//       onConfirm: () async {
//         isOrderConfirmationVisible = false;
//         await widget.onOrderConfirmed();
//         setState(() {});
//       },
//       onExit: () {
//         isOrderConfirmationVisible = false;
//         Navigator.of(context).pop();
//       },
//     );

//     _cancelOrderPopUp = _CancelOrderPopUp(
//       onCancel: () {
//         print('on Cancel Called');
//         isCancelDialogVisible = false;
//         widget.onCancelPopupCancel();
//         setState(() {});
//       },
//       onConfirm: () async {
//         print('on Confirm Called');
//         await widget.onCancelPopupConfirm();
//         isCancelDialogVisible = false;
//       },
//     );
//     _deliveryDonePopUp = _DeliveryDonePopUp(
//       verificationCode: widget.verificationCode,
//       onCancel: () {
//         isOrderCompleteDialogueVisible = false;
//         widget.onOrderCompletePopupCancel();
//         setState(() {});
//       },
//       onConfirm: () async {
//         isOrderCompleteDialogueVisible = false;
//         Utils.showLoadingDialog(context);
//         await widget.onOrderComplete();
//         int count = 0;
//         Navigator.popUntil(context, (route) => count++ > 1);
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       behavior: HitTestBehavior.translucent,
//       onTap: () {
//         if (!isOrderConfirmationVisible) {
//           if (isCancelDialogVisible) {
//             isCancelDialogVisible = false;
//             setState(() {});
//             widget.onCancelPopupCancel();
//           } else if (isOrderCompleteDialogueVisible) {
//             isOrderCompleteDialogueVisible = false;
//             setState(() {});
//             widget.onOrderCompletePopupCancel();
//           }
//         }
//       },
//       child: Container(
//         // color: Colors.white,
//         width: MediaQuery.of(context).size.width,
//         child: Stack(
//           children: <Widget>[
//             Center(
//               child: AnimatedContainer(
//                 duration: Duration(milliseconds: 500),
//                 child: _cancelOrderPopUp,
//                 width: isCancelDialogVisible ? _Popups.popUpWidth : 0,
//                 height: isCancelDialogVisible ? _Popups.popUpHeight : 0,
//               ),
//             ),
//             Center(
//               child: AnimatedContainer(
//                 duration: Duration(milliseconds: 500),
//                 height:
//                     isOrderCompleteDialogueVisible ? _Popups.popUpHeight : 0,
//                 width: isOrderCompleteDialogueVisible ? _Popups.popUpWidth : 0,
//                 child: _deliveryDonePopUp,
//               ),
//             ),
//             AnimatedPositioned(
//               duration: Duration(milliseconds: 500),
//               child: _orderConfirmationPopup,
//               left: 0,
//               right: 0,
//               bottom:
//                   isOrderConfirmationVisible ? 60 : -1 * (_Popups.popUpHeight),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _DeliveryDonePopUp extends StatefulWidget {
//   // final width;
//   // final height;
//   final Function onCancel;
//   final Function onConfirm;
//   final String verificationCode;
//   static GlobalKey<_DeliveryDonePopUpStateRevised> _key =
//       GlobalKey<_DeliveryDonePopUpStateRevised>();
//   _DeliveryDonePopUp({
//     @required this.onCancel,
//     @required this.onConfirm,
//     @required this.verificationCode,
//   }) : super(key: _key); //@required this.width, @required this.height})

//   // : super(key: key);

//   @override
//   State<StatefulWidget> createState() {
//     return _DeliveryDonePopUpStateRevised();
//   }

//   void show() {
//     // state.deliveryDonePopUpShown = true;
//     // state.outerContainerShown = true;
//     refresh();
//   }

//   void hide() {
//     // state.deliveryDonePopUpShown = false;
//     refresh();
//   }

//   void refresh() {
//     // state.refresh();
//   }
// }

// class _DeliveryDonePopUpStateRevised extends State<_DeliveryDonePopUp> {
//   String confirmationKey = '';

//   var _verificationCodeController = TextEditingController();

//   var hasError = false;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 10,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.all(
//           Radius.circular(8),
//         ),
//       ),
//       child: Container(
//         margin: EdgeInsets.only(top: 8, bottom: 8, left: 20, right: 20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             SizedBox(
//               height: 2,
//             ),
//             Text(
//               'Confirmation Key',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//             SizedBox(
//               height: 3,
//             ),
//             Text(
//               'Please Enter the Verification Key',
//             ),
//             SizedBox(
//               height: 2,
//             ),
//             PinCodeTextField(
//               length: 6,
//               obsecureText: false,
//               animationType: AnimationType.fade,
//               shape: PinCodeFieldShape.box,
//               animationDuration: Duration(milliseconds: 300),
//               borderRadius: BorderRadius.circular(5),
//               selectedColor: Theme.of(context).primaryColor,
//               controller: _verificationCodeController,
//               fieldHeight: 40,
//               fieldWidth: 35,
//               onChanged: (value) {
//                 confirmationKey = value;
//                 setState(() {});
//               },
//             ),
//             SizedBox(
//               height: 4,
//             ),
//             hasError
//                 ? Text(
//                     'Invalid Code! Try Again',
//                     style: Theme.of(context)
//                         .textTheme
//                         .bodyText2
//                         .copyWith(color: Colors.red),
//                   )
//                 : Opacity(
//                     opacity: 0,
//                   ),
//             RaisedButton(
//               child: Text(
//                 'Verify',
//                 style: Theme.of(context).textTheme.button,
//               ),
//               onPressed: () async {
//                 String key = widget.verificationCode;
//                 if (confirmationKey == key) {
//                   Utils.showSuccessDialog('Order Has been Delivered');
//                   Future.delayed(Duration(seconds: 2)).then((a) {
//                     BotToast.removeAll();
//                   });
//                   widget.onConfirm();
//                 } else {
//                   hasError = true;
//                   setState(() {
//                     _verificationCodeController.clear();
//                   });
//                   // Utils.showSnackBarError(context, 'Invalid Verification Code');
//                 }
//                 // Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//       // color: Colors.red,
//       // width: widget.width,
//       // height: widget.height,
//     );
//   }
// }

// class _CancelOrderPopUp extends StatefulWidget {
//   // final width;
//   // final height;

//   final Function onConfirm;
//   final Function onCancel;

//   _CancelOrderPopUp({@required this.onConfirm, @required this.onCancel})
//       : super(key: _key); //@required this.width, @required this.height})

//   // : super(key: key);
//   static GlobalKey<_CancelOrderPopUpStateRevised> _key =
//       GlobalKey<_CancelOrderPopUpStateRevised>();
//   @override
//   State<StatefulWidget> createState() {
//     return _CancelOrderPopUpStateRevised();
//   }

//   void show() {
//     // state.cancelOrderConfirmationShown = true;
//     refresh();
//   }

//   void hide() {
//     // state.cancelOrderConfirmationShown = false;
//     refresh();
//   }

//   void refresh() {
//     // state.refresh();
//   }
// }

// class _CancelOrderPopUpStateRevised extends State<_CancelOrderPopUp> {
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 10,
//       // color: Colors.red,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.all(
//           Radius.circular(8),
//         ),
//       ),
//       child: Center(
//         child: Container(
//           margin: EdgeInsets.all(8),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               SizedBox(
//                 height: 8,
//               ),
//               Text(
//                 'Exit',
//                 style: Theme.of(context).textTheme.headline4,
//               ),
//               SizedBox(
//                 height: 5,
//               ),
//               Text(
//                 'Are you sure you wanna cancel the delivery? ',
//                 style: Theme.of(context).textTheme.subtitle2,
//               ),
//               SizedBox(
//                 height: 2,
//               ),
//               ButtonBar(
//                 alignment: MainAxisAlignment.spaceEvenly,
//                 children: <Widget>[
//                   RaisedButton(
//                     elevation: 6,
//                     color: Colors.white,
//                     child: Text(
//                       'Cancel',
//                       textAlign: TextAlign.center,
//                     ),
//                     onPressed: () {
//                       widget.onCancel();
//                     },
//                   ),
//                   RaisedButton(
//                     elevation: 6,
//                     color: Theme.of(context).primaryColor,
//                     textColor: Colors.white,
//                     child: Text(
//                       'Confirm',
//                       textAlign: TextAlign.center,
//                     ),
//                     onPressed: () async {
//                       Utils.showLoadingDialog(context);
//                       await widget.onConfirm();
//                       int count = 0;
//                       Navigator.popUntil(context, (route) => count++ > 1);
//                       // widget.parent.setState(() {});
//                     },
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),

//       // width: widget.width,
//       // height: widget.height,
//     );
//   }
// }

// class _OrderConfirmation extends StatefulWidget {
//   final Function onConfirm;
//   final Function onExit;

//   _OrderConfirmation({@required this.onConfirm, @required this.onExit})
//       : super(key: _key);

//   static GlobalKey<_OrderConfirmationStateRevised> _key =
//       GlobalKey<_OrderConfirmationStateRevised>();

//   @override
//   State<StatefulWidget> createState() {
//     return _OrderConfirmationStateRevised();
//   }

//   // void show() {
//   //   state.orderConfirmed = false;
//   // }

//   // void refresh() {
//   //   state.refresh();
//   // }

// }

// class _OrderConfirmationStateRevised extends State<_OrderConfirmation> {
//   onPressAcceptOrder() async {
//     Utils.showLoadingDialog(context);
//     await widget.onConfirm();
//     Navigator.pop(context);
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if ((_Body._key.currentWidget as _Body).data['driverId'] != null) {
//         onPressAcceptOrder();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       // color: Colors.blue,
//       // width: MediaQuery.of(context).size.width,
//       child: Card(
//         margin: EdgeInsets.only(
//           left: 30,
//           right: 30,
//           bottom: 10,
//         ),
//         color: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(
//             Radius.circular(10),
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             SizedBox(
//               height: 16,
//             ),
//             Text(
//               'Accept the order?',
//               style: Theme.of(context).textTheme.headline6,
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: <Widget>[
//                 Spacer(),
//                 Expanded(
//                   flex: 4,
//                   child: RaisedButton(
//                     // shape: RoundedRectangleBorder(
//                     //   borderRadius: BorderRadius.all(
//                     //     Radius.circular(4),
//                     //   ),
//                     // ),
//                     onPressed: () {
//                       widget.onExit();
//                     },
//                     color: Colors.white,
//                     child: Text(
//                       'Cancel',
//                       style: TextStyle(color: Theme.of(context).primaryColor),
//                     ),
//                   ),
//                 ),
//                 Spacer(),
//                 Expanded(
//                   flex: 4,
//                   child: RaisedButton(
//                     // shape: RoundedRectangleBorder(
//                     //   borderRadius: BorderRadius.all(
//                     //     Radius.circular(4),
//                     //   ),
//                     // ),
//                     onPressed: () async {
//                       await onPressAcceptOrder();
//                     },
//                     color: Theme.of(context).primaryColor,
//                     child: Text(
//                       'Accept',
//                       style: Theme.of(context).textTheme.button,
//                     ),
//                   ),
//                 ),
//                 Spacer(),
//               ],
//             ),
//             SizedBox(
//               height: 16,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
