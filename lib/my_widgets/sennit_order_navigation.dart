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

class SennitOrderNavigationRoute extends StatelessWidget {
  static const NAME = "SennitOrderNavigationRoute";
  static var popUpHeight = 200.0;
  static var popUpWidth = 300.0;
  static double _lastTimestamp;
  static double _lastDistance;
  static double _currentDistance;
  static double _currentTimestamp;
  // bool isOrderConfirmed = false;
  final _Body body;
  final _MyAppBar myAppbar;
  final Map<String, dynamic> data;
  final MySolidBottomSheet myboottomSheet;

  final String verificationCode;

  static StreamSubscription<LocationData> _driverLocationSubscription;

  void onDonePressed() {
    body.showDeliveryCompleteDialogue();
  }

  SennitOrderNavigationRoute._({
    @required this.body,
    @required this.myAppbar,
    @required this.data,
    @required this.myboottomSheet,
    @required this.verificationCode,
  });

  factory SennitOrderNavigationRoute({@required Map<String, dynamic> data}) {
    _MyAppBar appBar;
    MySolidBottomSheet sheet;
    // var snapshot = Firestore.instance
    //     .collection("verificationCodes")
    //     .document(data['orderId'])
    //     .get();
    // var result = snapshot.then<String>((value) {
    //   return value.data['key'];
    // });

    var verificationCode = data['otp'];
    _Body body = _Body(
      verificationCode: verificationCode,
      onCancelPopupConfiremd: () async {
        data.update(('status'), (old) => 'Pending', ifAbsent: () => 'Accepted');
        data.update(
          ('driverId'),
          (old) => FieldValue.delete(),
          ifAbsent: () => FieldValue.delete(),
        );
        data.update(
          ('driverName'),
          (old) => FieldValue.delete(),
          ifAbsent: () => FieldValue.delete(),
        );
        data.update(
          ('driverImage'),
          (old) => FieldValue.delete(),
          ifAbsent: () => FieldValue.delete(),
        );

        await Firestore.instance
            .collection('postedOrders')
            .document(data['orderId'])
            .setData(
              data,
              merge: true,
            );
        await Firestore.instance
            .collection('userOrders')
            .document(data['userId'])
            .setData(
          {
            data['orderId']: data,
          },
          merge: true,
        );
      },
      onOrderConfirmed: () async {
        Driver driver = Session.data['driver'];
        appBar.showButton();
        data.update(('status'), (old) => 'Accepted',
            ifAbsent: () => 'Accepted');
        data.update(('driverId'), (old) => driver.driverId,
            ifAbsent: () => driver.driverId);
        data.update(('driverName'), (old) => driver.fullname,
            ifAbsent: () => driver.fullname);
        data.update(('driverImage'), (old) => driver.profilePicture,
            ifAbsent: () => driver.profilePicture);
        data.update(('driverPhoneNumber'), (old) => driver.phoneNumber,
            ifAbsent: () => driver.profilePicture);
        data.update(
            ('driverLicencePlateNumber'), (old) => driver.profilePicture,
            ifAbsent: () => driver.profilePicture);
        data.update(
          'acceptedOn',
          (old) => DateTime.now().millisecondsSinceEpoch,
          ifAbsent: () => DateTime.now().millisecondsSinceEpoch,
        );
        await Firestore.instance
            .collection('postedOrders')
            .document(data['orderId'])
            .setData(
              data,
              merge: true,
            );
        await Firestore.instance
            .collection('userOrders')
            .document(data['userId'])
            .setData(
          {
            data['orderId']: data,
          },
          merge: true,
        );
        Location location = Location();
        if (_driverLocationSubscription != null) {
          _driverLocationSubscription = null;
        }
        _driverLocationSubscription =
            location.onLocationChanged().listen((locationData) {
          _lastDistance = _currentDistance;
          _lastTimestamp = _currentTimestamp;
          _currentDistance = Utils.calculateDistance(
            Utils.latLngFromString(data['dropOffLatLng']),
            LatLng(
              locationData.latitude,
              locationData.longitude,
            ),
          );
          _currentTimestamp = DateTime.now().millisecondsSinceEpoch.toDouble();

          Map<String, dynamic> dataToUpload = {
            'lastDistance': _lastDistance,
            'lastTimestamp': _lastTimestamp,
            'currentDistance': _currentDistance,
            'currentTimestamp': _currentTimestamp,
            'driverLatLng':
                '${locationData.latitude},${locationData.longitude}',
          };

          Firestore.instance
              .collection('postedOrders')
              .document(data['orderId'])
              .setData(
                dataToUpload,
                merge: true,
              );
        });
      },
      onOrderComplete: () async {
        String driverId =
            await FirebaseAuth.instance.currentUser().then((user) => user.uid);
        DateTime now = DateTime.now();

        // Firestore.instance
        //     .collection("verificationCodes")
        //     .document(data['orderId'])
        //     .delete();

        // if (_driverLocationSubscription != null) {
        await _driverLocationSubscription?.cancel();
        _driverLocationSubscription = null;
        // }
        var userToken = Firestore.instance
            .collection('users')
            .document(data['userId'])
            .collection('tokens')
            .getDocuments();
        await Firestore.instance
            .collection('userOrders')
            .document(data['userId'])
            .setData(
          {
            data['orderId']: {
              'status': 'Delivered',
              'deliveryDate': '${now.millisecondsSinceEpoch}',
            }
          },
          merge: true,
        );
        await Firestore.instance
            .collection('users')
            .document(data['userId'])
            .collection('notifications')
            .add(
          {
            'title': 'Order Delivered',
            'message': '${data['driverName']} has delivered your order.',
            'seen': false,
            'rated': false,
          },
        );
        final snapshot = await userToken;
        final _fcmServerKey = await Utils.getFCMServerKey();
        final deviceTokens = <String>[];
        snapshot.documents.forEach((document) {
          deviceTokens.add(document.documentID);
        });
        var postRequest = http.post(
          'https://fcm.googleapis.com/fcm/send',
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=$_fcmServerKey',
          },
          body: jsonEncode(
            <String, dynamic>{
              'notification': <String, dynamic>{
                'body': '${data['driverName']} has delivered your order.',
                'title': 'Order Delivered'
              },
              'priority': 'high',
              'data': <String, dynamic>{
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'orderId': '${data['orderId']}',
                'status': 'delivered',
              },
              'registration_ids': deviceTokens,
            },
          ),
        );
        await Firestore.instance
            .collection('postedOrders')
            .document(data['orderId'])
            .delete();

        await Firestore.instance
            .collection('driverOrders')
            .document(driverId)
            .setData({
          data['orderId']: data
            ..update(
              'status',
              (old) => 'Delivered',
              ifAbsent: () => 'Delivered',
            )
            ..update(
              'deliveryDate',
              (old) => '${now.millisecondsSinceEpoch}',
              ifAbsent: () => '${now.millisecondsSinceEpoch}',
            ),
        });
        await postRequest;
      },
      onVerifyPopupCancel: () {
        appBar.enableButton();
      },
      onCancelPopupCancel: () {
        appBar.enableButton();
      },
      data: data,
      onMapTap: (latlng) {
        sheet?.hide();
      },
    );
    appBar = _MyAppBar(
      title: "${data['price']}R",
      onDonePressed: () {
        body.showDeliveryCompleteDialogue();
      },
    );

    sheet = MySolidBottomSheet(
      data: data,
      onSelectItem: (latlng) {
        body.animateToLatLng(latlng);
      },
    );

    return SennitOrderNavigationRoute._(
      body: body,
      myAppbar: appBar,
      data: data,
      myboottomSheet: sheet,
      verificationCode: verificationCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (body.isOrderConfirmationPopupShown() ?? false) {
          Navigator.pop(context);
          return false;
        }
        if (body.isDeliveryCompletePopupShown()) {
          body.hideDeliveryCompleteDialogue();
          myAppbar.enableButton();
          return false;
        }
        if (body.isCancelPopupShown() ?? false) {
          body.hideCancelDialogue();
          myAppbar.enableButton();
          return false;
        } else {
          body.showCancelDialogue();
          myAppbar.disableButton();
          return false;
        }
      },
      child: Scaffold(
        appBar: myAppbar,
        body: Stack(
          children: <Widget>[
            body,
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            body.centerCamera();
          },
          child: Icon(Icons.my_location),
        ),
        bottomSheet: myboottomSheet,
      ),
    );
  }
}

class MySolidBottomSheet extends StatefulWidget {
  final Function(LatLng) onSelectItem;
  final data;
  final state = MySolidBottomSheetState();

  MySolidBottomSheet({Key key, this.onSelectItem, this.data}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return state;
  }

  show() {
    state?._controller?.show();
  }

  hide() {
    state?._controller?.hide();
  }
}

class MySolidBottomSheetState extends State<MySolidBottomSheet> {
  bool isShown = false;
  final BottomBarIcon _icon = BottomBarIcon();

  var _controller = SolidController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SolidBottomSheet(
      controller: _controller,
      onShow: () async {
        _icon.setIconState(true);
      },
      onHide: () async {
        _icon.setIconState(false);
      },
      // enableDrag: true,
      // backgroundColor: Color.fromARGB(0, 0, 0, 0 ),
      maxHeight: 250,
      elevation: 8.0,
      draggableBody: true,
      headerBar: Container(
        height: 40,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
        ),
        child: _icon,
      ),
      body: _OrderTile(
        onSelectItem: widget.onSelectItem,
        data: widget.data,
        // return Container(child: SizedBox(height: , child: Text("lskjfa"),),);
      ),
    );
  }
}

class BottomBarIcon extends StatefulWidget {
  BottomBarIcon({Key key}) : super(key: key);
  final state = _BottomBarIconState();
  @override
  _BottomBarIconState createState() => state;

  setIconState(bool isShown) {
    state.isShown = isShown;
    state.refresh();
  }
}

class _BottomBarIconState extends State<BottomBarIcon> {
  void refresh() {
    setState(() {});
  }

  bool isShown = false;
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
  final state = _MyAppBarState();

  _MyAppBar({Key key, this.title, this.onDonePressed}) : super(key: key);

  void showButton() {
    state.showButton();
  }

  void hideButton() {}

  void enableButton() {
    state.enableButton();
  }

  void disableButton() {
    state.disableButton();
  }

  void refresh() {
    state.refresh();
  }

  @override
  State<StatefulWidget> createState() {
    return state;
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
  final state = _BodyState();
  final Function onOrderConfirmed;
  final Function onCancelPopupCancel;
  final Function onVerifyPopupCancel;
  final Function onCancelPopupConfiremd;
  final Function(LatLng) onMapTap;
  final Map<String, dynamic> data;
  final String verificationCode;
  final onOrderComplete;

  _Body({
    @required this.verificationCode,
    @required this.data,
    @required this.onOrderConfirmed,
    @required this.onCancelPopupCancel,
    @required this.onVerifyPopupCancel,
    @required this.onMapTap,
    @required this.onOrderComplete,
    @required this.onCancelPopupConfiremd,
  });

  @override
  State<StatefulWidget> createState() {
    return state;
  }

  bool isOrderConfirmationPopupShown() {
    return state?.isOrderConfirmationVisible;
  }

  bool isCancelPopupShown() {
    return state.isCancelDialogVisible;
  }

  bool isDeliveryCompletePopupShown() {
    return state.isOrderCompleteDialogeVisible;
  }

  showCancelDialogue() {
    state.showCancelPopup();
  }

  showDeliveryCompleteDialogue() {
    state.showDeliveryDonePopup();
  }

  hideCancelDialogue() {
    state.hideCancelPopup();
  }

  hideDeliveryCompleteDialogue() {
    state.hideDeliverDonePopup();
  }

  void centerCamera() {
    state?.mapWidget?.centerCamera();
  }

  void animateToLatLng(LatLng coordinates) {
    state?.mapWidget?.animateTo(coordinates);
  }
}

class _BodyState extends State<_Body> {
  _Popups _popups;

  _MapWidget mapWidget;

  bool get isCancelDialogVisible => _popups?.state?.isCancelDialogVisible;

  bool get isOrderCompleteDialogeVisible =>
      _popups?.state?.isOrderCompleteDialogeVisible;

  bool get isOrderConfirmationVisible =>
      _popups?.state?.isOrderConfirmationVisible;

  showCancelPopup() {
    _popups?.state?.showCancelPopup();

    // setState(() {});
  }

  hideCancelPopup() {
    // isCancelDialogVisible = false;
    _popups?.state?.hideCancelPopup();
    // setState(() {});
  }

  showDeliveryDonePopup() {
    // isOrderCompleteDialogeVisible = true;
    _popups?.state?.showOrderCompletePopup();
    // setState(() {});
  }

  hideDeliverDonePopup() {
    _popups?.state?.hideOrderCompletePopup();
    // setState(() {});
  }

  Widget getMap() {
    return _MapWidget(
      dropOff: Utils.latLngFromString(widget.data['dropOffLatLng']),
      pickup: Utils.latLngFromString(widget.data['pickUpLatLng']),
      onMapTap: (latlng) {
        widget.onMapTap(latlng);
        print('Map Tapped');
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _popups = _Popups(
      verificationCode: widget.verificationCode,
      onOrderComplete: widget.onOrderComplete,
      onOrderConfirmed: widget.onOrderConfirmed,
      onCancelPopupCancel: widget.onCancelPopupCancel,
      onOrderCompletePopupCancel: widget.onVerifyPopupCancel,
      onCancelPopupConfirmed: widget.onCancelPopupConfiremd,
    );
  }

  @override
  void dispose() {
    SennitOrderNavigationRoute?._driverLocationSubscription?.cancel();
    SennitOrderNavigationRoute?._driverLocationSubscription = null;
    super.dispose();
  }

  Widget getBody() {
    mapWidget = getMap();

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: <Widget>[
              mapWidget,
              _popups,
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
  final _MapState state = _MapState();
  final LatLng pickup;
  final LatLng dropOff;
  final Function(LatLng) onMapTap;

  _MapWidget(
      {Key key,
      @required this.pickup,
      @required this.dropOff,
      @required this.onMapTap})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return state;
  }

  void animateTo(LatLng position) async {
    await state._controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15.0),
      ),
    );
    onMapTap(position);
  }

  void centerCamera() async {
    LatLng mylocation = await Utils.getMyLocation();
    state._controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: mylocation, zoom: 15.0),
      ),
    );
    onMapTap(mylocation);
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

    Marker markerPickup = Marker(
      markerId: MarkerId("marker1"),
      infoWindow:
          InfoWindow(title: "Pick Up", snippet: "Click to Navigate here!"),
      position: widget.pickup,
      onTap: () {},
      flat: false,
      icon: await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(
            size: Size(
              100,
              100,
            ),
          ),
          'assets/images/pickup.png'),
    );

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

    markers..add(markerPickup)..add(markerDropOff);

    map = GoogleMap(
      compassEnabled: true,
      initialCameraPosition:
          CameraPosition(target: myLocation, zoom: 14, tilt: 30),
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
      onTap: (latlng) async {
        widget.onMapTap(latlng);
        print('Map Original Widget Tapped');
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
          children: [map],
        );
      },
    );
  }
}

class _Popups extends StatefulWidget {
  final state = _PopupsState();
  final Function onOrderConfirmed;
  final Function onCancelPopupCancel;
  final Function onOrderCompletePopupCancel;
  final Function onCancelPopupConfirmed;
  final String verificationCode;
  final onOrderComplete;

  _Popups({
    @required this.onOrderConfirmed,
    @required this.onCancelPopupCancel,
    @required this.onOrderCompletePopupCancel,
    @required this.verificationCode,
    @required this.onOrderComplete,
    @required this.onCancelPopupConfirmed,
  });

  @override
  State<StatefulWidget> createState() {
    return state;
  }
}

class _PopupsState extends State<_Popups> {
  _OrderConfirmation _orderConfirmationPopup;
  _DeliveryDonePopUp _deliveryDonePopUp;
  _CancelOrderPopUp _cancelOrderPopUp;

  bool isOrderConfirmationVisible = true;
  bool isOrderCompleteDialogeVisible = false;
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
    isOrderCompleteDialogeVisible = true;
    setState(() {});
    // _deliveryDonePopUp?.show();
  }

  hideOrderCompletePopup() {
    isOrderCompleteDialogeVisible = false;
    // _deliveryDonePopUp.hide();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _orderConfirmationPopup = _OrderConfirmation(
      onConfirm: () async {
        isOrderConfirmationVisible = false;
        await widget.onOrderConfirmed();
        setState(() {});
      },
      onExit: () {
        isOrderConfirmationVisible = false;
        Navigator.of(context).pop();
      },
    );

    _cancelOrderPopUp = _CancelOrderPopUp(
      onCancel: () {
        print('on Cancel Called');
        isCancelDialogVisible = false;
        widget.onCancelPopupCancel();
        setState(() {});
      },
      onConfirm: () async {
        print('on Confirm Called');
        isCancelDialogVisible = false;
        widget.onCancelPopupConfirmed();
        // Navigator.pop(context);
      },
    );
    _deliveryDonePopUp = _DeliveryDonePopUp(
      verificationCode: widget.verificationCode,
      onCancel: () {
        isOrderCompleteDialogeVisible = false;
        widget.onOrderCompletePopupCancel();
        setState(() {});
      },
      onConfirm: () async {
        isOrderCompleteDialogeVisible = false;
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
      behavior: isOrderCompleteDialogeVisible ||
              isCancelDialogVisible ||
              isOrderConfirmationVisible
          ? HitTestBehavior.translucent
          : HitTestBehavior.deferToChild,
      onTap: () {
        if (!isOrderConfirmationVisible) {
          if (isCancelDialogVisible) {
            isCancelDialogVisible = false;
            setState(() {});
            widget.onCancelPopupCancel();
          } else if (isOrderCompleteDialogeVisible) {
            isOrderCompleteDialogeVisible = false;
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
                width: isCancelDialogVisible
                    ? SennitOrderNavigationRoute.popUpWidth
                    : 0,
                height: isCancelDialogVisible
                    ? SennitOrderNavigationRoute.popUpHeight
                    : 0,
              ),
            ),
            Center(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                height: isOrderCompleteDialogeVisible
                    ? SennitOrderNavigationRoute.popUpHeight
                    : 0,
                width: isOrderCompleteDialogeVisible
                    ? SennitOrderNavigationRoute.popUpWidth
                    : 0,
                child: _deliveryDonePopUp,
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              child: _orderConfirmationPopup,
              left: 0,
              right: 0,
              bottom: isOrderConfirmationVisible
                  ? 0
                  : -1 * (SennitOrderNavigationRoute.popUpHeight),
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

  _DeliveryDonePopUp({
    @required this.verificationCode,
    @required this.onCancel,
    @required this.onConfirm,
  }); //@required this.width, @required this.height})

  final _DeliveryDonePopUpStateRevised state = _DeliveryDonePopUpStateRevised();

  // : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return state;
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
              style: Theme.of(context).textTheme.display1,
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
              controller: _verificationCodeController,
              animationType: AnimationType.fade,
              shape: PinCodeFieldShape.box,
              animationDuration: Duration(milliseconds: 300),
              borderRadius: BorderRadius.circular(5),
              selectedColor: Theme.of(context).primaryColor,
              fieldHeight: 40,
              fieldWidth: 35,
              onChanged: (value) {
                confirmationKey = value;
                setState(() {});
              },
            ),
            SizedBox(
              height: 8,
            ),
            RaisedButton(
              child: Text(
                'Verify',
                style: Theme.of(context).textTheme.button,
              ),
              onPressed: () async {
                final key = widget.verificationCode;
                if (confirmationKey == key) {
                  Utils.showSuccessDialog('Success');
                  Future.delayed(Duration(seconds: 2)).then((a) {
                    BotToast.removeAll();
                  });
                  widget.onConfirm();
                } else {
                  Utils.showSnackBarError(context, 'Invalid Verification Code');
                  _verificationCodeController.clear();
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

  _CancelOrderPopUp(
      {@required this.onConfirm,
      @required this.onCancel}); //@required this.width, @required this.height})

  // : super(key: key);
  final _CancelOrderPopUpStateRevised state = _CancelOrderPopUpStateRevised();
  @override
  State<StatefulWidget> createState() {
    return state;
  }

  void show() {
    // state.cancelOrderConfirmationShown = true;
    // state.outerspaceShown = true;
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
                style: Theme.of(context).textTheme.display1,
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'Are you sure you wanna cancel the delivery? ',
                style: Theme.of(context).textTheme.subtitle,
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

  _OrderConfirmation({Key key, @required this.onConfirm, @required this.onExit})
      : super(key: key);

  final _OrderConfirmationStateRevised state = _OrderConfirmationStateRevised();

  @override
  State<StatefulWidget> createState() {
    return state;
  }

  // void show() {
  //   state.orderConfirmed = false;
  // }

  // void refresh() {
  //   state.refresh();
  // }

}

class _OrderConfirmationStateRevised extends State<_OrderConfirmation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.blue,
      // width: MediaQuery.of(context).size.width,
      child: Card(
        margin: EdgeInsets.only(
          left: 30,
          right: 30,
          bottom: 50,
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
              style: Theme.of(context).textTheme.title,
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
                      Utils.showLoadingDialog(context);
                      // orderConfirmed = true;
                      await widget.onConfirm();
                      Navigator.pop(context);
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
      (route) => route.settings.name == SennitOrderNavigationRoute.NAME,
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
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 8,
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
            ],
          ),
        );
      },
    );
  }
}
