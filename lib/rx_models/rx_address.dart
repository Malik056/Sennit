import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sennit/main.dart';

class RxAddress {
  StreamSubscription subscription;

  Future<Object> init() async {
    Location location = Location();
    location.changeSettings(
      interval: 4000,
      distanceFilter: 50,
    );
    if (await location.hasPermission() != PermissionStatus.granted) {
      bool serviceResult = await location.requestService();
      if (!serviceResult) {
        BotToast.showText(
          text:
              'This App Needs to know your location in order to Work. Exiting .....',
        );
        SystemNavigator.pop();
        return null;
      }
      var result = await location.requestPermission();
      if (result != PermissionStatus.granted) {
        if (result == PermissionStatus.deniedForever) {
          Utils.showSnackBarError(null,
              'Permission Denied Forever. Please change permission in settings and restart the app.');
        }
        return null;
      }
    } else if (!(await location.serviceEnabled())) {
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
        SystemNavigator.pop();
        return null;
      }
    }

    LocationData data = await location.getLocation();
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
    subscription?.cancel();
    subscription = location.onLocationChanged.listen((event) async {
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
