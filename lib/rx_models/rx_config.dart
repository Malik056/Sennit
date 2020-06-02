import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class RxConfig {
  BehaviorSubject<Map<String, dynamic>> config =
      BehaviorSubject<Map<String, dynamic>>.seeded({
    'versionName': '2.2.5',
    'versionCode': 45,
    'receiveItMinimumStoreDistance': 8,
    'receiveItPricePerExtraKilometer': 4.5,
    'receiveItPriceFor5Km': 30,
    'driverMinimumOrderTakingDistance': 10,
    'compulsory': false,
  });
  // BehaviorSubject<String> versionName = BehaviorSubject<String>.seeded('2.2.5');
  // BehaviorSubject<int> versionCode = BehaviorSubject<int>.seeded(45);
  // BehaviorSubject<double> receiveItMinimumStoreDistance =
  //     BehaviorSubject<double>.seeded(8);
  // BehaviorSubject<double> receiveItPricePerExtraKilometer =
  //     BehaviorSubject<double>.seeded(4.5);
  // BehaviorSubject<double> receiveItPriceFor5Km =
  //     BehaviorSubject<double>.seeded(30);
  // BehaviorSubject<double> driverMinimumOrderTakingDistance =
  //     BehaviorSubject<double>.seeded(10);

  Stream<Map<String, dynamic>> get config$ => config.stream;

  // double get currentReceiveItMinimumStoreDistance =>
  //     receiveItMinimumStoreDistance.value;
  // double get currentReceiveItPricePerExtraKilometer$ =>
  //     receiveItPricePerExtraKilometer.value;
  // double get currentReceiveItPriceFor5Km$ => receiveItPriceFor5Km.value;
  // double get currentDriverMinimumOrderTakingDistance$ =>
  //     driverMinimumOrderTakingDistance.value;
  // String get currentVersionName => versionName.value;
  // int get currentVersionCode => versionCode.value;

  // Observable<double> get receiveItMinimumStoreDistance$ =>
  //     receiveItMinimumStoreDistance.stream;
  // Observable<double> get receiveItPricePerExtraKilometer$ =>
  //     receiveItPricePerExtraKilometer.stream;
  // Observable<double> get receiveItPriceFor5Km$ => receiveItPriceFor5Km.stream;
  // Observable<double> get driverMinimumOrderTakingDistance$ =>
  //     driverMinimumOrderTakingDistance.stream;
  // Observable<String> get versionName$ => versionName.stream;
  // Observable<int> get versionCode$ => versionCode.stream;
  StreamSubscription subscription;
  Future<Map<String, dynamic>> init() async {
    var data = await Firestore.instance
        .collection('configs')
        .document('version1.0')
        .get()
        .then<Map<String, dynamic>>((event) {
      if (!event.exists) return null;
      setConfigData(event.data);
      return event.data;
      // String versionName = event.data['versionName'];
      // int versionCode = (event.data['versionCode'] as num).toInt();
      // double receiveItMinimumStoreDistance =
      //     (event.data['receiveItMinimumStoreDistance'] as num).toDouble();
      // double receiveItPricePerExtraKilometer =
      //     (event.data['receiveItPricePerExtraKilometer'] as num).toDouble();
      // double receiveItPriceFor5Km = event.data['receiveItPriceFor5Km'];
      // double driverMinimumOrderTakingDistance =
      //     (event.data['driverMinimumOrderTakingDistance'] as num).toDouble();
      // if (versionName != null) {
      //   setVersionName(versionName);
      // }
      // if (versionCode != null) {
      //   setVersionCode(versionCode);
      // }
      // if (receiveItMinimumStoreDistance != null) {
      //   setReceiveItMinimumStoreDistance(receiveItMinimumStoreDistance);
      // }
      // if (receiveItPricePerExtraKilometer != null) {
      //   setReceiveItPricePerExtraKilometer(receiveItPricePerExtraKilometer);
      // }
      // if (receiveItPriceFor5Km != null) {
      //   setReceiveItPriceFor5Km(receiveItPriceFor5Km);
      // }
      // if (driverMinimumOrderTakingDistance != null) {
      //   setDriverMinimumOrderTakingDistance(driverMinimumOrderTakingDistance);
      // }
    });
    subscription?.cancel();
    subscription = Firestore.instance
        .collection('configs')
        .document('version1.0')
        .snapshots()
        .listen((event) {
      if (event['maintenanceNotice'] != null) {
        try {
          BotToast.showNotification(
            align: Alignment.topCenter,
            title: (fn) => Text('Maintenance Notice'),
            duration: Duration(seconds: 5),
            crossPage: true,
            subtitle: (fn) => Text(
              'This App is undergoing maintenance on ${event['maintenanceNotice']}.\n Please Don\'t make any new orders.\n For More Details Contact Customer Support.',
            ),
          );
        } catch (ex) {
          print(ex.toString());
        }
      }
      setConfigData(event.data);
    });
    return data;
  }

  void setConfigData(Map<String, dynamic> configData) {
    if (configData == null) {
      return;
    }
    configData.forEach((key, value) {
      config.value.update(key, (old) => value, ifAbsent: () => value);
    });
    config.add(config.value);
  }
  // setVersionName(String pVersionName) {
  //   versionName.add(pVersionName);
  // }

  // setVersionCode(int pVersionCode) {
  //   versionCode.add(pVersionCode);
  // }

  // setReceiveItMinimumStoreDistance(double pReceiveItMinimumStoreDistance) {
  //   receiveItMinimumStoreDistance.add(pReceiveItMinimumStoreDistance);
  // }

  // setReceiveItPricePerExtraKilometer(double pReceiveItPricePerExtraKilometer) {
  //   receiveItPricePerExtraKilometer.add(pReceiveItPricePerExtraKilometer);
  // }

  // setReceiveItPriceFor5Km(double pReceiveItPriceFor5Km) {
  //   receiveItPriceFor5Km.add(pReceiveItPriceFor5Km);
  // }

  // setDriverMinimumOrderTakingDistance(
  //     double pDriverMinimumOrderTakingDistance) {
  //   driverMinimumOrderTakingDistance.add(pDriverMinimumOrderTakingDistance);
  // }
}
