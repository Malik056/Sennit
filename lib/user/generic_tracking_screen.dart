import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart'
    as mapbox;
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sennit/main.dart';
import 'package:sennit/models/models.dart';
import 'package:sennit/rx_models/rx_address.dart';
import 'package:sennit/rx_models/rx_storesAndItems.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

enum OrderTrackingType {
  SENNIT,
  RECEIVE_IT,
}

class OrderTracking extends StatefulWidget {
  final data;
  final OrderTrackingType type;
  static const NAME = "OrderTracking";

  OrderTracking({@required this.data, @required this.type});

  static startNavigation(context, LatLng destination, LatLng myLocation) async {
    // Utils.showLoadingDialog(context);
    // MapsLauncher.launchCoordinates(
    //     pickup.latitude, pickup.longitude);
    Utils.showSnackBarWarning(context, 'Loading Route, Please Wait......');
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
          // Navigator.popUntil(
          //   context,
          //   (route) => route.settings.name == OrderTracking.NAME,
          // );
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
    // Navigator.popUntil(
    //   context,
    //   (route) => route.settings.name == OrderTracking.NAME,
    // );
  }

  @override
  State<StatefulWidget> createState() {
    return _OrderTrackingState();
  }
}

class _OrderTrackingState extends State<OrderTracking> {
  // _Body body;
  // _MyStatefulAppBar appbar;
  RxAddress addressService = GetIt.I.get<RxAddress>();
  _MySolidBottomSheetForReceiveIt solidBottomSheet;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    LatLng myLatLng = Utils.latLngFromCoordinates(
        addressService.currentMyAddress.coordinates);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.my_location),
        onPressed: () {
          (_Body._key?.currentWidget as _Body)?.animateToLatLng(myLatLng);
        },
      ),
      key: scaffoldKey,
      appBar: _MyStatefulAppBar(
        title: 'R${(widget.data['price'] as double).toStringAsFixed(2)}',
        onDonePressed: () {
          _Body._key?.currentState?.showPopup();
        },
      ),
      body: _Body(
        onPopupHidden: () {
          _MyStatefulAppBar?._key?.currentState?.showButton();
        },
        pickups: widget.type == OrderTrackingType.RECEIVE_IT
            ? (widget.data['pickups'] as List)
                .map((x) => Utils.latLngFromString(x))
                .toList()
            : [Utils.latLngFromString(widget.data['pickUpLatLng'])],
        dropOff: Utils.latLngFromString(widget.data[
            widget.type == OrderTrackingType.SENNIT
                ? 'dropOffLatLng'
                : 'destination']),
        overlayClicked: () {
          _MyStatefulAppBar?._key?.currentState?.showButton();
          print('Overlay Clicked');
        },
        onMapTap: (latlng) {},
        data: widget.data,
        onDriverAvailable: (latlng) {},
      ),
      bottomSheet: widget.type == OrderTrackingType.RECEIVE_IT
          ? _MySolidBottomSheetForReceiveIt(
              data: widget.data,
              animateToLatLng: (latlng) {
                (_Body._key?.currentWidget as _Body)?.animateToLatLng(latlng);
              },
            )
          : MySolidBottomSheet(
              data: widget.data,
              onSelectItem: (latlng) {
                (_Body._key?.currentWidget as _Body)?.animateToLatLng(latlng);
              },
            ),
    );
  }
}

class _MyStatefulAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Function() onDonePressed;
  static GlobalKey<__MyStatefulAppBarState> _key =
      GlobalKey<__MyStatefulAppBarState>();
  _MyStatefulAppBar({@required this.title, @required this.onDonePressed})
      : super(key: _key);

  @override
  __MyStatefulAppBarState createState() => __MyStatefulAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class __MyStatefulAppBarState extends State<_MyStatefulAppBar> {
  bool isButtonVisible = true;
  bool isButtonEnabled = true;

  refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  showButton() {
    isButtonVisible = true;
    isButtonEnabled = true;
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
      title: Text(widget.title),
      centerTitle: true,
      actions: <Widget>[
        !isButtonVisible
            ? Opacity(
                opacity: 0,
              )
            : FlatButton(
                child: Text('OTP'),
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
  final List<LatLng> pickups;
  final LatLng dropOff;
  final Function() overlayClicked;
  static GlobalKey<__BodyState> _key = GlobalKey<__BodyState>();
  final Function(LatLng) onMapTap;
  final Map<String, dynamic> data;
  final Function(LatLng) onDriverAvailable;

  final Function() onPopupHidden;

  _Body({
    @required this.pickups,
    @required this.dropOff,
    @required this.overlayClicked,
    @required this.onMapTap,
    @required this.data,
    @required this.onDriverAvailable,
    @required this.onPopupHidden,
  }) : super(key: _key);

  @override
  __BodyState createState() => __BodyState();

  Future<void> animateToLatLng(LatLng position) async {
    if (position == null) {
      return;
    }
    await _key?.currentState?._controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15.0),
      ),
    );
    onMapTap(position);
  }

  void centerCamera() async {
    LatLng myLocation = await Utils.getLatestLocation();
    _key?.currentState?._controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: myLocation, zoom: 15.0),
      ),
    );
    onMapTap(myLocation);
  }

  showPopup() {
    _key?.currentState?.showPopup();
  }

  hidePopup() {
    _key?.currentState?.hidePopup();
  }
}

class __BodyState extends State<_Body> {
  // bool isOverlayVisible = false;
  List<Marker> markers = [];
  Set<Polyline> polylines = {};
  // BitmapDescriptor driverIcon;
  GoogleMapController _controller;
  Widget driverInfoWindow;
  Marker driverMarker;
  List<Marker> markerPickups;
  Marker markerDropOff;
  BitmapDescriptor driverIcon;
  BitmapDescriptor pickupIcon;
  BitmapDescriptor dropOffIcon;
  Future<LatLng> initializeTracking;
  StreamSubscription<DocumentSnapshot> _firebaseSubscription;
  RxAddress addressService = GetIt.I.get<RxAddress>();

  String driverId;
  String driverLicencePlateNumber;
  String driverImage;
  String driverName;
  LatLng driverLatLng;
  String driverPhoneNumber;
  bool firstTime = true;
  _VerificationCodePopUp popUp;

  double time = 0;

  showPopup() {
    // isOverlayVisible = true;
    _VerificationCodePopUp?._key?.currentState?.show();
    if (mounted) {
      setState(() {});
    }
  }

  hidePopup() {
    // isOverlayVisible = false;
    _VerificationCodePopUp?._key?.currentState?.hide();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    initializeTracking = initialize();
    popUp = _VerificationCodePopUp(
      verificationCode: widget.data['otp'],
      onHide: widget.onPopupHidden,
    );
  }

  double calculateTime({
    double lastDistance,
    double lastSpeed = 25,
    double lastTimestamp,
    double currentDistance,
    double currentTimestamp,
  }) {
    if (lastDistance == null || lastTimestamp == null) {
      return currentDistance / lastSpeed;
    } else {
      var distanceChange = lastDistance - currentDistance;
      if (distanceChange < 0) {
        return lastDistance / lastSpeed;
      } else {
        var timeDifference = currentTimestamp - lastTimestamp;
        if (timeDifference <= 0) {
          return lastSpeed;
        } else {
          var currentSpeed = distanceChange / timeDifference;
          return currentDistance / currentSpeed;
        }
      }
    }
  }

  Future<LatLng> initialize() async {
    driverLatLng = Utils.latLngFromString(widget.data['driverLatLng']);
    driverId = widget.data['driverId'];
    driverLicencePlateNumber = widget.data['driverLicencePlateNumber'];
    driverPhoneNumber = widget.data['driverPhoneNumber'];
    driverName = widget.data['driverName'];
    driverImage = widget.data['driverImage'];

    // await Utils.getMyLocation().timeout(Duration(seconds: 2), onTimeout: () {
    //   return;
    // });
    // LatLng myLatLng = await Utils.getLatestLocation();
    driverIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      'assets/images/car.png',
    );
    // pickupIcon = await BitmapDescriptor.fromAssetImage(
    //     ImageConfiguration(
    //       size: Size(
    //         100,
    //         100,
    //       ),
    //     ),
    //     'assets/images/pickup.png');
    dropOffIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(
          size: Size(
            100,
            100,
          ),
        ),
        'assets/images/flag.png');
    if (_firebaseSubscription != null) {
      _firebaseSubscription.cancel();
    }
    final tempPickups = [];
    int index = 0;
    for (LatLng pickup in widget.pickups) {
      if (!tempPickups.contains(pickup)) {
        index++;
        Marker markerPickup = Marker(
          markerId: MarkerId("marker$index"),
          infoWindow: InfoWindow(title: "Item", snippet: "Your Ordered Item!"),
          position: pickup,
          onTap: () {},
          flat: false,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            250,
          ),
        );
        tempPickups.add(pickup);
        markers.add(markerPickup);
      }
    }

    markerDropOff = Marker(
      markerId: MarkerId('dropOffMarker'),
      infoWindow: InfoWindow(title: "Drop Off", snippet: "Drop off point"),
      position: widget.dropOff,
      icon: dropOffIcon,
    );
    driverMarker = Marker(
      markerId: MarkerId('driverMarker'),
      flat: true,
      rotation: 0,
      position: driverLatLng ?? LatLng(0, 0),
      icon: driverIcon,
      draggable: false,
      visible: driverLatLng != null,
    );
    _firebaseSubscription = Firestore.instance
        .collection('orders')
        .document(widget.data['orderId'])
        .snapshots()
        .listen((orderData) async {
      if (orderData.data == null) {
        return;
      }
      driverLatLng = Utils.latLngFromString((orderData.data)['driverLatLng']);
      await Future.delayed(Duration(seconds: 3));
      time = 0;
      if (driverLatLng != null && firstTime && _controller != null) {
        firstTime = false;
        await widget.animateToLatLng(driverLatLng);
      } else if (driverLatLng != null && _controller != null) {
        time = calculateTime(
          lastDistance: orderData['lastDistance'],
          // lastSpeed: orderData['lastSpeed'],
          lastTimestamp: orderData['lastTimestamp'],
          currentDistance: orderData['currentDistance'],
          currentTimestamp: orderData['currentTimestamp'],
        );
      }
      if (mounted) {
        setState(() {
          driverId = orderData.data['driverId'];
          driverLicencePlateNumber = orderData.data['driverLicencePlateNumber'];
          driverPhoneNumber = orderData.data['driverPhoneNumber'];
          driverName = orderData.data['driverName'];
          driverImage = orderData.data['driverImage'];
          if (driverLatLng != null) {
            widget.onDriverAvailable(driverLatLng);
          }
          driverMarker = Marker(
            markerId: MarkerId('driverMarker'),
            flat: true,
            rotation: 90,
            icon: driverIcon,
            anchor: Offset(
              0.5,
              0.5,
            ),
            zIndex: 2,
            draggable: false,
            position: orderData.data['driverLatLng'] != null
                ? Utils.latLngFromString(orderData.data['driverLatLng'])
                : LatLng(0, 0),
            visible: orderData.data.containsKey('driverId') &&
                    orderData.data['driverId'] != null
                ? true
                : false,
          );
        });
      }
    });
    return driverLatLng;
  }

  @override
  void dispose() {
    super.dispose();
    _firebaseSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        FutureBuilder<LatLng>(
            future: initializeTracking,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Container(
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    GoogleMap(
                      myLocationEnabled: true,
                      initialCameraPosition: CameraPosition(
                        target: snapshot.data ??
                            Utils.latLngFromCoordinates(
                              addressService.currentMyAddress.coordinates,
                            ),
                        zoom: 14,
                      ),
                      buildingsEnabled: false,
                      compassEnabled: true,
                      mapType: MapType.terrain,
                      trafficEnabled: true,

                      // circles: driverId != null
                      //     ? Set.from({
                      //         Circle(
                      //           circleId: CircleId('driverCircle'),
                      //           center: driverLatLng,
                      //           radius: 10,
                      //           fillColor: Colors.blueGrey,
                      //           strokeColor: Colors.blueAccent,
                      //         )
                      //       })
                      //     : {},
                      onMapCreated: (controller) {
                        _controller = controller;
                      },
                      markers: markers != null
                          ? Set.from(driverMarker == null
                              ? ((markers.toList())..add(markerDropOff))
                              : markers.toList()
                            ..add(markerDropOff)
                            ..add(driverMarker))
                          : {},
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: driverId != null
                          ? Card(
                              margin: EdgeInsets.all(8),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 1.1,
                                // margin: EdgeInsets.all(8),
                                // padding: EdgeInsets.all(8),
                                child: ListTile(
                                  onTap: () {
                                    print(
                                        'Driver tap: LatLng: ${driverLatLng.toString()}');
                                    widget.animateToLatLng(
                                      // Utils.latLngFromString(
                                      driverLatLng,
                                      // ),
                                    );
                                    // setState(() {});
                                  },
                                  leading: driverImage == null ||
                                          driverImage == ''
                                      ? Icon(
                                          Icons.account_circle,
                                          size: 40,
                                          color: Theme.of(context).primaryColor,
                                        )
                                      : FadeInImage.assetNetwork(
                                          placeholder: 'assets/images/user.png',
                                          image: driverImage,
                                          width: 80,
                                          height: 80,
                                        ),
                                  title: Text(driverName),
                                  subtitle: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        driverLicencePlateNumber ??
                                            'Not Registered',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      // Text.rich(
                                      //   TextSpan(
                                      //     children: [
                                      //       TextSpan(
                                      //         text: 'ETA: ',
                                      //         style: Theme.of(context)
                                      //             .textTheme
                                      //             .subtitle,
                                      //       ),
                                      //       TextSpan(
                                      //         text:
                                      //             '${time / 60} minutes, ${time % 60} seconds',
                                      //         style: Theme.of(context)
                                      //             .textTheme
                                      //             .bodyText2,
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                      // SizedBox(
                                      //   height: 4,
                                      // ),
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Phone: ',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2,
                                            ),
                                            TextSpan(
                                              text: driverPhoneNumber ??
                                                  'Not Available',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: InkWell(
                                    onTap: () {
                                      OrderTracking.startNavigation(
                                        context,
                                        driverLatLng,
                                        Utils.latLngFromCoordinates(
                                            addressService
                                                .currentMyAddress.coordinates),
                                      );
                                    },
                                    child: Container(
                                      height: 80,
                                      padding: EdgeInsets.all(4),
                                      decoration: ShapeDecoration(
                                        shape: Border(
                                          left: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 2),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Icon(
                                            Icons.location_on,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          Text(
                                            'Go',
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Card(
                              margin: EdgeInsets.all(8),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 1.1,
                                // margin: EdgeInsets.all(8),
                                // padding: EdgeInsets.all(8),
                                child: Center(
                                  heightFactor: 2,
                                  child: Text(
                                    ' Finding Your Driver .... ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              );
            }),
        // isOverlayVisible
        //     ? GestureDetector(
        //         onTap: () {
        //           isOverlayVisible = false;
        //           widget.overlayClicked();
        //           setState(() {});
        //         },
        //         child: Container(
        //           color: Colors.black54,
        //         ),
        //       )
        //     : SizedBox(
        //         height: 0,
        //         width: 0,
        //       ),
        popUp,
      ],
    );
  }
}

class _MySolidBottomSheetForReceiveIt extends StatefulWidget {
  // static GlobalKey<_MySolidBottomSheetForReceiveItState> _key =
  //     GlobalKey<_MySolidBottomSheetForReceiveItState>();
  final data;

  final Function(LatLng) animateToLatLng;

  _MySolidBottomSheetForReceiveIt({
    @required this.data,
    @required this.animateToLatLng,
  }); // : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MySolidBottomSheetForReceiveItState();
  }
}

class _MySolidBottomSheetForReceiveItState
    extends State<_MySolidBottomSheetForReceiveIt> {
  var _solidController = SolidController();
  Future<Map<String, dynamic>> items;
  final BottomBarIcon _icon = BottomBarIcon();
  RxAddress addressService = GetIt.I.get<RxAddress>();
  OrderFromReceiveIt order;
  show() {
    _solidController?.show();
    // _icon?.setIconState(true);
  }

  hide() {
    _solidController?.hide();
    // _icon?.setIconState(false);
  }

  Future<Map<String, dynamic>> getItems(data) async {
    LatLng destination = Utils.latLngFromString(data['destination']);
    StoreToReceiveItOrderItems itemsData =
        StoreToReceiveItOrderItems.fromMap(data['itemsData']);
    List<Map<String, dynamic>> itemDetails = [];
    Map<String, dynamic> result = {};
    final keys = itemsData.itemDetails.keys;
    for (String itemKey in keys) {
      final result =
          await Firestore.instance.collection('items').document(itemKey).get();
      result.data.update(
        'price',
        (old) => old.runtimeType == int ? (old as int).toDouble() : old,
      );
      // LatLng latlng = Utils.latLngFromString(result.data['latlng']);
      // Address address = (await Geocoder.google(await Utils.getAPIKey())
      //     .findAddressesFromCoordinates(
      //         Coordinates(latlng.latitude, latlng.longitude)))[0];
      result.data.putIfAbsent('address', () => result.data['storeAddress']);
      itemDetails.add(result.data);
    }

    Address address = (await Geocoder.google(await Utils.getAPIKey())
        .findAddressesFromCoordinates(
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
  void initState() {
    super.initState();
    _solidController = SolidController();
    order = OrderFromReceiveIt.fromMap(widget.data);
  }

  Future<Address> initializeItemsAndGetAddress() async {
    // LatLng destination = Utils.latLngFromString(order.destination);
    StoreToReceiveItOrderItems itemsData = order.itemsData;
    // List<Map<String, dynamic>> itemDetails = [];
    // Map<String, dynamic> finalResult = {};
    final keys = itemsData.itemDetails.keys;
    List<Future<DocumentSnapshot>> requests = [];
    RxStoresAndItems storesAndItems = GetIt.I.get<RxStoresAndItems>();
    Map<String, StoreItem> itemsMap = storesAndItems.items.value;
    // Map<String, Store> storesMap = storesAndItems.stores.value;

    for (String itemKey in keys) {
      final request =
          Firestore.instance.collection('items').document(itemKey).get();
      requests.add(request);
    }
    for (var request in requests) {
      final result = await request;
      itemsMap.putIfAbsent(
        result.documentID,
        () => StoreItem.fromMap(result.data),
      );
    }
    Address address = (await Geocoder.google(await Utils.getAPIKey())
        .findAddressesFromCoordinates(Coordinates(
            order.destination.latitude, order.destination.longitude)))[0];
    return address;
    // itemDetails.add({'destination' : address.addressLine});
    // finalResult.putIfAbsent('destinationLatLng', () {
    //   return destination;
    // });

    // finalResult.putIfAbsent('itemDetails', () {
    //   return itemDetails;
    // });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   items = getItems(widget.data);
  // }

  @override
  Widget build(BuildContext context) {
    LatLng myLatLng = Utils.latLngFromCoordinates(
        addressService.currentMyAddress.coordinates);
    return SolidBottomSheet(
      controller: _solidController..hide(),
      toggleVisibilityOnTap: true,
      onShow: () async {
        (BottomBarIcon._key?.currentWidget as BottomBarIcon)
            ?.setIconState(true);
      },
      onHide: () async {
        (BottomBarIcon._key?.currentWidget as BottomBarIcon)
            ?.setIconState(false);
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
      body: FutureBuilder<Address>(
          future: initializeItemsAndGetAddress(),
          builder: (context, destinationSnapshot) {
            if (destinationSnapshot.connectionState ==
                ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return StreamBuilder<Map<String, Address>>(
                stream: addressService.stream$,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  RxStoresAndItems storesAndItems =
                      GetIt.I.get<RxStoresAndItems>();

                  Map<String, Store> stores = storesAndItems.stores.value;
                  Map<String, StoreItem> items = storesAndItems.items.value;

                  List<Widget> widgets = [];
                  //Adding Top Widgets Before Stores and Items.
                  widgets.addAll([
                    SizedBox(height: 10),
                    Text(
                      'OrderId: ${widget.data['shortId']}',
                      style: Theme.of(context).textTheme.subtitle1,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                              text: 'Phone: ',
                              style: Theme.of(context).textTheme.subtitle1),
                          TextSpan(
                              text: order.phoneNumber,
                              style: Theme.of(context).textTheme.subtitle2),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    (order.house ?? '') != ''
                        ? Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                    text: 'Apt: ',
                                    style:
                                        Theme.of(context).textTheme.subtitle1),
                                TextSpan(
                                    text: order.house,
                                    style:
                                        Theme.of(context).textTheme.subtitle2),
                              ],
                            ),
                          )
                        : Opacity(opacity: 0),
                    (order.house ?? '') != ''
                        ? SizedBox(height: 4.0)
                        : Opacity(
                            opacity: 0,
                          ),
                    Text(
                      order.dropToDoor
                          ? 'Bring Order to Door'
                          : 'You Meet at Vehicle',
                      style: Theme.of(context).textTheme.subtitle1,
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
                  ]);

                  //Adding Lists of Stores and their Items.
                  Map<String, ReceiveItOrderItem> storeAndItsItems =
                      order.itemsData.itemDetails;
                  for (var storeId in order.itemsData.itemDetails.keys) {
                    Store store = stores[storeId];
                    var itemKeysOfCurrentStore =
                        storeAndItsItems[storeId].itemDetails.keys.toList();
                    widgets.add(
                      SizedBox(height: 14),
                    );
                    widgets.add(
                      Text(
                        '  ${store.storeName}',
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    );
                    widgets.add(
                      SizedBox(height: 7),
                    );
                    widgets.add(
                      InkWell(
                        splashColor:
                            Theme.of(context).primaryColor.withAlpha(190),
                        onTap: () async {
                          widget.animateToLatLng(
                            store.storeLatLng,
                          );
                          _solidController.hide();
                        },
                        child: SizedBox(
                          height: 110,
                          child: Row(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  height: 110,
                                  child: ListView.builder(
                                    padding: EdgeInsets.only(right: 20),
                                    scrollDirection: Axis.horizontal,
                                    // dragStartBehavior: DragStartBehavior.start,
                                    physics: BouncingScrollPhysics(),
                                    itemCount:
                                        itemKeysOfCurrentStore.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index == 0) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0),
                                          child: SizedBox(
                                            height: 110,
                                            width: 150,
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                      text: 'Address: ',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle2),
                                                  TextSpan(
                                                    text: store.storeAddress,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2,
                                                  ),
                                                ],
                                              ),
                                              strutStyle: StrutStyle(
                                                height: 1,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      index -= 1;
                                      StoreItem item =
                                          items[itemKeysOfCurrentStore[index]];
                                      ReceiveItOrderItemDetails
                                          receiveItOrderItemDetails =
                                          storeAndItsItems[storeId]
                                              .itemDetails[item.itemId];
                                      // return Container(color: Colors.brown,child: Text('Hello!'));
                                      return Card(
                                        elevation: 8,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Container(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Container(
                                                  color: Colors.black,
                                                  child: Image.network(
                                                    '${item.images[0]}',
                                                    height: 100,
                                                    width: 100,
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 0,
                                                  width: 8,
                                                ),
                                                Container(
                                                  width: 150,
                                                  // height: 100,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      SizedBox(
                                                        height: 4,
                                                      ),
                                                      Text(
                                                        item.itemName,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .subtitle1,
                                                      ),
                                                      SizedBox(
                                                        height: 4,
                                                      ),
                                                      Text(
                                                          'Price: R${item.price.toStringAsFixed(1)}'),
                                                      SizedBox(
                                                        height: 4,
                                                      ),
                                                      Text(
                                                          'Qty: ${receiveItOrderItemDetails.quantity}'),
                                                      SizedBox(
                                                        height: 4,
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .bottomRight,
                                                        child: Text(
                                                          "Total: R${(item.price * receiveItOrderItemDetails.quantity).toStringAsFixed(1)}",
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
                                                Container(
                                                  color: Colors.grey,
                                                  child: SizedBox(
                                                    height: 0,
                                                    width: 8,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    // widgets.add(
                    //   InkWell(
                    //     splashColor:
                    //         Theme.of(context).primaryColor.withAlpha(190),
                    //     onTap: () async {
                    //       LatLng latlng = store.storeLatLng;
                    //       print('Navigating to $latlng');
                    //       OrderTracking.startNavigation(
                    //         context,
                    //         latlng,
                    //         myLatLng,
                    //       );
                    //     },
                    //     child: Container(
                    //       width: MediaQuery.of(context).size.width,
                    //       color: Theme.of(context).primaryColor,
                    //       child: Row(
                    //         children: [
                    //           Expanded(
                    //             child: Container(
                    //               padding: const EdgeInsets.all(8.0),
                    //               child: Text(
                    //                 'Navigate Here!',
                    //                 style: TextStyle(color: Colors.white),
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // );

                  }
                  widgets.add(
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
                            LatLng latLng = order.destination;
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
                                        '${destinationSnapshot?.data?.addressLine ?? 'Unable to Fetch the address'}',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // InkWell(
                              //   splashColor: Theme.of(context)
                              //       .primaryColor
                              //       .withAlpha(190),
                              //   onTap: () async {
                              //     print('Opened in maps');
                              //     LatLng latLng = order.destination;
                              //     // MapsLauncher.launchCoordinates(
                              //     //   latLng.latitude,
                              //     //   latLng.longitude,
                              //     // );
                              //     OrderTracking.startNavigation(
                              //       context,
                              //       latLng,
                              //       myLatLng,
                              //     );
                              //   },
                              //   child: Container(
                              //     decoration: ShapeDecoration(
                              //       shape: RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.only(
                              //           bottomLeft: Radius.circular(8.0),
                              //           bottomRight: Radius.circular(8.0),
                              //         ),
                              //       ),
                              //       color: Theme.of(context).primaryColor,
                              //     ),
                              //     padding: EdgeInsets.all(8.0),
                              //     child: Text(
                              //       'Navigate Here!',
                              //       style: TextStyle(
                              //         color: Colors.white,
                              //       ),
                              //       textAlign: TextAlign.center,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );

                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widgets,
                      // <Widget>[
                      //   SizedBox(height: 10),
                      //   Text(
                      //     'OrderId: ${widget.data['shortId']}',
                      //     style: Theme.of(context).textTheme.subtitle1,
                      //     textAlign: TextAlign.center,
                      //   ),
                      //   SizedBox(
                      //     height: 40,
                      //   ),
                      //   Container(
                      //     color: Theme.of(context).primaryColor,
                      //     padding: EdgeInsets.all(6),
                      //     child: Text(
                      //       ' P i c k u p ',
                      //       textAlign: TextAlign.center,
                      //       style: TextStyle(
                      //           color: Colors.white,
                      //           fontSize: 18,
                      //           fontWeight: FontWeight.bold),
                      //     ),
                      //   ),
                      //   SizedBox(
                      //     height: 10,
                      //   ),
                      //   Container(
                      //     // color: Colors.black,
                      //     // width: MediaQuery.of(context).size.width,
                      //     height: 200,
                      //     child: ListView.builder(
                      //       // padding: EdgeInsets.only(right: 20),
                      //       scrollDirection: Axis.horizontal,
                      //       // dragStartBehavior: DragStartBehavior.start,
                      //       physics: BouncingScrollPhysics(),
                      //       itemCount: 10, // TODO://Fix it,
                      //       itemBuilder: (context, index) {
                      //         return Column(
                      //           mainAxisSize: MainAxisSize.min,
                      //           children: <Widget>[
                      //             Card(
                      //               elevation: 8,
                      //               child: ClipRRect(
                      //                 borderRadius: BorderRadius.circular(4),
                      //                 child: InkWell(
                      //                   splashColor: Theme.of(context)
                      //                       .primaryColor
                      //                       .withAlpha(190),
                      //                   onTap: () async {
                      //                     widget.animateToLatLng(
                      //                       Utils.latLngFromString(
                      //                         snapshot.data['itemDetails']
                      //                             [index]['latlng'],
                      //                       ),
                      //                     );
                      //                     _solidController.hide();
                      //                   },
                      //                   child: Column(
                      //                     mainAxisSize: MainAxisSize.min,
                      //                     children: <Widget>[
                      //                       Row(
                      //                         mainAxisSize: MainAxisSize.min,
                      //                         children: <Widget>[
                      //                           Container(
                      //                             color: Colors.black,
                      //                             child: Image.network(
                      //                               '${snapshot.data['itemDetails'][index]['images'][0]}',
                      //                               height: 100,
                      //                               width: 100,
                      //                               fit: BoxFit.fitWidth,
                      //                             ),
                      //                           ),
                      //                           SizedBox(
                      //                             width: 8,
                      //                           ),
                      //                           Container(
                      //                             width: 150,
                      //                             child: Column(
                      //                               crossAxisAlignment:
                      //                                   CrossAxisAlignment
                      //                                       .start,
                      //                               children: <Widget>[
                      //                                 SizedBox(
                      //                                   height: 4,
                      //                                 ),
                      //                                 Text(
                      //                                   snapshot.data[
                      //                                           'itemDetails']
                      //                                       [index]['itemName'],
                      //                                   style: Theme.of(context)
                      //                                       .textTheme
                      //                                       .subtitle1,
                      //                                 ),
                      //                                 SizedBox(
                      //                                   height: 4,
                      //                                 ),
                      //                                 Text(
                      //                                     '${snapshot.data['itemDetails'][index]['storeAddress']}'),
                      //                                 Align(
                      //                                   alignment: Alignment
                      //                                       .centerRight,
                      //                                   child: Text(
                      //                                     "Price: R${(snapshot.data['itemDetails'][index]['price'] as num).toDouble().toStringAsFixed(2)} x ${widget.data['itemsData'][snapshot.data['itemDetails'][index]['itemId']]['quantity']}",
                      //                                     overflow: TextOverflow
                      //                                         .ellipsis,
                      //                                     maxLines: 1,
                      //                                     style: TextStyle(
                      //                                       fontSize: 14,
                      //                                       fontWeight:
                      //                                           FontWeight.bold,
                      //                                     ),
                      //                                   ),
                      //                                 )
                      //                               ],
                      //                             ),
                      //                           ),
                      //                           SizedBox(
                      //                             width: 8,
                      //                           ),
                      //                         ],
                      //                       ),
                      //                       InkWell(
                      //                         splashColor: Theme.of(context)
                      //                             .primaryColor
                      //                             .withAlpha(190),
                      //                         onTap: () async {
                      //                           LatLng latlng =
                      //                               Utils.latLngFromString(
                      //                             snapshot.data['itemDetails']
                      //                                 [index]['latlng'],
                      //                           );
                      //                           print('Navigating to $latlng');
                      //                           OrderNavigationRoute
                      //                               ._startNavigation(
                      //                             context,
                      //                             latlng,
                      //                             myLatLng,
                      //                           );
                      //                         },
                      //                         child: Container(
                      //                           width: 270.0,
                      //                           color: Theme.of(context)
                      //                               .primaryColor,
                      //                           child: Row(
                      //                             children: [
                      //                               Expanded(
                      //                                 child: Container(
                      //                                   padding:
                      //                                       const EdgeInsets
                      //                                           .all(8.0),
                      //                                   child: Text(
                      //                                     'Navigate Here!',
                      //                                     style: TextStyle(
                      //                                         color:
                      //                                             Colors.white),
                      //                                   ),
                      //                                 ),
                      //                               ),
                      //                             ],
                      //                           ),
                      //                         ),
                      //                       )
                      //                     ],
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             // RaisedButton(
                      //             //   onPressed: () {},
                      //             //   child: Text('Open in Map',
                      //             //       style: TextStyle(color: Colors.white)),
                      //             // ),
                      //           ],
                      //         );
                      //       },
                      //     ),
                      //   ),
                      //   SizedBox(
                      //     height: 10,
                      //   ),
                      //   Padding(
                      //     padding: const EdgeInsets.all(18.0),
                      //     child: Card(
                      //       elevation: 8,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(8.0),
                      //       ),
                      //       child: InkWell(
                      //         splashColor:
                      //             Theme.of(context).primaryColor.withAlpha(190),
                      //         onTap: () {
                      //           LatLng latLng =
                      //               snapshot.data['destinationLatLng'];
                      //           widget.animateToLatLng(latLng);
                      //           _solidController.hide();
                      //         },
                      //         child: Column(
                      //           mainAxisSize: MainAxisSize.min,
                      //           crossAxisAlignment: CrossAxisAlignment.stretch,
                      //           children: <Widget>[
                      //             Container(
                      //               decoration: ShapeDecoration(
                      //                 shape: RoundedRectangleBorder(
                      //                   borderRadius: BorderRadius.only(
                      //                     topLeft: Radius.circular(8.0),
                      //                     topRight: Radius.circular(8.0),
                      //                   ),
                      //                 ),
                      //                 color: Theme.of(context).primaryColor,
                      //               ),
                      //               padding: EdgeInsets.all(6),
                      //               child: Text(
                      //                 ' D r o p o f f ',
                      //                 textAlign: TextAlign.center,
                      //                 style: TextStyle(
                      //                   color: Colors.white,
                      //                   fontSize: 18,
                      //                   fontWeight: FontWeight.bold,
                      //                 ),
                      //               ),
                      //             ),
                      //             SizedBox(
                      //               height: 10,
                      //             ),
                      //             Container(
                      //               padding: const EdgeInsets.all(8.0),
                      //               child: Row(
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.center,
                      //                 children: <Widget>[
                      //                   Icon(Icons.location_on),
                      //                   Expanded(
                      //                     child: Text(
                      //                       '${(snapshot.data['destination'] as Address).addressLine}',
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //             SizedBox(
                      //               height: 10,
                      //             ),
                      //             InkWell(
                      //               splashColor: Theme.of(context)
                      //                   .primaryColor
                      //                   .withAlpha(190),
                      //               onTap: () async {
                      //                 print('Opened in maps');
                      //                 LatLng latLng =
                      //                     snapshot.data['destinationLatLng'];
                      //                 // MapsLauncher.launchCoordinates(
                      //                 //   latLng.latitude,
                      //                 //   latLng.longitude,
                      //                 // );
                      //                 OrderNavigationRoute._startNavigation(
                      //                   context,
                      //                   latLng,
                      //                   myLatLng,
                      //                 );
                      //               },
                      //               child: Container(
                      //                 decoration: ShapeDecoration(
                      //                   shape: RoundedRectangleBorder(
                      //                     borderRadius: BorderRadius.only(
                      //                       bottomLeft: Radius.circular(8.0),
                      //                       bottomRight: Radius.circular(8.0),
                      //                     ),
                      //                   ),
                      //                   color: Theme.of(context).primaryColor,
                      //                 ),
                      //                 padding: EdgeInsets.all(8.0),
                      //                 child: Text(
                      //                   'Navigate Here!',
                      //                   style: TextStyle(
                      //                     color: Colors.white,
                      //                   ),
                      //                   textAlign: TextAlign.center,
                      //                 ),
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ],
                    ),
                  );
                });
          }),
    );
  }

  // @override
  // void initState() {
  //   super.initState();
  //   items = getItems(widget.data);
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return SolidBottomSheet(
  //     controller: _solidController,
  //     // enableDrag: true,
  //     // backgroundColor: Color.fromARGB(0, 0, 0, 0 ),
  //     maxHeight: 550,
  //     onShow: () async {
  //       _icon?.setIconState(true);
  //     },
  //     onHide: () async {
  //       _icon?.setIconState(false);
  //     },
  //     elevation: 8.0,
  //     draggableBody: true,
  //     toggleVisibilityOnTap: true,
  //     // headerBar: InkWell(
  //     //   onTap: () {
  //     //     if(_solidController != null && _solidController.isOpened) {
  //     //       hide();
  //     //     }
  //     //     else {
  //     //       show();
  //     //     }
  //     //   },
  //     // child:
  //     headerBar: Container(
  //       height: 40,
  //       decoration: ShapeDecoration(
  //         color: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.only(
  //               topLeft: Radius.circular(20), topRight: Radius.circular(20)),
  //         ),
  //       ),
  //       child: _icon,
  //     ),
  //     // ),

  //     body: FutureBuilder<Map<String, dynamic>>(
  //         future: items,
  //         builder: (context, snapshot) {
  //           if (snapshot.connectionState == ConnectionState.waiting ||
  //               snapshot.data == null) {
  //             return Center(
  //               child: CircularProgressIndicator(),
  //             );
  //           }
  //           return SingleChildScrollView(
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.stretch,
  //               children: <Widget>[
  //                 SizedBox(
  //                   height: 8,
  //                 ),
  //                 Text(
  //                   'OrderId: ${widget.data['shortId']}',
  //                   style: Theme.of(context).textTheme.subtitle1,
  //                 ),
  //                 SizedBox(
  //                   height: 10,
  //                 ),
  //                 Container(
  //                   color: Theme.of(context).primaryColor,
  //                   padding: EdgeInsets.all(6),
  //                   child: Text(
  //                     ' P i c k u p ',
  //                     textAlign: TextAlign.center,
  //                     style: TextStyle(
  //                         color: Colors.white,
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.bold),
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   height: 10,
  //                 ),
  //                 Container(
  //                   // color: Colors.black,
  //                   // width: MediaQuery.of(context).size.width,
  //                   height: 200,
  //                   child: ListView.builder(
  //                     // padding: EdgeInsets.only(right: 20),
  //                     scrollDirection: Axis.horizontal,
  //                     // dragStartBehavior: DragStartBehavior.start,
  //                     physics: BouncingScrollPhysics(),
  //                     itemCount: snapshot.data['itemDetails'].length,
  //                     itemBuilder: (context, index) {
  //                       return Column(
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: <Widget>[
  //                           Card(
  //                             elevation: 8,
  //                             child: ClipRRect(
  //                               borderRadius: BorderRadius.circular(4),
  //                               child: InkWell(
  //                                 splashColor: Theme.of(context)
  //                                     .primaryColor
  //                                     .withAlpha(190),
  //                                 onTap: () async {
  //                                   widget.animateToLatLng(
  //                                     Utils.latLngFromString(
  //                                       snapshot.data['itemDetails'][index]
  //                                           ['latlng'],
  //                                     ),
  //                                   );
  //                                   hide();
  //                                 },
  //                                 child: Column(
  //                                   mainAxisSize: MainAxisSize.min,
  //                                   children: <Widget>[
  //                                     Row(
  //                                       mainAxisSize: MainAxisSize.min,
  //                                       children: <Widget>[
  //                                         Container(
  //                                           color: Colors.black,
  //                                           child: Image.network(
  //                                             '${snapshot.data['itemDetails'][index]['images'][0]}',
  //                                             height: 100,
  //                                             width: 100,
  //                                             fit: BoxFit.fitWidth,
  //                                           ),
  //                                         ),
  //                                         SizedBox(
  //                                           width: 8,
  //                                         ),
  //                                         Container(
  //                                           width: 150,
  //                                           child: Column(
  //                                             crossAxisAlignment:
  //                                                 CrossAxisAlignment.start,
  //                                             children: <Widget>[
  //                                               SizedBox(
  //                                                 height: 4,
  //                                               ),
  //                                               Text(
  //                                                 snapshot.data['itemDetails']
  //                                                     [index]['itemName'],
  //                                                 style: Theme.of(context)
  //                                                     .textTheme
  //                                                     .subtitle1,
  //                                               ),
  //                                               SizedBox(
  //                                                 height: 4,
  //                                               ),
  //                                               Text(
  //                                                   '${snapshot.data['itemDetails'][index]['storeAddress']}'),
  //                                               Align(
  //                                                 alignment:
  //                                                     Alignment.centerRight,
  //                                                 child: Text(
  //                                                   "Price: R${(snapshot.data['itemDetails'][index]['price'] as num).toDouble().toStringAsFixed(1)} x ${widget.data['itemsData'][snapshot.data['itemDetails'][index]['itemId']]['quantity']}",
  //                                                   overflow:
  //                                                       TextOverflow.ellipsis,
  //                                                   maxLines: 1,
  //                                                   style: TextStyle(
  //                                                     fontSize: 14,
  //                                                     fontWeight:
  //                                                         FontWeight.bold,
  //                                                   ),
  //                                                 ),
  //                                               )
  //                                             ],
  //                                           ),
  //                                         ),
  //                                         SizedBox(
  //                                           width: 8,
  //                                         ),
  //                                       ],
  //                                     ),
  //                                     InkWell(
  //                                       splashColor: Theme.of(context)
  //                                           .primaryColor
  //                                           .withAlpha(190),
  //                                       onTap: () async {
  //                                         print('Opened in Maps');
  //                                         LatLng latlng =
  //                                             Utils.latLngFromString(
  //                                           snapshot.data['itemDetails'][index]
  //                                               ['latlng'],
  //                                         );
  //                                         OrderTracking.startNavigation(
  //                                             context,
  //                                             latlng,
  //                                             Utils.latLngFromCoordinates(
  //                                                 addressService
  //                                                     .currentMyAddress
  //                                                     .coordinates));
  //                                       },
  //                                       child: Container(
  //                                         width: 270.0,
  //                                         color: Theme.of(context).primaryColor,
  //                                         // child: Row(
  //                                         //   children: [
  //                                         //     Expanded(
  //                                         //       child: Container(
  //                                         //         padding:
  //                                         //             const EdgeInsets.all(8.0),
  //                                         //         child: Text(
  //                                         //           'Navigate Here!',
  //                                         //           style: TextStyle(
  //                                         //               color: Colors.white),
  //                                         //         ),
  //                                         //       ),
  //                                         //     ),
  //                                         //   ],
  //                                         // ),
  //                                       ),
  //                                     )
  //                                   ],
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           // RaisedButton(
  //                           //   onPressed: () {},
  //                           //   child: Text('Open in Map',
  //                           //       style: TextStyle(color: Colors.white)),
  //                           // ),
  //                         ],
  //                       );
  //                     },
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   height: 10,
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.all(18.0),
  //                   child: Card(
  //                     elevation: 8,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(8.0),
  //                     ),
  //                     child: InkWell(
  //                       splashColor:
  //                           Theme.of(context).primaryColor.withAlpha(190),
  //                       onTap: () {
  //                         LatLng latLng = snapshot.data['destinationLatLng'];
  //                         widget.animateToLatLng(latLng);
  //                         hide();
  //                       },
  //                       child: Column(
  //                         mainAxisSize: MainAxisSize.min,
  //                         crossAxisAlignment: CrossAxisAlignment.stretch,
  //                         children: <Widget>[
  //                           Container(
  //                             decoration: ShapeDecoration(
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.only(
  //                                   topLeft: Radius.circular(8.0),
  //                                   topRight: Radius.circular(8.0),
  //                                 ),
  //                               ),
  //                               color: Theme.of(context).primaryColor,
  //                             ),
  //                             padding: EdgeInsets.all(6),
  //                             child: Text(
  //                               ' D r o p o f f ',
  //                               textAlign: TextAlign.center,
  //                               style: TextStyle(
  //                                 color: Colors.white,
  //                                 fontSize: 18,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                           ),
  //                           SizedBox(
  //                             height: 10,
  //                           ),
  //                           Container(
  //                             padding: const EdgeInsets.all(8.0),
  //                             child: Row(
  //                               crossAxisAlignment: CrossAxisAlignment.center,
  //                               children: <Widget>[
  //                                 Icon(Icons.location_on),
  //                                 Expanded(
  //                                   child: Text(
  //                                     '${(snapshot.data['destination'] as Address).addressLine}',
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                           SizedBox(
  //                             height: 10,
  //                           ),
  //                           InkWell(
  //                             splashColor:
  //                                 Theme.of(context).primaryColor.withAlpha(190),
  //                             onTap: () async {
  //                               print('Opened in maps');
  //                               LatLng latLng =
  //                                   snapshot.data['destinationLatLng'];
  //                               // MapsLauncher.launchCoordinates(
  //                               //   latLng.latitude,
  //                               //   latLng.longitude,
  //                               // );
  //                               OrderTracking.startNavigation(
  //                                 context,
  //                                 latLng,
  //                                 Utils.latLngFromCoordinates(addressService
  //                                     .currentMyAddress.coordinates),
  //                               );
  //                             },
  //                             child: Container(
  //                               decoration: ShapeDecoration(
  //                                 shape: RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.only(
  //                                     bottomLeft: Radius.circular(8.0),
  //                                     bottomRight: Radius.circular(8.0),
  //                                   ),
  //                                 ),
  //                                 color: Theme.of(context).primaryColor,
  //                               ),
  //                               padding: EdgeInsets.all(8.0),
  //                               child: Text(
  //                                 'Navigate Here!',
  //                                 style: TextStyle(
  //                                   color: Colors.white,
  //                                 ),
  //                                 textAlign: TextAlign.center,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         }),
  //   );
  // }

}

class MySolidBottomSheet extends StatefulWidget {
  final Function(LatLng) onSelectItem;
  final data;
  // static GlobalKey<MySolidBottomSheetState> _key =
  //     GlobalKey<MySolidBottomSheetState>();
  // void refreshState(LatLng driverLatLng) {
  //   _key?.currentState?.refresh(driverLatLng);
  // }

  MySolidBottomSheet({Key key, this.onSelectItem, this.data}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return MySolidBottomSheetState();
  }

  // show() {
  //   _key?.currentState?._controller?.show();
  // }

  // hide() {
  //   _key?.currentState?._controller?.hide();
  // }
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
      onSelectItem: (latlng) {
        _controller.hide();
        widget.onSelectItem(latlng);
      },
      data: widget.data,
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
      maxHeight: 380,
      elevation: 8.0,
      draggableBody: true,
      toggleVisibilityOnTap: true,
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
  BottomBarIcon() : super(key: _key);
  static GlobalKey<_BottomBarIconState> _key = GlobalKey<_BottomBarIconState>();
  @override
  _BottomBarIconState createState() => _BottomBarIconState();

  setIconState(bool isShown) {
    _key?.currentState?.isShown = isShown;
    _key?.currentState?.refresh();
  }
}

class _BottomBarIconState extends State<BottomBarIcon> {
  void refresh() {
    if (mounted) {
      setState(() {});
    }
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

class _VerificationCodePopUp extends StatefulWidget {
  final String verificationCode;
  final Function() onHide;
  static GlobalKey<_VerificationCodePopUpState> _key =
      GlobalKey<_VerificationCodePopUpState>();

  _VerificationCodePopUp({
    @required this.verificationCode,
    @required this.onHide,
  }) : super(key: _key);

  @override
  State<StatefulWidget> createState() {
    return _VerificationCodePopUpState();
  }
}

class _VerificationCodePopUpState extends State<_VerificationCodePopUp> {
  bool isVisible = false;
  bool showPopup = false;
  double width = 0;
  double height = 0;

  bool isOverlayVisible = false;

  @override
  void initState() {
    super.initState();
  }

  show() {
    isOverlayVisible = true;
    setState(() {});
    isVisible = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      width = MediaQuery.of(context).size.width * 0.8;
      height = 100;
      setState(() {});
    });
  }

  hide() {
    width = 0;
    height = 0;
    isOverlayVisible = false;
    // isVisible = true;
    widget.onHide();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isOverlayVisible) {
          hide();
          return false;
        }
        if (isVisible) {
          return false;
        }
        return true;
      },
      child: isVisible
          ? Stack(
              children: <Widget>[
                isOverlayVisible
                    ? GestureDetector(
                        onTap: () {
                          isOverlayVisible = false;
                          // widget.overlayClicked();
                          hide();
                          setState(() {});
                        },
                        child: Container(
                          color: Colors.black54,
                        ),
                      )
                    : SizedBox(
                        height: 0,
                        width: 0,
                      ),
                Center(
                  child: Card(
                    margin: EdgeInsets.all(8),
                    elevation: 8,
                    child: AnimatedContainer(
                      width: width,
                      height: height + 40,
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 2),
                      duration: Duration(milliseconds: 500),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Verification Code\n' + widget.verificationCode,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            Spacer(),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: FlatButton(
                                    onPressed: () {
                                      isOverlayVisible = false;
                                      hide();
                                      setState(() {});
                                    },
                                    child: Text(
                                      'Go Back',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .button
                                          .copyWith(
                                            color: Colors.black,
                                          ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                  width: 2,
                                  child: Container(color: Colors.black),
                                ),
                                Expanded(
                                  child: FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Done',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .button
                                          .copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      onEnd: () {
                        if (width == 0) {
                          isVisible = false;
                        } else {
                          isVisible = true;
                        }
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ],
            )
          : Opacity(
              opacity: 0,
            ),
    );
  }
}

class _OrderTile extends StatefulWidget {
  final Location location = Location();
  final Map<String, dynamic> data;
  final driverLatLng;
  final Function(LatLng) onSelectItem;
  static GlobalKey<_OrderTileState> _key = GlobalKey<_OrderTileState>();
  void refresh(driverLatLng) {
    _key?.currentState?.refresh(driverLatLng);
  }

  _OrderTile({
    Key key,
    @required this.data,
    @required this.onSelectItem,
    @required this.driverLatLng,
  }) : super(key: _key);

  @override
  State<StatefulWidget> createState() {
    return _OrderTileState(driverLatLng: driverLatLng);
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
      accuracy: LocationAccuracy.navigation,
    );
    driverLatLng = Utils.latLngFromString(widget.data['driverLatLng']);
  }

  double getDistanceFromYourLocation(LatLng source, LatLng destination) {
    if (source == null || destination == null) return null;
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

    return SingleChildScrollView(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 8,
              ),
              Text(
                'OrderId: ${widget.data['shortId']}',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
                              widget.onSelectItem(pickup);
                            },
                            child: Container(
                              height: 200,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
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
                                    child: Text(
                                        '${widget.data['pickUpAddress']}'),
                                  ),
                                  Spacer(),
                                  Container(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text.rich(
                                      TextSpan(
                                        text: 'Distance: ',
                                        children: [
                                          TextSpan(
                                            text: driverLatLng != null
                                                ? '${getDistanceFromYourLocation(driverLatLng, pickup)?.toStringAsFixed(1) ?? 'N/A'} Km\n'
                                                : 'Waiting for Driver\n',
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
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        // Container(
                        //   padding: EdgeInsets.all(8),
                        //   child: RaisedButton(
                        //     child: Text(
                        //       'Open in Maps',
                        //       style: TextStyle(color: Colors.white),
                        //     ),
                        //     onPressed: () {
                        //       MapsLauncher.launchCoordinates(
                        //           pickup.latitude, pickup.longitude);
                        //     },
                        //   ),
                        // ),
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(
                              text: 'Apt: ',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            TextSpan(
                              text: '${widget.data['senderHouse']}',
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ]),
                        ),
                        SizedBox(height: 4.0),
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(
                              text: 'Sender Phone: ',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            TextSpan(
                              text: '${widget.data['senderPhone']}',
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ]),
                        ),
                        SizedBox(height: 6.0),
                        Text(
                          (widget.data['pickFromDoor'] ?? true)
                              ? 'Pick Order From Door'
                              : 'You Will Meet Driver at Vehicle',
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
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
                              height: 200,
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
                                  Expanded(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                              '${widget.data['dropOffAddress']}'),
                                        ),
                                        Spacer(),
                                        Container(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text.rich(
                                            TextSpan(
                                              text: 'Distance: ',
                                              children: [
                                                TextSpan(
                                                  text: driverLatLng == null
                                                      ? 'Waiting for driver\n'
                                                      : '${getDistanceFromYourLocation(driverLatLng, destination)?.toStringAsFixed(1) ?? 'N/A'} Km\n',
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
                                        ),
                                      ],
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
                        // Container(
                        //   padding: EdgeInsets.all(8),
                        //   child: RaisedButton(
                        //     child: Text(
                        //       'Open in Maps',
                        //       style: TextStyle(color: Colors.white),
                        //     ),
                        //     onPressed: () {
                        //       MapsLauncher.launchCoordinates(
                        //           destination.latitude, destination.longitude);
                        //     },
                        //     onLongPress: () {},
                        //   ),
                        // ),
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(
                              text: 'Apt: ',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            TextSpan(
                              text: '${widget.data['receiverHouse']}',
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ]),
                        ),
                        SizedBox(height: 4),
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(
                              text: 'Receiver Phone: ',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            TextSpan(
                              text: '${widget.data['receiverPhone']}',
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ]),
                        ),
                        SizedBox(height: 6.0),
                        Text(
                          (widget.data['dropAtDoor'] ?? true)
                              ? 'Drop Order To Door'
                              : 'Receiver Will Meet Driver at Vehicle',
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '''${(widget.data['numberOfBoxes'] == null || widget.data['numberOfBoxes'] <= 0) ? '' : '${widget.data['numberOfBoxes']} Box(s)'} ${(widget.data['numberOfSleevesNeeded'] == null || widget.data['numberOfSleevesNeeded'] <= 0) ? '' : '${(widget.data['numberOfBoxes'] != null && widget.data['numberOfBoxes'] > 0) ? ', ' : ''}${widget.data['numberOfSleevesNeeded']} Sleeve(s)'}''',
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
    // });
  }
}
