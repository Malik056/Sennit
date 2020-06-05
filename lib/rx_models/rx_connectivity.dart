import 'dart:async';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sennit/my_widgets/custom_loding_widget.dart';

class RxConnectivity {
  StreamSubscription connectivityCheck;
  final Connectivity _connectivity = Connectivity();

  Future<bool> checkConnection() async {
    ConnectivityResult networkStatus = ConnectivityResult.none;
    try {
      // temp reach-around for https://github.com/flutter/flutter/issues/20980
      networkStatus = await _connectivity.checkConnectivity();
    } catch (e) {
      print(e.toString());
    }
    if (networkStatus == ConnectivityResult.none) {
      return false;
    }
    try {
      final result = await http.get('http://example.com');
      if (result.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    } on SocketException catch (_) {
      print('not connected');
      return false;
    }
  }

  Future<void> init() async {
    ConnectivityResult networkStatus = ConnectivityResult.none;
    try {
      // temp reach-around for https://github.com/flutter/flutter/issues/20980
      networkStatus = await _connectivity.checkConnectivity();
    } catch (e) {
      print(e.toString());
    }
    if (networkStatus != ConnectivityResult.none) {
      connectivityCheck?.cancel();
      connectivityCheck = Stream.periodic(
        new Duration(seconds: 5),
      ).listen(
        (event) async {
          bool hasConnection = await checkConnection();

          if (connectivity.value != hasConnection) {
            connectivity.add(hasConnection);
          }

          if (!hasConnection) {
            BotToast.showCustomLoading(
              align: Alignment.center,
              allowClick: false,
              clickClose: false,
              crossPage: true,
              toastBuilder: (fn) {
                return CustomWifiLoadingWidget();
              },
            );
          } else {
            try {
              BotToast.closeAllLoading();
            } catch (_) {
              print(_);
            }
          }
        },
      );

      bool result = await checkConnection();
      connectivity.add(result);
    } else if (Platform.isIOS) {
      connectivityCheck?.cancel();
      connectivityCheck = Stream.periodic(
        new Duration(seconds: 5),
      ).listen(
        (event) async {
          bool hasConnection = await checkConnection();

          if (connectivity.value != hasConnection) {
            connectivity.add(hasConnection);
          }

          if (!hasConnection) {
            BotToast.showCustomLoading(
              align: Alignment.center,
              allowClick: false,
              clickClose: false,
              crossPage: true,
              toastBuilder: (fn) {
                return CustomWifiLoadingWidget();
              },
            );
          } else {
            BotToast.closeAllLoading();
          }
        },
      );
    }
    print(networkStatus.toString());
    try {
      _connectivity.onConnectivityChanged
          .listen((ConnectivityResult result) async {
        if (result == ConnectivityResult.none) {
          // timer?.cancel();
          if (!Platform.isIOS) {
            connectivityCheck?.cancel();
          }
          if (connectivity.value) {
            BotToast.showCustomLoading(
              align: Alignment.center,
              allowClick: false,
              clickClose: false,
              crossPage: true,
              toastBuilder: (fn) {
                return CustomWifiLoadingWidget();
              },
            );
            connectivity.add(false);
          }
        } else {
          connectivityCheck?.cancel();
          connectivityCheck = Stream.periodic(
            new Duration(seconds: 5),
          ).listen((event) async {
            bool hasConnection = await checkConnection();

            if (connectivity.value != hasConnection) {
              connectivity.add(hasConnection);
            }

            if (!hasConnection) {
              BotToast.showCustomLoading(
                align: Alignment.center,
                allowClick: false,
                clickClose: false,
                crossPage: true,
                toastBuilder: (fn) {
                  return CustomWifiLoadingWidget();
                },
              );
            } else {
              BotToast.closeAllLoading();
            }
          });
          bool hasConnection = await checkConnection();
          if (connectivity.value != hasConnection) {
            connectivity.add(hasConnection);
          }
        }
      });
    } catch (e) {
      print(e.toString());
    }
    // var connection = Connectivity();
    // connectivity
    //     .add(await connection.checkConnectivity() != ConnectivityResult.none);

    // Stream.periodic(
    //   Duration(seconds: 1),
    // ).listen((event) async {
    //   http.Response response = await http.get('www.google.com');
    //   if(response)
    // });

    // connection.onConnectivityChanged.listen((event) {
    //   connectivity.add(event != ConnectivityResult.none);
    // });
  }

  BehaviorSubject<bool> connectivity = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get stream$ => connectivity.stream;

  bool get currentState => connectivity.value;
}
