// import 'dart:async';
// import 'dart:convert';
// import 'package:bot_toast/bot_toast.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart'
//     as mapbox;
// import 'package:geocoder/geocoder.dart';
// import 'package:get_it/get_it.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:location/location.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
// import 'package:sennit/main.dart';
// import 'package:sennit/models/models.dart';
// import 'package:sennit/rx_models/rx_address.dart';
// import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

// class SennitOrderNavigationRoute extends StatefulWidget {
//   static const NAME = "SennitOrderNavigationRoute";
//   // bool isOrderConfirmed = false;
//   // final _Body body;
//   // final _MyAppBar myAppbar;
//   final Map<String, dynamic> data;
//   // final MySolidBottomSheet myBottomSheet;
//   final String verificationCode;

//   void onDonePressed() {
//     _Body._key.currentState.showDeliveryDonePopup();
//   }

//   SennitOrderNavigationRoute({
//     @required this.data,
//     @required this.verificationCode,
//   });

//   @override
//   State<StatefulWidget> createState() {
//     return _SennitOrderNavigationRouteState();
//   }
// }

// class _SennitOrderNavigationRouteState
//     extends State<SennitOrderNavigationRoute> {
//   StreamSubscription<LocationData> _driverLocationSubscription;
//   StreamSubscription<DocumentSnapshot> documentStream;
//   double _lastTimestamp;
//   double _lastDistance;
//   double _currentDistance;
//   double _currentTimestamp;

//   @override
//   void initState() {
//     super.initState();
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
//   void dispose() {
//     super.dispose();
//     _driverLocationSubscription?.cancel();
//     documentStream?.cancel();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         if (_Body._key?.currentState?.isOrderConfirmationVisible ?? false) {
//           await _driverLocationSubscription?.cancel();
//           Navigator.pop(context);
//           return false;
//         }
//         if (_Body._key?.currentState?.isOrderCompleteDialogueVisible ?? false) {
//           _Body._key?.currentState?.hideDeliverDonePopup();
//           _MyAppBar._key?.currentState?.enableButton();
//           return false;
//         }
//         if (_Body._key?.currentState?.isCancelDialogVisible ?? false) {
//           _Body._key?.currentState?.hideCancelPopup();
//           _MyAppBar._key?.currentState?.enableButton();
//           return false;
//         } else {
//           _Body._key?.currentState?.showCancelPopup();
//           _MyAppBar._key?.currentState?.disableButton();
//           return false;
//         }
//       },
//       child: Scaffold(
//         appBar: _MyAppBar(
//           title:
//               "R${(widget.data['price'] as num).toDouble().toStringAsFixed(2)}",
//           onDonePressed: () {
//             _Body._key?.currentState?.showDeliveryDonePopup();
//           },
//         ),
//         body: Stack(
//           children: <Widget>[
//             _Body(
//               verificationCode: widget.verificationCode,
//               onCancelPopupConfirmed: () async {
//                 _driverLocationSubscription?.cancel();
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
//               },
//               onOrderConfirmed: () async {
//                 Driver driver = Session.data['driver'];
//                 _MyAppBar._key?.currentState?.showButton();
//                 // widget.data.update(('status'), (old) => 'Accepted',
//                 //     ifAbsent: () => 'Accepted');
//                 // widget.data.update(('driverId'), (old) => driver.driverId,
//                 //     ifAbsent: () => driver.driverId);
//                 // widget.data.update(('driverName'), (old) => driver.fullName,
//                 //     ifAbsent: () => driver.fullName);
//                 // widget.data.update(
//                 //     ('driverImage'), (old) => driver.profilePicture,
//                 //     ifAbsent: () => driver.profilePicture);
//                 // widget.data.update(
//                 //     ('driverPhoneNumber'), (old) => driver.phoneNumber,
//                 //     ifAbsent: () => driver.profilePicture);
//                 // widget.data.update(('driverLicencePlateNumber'),
//                 //     (old) => driver.profilePicture,
//                 //     ifAbsent: () => driver.profilePicture);
//                 // widget.data.update(
//                 //   'acceptedOn',
//                 //   (old) => DateTime.now().millisecondsSinceEpoch,
//                 //   ifAbsent: () => DateTime.now().millisecondsSinceEpoch,
//                 // );

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
//                   if ((snapshot.data['status'] as String).toLowerCase() ==
//                           'accepted' &&
//                       snapshot.data['driverId'] != driver.driverId) {
//                     Navigator.pop(context);
//                     Utils.showInfoDialog(
//                         'Sorry! Order has already been taken by another driver');
//                   }
//                   Map<String, dynamic> data =
//                       Map<String, dynamic>.from(snapshot.data);
//                   data.update('orderId', (old) => snapshot.documentID,
//                       ifAbsent: () => snapshot.documentID);
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
//                       ifAbsent: () => driver.phoneNumber);
//                   data.update(
//                     ('driverLicencePlateNumber'),
//                     (old) => driver.licencePlateNumber,
//                     ifAbsent: () => driver.licencePlateNumber,
//                   );
//                   data.update(
//                     'acceptedOn',
//                     (old) => DateTime.now().millisecondsSinceEpoch,
//                     ifAbsent: () => DateTime.now().millisecondsSinceEpoch,
//                   );

//                   widget.data.clear();
//                   widget.data.addAll(data);
//                   try {
//                     final postedOrderUpdate = trx.set(ref, data);
//                     final userOrderUpdate = trx.set(userOrderRef, data);
//                     await userOrderUpdate;
//                     await postedOrderUpdate;
//                   } catch (ex) {
//                     print(ex);
//                     Utils.showInfoDialog(
//                         'The Order has already picked by other driver');
//                     documentStream.cancel();
//                   }
//                 });
//                 documentStream?.cancel();

//                 // await Firestore.instance
//                 //     .collection('postedOrders')
//                 //     .document(widget.data['orderId'])
//                 //     .setData(
//                 //       widget.data,
//                 //       merge: true,
//                 //     );
//                 // await Firestore.instance
//                 //     .collection('users')
//                 //     .document(widget.data['userId'])
//                 //     .collection('orders')
//                 //     .document(widget.data['orderId'])
//                 //     .setData(
//                 //       widget.data,
//                 //       merge: true,
//                 //     );
//                 Location location = Location();
//                 await location.changeSettings(
//                   distanceFilter: 50,
//                 );
//                 if (_driverLocationSubscription != null) {
//                   _driverLocationSubscription = null;
//                 }
//                 _driverLocationSubscription =
//                     location.onLocationChanged().listen((locationData) {
//                   _lastDistance = _currentDistance;
//                   _lastTimestamp = _currentTimestamp;
//                   _currentDistance = Utils.calculateDistance(
//                     Utils.latLngFromString(widget.data['dropOffLatLng']),
//                     LatLng(
//                       locationData.latitude,
//                       locationData.longitude,
//                     ),
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
//               },
//               onOrderComplete: () async {
//                 await _driverLocationSubscription?.cancel();
//                 _driverLocationSubscription = null;
//                 String driverId = await FirebaseAuth.instance
//                     .currentUser()
//                     .then((user) => user.uid);
//                 DateTime now = DateTime.now();

//                 // Firestore.instance
//                 //     .collection("verificationCodes")
//                 //     .document(data['orderId'])
//                 //     .delete();

//                 // if (_driverLocationSubscription != null) {
//                 await _driverLocationSubscription?.cancel();
//                 _driverLocationSubscription = null;
//                 // }
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
//                     .document(
//                       widget.data['orderId'],
//                     )
//                     .setData(
//                   {
//                     'title': 'Order Delivered',
//                     'message':
//                         '${widget.data['driverName']} has delivered your order.',
//                     'seen': false,
//                     'rated': false,
//                     'date': now.millisecondsSinceEpoch,
//                     'orderId': widget.data['orderId'],
//                     'driverId': driverId,
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
//                         'date': now.millisecondsSinceEpoch,
//                         'driverId': driverId,
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
//               },
//               onVerifyPopupCancel: () {
//                 _MyAppBar._key?.currentState?.enableButton();
//               },
//               onCancelPopupCancel: () {
//                 _MyAppBar._key?.currentState?.enableButton();
//               },
//               data: widget.data,
//               onMapTap: (latlng) {
//                 (MySolidBottomSheet._key?.currentWidget as MySolidBottomSheet)
//                     ?.hide();
//               },
//             ),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             (_Body._key?.currentWidget as _Body)?.centerCamera();
//           },
//           child: Icon(Icons.my_location),
//         ),
//         bottomSheet: MySolidBottomSheet(
//           data: widget.data,
//           onSelectItem: (latlng) {
//             _Body._key?.currentState?.widget?.animateToLatLng(latlng);
//           },
//         ),
//       ),
//     );
//   }
// }

// class MySolidBottomSheet extends StatefulWidget {
//   final Function(LatLng) onSelectItem;
//   final data;
//   static GlobalKey<MySolidBottomSheetState> _key =
//       GlobalKey<MySolidBottomSheetState>();

//   MySolidBottomSheet({Key key, this.onSelectItem, this.data})
//       : super(key: _key);
//   @override
//   State<StatefulWidget> createState() {
//     return MySolidBottomSheetState();
//   }

//   show() {
//     _key?.currentState?._controller?.show();
//   }

//   hide() {
//     _key?.currentState?._controller?.hide();
//   }
// }

// class MySolidBottomSheetState extends State<MySolidBottomSheet> {
//   bool isShown = false;
//   final BottomBarIcon _icon = BottomBarIcon();

//   var _controller = SolidController();
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SolidBottomSheet(
//       controller: _controller,
//       onShow: () async {
//         _icon.setIconState(true);
//       },
//       onHide: () async {
//         _icon.setIconState(false);
//       },
//       // enableDrag: true,
//       // backgroundColor: Color.fromARGB(0, 0, 0, 0 ),
//       maxHeight: 350,
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
//       body: _OrderTile(
//         onSelectItem: widget.onSelectItem,
//         data: widget.data,
//         // return Container(child: SizedBox(height: , child: Text(""),),);
//       ),
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

//   static GlobalKey<_MyAppBarState> _key = GlobalKey<_MyAppBarState>();
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
//     if (mounted) {
//       setState(() {});
//     }
//   }

//   enableButton() {
//     isButtonEnabled = true;
//     if (mounted) {
//       setState(() {});
//     }
//   }

//   disableButton() {
//     isButtonEnabled = false;
//     if (mounted) {
//       setState(() {});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
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
//   final Function onCancelPopupConfirmed;
//   final Function(LatLng) onMapTap;
//   final Map<String, dynamic> data;
//   final String verificationCode;
//   final onOrderComplete;
//   static GlobalKey<_BodyState> _key = GlobalKey<_BodyState>();

//   _Body({
//     this.onOrderConfirmed,
//     this.onCancelPopupCancel,
//     this.onVerifyPopupCancel,
//     this.onCancelPopupConfirmed,
//     this.onMapTap,
//     this.data,
//     this.verificationCode,
//     this.onOrderComplete,
//   }) : super(key: _key); // = GlobalKey<_BodyState>();

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
//       dropOff: Utils.latLngFromString(widget.data['dropOffLatLng']),
//       pickup: Utils.latLngFromString(widget.data['pickUpLatLng']),
//       onMapTap: (latlng) {
//         widget.onMapTap(latlng);
//         print('Map Tapped');
//       },
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _popups = _Popups(
//       verificationCode: widget.verificationCode,
//       onOrderComplete: widget.onOrderComplete,
//       onOrderConfirmed: widget.onOrderConfirmed,
//       onCancelPopupCancel: widget.onCancelPopupCancel,
//       onOrderCompletePopupCancel: widget.onVerifyPopupCancel,
//       onCancelPopupConfirmed: widget.onCancelPopupConfirmed,
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   Widget getBody() {
//     mapWidget = getMap();

//     return Column(
//       children: [
//         Expanded(
//           child: Stack(
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
//   static GlobalKey<_MapState> _key = GlobalKey<_MapState>();
//   final LatLng pickup;
//   final LatLng dropOff;
//   final Function(LatLng) onMapTap;

//   _MapWidget(
//       {Key key,
//       @required this.pickup,
//       @required this.dropOff,
//       @required this.onMapTap})
//       : super(key: _key);
//   @override
//   State<StatefulWidget> createState() {
//     return _MapState();
//   }

//   void animateTo(LatLng position) async {
//     await _key?.currentState?._controller?.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(target: position, zoom: 15.0),
//       ),
//     );
//     onMapTap(position);
//   }

//   void centerCamera() async {
//     LatLng myLocation = await Utils.getLatestLocation();
//     _key?.currentState?._controller?.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(target: myLocation, zoom: 15.0),
//       ),
//     );
//     onMapTap(myLocation);
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
//     final myLocation = await Utils.getLatestLocation();

//     Marker markerPickup = Marker(
//       markerId: MarkerId("marker1"),
//       infoWindow:
//           InfoWindow(title: "Pick Up", snippet: "Click to Navigate here!"),
//       position: widget.pickup,
//       onTap: () {},
//       flat: false,
//       icon: await BitmapDescriptor.fromAssetImage(
//           ImageConfiguration(
//             size: Size(
//               100,
//               100,
//             ),
//           ),
//           'assets/images/pickup.png'),
//     );

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

//     markers..add(markerPickup)..add(markerDropOff);

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
//       onTap: (latlng) async {
//         widget.onMapTap(latlng);
//         print('Map Original Widget Tapped');
//       },
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
//   static GlobalKey<_PopupsState> _key = GlobalKey<_PopupsState>();
//   final Function onOrderConfirmed;
//   final Function onCancelPopupCancel;
//   final Function onOrderCompletePopupCancel;
//   final Function onCancelPopupConfirmed;
//   final String verificationCode;
//   final onOrderComplete;
//   static var popUpHeight = 200.0;
//   static var popUpWidth = 300.0;

//   _Popups({
//     @required this.onOrderConfirmed,
//     @required this.onCancelPopupCancel,
//     @required this.onOrderCompletePopupCancel,
//     @required this.verificationCode,
//     @required this.onOrderComplete,
//     @required this.onCancelPopupConfirmed,
//   }) : super(key: _key);

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
//     if (mounted) {
//       setState(() {});
//     }
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
//         if (mounted) {
//           setState(() {});
//         }
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
//         isCancelDialogVisible = false;
//         widget.onCancelPopupConfirmed();
//         // Navigator.pop(context);
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
//         BotToast.closeAllLoading();
//         Navigator.popUntil(context, (route) => count++ > 1);
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       behavior: isOrderCompleteDialogueVisible ||
//               isCancelDialogVisible ||
//               isOrderConfirmationVisible
//           ? HitTestBehavior.translucent
//           : HitTestBehavior.deferToChild,
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
//                   isOrderConfirmationVisible ? 0 : -1 * (_Popups.popUpHeight),
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

//   _DeliveryDonePopUp({
//     @required this.verificationCode,
//     @required this.onCancel,
//     @required this.onConfirm,
//   }) : super(key: _key); //@required this.width, @required this.height})

//   static GlobalKey<_DeliveryDonePopUpStateRevised> _key =
//       GlobalKey<_DeliveryDonePopUpStateRevised>();

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
//               controller: _verificationCodeController,
//               animationType: AnimationType.fade,
//               shape: PinCodeFieldShape.box,
//               animationDuration: Duration(milliseconds: 300),
//               borderRadius: BorderRadius.circular(5),
//               selectedColor: Theme.of(context).primaryColor,
//               fieldHeight: 40,
//               fieldWidth: 35,
//               onChanged: (value) {
//                 confirmationKey = value;
//                 setState(() {});
//               },
//             ),
//             SizedBox(
//               height: 8,
//             ),
//             RaisedButton(
//               child: Text(
//                 'Verify',
//                 style: Theme.of(context).textTheme.button,
//               ),
//               onPressed: () async {
//                 final key = widget.verificationCode;
//                 if (confirmationKey == key) {
//                   Utils.showSuccessDialog('Success');
//                   Future.delayed(Duration(seconds: 2)).then((a) {
//                     BotToast.removeAll();
//                   });
//                   widget.onConfirm();
//                 } else {
//                   Utils.showSnackBarError(context, 'Invalid Verification Code');
//                   _verificationCodeController.clear();
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
//       : super(
//           key: _key,
//         ); //@required this.width, @required this.height})

//   // : super(key: key);
//   static GlobalKey<_CancelOrderPopUpStateRevised> _key =
//       GlobalKey<_CancelOrderPopUpStateRevised>();
//   @override
//   State<StatefulWidget> createState() {
//     return _CancelOrderPopUpStateRevised();
//   }

//   void show() {
//     // state.cancelOrderConfirmationShown = true;
//     // state.outerSpaceShown = true;
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
//                       BotToast.closeAllLoading();
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

//   _OrderConfirmation({Key key, @required this.onConfirm, @required this.onExit})
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
//     // orderConfirmed = true;
//     await widget.onConfirm();
//     // Navigator.pop(context);
//     BotToast.closeAllLoading();
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
//           bottom: 50,
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

// class _OrderTile extends StatelessWidget {
//   final Map<String, dynamic> data;
//   final Location location = Location();
//   final Function(LatLng) onSelectItem;

//   _OrderTile({Key key, @required this.data, @required this.onSelectItem})
//       : super(key: key) {
//     location.changeSettings(
//       accuracy: LocationAccuracy.NAVIGATION,
//     );
//   }

//   double getDistanceFromYourLocation(LatLng source, LatLng destination) {
//     return Utils.calculateDistance(source, destination);
//   }

//   _startNavigation(context, LatLng destination, LatLng myLocation) async {
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
//         // if (arrived) {
//         //   await _directions.finishNavigation();
//         //   // Navigator.popUntil(
//         //   //   context,
//         //   //   (route) => route.settings.name == SennitOrderNavigationRoute.NAME,
//         //   // );
//         //   // Utils.showSuccessDialog('You Have Arrived');
//         //   // await Future.delayed(Duration(seconds: 2));
//         //   // BotToast.cleanAll();
//         // }
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
//       simulateRoute: true,
//       language: "English",
//     );
//     // await Future.delayed(
//     //   Duration(seconds: 2),
//     // );
//     BotToast.closeAllLoading();

//     // Navigator.popUntil(
//     //   context,
//     //   (route) => route.settings.name == SennitOrderNavigationRoute.NAME,
//     // );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<Map<String, Address>>(
//       stream: GetIt.I.get<RxAddress>().stream$,
//       builder: (context, snapshot) {
//         LatLng myLocation = snapshot.connectionState == ConnectionState.waiting
//             ? (snapshot.data is LatLng)
//                 ? snapshot.data
//                 : snapshot.data is Coordinates
//                     ? Utils.latLngFromCoordinates(
//                         snapshot.data['myAddress'].coordinates)
//                     : null
//             : snapshot.connectionState == ConnectionState.active
//                 ? LatLng((snapshot.data as LocationData).latitude,
//                     (snapshot.data as LocationData).longitude)
//                 : null;
//         LatLng pickup = Utils.latLngFromString(data['pickUpLatLng']);
//         LatLng destination = Utils.latLngFromString(data['dropOffLatLng']);

//         return Card(
//           margin: EdgeInsets.all(8.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               SizedBox(
//                 height: 8,
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: <Widget>[
//                         Card(
//                           elevation: 4.0,
//                           child: InkWell(
//                             splashColor:
//                                 Theme.of(context).primaryColor.withAlpha(190),
//                             onTap: () async {
//                               onSelectItem(pickup);
//                             },
//                             child: Container(
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                                 children: <Widget>[
//                                   Container(
//                                     decoration: ShapeDecoration(
//                                       color: Theme.of(context).primaryColor,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.only(
//                                             topLeft: Radius.circular(4),
//                                             topRight: Radius.circular(4)),
//                                       ),
//                                     ),
//                                     padding: EdgeInsets.all(4),
//                                     child: Text(
//                                       ' P i c k u p ',
//                                       // textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: 4,
//                                   ),
//                                   Container(
//                                     padding: EdgeInsets.all(8.0),
//                                     child: Text('${data['pickUpAddress']}'),
//                                   ),
//                                   SizedBox(
//                                     height: 4,
//                                   ),
//                                   myLocation != null
//                                       ? Container(
//                                           child: Text.rich(
//                                             TextSpan(
//                                               text: 'Distance: ',
//                                               children: [
//                                                 TextSpan(
//                                                   text:
//                                                       '${getDistanceFromYourLocation(myLocation, pickup).toStringAsFixed(1)} Km',
//                                                   style: TextStyle(
//                                                     fontWeight:
//                                                         FontWeight.normal,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         )
//                                       : Opacity(
//                                           opacity: 0,
//                                         ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 6,
//                         ),
//                         Container(
//                           padding: EdgeInsets.all(8),
//                           child: RaisedButton(
//                             child: Text(
//                               'Start Navigation',
//                               style: TextStyle(color: Colors.white),
//                             ),
//                             onPressed: () async {
//                               _startNavigation(
//                                 context,
//                                 pickup,
//                                 myLocation,
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(
//                     width: 2,
//                   ),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       mainAxisSize: MainAxisSize.min,
//                       children: <Widget>[
//                         Card(
//                           elevation: 4.0,
//                           child: InkWell(
//                             splashColor:
//                                 Theme.of(context).primaryColor.withAlpha(190),
//                             onTap: () async {
//                               onSelectItem(destination);
//                             },
//                             child: Container(
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                                 children: <Widget>[
//                                   Container(
//                                     decoration: ShapeDecoration(
//                                       color: Theme.of(context).primaryColor,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.only(
//                                             topLeft: Radius.circular(4),
//                                             topRight: Radius.circular(4)),
//                                       ),
//                                     ),
//                                     padding: EdgeInsets.all(4),
//                                     child: Text(
//                                       ' D r o p O f f ',
//                                       style: TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 14),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: 4,
//                                   ),
//                                   Container(
//                                     padding: EdgeInsets.all(8.0),
//                                     child: Text('${data['dropOffAddress']}'),
//                                   ),
//                                   SizedBox(
//                                     height: 4,
//                                   ),
//                                   myLocation != null
//                                       ? Container(
//                                           child: Text.rich(
//                                             TextSpan(
//                                               text: 'Distance: ',
//                                               children: [
//                                                 TextSpan(
//                                                     text:
//                                                         '${getDistanceFromYourLocation(myLocation, destination).toStringAsFixed(1)} Km',
//                                                     style: TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.normal,
//                                                     )),
//                                               ],
//                                             ),
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         )
//                                       : Opacity(
//                                           opacity: 0,
//                                         ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 6,
//                         ),
//                         Container(
//                           padding: EdgeInsets.all(8),
//                           child: RaisedButton(
//                             child: Text(
//                               'Start Navigation',
//                               style: TextStyle(color: Colors.white),
//                             ),
//                             onPressed: () async {
//                               _startNavigation(
//                                   context, destination, myLocation);
//                             },
//                             onLongPress: () {},
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Text(
//                 '''${(data['numberOfBoxes'] == null || data['numberOfBoxes'] <= 0) ? '' : '${data['numberOfBoxes']} Box(s)'}
//               ${(data['numberOfSleevesNeeded'] == null || data['numberOfSleevesNeeded'] <= 0) ? '' : '${(data['numberOfBoxes'] != null && data['numberOfBoxes'] > 0) ? ', ' : ''}${data['numberOfSleevesNeeded']} Sleeve(s)'}''',
//                 style: Theme.of(context)
//                     .textTheme
//                     .subtitle1
//                     .copyWith(fontSize: 18),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
