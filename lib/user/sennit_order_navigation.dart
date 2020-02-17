import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sennit/main.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

class SennitOrderNavigationRoute extends StatelessWidget {
  static var popUpHeight = 200.0;
  static var popUpWidth = 300.0;
  // bool isOrderConfirmed = false;
  final _Body body;
  final _MyAppBar myAppbar;
  final Map<String, dynamic> data;
  final MySolidBottomSheet myboottomSheet;

  final Future<String> verificationCode;

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
    var snapshot = Firestore.instance
        .collection("verificationCodes")
        .document(data['orderId'])
        .get();
    var result = snapshot.then<String>((value) {
      return value.data['key'];
    });

    var verificationCode = result;
    _Body body = _Body(
      onDriverAvailable: (latlng) {
        sheet?.refreshState(latlng);
      },
      verificationCode: verificationCode,
      onOrderComplete: () async {
        String driverId =
            await FirebaseAuth.instance.currentUser().then((user) => user.uid);
        DateTime now = DateTime.now();

        Firestore.instance
            .collection("verificationCodes")
            .document(data['orderId'])
            .delete();

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
      },
      onVerifyPopupCancel: () {
        appBar.enableButton();
      },
      data: data,
      onMapTap: (latlng) {
        sheet?.hide();
      },
    );
    appBar = _MyAppBar(
      title: "Navigation",
      onDonePressed: () {
        body.showDeliveryCompleteDialogue();
      },
    );

    sheet = MySolidBottomSheet(
      data: data,
      onSelectItem: (latlng) {
        body.animteToLatLng(latlng);
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
        if (body.isDeliveryCompletePopupShown() ?? false) {
          body.hideDeliveryCompleteDialogue();
          myAppbar.enableButton();
          return false;
        }
        return true;
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

  void refreshState(LatLng driverLatLng) {
    state.refresh(driverLatLng);
  }

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
  _OrderTile orderTile;
  LatLng driverLatLng;

  void refresh(driverLatLng) {
    orderTile?.refresh(driverLatLng);
  }

  @override
  void initState() {
    super.initState();
    orderTile = _OrderTile(
      driverLatLng: driverLatLng,
      onSelectItem: widget.onSelectItem,
      data: widget.data,
      // return Container(child: SizedBox(height: , child: Text("lskjfa"),),);
    );
  }

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
      maxHeight: 280,
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
      body: orderTile,
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
  final Function onVerifyPopupCancel;
  final Function(LatLng) onMapTap;
  final Map<String, dynamic> data;
  final verificationCode;
  final onOrderComplete;

  final Function(LatLng) onDriverAvailable;

  _Body({
    @required this.verificationCode,
    @required this.data,
    @required this.onVerifyPopupCancel,
    @required this.onMapTap,
    @required this.onOrderComplete,
    @required this.onDriverAvailable,
  });

  @override
  State<StatefulWidget> createState() {
    return state;
  }

  bool isDeliveryCompletePopupShown() {
    return state.isOrderCompleteDialogeVisible;
  }

  showDeliveryCompleteDialogue() {
    state.showDeliveryDonePopup();
  }

  hideDeliveryCompleteDialogue() {
    state.hideDeliverDonePopup();
  }

  void centerCamera() {
    state?.mapWidget?.centerCamera();
  }

  void animteToLatLng(LatLng coordinates) {
    state?.mapWidget?.animateTo(coordinates);
  }
}

class _BodyState extends State<_Body> {
  _Popups _popups;

  _MapWidget mapWidget;

  bool get isOrderCompleteDialogeVisible =>
      _popups?.state?.isOrderCompleteDialogeVisible;

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
      onDriverAvailable: widget.onDriverAvailable,
      orderId: widget.data['orderId'],
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
      onOrderCompletePopupCancel: widget.onVerifyPopupCancel,
    );
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
  final String orderId;
  final Function(LatLng) onDriverAvailable;
  final Function(LatLng) onMapTap;

  _MapWidget({
    Key key,
    @required this.onDriverAvailable,
    @required this.pickup,
    @required this.dropOff,
    @required this.onMapTap,
    @required this.orderId,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return state;
  }

  void animateTo(LatLng position) async {
    if (position == null) {
      return;
    }
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
  // GoogleMap map;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  BitmapDescriptor driverIcon;
  GoogleMapController _controller;
  Widget driverInfoWindow;

  @override
  void initState() {
    super.initState();
  }

  Future<GoogleMap> initialize() async {
    final myLocation = await Utils.getMyLocation();
    driverIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        size: Size(
          100,
          100,
        ),
      ),
      'assets/images/flag.png',
    );
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

    return GoogleMap(
      compassEnabled: true,
      initialCameraPosition:
          CameraPosition(target: myLocation, zoom: 14, tilt: 30),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      buildingsEnabled: true,
      markers: Set<Marker>.from(markers),
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
    return FutureBuilder<GoogleMap>(
      future: initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance
                .collection("postedOrders")
                .document(widget.orderId)
                .snapshots(),
            builder: (context, streamSnapshot) {
              return FutureBuilder<GoogleMap>(
                  future:
                      reinitialize(streamSnapshot.data?.data, snapshot.data),
                  builder: (context, snapshot) {
                    return Stack(
                      children: [
                        snapshot.data ??
                            Opacity(
                              opacity: 0,
                            ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: driverInfoWindow ??
                              Opacity(
                                opacity: 0,
                              ),
                        ),
                      ],
                    );
                  });
            });
      },
    );
  }

  Future<GoogleMap> reinitialize(driverData, map) async {
    Map<String, dynamic> data = driverData;

    if (data != null &&
        data.containsKey('driverId') &&
        data['driverId'] != '' &&
        data['driverId'] != null) {
      LatLng driverLatLng = Utils.latLngFromString(data['driverLatLng']);
      widget.onDriverAvailable(driverLatLng);

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

      Marker driverMarker = Marker(
        markerId: MarkerId('driverMarker'),
        infoWindow: InfoWindow(
          title: data['driverName'],
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      );
      LatLng currentLatLng = await _controller?.getLatLng(
        ScreenCoordinate(
            x: MediaQuery.of(context).size.width ~/ 2,
            y: MediaQuery.of(context).size.width ~/ 2),
      );
      markers..add(driverMarker);
      driverInfoWindow = Card(
        margin: EdgeInsets.all(8),
        child: Container(
          width: MediaQuery.of(context).size.width / 1.1,
          // margin: EdgeInsets.all(8),
          // padding: EdgeInsets.all(8),
          child: ListTile(
            onTap: () {
              print('Driver tap: LatLng: ${data['driverLatLng']}');
              widget.animateTo(
                Utils.latLngFromString(
                  data['driverLatLng'],
                ),
              );
              // setState(() {});
            },
            leading: data['driverImage'] == null || data['driverImage'] == ''
                ? Icon(
                    Icons.account_circle,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  )
                : FadeInImage.assetNetwork(
                    placeholder: 'assets/user.png',
                    image: data['driverImage'],
                  ),
            title: Text(data['driverName']),
            subtitle: Text(
              'LatLng: ' + data['driverLatLng'] ?? 'Waiting for Driver',
              style: Theme.of(context).textTheme.body1.copyWith(
                    fontSize: 14,
                    color: Colors.black,
                  ),
            ),
            trailing: Icon(
              Icons.location_on,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      );

      return GoogleMap(
        compassEnabled: true,
        initialCameraPosition: CameraPosition(
          target: currentLatLng??Utils.getLastKnowLocation(),
          zoom: 0,
          tilt: 30,
        ),
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
    return map;
  }
}

class _Popups extends StatefulWidget {
  final state = _PopupsState();
  final Function onOrderCompletePopupCancel;
  final verificationCode;
  final onOrderComplete;

  _Popups({
    @required this.onOrderCompletePopupCancel,
    @required this.verificationCode,
    @required this.onOrderComplete,
  });

  @override
  State<StatefulWidget> createState() {
    return state;
  }
}

class _PopupsState extends State<_Popups> {
  _DeliveryDonePopUp _deliveryDonePopUp;

  bool isOrderCompleteDialogeVisible = false;

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
      behavior: isOrderCompleteDialogeVisible
          ? HitTestBehavior.translucent
          : HitTestBehavior.deferToChild,
      onTap: () {
        if (isOrderCompleteDialogeVisible) {
          isOrderCompleteDialogeVisible = false;
          setState(() {});
          widget.onOrderCompletePopupCancel();
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
                height: isOrderCompleteDialogeVisible
                    ? SennitOrderNavigationRoute.popUpHeight
                    : 0,
                width: isOrderCompleteDialogeVisible
                    ? SennitOrderNavigationRoute.popUpWidth
                    : 0,
                child: _deliveryDonePopUp,
              ),
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
  final Future<String> verificationCode;

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
                final key = await widget.verificationCode;
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

class _OrderTile extends StatefulWidget {
  final Location location = Location();
  final Map<String, dynamic> data;
  final Function(LatLng) onSelectItem;
  final state;

  void refresh(driverLatLng) {
    state.refresh(driverLatLng);
  }

  _OrderTile({
    Key key,
    @required this.data,
    @required this.onSelectItem,
    @required driverLatLng,
  })  : state = _OrderTileState(driverLatLng: driverLatLng),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return state;
  }
}

class _OrderTileState extends State<_OrderTile> {
  // final Map<String, dynamic> data;
  // final Location location = Location();
  // final Function(LatLng) onSelectItem;
  var driverLatLng;

  _OrderTileState({
    @required this.driverLatLng,
  });

  @override
  void initState() {
    super.initState();
    widget.location.changeSettings(
      accuracy: LocationAccuracy.NAVIGATION,
    );
  }

  double getDistanceFromYourLocation(LatLng source, LatLng destination) {
    return Utils.calculateDistance(source, destination);
  }

  void refresh(driverLatLng) {
    this.driverLatLng = driverLatLng;
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // return StreamBuilder<dynamic>(
    //     initialData: null, //Utils.getLastKnowLocation(),
    //     stream: Firestore.instance
    //         .collection('postedOrders')
    //         .document(data['orderId'])
    //         .snapshots(),
    //     builder: (context, snapshot) {
    // LatLng myLocation = snapshot.connectionState ==
    //         ConnectionState.waiting
    //     ? (snapshot.data is LatLng)
    //         ? snapshot.data
    //         : snapshot.data is Coordinates
    //             ? LatLng(snapshot.data.latitude, snapshot.data.longitude)
    //             : snapshot.connectionState == ConnectionState.active
    //                 ? LatLng((snapshot.data as LocationData).latitude,
    //                     (snapshot.data as LocationData).longitude)
    //                 : null
    //     : null;
    // LatLng driverLatLng = snapshot.hasData &&
    //         snapshot.data.data.containsKey('driverLatLng') &&
    //         snapshot.data.data['driverLatLng'] != null
    //     ? Utils.latLngFromString(snapshot.data['driverLatLng'])
    //     : null;
    LatLng pickup = Utils.latLngFromString(widget.data['pickUpLatLng']);
    LatLng destination = Utils.latLngFromString(widget.data['dropOffLatLng']);

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
                          widget.onSelectItem(pickup);
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
                                child: Text('${widget.data['pickUpAddress']}'),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Container(
                                child: Text.rich(
                                  TextSpan(
                                    text: ' Distance: ',
                                    children: [
                                      TextSpan(
                                        text: driverLatLng != null
                                            ? '${getDistanceFromYourLocation(driverLatLng, pickup).toStringAsFixed(1)} Km\n'
                                            : 'Waiting for Driver\n',
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                          'Open in Maps',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          MapsLauncher.launchCoordinates(
                              pickup.latitude, pickup.longitude);
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
                          widget.onSelectItem(destination);
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
                                child: Text('${widget.data['dropOffAddress']}'),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Container(
                                child: Text.rich(
                                  TextSpan(
                                    text: ' Distance: ',
                                    children: [
                                      TextSpan(
                                        text: driverLatLng == null
                                            ? 'Waiting for driver\n'
                                            : '${getDistanceFromYourLocation(driverLatLng, destination).toStringAsFixed(1)} Km\n',
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                          'Open in Maps',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          MapsLauncher.launchCoordinates(
                              destination.latitude, destination.longitude);
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
    // });
  }
}
