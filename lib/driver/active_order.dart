import 'package:flutter/material.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sennit/main.dart';

class ActiveOrder extends StatelessWidget {
  static GoogleMap map;
  static GoogleMapController controller;
  static LatLng myLocation;
  static bool cancelOrderConfirmationShown = false;
  static bool deliveryDonePopUpShown = false;
  final _ActiveOrderBody body = _ActiveOrderBody();
  final Set<Marker> markers = Set<Marker>();
  final Set<Polyline> polylines = Set<Polyline>();
  static bool orderConfirmed = false;

  ActiveOrder(){
    orderConfirmed = false;
    cancelOrderConfirmationShown = false;
    deliveryDonePopUpShown = false;
  }

  getLocation(context) async {
    myLocation = await Utils.getMyLocation();
    LatLng starting = LatLng(31.6537497, 74.2824057);
    LatLng ending = LatLng(31.640333, 74.2859132);

    Marker markerPickup = Marker(
      markerId: MarkerId("marker1"),
      infoWindow:
          InfoWindow(title: "Pick Up", snippet: "Click to Navigate here!"),
      position: starting,
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

    Marker marker = Marker(
      markerId: MarkerId("marker1"),
      infoWindow:
          InfoWindow(title: "Drop Off", snippet: "Click to Navigate here!"),
      position: ending,
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

    markers..add(marker)..add(markerPickup);
    List<LatLng> route =
        await GoogleMapPolyline(apiKey: await Utils.getAPIkey(context: context))
            .getCoordinatesWithLocation(
      origin: starting,
      destination: ending,
      mode: RouteMode.driving,
    );

    // List<LatLng> route = List();
    // pointLatLngList.forEach((value) {
    //   LatLng latlng = LatLng(value.latitude, value.longitude);
    //   route.add(latlng);
    // });

    Polyline polyline = Polyline(
      polylineId: PolylineId("route1"),
      points:
          route, //[LatLng(31.6537497, 74.2824057), LatLng(31.640333, 74.2859132)],
      visible: true,
      jointType: JointType.bevel,
      startCap: Cap.roundCap,
      endCap: Cap.buttCap,
      zIndex: 2,
      width: 4,
      color: Colors.blue,
      // patterns: [PatternItem.dash(4),],
      // patterns: [PatternItem.dash(2)],
    );

    polylines.add(polyline);

    // Polygon polygon = Polygon(
    //   polygonId: PolygonId("route2"),
    //   points: route,
    //   visible: true,
    //   strokeWidth: 2,
    //   fillColor: Colors.black,
    //   strokeColor: Colors.black,
    // );
    // map.polylines.add(polyline);
    // map.polygons.add(polygon);
    // map.circles.add(
    //   Circle(
    //       circleId: CircleId("adf"),
    //       strokeColor: Colors.black,
    //       center: myLocation,
    //       fillColor: Colors.white),
    // );
    map = GoogleMap(
      compassEnabled: true,
      initialCameraPosition:
          CameraPosition(target: starting, zoom: 14, tilt: 30),
      myLocationEnabled: true,
      markers: markers,
      polylines: polylines,
      mapType: MapType.normal,
      zoomGesturesEnabled: true,
      mapToolbarEnabled: false,
      polygons: Set(),
      circles: Set(),
      onMapCreated: (controller) {
        ActiveOrder.controller = controller;
      },
      onTap: (latlng) async {
        // map.markers.add(
        //   Marker(markerId: MarkerId("marker 1"), position: latlng),
        // );
        // (context as Element).markNeedsBuild();

        // (context as Element).markNeedsBuild();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!orderConfirmed) {
          Navigator.pop(context);
          return false;
        }
        if (deliveryDonePopUpShown) {
          deliveryDonePopUpShown = false;
          body.setWidgetState();
          return false;
        } else if (!cancelOrderConfirmationShown) {
          cancelOrderConfirmationShown = true;
          body.setWidgetState();
          return false;
        } else if (cancelOrderConfirmationShown) {
          cancelOrderConfirmationShown = false;
          body.setWidgetState();
          return false;
        }
        return true;
      },
      child: FutureBuilder(
        future: getLocation(context),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // myLocation = snapshot.data;
            return Scaffold(
              appBar: AppBar(
                title: Text('${200} R'),
                centerTitle: true,
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      'Done',
                    ),
                    onPressed: () {
                      if (!orderConfirmed) {
                        return;
                      }
                      if (cancelOrderConfirmationShown) {
                        return;
                      }
                      if (deliveryDonePopUpShown) {
                        return;
                      }
                      deliveryDonePopUpShown = true;
                      body.setWidgetState();
                    },
                  ),
                ],
              ),
              body: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  _Navigation(
                    map: map,
                    controller: ActiveOrder.controller,
                    myLocation: myLocation,
                  ),
                  // _ActiveOrderBody(),
                  body,
                ],
              ),
            );
          } else {
            return Opacity(
              opacity: 0,
            ); //Center(
            //   child: CircularProgressIndicator(),
            // );
          }
        },
      ),
    );
  }
}

class _ActiveOrderBody extends StatefulWidget {
  // final Delivery delivery;
  // ActiveOrder({@required this.delivery});

  final state = _ActiveOrderState();

  setWidgetState() {
    // createState();
    state.refresh();
  }

  @override
  State<StatefulWidget> createState() {
    return state;
  }
}

class _ActiveOrderState extends State<_ActiveOrderBody> {
  @override
  Widget build(BuildContext context) {
    var popUpHeight = 200.0;
    var popUpWidth = 300.0;

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Align(
          alignment: Alignment.bottomCenter,
          child: _OrderConfirmation(parent: this),
        ),
        (ActiveOrder.cancelOrderConfirmationShown ||
                ActiveOrder.deliveryDonePopUpShown)
            ? GestureDetector(
                child: Container(
                  color: Color.fromARGB(100, 255, 255, 255),
                ),
                onTap: () {
                  if (ActiveOrder.deliveryDonePopUpShown) {
                    ActiveOrder.deliveryDonePopUpShown = false;
                    refresh();
                  } else if (ActiveOrder.cancelOrderConfirmationShown) {
                    ActiveOrder.cancelOrderConfirmationShown = false;
                    refresh();
                  }
                },
              )
            : Opacity(
                opacity: 0,
              ),
        GestureDetector(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 600),
            width: ActiveOrder.deliveryDonePopUpShown ? popUpWidth : 0,
            height: ActiveOrder.deliveryDonePopUpShown ? popUpHeight : 0,
            curve: Curves.linearToEaseOut,
            child: _DeliveryDonePopUp(parent: this),
          ),
          onTap: () {
            print('Verify Order Pop up clicked!');
          },
        ),
        GestureDetector(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 600),
            width: ActiveOrder.cancelOrderConfirmationShown ? popUpWidth : 0,
            height: ActiveOrder.cancelOrderConfirmationShown ? popUpHeight : 0,
            curve: Curves.linearToEaseOut,
            child: _CancelOrderPopUp(parent: this),
          ),
          onTap: () {
            print('cancel Order Pop up clicked!');
          },
        ),
      ],
    );
  }

  void refresh() {
    setState(() {});
  }
}

class _Navigation extends StatefulWidget {
  final GoogleMap map;
  final GoogleMapController controller;
  final LatLng myLocation;

  const _Navigation(
      {Key key,
      @required this.map,
      @required this.controller,
      @required this.myLocation})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NavigationState();
  }
}

class _NavigationState extends State<_Navigation> {
  // Marker myMarker;
  Set<Marker> markers = new Set<Marker>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: widget.myLocation as dynamic,
      stream: Utils.getLocationStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return widget.map;
        } else {
          return widget.map;
        }
      },
    );
  }
}

class _DeliveryDonePopUp extends StatefulWidget {
  // final width;
  // final height;
  final _ActiveOrderState parent;

  const _DeliveryDonePopUp(
      {this.parent}); //@required this.width, @required this.height})

  // : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _DeliveryDonePopUpState();
  }
}

class _DeliveryDonePopUpState extends State<_DeliveryDonePopUp> {
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
                ActiveOrder.deliveryDonePopUpShown = false;
                widget.parent.setState(() {});
                Navigator.pop(context);
                // setState(() {});
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
  final _ActiveOrderState parent;
  const _CancelOrderPopUp(
      {this.parent}); //@required this.width, @required this.height})

  // : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _CancelOrderPopUpState();
  }
}

class _CancelOrderPopUpState extends State<_CancelOrderPopUp> {
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
                      ActiveOrder.cancelOrderConfirmationShown = false;
                      widget.parent.setState(() {});
                      // setState(() {});
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
                      ActiveOrder.cancelOrderConfirmationShown = false;
                      Navigator.pop(context);
                      widget.parent.setState(() {});
                      // setState(() {});
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
  final _ActiveOrderState parent;

  const _OrderConfirmation({Key key, this.parent}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _OrderConfirmationState();
  }
}

class _OrderConfirmationState extends State<_OrderConfirmation> {

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: Duration(milliseconds: 500),
          // left: orderConfirmed ? -2000 : 100,
          left: ActiveOrder.orderConfirmed ? 0 : 0,
          // top: 0,
          right: ActiveOrder.orderConfirmed ? 0 : 0,
          bottom: ActiveOrder.orderConfirmed ? -400 : 0,
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
                          Navigator.pop(context);
                        },
                        color: Colors.white,
                        child: Text(
                          'Cancel',
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
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
                          ActiveOrder.orderConfirmed = true;
                          setState(() {});
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
        ),
      ],
    );
  }
}
