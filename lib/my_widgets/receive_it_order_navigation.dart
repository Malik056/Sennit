import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sennit/main.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

// class SennitOrderRoute extends StatefulWidget {
//   static var popUpHeight = 200.0;
//   static var popUpWidth = 300.0;

//   @override
//   State<StatefulWidget> createState() {
//     // return _SennitOrderRouteState();
//   }
// }

class RecieveItOrderNavigationRoute extends StatelessWidget {
  static var popUpHeight = 200.0;
  static var popUpWidth = 300.0;
  // bool isOrderConfirmed = false;
  final _Body body;
  final _MyAppBar myAppbar;
  final Map<String, dynamic> data;
  final _solidController = SolidController();
  void onDonePressed() {
    body.showDeliveryCompleteDialogue();
  }

  RecieveItOrderNavigationRoute._(
      {@required this.body, @required this.myAppbar, @required this.data});

  factory RecieveItOrderNavigationRoute({@required Map<String, dynamic> data}) {
    _MyAppBar appBar;
    _Body body = _Body(
      onOrderConfirmed: () {
        appBar.showButton();
      },
      onVerifyPopupCancel: () {
        appBar.enableButton();
      },
      onCancelPopupCancel: () {
        appBar.enableButton();
      },
      data: data,
    );
    appBar = _MyAppBar(
      title: "Navigation",
      onDonePressed: () {
        body.showDeliveryCompleteDialogue();
      },
    );

    return RecieveItOrderNavigationRoute._(
      body: body,
      myAppbar: appBar,
      data: data,
    );
  }

  Future<Map<String, dynamic>> getItems() async {
    LatLng destination = Utils.latLngFromString(data['destination']);
    List<String> items = (data['items'] as List).cast<String>();
    List<Map<String, dynamic>> itemDetails = [];
    Map<String, dynamic> result = {};
    for (String item in items) {
      final result =
          await Firestore.instance.collection('items').document(item).get();
      LatLng latlng = Utils.latLngFromString(result.data['latlng']);
      Address address = (await Geocoder.local.findAddressesFromCoordinates(
          Coordinates(latlng.latitude, latlng.longitude)))[0];
      result.data.putIfAbsent('address', () => address.addressLine);
      itemDetails.add(result.data);
    }

    Address address = (await Geocoder.local.findAddressesFromCoordinates(
        Coordinates(destination.latitude, destination.longitude)))[0];
    // itemDetails.add({'destination' : address.addressLine});
    result.putIfAbsent('destination', () {
      return address;
    });
    result.putIfAbsent('destinationLatLng', () {
      return destination;
    });

    result.putIfAbsent('itemDetails', () {
      return itemDetails;
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (body.isOrderConfirmationPopupShown()) {
          Navigator.pop(context);
          return false;
        }
        if (body.isDeliveryCompletePopupShown()) {
          body.hideDeliveryCompleteDialogue();
          myAppbar.enableButton();
          return false;
        }
        if (body.isCancelPopupShown()) {
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
            _solidController.hide();
          },
          child: Icon(Icons.my_location),
        ),
        bottomSheet: SolidBottomSheet(
          controller: _solidController,
          // enableDrag: true,
          // backgroundColor: Color.fromARGB(0, 0, 0, 0 ),
          maxHeight: 550,
          elevation: 8.0,
          draggableBody: true,
          headerBar: Container(
            height: 40,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
            ),
          ),

          body: FutureBuilder<Map<String, dynamic>>(
              future: getItems(),
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
                        height: 200,
                        child: Center(
                          child: ListView.builder(
                            padding: EdgeInsets.only(right: 20),
                            scrollDirection: Axis.horizontal,
                            dragStartBehavior: DragStartBehavior.start,
                            physics: BouncingScrollPhysics(),
                            itemCount:
                                (snapshot.data['itemDetails'] as List).length,
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
                                          body.animteToLatLng(
                                            Utils.latLngFromString(
                                              snapshot.data['itemDetails']
                                                  [index]['latlng'],
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      SizedBox(
                                                        height: 4,
                                                      ),
                                                      Text(
                                                        snapshot.data[
                                                                'itemDetails']
                                                            [index]['itemName'],
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .subhead,
                                                      ),
                                                      SizedBox(
                                                        height: 4,
                                                      ),
                                                      Text(
                                                          '${snapshot.data['itemDetails'][index]['storeName'] + ', ' + snapshot.data['itemDetails'][index]['address']}'),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                          "Price: ${snapshot.data['itemDetails'][index]['price']}",
                                                          overflow: TextOverflow
                                                              .ellipsis,
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
                                              splashColor:
                                  Theme.of(context).primaryColor.withAlpha(190),
                                              onTap: () async {
                                                print('Opened in maps');
                                              },
                                              child: Container(
                                                width: 270.0,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          'Open in Map',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
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
                              LatLng latLng =
                                  snapshot.data['destinationLatLng'];
                              body.animteToLatLng(latLng);
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                      'Open in Map',
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
        ),
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

  final Map<String, dynamic> data;

  _Body({
    @required this.data,
    @required this.onOrderConfirmed,
    @required this.onCancelPopupCancel,
    @required this.onVerifyPopupCancel,
  });

  @override
  State<StatefulWidget> createState() {
    return state;
  }

  bool isOrderConfirmationPopupShown() {
    return state.isOrderConfirmationVisible;
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

  void animteToLatLng(LatLng coordinates) {
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
      dropOff: Utils.latLngFromString(widget.data['destination']),
      pickups: (widget.data['pickups'] as List)
          .map((x) => Utils.latLngFromString(x))
          .toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    _popups = _Popups(
      onOrderConfirmed: widget.onOrderConfirmed,
      onCancelPopupCancel: widget.onCancelPopupCancel,
      onOrderCompletePopupCancel: widget.onVerifyPopupCancel,
    );
  }

  Widget getBody() {
    mapWidget = getMap();

    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
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
  final List<LatLng> pickups;
  final LatLng dropOff;

  _MapWidget({Key key, @required this.pickups, @required this.dropOff})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return state;
  }

  void animateTo(LatLng position) {
    state._controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15.0),
      ),
    );
  }

  void centerCamera() async {
    LatLng mylocation = await Utils.getMyLocation();
    state._controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: mylocation, zoom: 15.0),
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
      onTap: (latlng) async {},
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
  _Popups(
      {@required this.onOrderConfirmed,
      @required this.onCancelPopupCancel,
      @required this.onOrderCompletePopupCancel});

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
      onConfirm: () {
        isOrderConfirmationVisible = false;
        widget.onOrderConfirmed();
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
      onConfirm: () {
        print('on Confirm Called');
        isCancelDialogVisible = false;
        Navigator.pop(context);
      },
    );
    _deliveryDonePopUp = _DeliveryDonePopUp(
      onCancel: () {
        isOrderCompleteDialogeVisible = false;
        widget.onOrderCompletePopupCancel();
        setState(() {});
      },
      onConfirm: () {
        isOrderCompleteDialogeVisible = false;
        Navigator.pop(context);
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
                    ? RecieveItOrderNavigationRoute.popUpWidth
                    : 0,
                height: isCancelDialogVisible
                    ? RecieveItOrderNavigationRoute.popUpHeight
                    : 0,
              ),
            ),
            Center(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                height: isOrderCompleteDialogeVisible
                    ? RecieveItOrderNavigationRoute.popUpHeight
                    : 0,
                width: isOrderCompleteDialogeVisible
                    ? RecieveItOrderNavigationRoute.popUpWidth
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
                  ? 60
                  : -1 * (RecieveItOrderNavigationRoute.popUpHeight),
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

  _DeliveryDonePopUp({
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
              animationType: AnimationType.fade,
              shape: PinCodeFieldShape.box,
              animationDuration: Duration(milliseconds: 300),
              borderRadius: BorderRadius.circular(5),
              selectedColor: Theme.of(context).primaryColor,
              fieldHeight: 40,
              fieldWidth: 35,
              onChanged: (value) {
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
              onPressed: () {
                widget.onConfirm();
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
                    onPressed: () {
                      widget.onConfirm();
                      // Navigator.pop(context);
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
                    onPressed: () {
                      // orderConfirmed = true;
                      widget.onConfirm();
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
