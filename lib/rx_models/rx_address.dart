import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sennit/main.dart';
import 'package:sennit/rx_models/rx_config.dart';

class RxAddress {
  StreamSubscription subscription;

  Future<Object> init() async {
    Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    var status = await geolocator.checkGeolocationPermissionStatus();

    Location location = Location();
    // location.changeSettings(
    //   interval: 4000,
    //   distanceFilter: 50,
    // );
    if (status == GeolocationStatus.denied) {
      bool serviceResult = await geolocator.isLocationServiceEnabled();
      if (!serviceResult) {
        serviceResult = await location.requestService();
      }
      if (!serviceResult) {
        BotToast.showText(
          text:
              'This App Needs to know your location in order to Work. Exiting .....',
        );
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return null;
      }
      var result = await location.requestPermission();
      if (result != PermissionStatus.granted) {
        if (result == PermissionStatus.deniedForever) {
          Utils.showSnackBarError(
            null,
            'Permission Denied Forever. Please change permission in settings and restart the app.',
            duration: Duration(
              seconds: 20,
            ),
          );
        }
        return null;
      }
    } else if (!(await geolocator.isLocationServiceEnabled())) {
      bool serviceResult = false;
      try {
        serviceResult = await location.requestService().then((value) {
          print(value);
          return value;
        });
      } catch (ex) {
        print(ex.toString());
      }
      if (!serviceResult) {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return null;
      }
    }
    var permissionStatus = await geolocator.checkGeolocationPermissionStatus();
    if (permissionStatus != GeolocationStatus.granted) {
      if (permissionStatus == GeolocationStatus.disabled) {
        Utils.showSnackBarError(
          null,
          'Permission Denied Forever. Please change permission in settings and restart the app. Exiting....',
          duration: Duration(
            seconds: 20,
          ),
        );
        await Future.delayed(Duration(seconds: 5));
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return null;
      }
    }

    Position data = await geolocator.getCurrentPosition();
    if (data == null) {
      return null;
    }
    // return null;
    List<Address> addresses = (await Geocoder.google(await Utils.getAPIKey())
        .findAddressesFromCoordinates(
            Coordinates(data.latitude, data.longitude))
        .catchError((error) {
      print(error.toString());
      return null;
    }));
    if (addresses == null) {
      return null;
    }
    Address address = addresses[0];
    if (address == null) {
      return null;
    }
    setMyAddress(address);
    RxConfig config = GetIt.I.get<RxConfig>();
    config.config$.listen((event) {
      subscription?.cancel();
      subscription = geolocator
          .getPositionStream(
        LocationOptions(
          distanceFilter: (event['updateLocationAfterMeters'] as num).toInt() ?? 50,
        ),
      )
          .listen((event) async {
        Address address = (await Geocoder.google(await Utils.getAPIKey())
            .findAddressesFromCoordinates(
                Coordinates(event.latitude, event.longitude)))[0];
        if (currentFromAddress == null) {
          this.address.value.update(
                'fromAddress',
                (old) => address,
                ifAbsent: () => address,
              );
        }
        setMyAddress(address);
      });
    });
    return {};
  }

  BehaviorSubject<Map<String, Address>> address =
      BehaviorSubject<Map<String, Address>>.seeded(<String, Address>{
    'fromAddress': null,
    'toAddress': null,
    'myAddress': null,
  });

  Stream<Map<String, Address>> get stream$ => address.stream;
  Address get currentFromAddress => address.value['fromAddress'];
  Address get currentToAddress => address.value['toAddress'];
  Address get currentMyAddress => address.value['myAddress'];

  setFromAddress(Address fromAddress) {
    address.value.update(
      ('fromAddress'),
      (value) => fromAddress,
      ifAbsent: () => fromAddress,
    );
    address.add(address.value);
  }

  setToAddress(Address toAddress) {
    address.value.update(
      ('toAddress'),
      (value) => toAddress,
      ifAbsent: () => toAddress,
    );
    address.add(address.value);
  }

  setMyAddress(Address myAddress) {
    address.value.update(
      ('myAddress'),
      (value) => myAddress,
      ifAbsent: () => myAddress,
    );
    address.add(address.value);
  }
}
