import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sennit/main.dart';

enum OpenAs {
  PREVIEW,
  NAVIGATION,
}

class DeliveryTrackingRoute extends StatelessWidget {
  final LatLng fromCoordinate;
  final LatLng toCoordinate;
  final LatLng myLocation;
  final OpenAs openAs;
  DeliveryTrackingRoute(
    this.openAs, {
    @required this.fromCoordinate,
    @required this.toCoordinate,
    @required this.myLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DeliveryTrackingRouteBody(
        openAs,
        fromCoordinate: fromCoordinate,
        toCoordinate: toCoordinate,
        myLocation: myLocation,
      ),
    );
  }
}

class DeliveryTrackingRouteBody extends StatefulWidget {
  final LatLng fromCoordinate;
  final LatLng toCoordinate;
  final LatLng myLocation;
  final OpenAs openAs;

  DeliveryTrackingRouteBody(
    this.openAs, {
    @required this.fromCoordinate,
    @required this.toCoordinate,
    @required this.myLocation,
  });

  @override
  State<StatefulWidget> createState() {
    LatLng focusPoint = openAs == OpenAs.NAVIGATION
        ? LatLng(
            (fromCoordinate.latitude +
                    toCoordinate.latitude +
                    myLocation.latitude) /
                3,
            (fromCoordinate.longitude +
                    toCoordinate.longitude +
                    myLocation.longitude) /
                3)
        : LatLng((fromCoordinate.latitude + toCoordinate.latitude) / 2,
            (fromCoordinate.longitude + toCoordinate.longitude) / 2);
    return DeliveryTrackingRouteState(focusPoint);
  }
}

class DeliveryTrackingRouteState extends State<DeliveryTrackingRouteBody> {
  LatLng cameraFocus;

  DeliveryTrackingRouteState(this.cameraFocus);

  @override
  Widget build(BuildContext context) {
    // return Stack(
    //   fit: StackFit.expand,
    //   children: <Widget>[
    //     GoogleMap(
    //       initialCameraPosition: CameraPosition(target: cameraFocus, zoom: 14),
    //       compassEnabled: true,
    //       mapToolbarEnabled: widget.openAs == OpenAs.NAVIGATION ? true : false,
    //       myLocationButtonEnabled:
    //           widget.openAs == OpenAs.NAVIGATION ? true : false,
    //       polylines: Set()
    //         ..add(
    //           Polyline(
    //             polylineId: PolylineId("Route 0"),
    //             points: [
    //               widget.myLocation,
    //               widget.fromCoordinate,
    //               widget.toCoordinate
    //             ],
    //           ),
    //         ),
    //     ),
    //   ],
    // );
    return FutureBuilder(
      future: Utils.getMyLocation(),
      builder: (context, AsyncSnapshot<LatLng> asyncData) {
        if (asyncData.connectionState == ConnectionState.done &&
            asyncData.data != null) {
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: asyncData.data, zoom: 14),
              ),
            ],
          );
        } else {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
