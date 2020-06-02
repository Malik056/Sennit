import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
// import 'package:geocoder/geocoder.dart' as geocoder;
import 'package:geocoder/model.dart';
import 'package:get_it/get_it.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_map_location_picker/generated/i18n.dart'
    as location_picker;
import 'package:location/location.dart' as location;
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
// import 'package:place_picker/place_picker.dart';
import 'package:sennit/driver/delivery_navigation.dart';
import 'package:sennit/driver/driver_startpage.dart';
import 'package:sennit/driver/home.dart';
import 'package:sennit/driver/signin.dart';
import 'package:sennit/my_widgets/notification.dart';
import 'package:sennit/my_widgets/review.dart';
import 'package:sennit/my_widgets/update_notice.dart';
import 'package:sennit/my_widgets/verify_email_route.dart';
import 'package:sennit/partner_store/home.dart';
import 'package:sennit/rx_models/rx_cart.dart';
import 'package:sennit/rx_models/rx_config.dart';
import 'package:sennit/rx_models/rx_connectivity.dart';
import 'package:sennit/rx_models/rx_receiveit_tab.dart';
import 'package:sennit/rx_models/rx_searchbar_title.dart';
import 'package:sennit/rx_models/rx_storesAndItems.dart';
import 'package:sennit/start_page.dart';
import 'package:sennit/rx_models/rx_address.dart';
import 'package:sennit/user/home.dart';
import 'package:sennit/user/sendit.dart';
import 'package:sennit/user/signin.dart';
import 'package:sennit/user/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shortid/shortid.dart';
import 'driver/signup.dart';
import 'models/models.dart';
import 'user/user_startpage.dart';

// Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
//   if (message.containsKey('data')) {
//     // Handle data message
//     final dynamic data = message['data'];
//   }

//   if (message.containsKey('notification')) {
//     // Handle notification message
//     final dynamic notification = message['notification'];
//   }

//   // Or do other work.
// }
void registerSingletons() {
  GetIt.I.registerSingleton<RxConnectivity>(RxConnectivity());
  GetIt.I.registerSingleton<RxAddress>(RxAddress());
  GetIt.I.registerSingleton<RxConfig>(RxConfig());
  GetIt.I.registerSingleton<RxReceiveItSearchBarTitle>(
      RxReceiveItSearchBarTitle());
  GetIt.I.registerSingleton<RxReceiveItTab>(RxReceiveItTab());
  RxStoresAndItems rxStoresAndItems = RxStoresAndItems();
  GetIt.I.registerSingleton<RxStoresAndItems>(rxStoresAndItems);
  GetIt.I.registerSingleton<RxUserCart>(RxUserCart());
}

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // await locationInitializer();
  shortid.characters('ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-');
  shortid.seed(DateTime.now().millisecondsSinceEpoch / 100000);
  registerSingletons();
  RxConnectivity rxConnectivity = GetIt.I.get<RxConnectivity>();
  await rxConnectivity.init();
  // await databaseInitializer();
  Utils.getFCMServerKey();
  await Utils.getAPIKey();

  // await initializeDateFormatting('en_ZA');
  runApp(MaterialApp(home: MyApp()));
}

databaseInitializer() async {
  // await DatabaseHelper.iniitialize();
}

class MyApp extends StatefulWidget with WidgetsBindingObserver {
  static const String startPage = 'startPage';
  static String initialRoute = startPage;
  static Address dummyAddress = Address(
    addressLine: 'NULL',
    adminArea: 'Null',
    coordinates: Coordinates(0, 0),
    countryName: 'Null',
    countryCode: 'Null',
    featureName: 'Null',
    locality: 'Null',
    postalCode: 'Null',
    subAdminArea: 'Null',
    subLocality: 'Null',
    subThoroughfare: 'NULL',
    thoroughfare: 'NULL',
  );
  // static const String searchPage = 'searchPage';
  // static Future<void> futureCart;
  // static final String startPage2 = '/startPage2';
  static const String userSignup = '$userStartPage/userSignup';
  static const String userSignIn = '$userStartPage/userSignIn';
  static const String driverSignup = '$driverStartPage/driverSignup';
  static const String userStartPage = '$startPage/userStartPage';
  static const String driverStartPage = '$startPage/driverStartPage';
  static const String driverSignin = '$driverStartPage/driverSignin';
  static const String verifyEmailRoute = 'verifyEmailRoute';
  static const String userHome = 'userHome';
  static const String selectFromAddress = 'sendItSourceRoute';
  static const String deliverToAddresses = 'sendItDestinationRoute';
  static const String addAddressFrom = 'addAddressFrom';
  static const String addAddressToForSennit = 'addAddressToSennit';
  static const String addAddressToReceiveIt = 'addAddressToReceiveIt';
  static const String senditCartPage = 'sendItCartPage';
  // static const String receiveItRoute = 'receiveItRoute';
  static const String storeMainPage = 'storeMainPage';
  static const String partnerStoreHome = 'partnerStoreHome';
  static const String driverHome = 'driverHome';
  static const String driverNavigationRoute = 'driverNavigationRoute';
  static const String activeOrderBody = 'activeOrderBody';
  static const String reviewWidget = 'reviewWidget';
  static const String notificationWidget = 'notificationWidget';
  static const String sennitOrderRoute = 'sennitOrderRoute';

  static const Color secondaryColor = Color.fromARGB(255, 57, 59, 82);
  static const Color primaryColor = Color.fromARGB(255, 87, 89, 152);
  static Color disabledPrimaryColor =
      Color.fromARGB(255, 87 + 40, 89 + 40, 152 + 40);
  // static Address _address;
  // static Location _location;
  // static Future<LatLng> _lastKnowLocation;

  // static LatLng _initialLocation;

  MyApp() {
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  BehaviorSubject<String> statusBehavior =
      BehaviorSubject<String>.seeded('Loading ...');
  Stream<String> get status$ => statusBehavior.stream;
  String get status => statusBehavior.value;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('logo');
    var initializationSettingsIOS = new IOSInitializationSettings(
      onDidReceiveLocalNotification: (a, b, c, d) async {},
    );
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // DatabaseHelper.getDatabase().close();
      // setState(() {});
    }
  }

  Future<dynamic> onSelectNotification(String payload) async {
    flutterLocalNotificationsPlugin.cancelAll();
    Map<String, dynamic> payloadMap = json.decode(payload);
    Map<String, dynamic> data =
        Platform.isIOS ? payloadMap : payloadMap['data'];
    Firestore.instance
        .collection('users')
        .document(data['userId'])
        .collection('notifications')
        .document(data['orderId'])
        .setData(
      {
        'seen': true,
      },
      merge: true,
    );
    if (data.containsKey('type')) {
      return;
    }
    // Navigator.popUntil(context, predicate)
    navigatorKey.currentState.push(
      MaterialPageRoute(
        builder: (ctx) => ReviewWidget(
          user: Session.data['user'],
          itemId: null,
          isDriver: true,
          userId: data['userId'],
          driverId: data['driverId'],
          fromNotification: true,
          orderId: data['orderId'],
        ),
      ),
    );
    // Navigator.push(
    //   context,
    // );
  }

  static Future showNotificationWithDefaultSound(
      Map<String, dynamic> jsonData) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'orderCompleteChannel',
      'OrderComplete',
      'When The Order is Delivered this channel will show the notifications',
      importance: Importance.Max,
      priority: Priority.High,
      enableLights: true,
      enableVibration: true,
      autoCancel: true,
      color: Colors.green,
      playSound: true,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      jsonData['title'] ?? 'Order Delivered',
      jsonData['message'] ?? 'Your Order has delivered',
      platformChannelSpecifics,
      payload: json.encode(
        jsonData,
      ),
    );
  }

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  // This widget is the root of your application.

  Future<bool> checkForUpdate() async {
    var connection = GetIt.I.get<RxConnectivity>();
    if (!connection.currentState) {
      // setState(() {
      statusBehavior.add('No Internet Connection, Waiting ....');
      // });
      return null;
    }
    RxConfig rxConfig = GetIt.I.get<RxConfig>();
    await rxConfig.init();
    Map<String, dynamic> config = rxConfig.config.value;
    if (config['maintenanceNotice'] != null) {
      try {
        BotToast.showNotification(
          align: Alignment.topCenter,
          title: (fn) => Text('Maintenance Notice'),
          duration: Duration(seconds: 5),
          crossPage: true,
          subtitle: (fn) => Text(
            'This App is undergoing maintenance on ${config['maintenanceNotice']}.\n Please Don\'t make any new orders.\n For More Details Contact Customer Support.',
          ),
        );
      } catch (ex) {
        print(ex.toString());
      }
    }
    num newVersionCode = config['versionCode'];
    if (newVersionCode > Session.version) {
      return true;
    } else {
      return false;
    }
  }

  Widget getLoadingWidget() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/images/logo.png'),
          SizedBox(height: 20),
          StreamBuilder<String>(
              initialData: 'Initializing .....',
              stream: status$,
              builder: (context, snapshot) {
                return Center(
                  child: Text(snapshot.data),
                );
              }),
        ],
      ),
    );
  }

  Future<String> initializeAndGetInitialRoute() async {
    // var initializingSuccessful = await initialize(setState);
    // if (!initializingSuccessful) {
    //   return null;
    // }
    var rxConnectivity = GetIt.I.get<RxConnectivity>();
    bool connected = rxConnectivity.currentState;

    if (!connected) {
      // setState(() {
      statusBehavior.add('No Connection! Waiting for Connection ....');
      // });
      return null;
    }
    // RxConfig rxConfig = GetIt.I.get<RxConfig>();
    // setState(() {
    //   status = 'Checking for updates 10%';
    // });
    // await rxConfig.init();
    // setState(() {
    statusBehavior.add('Fetching your location ...20%');
    // });
    RxAddress rxAddress = GetIt.I.get<RxAddress>();
    StreamSubscription loadingProgressSubscription = Stream.periodic(
        Duration(
          milliseconds: 300,
        ), (value) {
      int computedValue = 20 + value;
      if (computedValue > 40) {
        return 40;
      }
      return computedValue;
    }).listen((event) {
      // setState(() {
      statusBehavior.add('Fetching your location ... $event%');
      // });
    });
    var addressResult;
    try {
      addressResult = await rxAddress.init();
    } catch (ex) {
      debugPrint(ex.toString());
    }
    loadingProgressSubscription?.cancel();
    if (addressResult == null) {
      // setState(() {
      statusBehavior.add("Couldn't get your location. Retrying .....");
      // });
      return null;
    }
    statusBehavior.add('Initialized Stores and Items ... 45%');
    RxStoresAndItems rxStoresAndItems = GetIt.I.get<RxStoresAndItems>();
    loadingProgressSubscription = Stream.periodic(
        Duration(
          milliseconds: 600,
        ), (value) {
      int computedValue = 45 + value;
      if (computedValue > 70) {
        return 70;
      }
      return computedValue;
    }).listen((event) {
      // setState(() {
      statusBehavior.add('Initialized Stores and Items ... $event%');
      // });
    });
    var storesAndItemsResult =
        await rxStoresAndItems.initializeStoresAndItems();
    loadingProgressSubscription.cancel();
    if (storesAndItemsResult == null) {
      // setState(() {
      statusBehavior.add("Couldn't get Stores and Products. Retrying .....");
      // });
      return null;
    }
    // setState(() {
    statusBehavior.add('Fetching User Data..... 75%');
    // });

    final user = await FirebaseAuth.instance.currentUser().catchError((error) {
      print(error.toString());
      return null;
    });
    if (user == null) {
      return MyApp.startPage;
    }
    final result = await Firestore.instance
        .collection('users')
        .document(user.uid)
        .get()
        .catchError((error) {
      print(error.toString());
      return null;
    });
    if (result == null) {
      statusBehavior.add('Couldn\'t Fetch User Data. Retrying ......');
      return null;
    }
    statusBehavior.add('Fetching User Data..... 85%');
    User newUser;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Driver newDriver;
    if (result != null &&
        result.data != null &&
        result.data.length > 0 &&
        result.exists) {
      // Session.data.update('user', (a) {
      //   return User.fromMap(result.data);
      // }, ifAbsent: () {
      //   return User.fromMap(result.data);
      // });
      newUser = User.fromMap(result.data);
      // if (user.isEmailVerified) {
      //   // MyApp.initialRoute = MyApp.userHome;
      // } else {
      //   // MyApp.initialRoute = MyApp.verifyEmailRoute;
      // }
    }
    final driverResult = await Firestore.instance
        .collection('drivers')
        .document(user.uid)
        .get()
        .catchError((error) {
      return null;
    });
    if (driverResult == null) {
      statusBehavior.add('Couldn\'t Fetch User Data..... retrying');
      return null;
    }
    if ((driverResult.data?.length ?? 0) > 0 && driverResult.exists) {
      newDriver = Driver.fromMap(driverResult.data);
      newDriver.driverId = user.uid;
      statusBehavior.add('Fetching User Data..... 90%');
      // driverResult.data
      //     .update('driverId', (old) => user.uid, ifAbsent: () => user.uid);
      // Session.data.update('driver', (a) {
      //   return Driver.fromMap(driverResult.data);
      // }, ifAbsent: () {
      //   return Driver.fromMap(driverResult.data);
      // });
      // if (user.isEmailVerified) {
      //   MyApp.initialRoute = MyApp.driverHome;
      // } else {
      //   MyApp.initialRoute = MyApp.verifyEmailRoute;
      // }

      if (newUser != null) {
        String userType = preferences.getString('user');
        if ((userType ?? '') == 'user') {
          statusBehavior.add('Done ..... 100%');
          if (user.isEmailVerified) {
            Session.data.putIfAbsent('user', () => newUser);
            return MyApp.userHome;
          } else {
            return MyApp.verifyEmailRoute;
          }
        } else if ((userType ?? '') == 'driver') {
          statusBehavior.add('Done ..... 100%');
          if (user.isEmailVerified) {
            Session.data.putIfAbsent('driver', () => newDriver);
            return MyApp.driverHome;
          } else {
            return MyApp.verifyEmailRoute;
          }
        }
        statusBehavior.add('Awaiting response .....');
        String nextRoute = await showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text('Login'),
                insetPadding: EdgeInsets.all(0),
                contentPadding: EdgeInsets.only(top: 20),
                content: WillPopScope(
                  onWillPop: () async => false,
                  child: Center(
                    heightFactor: 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          // selected: true,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          leading: Icon(FontAwesomeIcons.car),
                          title: Text('Login as Driver'),
                          trailing: Icon(Icons.navigate_next),
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setString('user', 'driver');
                            Session.data.putIfAbsent('driver', () => newDriver);
                            if (!user.isEmailVerified) {
                              Navigator.pop(context, MyApp.verifyEmailRoute);
                            }
                            Navigator.pop(context, MyApp.driverHome);
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          // selected: true,
                          leading: Icon(
                            Icons.account_circle,
                          ),
                          title: Text('Login as User'),
                          trailing: Icon(Icons.navigate_next),
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setString('user', 'user');
                            Session.data.putIfAbsent('user', () => newUser);
                            if (!user.isEmailVerified) {
                              Navigator.pop(context, MyApp.verifyEmailRoute);
                            }
                            Navigator.pop(context, MyApp.userHome);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });

        statusBehavior.add('Done .... 100%');
        return nextRoute;
      } else {
        statusBehavior.add('Done ..... 100%');
        preferences.setString('user', 'driver');
        Session.data.update(
          'driver',
          (old) => newDriver,
          ifAbsent: () => newDriver,
        );
        if (user.isEmailVerified) {
          // statusBehavior.add('Done .... 100%');
          return MyApp.driverHome;
        } else {
          // statusBehavior.add('Done .... 100%');
          return MyApp.verifyEmailRoute;
        }
      }
    } else if (newUser != null) {
      statusBehavior.add('Done .... 100%');
      preferences.setString('user', 'user');
      Session.data.update(
        'user',
        (old) => newUser,
        ifAbsent: () => newUser,
      );
      if (user.isEmailVerified) {
        return MyApp.userHome;
      } else {
        return MyApp.verifyEmailRoute;
      }
    }
    final partnerStoreResult = await Firestore.instance
        .collection('partnerStores')
        .document(user.uid)
        .get()
        .catchError((error) {
      return null;
    });
    if (partnerStoreResult == null) {
      statusBehavior.add('Couldn\'t Fetch User Data..... retrying');
      return null;
    }
    if (partnerStoreResult.exists &&
        (partnerStoreResult.data?.length ?? 0) > 0) {
      var data = await Firestore.instance
          .collection('stores')
          .document(partnerStoreResult.data['storeId'])
          .get()
          .catchError((error) {
        print(error.toString());
        return null;
      });
      if (data == null) {
        statusBehavior.add('Couldn\'t Fetch User Data..... retrying');
        return null;
      }
      if (data != null &&
          data.exists &&
          data.data != null &&
          data.data.length > 0) {
        Session.data.update('partnerStore', (a) {
          return Store.fromMap(data.data)..storeId = data.documentID;
        }, ifAbsent: () {
          return Store.fromMap(data.data)..storeId = data.documentID;
        });
      }
      statusBehavior.add('Done .... 100%');
      preferences.setString('user', 'store');
      return MyApp.partnerStoreHome;
    } else {
      bool error = false;
      await FirebaseAuth.instance.signOut().catchError((error) {
        error = true;
      });
      if (error) {
        return null;
      }
      preferences.setString('user', null);
      statusBehavior.add('Done .... 100%');
      return MyApp.startPage;
    }
  }

  Widget build(BuildContext context) {
    statusBehavior.add('Checking for Updates ....');
    Future<bool> newVersionCheck = checkForUpdate();
    return MaterialApp(
      builder: BotToastInit(),
      navigatorKey: navigatorKey,
      localizationsDelegates: const [
        location_picker.S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('en', ''),
        // Locale('ar', ''),
      ],
      navigatorObservers: [BotToastNavigatorObserver()],
      // initialRoute: MyApp.initialRoute,
      routes: {
        MyApp.driverNavigationRoute: (context) => DeliveryTrackingRoute(
              OpenAs.NAVIGATION,
              fromCoordinate: LatLng(31, 74),
              toCoordinate: LatLng(40, 80),
              myLocation: LatLng(42, 85),
            ),
        MyApp.startPage: (context) => StartPage(),
        MyApp.driverHome: (context) => HomeScreenDriver(),
        MyApp.userSignup: (context) => UserSignUpRoute(),
        MyApp.userSignIn: (context) => UserSignInRoute(),
        MyApp.userStartPage: (context) => UserStartPage(),
        MyApp.driverSignup: (context) => DriverSignUpRoute(),
        MyApp.driverSignin: (context) => DriverSignInRoute(),
        MyApp.driverStartPage: (context) => DriverStartPage(),
        MyApp.userHome: (context) => UserHomeRoute(),
        MyApp.verifyEmailRoute: (context) => VerifyEmailRoute(),
        MyApp.selectFromAddress: (context) => SelectFromAddressRoute(),
        // MyApp.receiveItRoute: (context) => StoresRoute(
        //       key: GlobalKey<StoresRouteState>(),
        //       address: MyApp._address,
        //     ),
        // MyApp.storeMainPage: (context) => StoreMainPage(),
        MyApp.partnerStoreHome: (context) => OrderedItemsList(),
        // activeOrderBody: (context) => ActiveOrder(),
        // MyApp.searchPage: (context) => SearchWidget(demo: true,),
        MyApp.notificationWidget: (context) => UserNotificationWidget(),
        // sennitOrderRoute: (context) => SennitOrderRoute({}),
      },
      title: 'Sennit',
      theme: ThemeData(
        backgroundColor: Colors.white,
        fontFamily: 'ArchivoNarrow',
        primaryColor: MyApp.secondaryColor,
        accentColor: MyApp.secondaryColor,
        // buttonColor: primaryColor,
        buttonTheme: ButtonThemeData(
          buttonColor: MyApp.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(6),
            ),
          ),
        ),
        bottomAppBarColor: Colors.white,
        bottomAppBarTheme: BottomAppBarTheme(
          color: Colors.white,
          elevation: 8,
        ),
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(
            color: MyApp.secondaryColor,
          ),
          color: Colors.white,
          textTheme: TextTheme(
            headline6: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'ArchivoNarrow',
              fontSize: 22,
              color: MyApp.secondaryColor,
            ),
          ),
        ),
        iconTheme: IconThemeData(
          color: MyApp.secondaryColor,
        ),
        textTheme: TextTheme(
          headline6: TextStyle(
            color: MyApp.secondaryColor,
            fontSize: 22,
            fontWeight: FontWeight.normal,
          ),
          headline5: TextStyle(
            color: MyApp.secondaryColor,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
          subtitle1: TextStyle(
            color: MyApp.secondaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          subtitle2: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          bodyText2: TextStyle(
            fontSize: 14,
            decorationColor: Colors.black,
            fontFamily: 'Roboto',
          ),
          button: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          headline4: TextStyle(
            fontSize: 26,
            color: MyApp.secondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: StatefulBuilder(builder: (context, setState) {
        return WillPopScope(
          onWillPop: () async => false,
          child: FutureBuilder<bool>(
            future: newVersionCheck,
            initialData: null,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              RxConfig rxConfig = GetIt.I.get<RxConfig>();
              if (snapshot.connectionState == ConnectionState.waiting) {
                return getLoadingWidget();
              }

              if (snapshot.data == null) {
                statusBehavior.add('Failed To Fetch Config. Retrying .......');
                newVersionCheck = checkForUpdate();
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  setState(() {});
                });
                return getLoadingWidget();
              }

              if (snapshot.data == true) {
                return UpdateNoticeRoute();
              } else if (rxConfig?.config?.value['closedForMaintenance'] ??
                  false) {
                return Center(
                  child: Column(
                    children: <Widget>[
                      Icon(FontAwesomeIcons.tools, size: 40),
                      SizedBox(height: 10),
                      Text(
                        'Sorry For Inconvenience! The App is Closed for Maintenance',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Text(
                        rxConfig?.config?.value['waitTime'] != null
                            ? 'We Will be back in ${rxConfig.config.value['waitTime']}'
                            : '',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                );
              }
              statusBehavior.add('Initializing Data .... 0%');
              Future<String> initialRoute = initializeAndGetInitialRoute();
              return StatefulBuilder(builder: (context, setStateVar) {
                return FutureBuilder<String>(
                    initialData: null,
                    future: initialRoute,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return getLoadingWidget();
                      }

                      if (snapshot.data == null) {
                        initialRoute = initializeAndGetInitialRoute();
                        WidgetsBinding.instance
                            .addPostFrameCallback((timeStamp) {
                          setStateVar(() {});
                        });
                        return getLoadingWidget();
                      }

                      if (snapshot.data == MyApp.startPage) {
                        return StartPage();
                      } else if (snapshot.data == MyApp.userHome) {
                        return UserHomeRoute();
                      } else if (snapshot.data == MyApp.driverHome) {
                        return HomeScreenDriver();
                      } else if (snapshot.data == MyApp.partnerStoreHome) {
                        return OrderedItemsList();
                      } else {
                        return StartPage();
                      }
                    });
              });
            },
          ),
        );
      }),
    );
  }

  // @override
  Widget build2(BuildContext context) {
    return FutureBuilder<void>(
      // future: initialize(null),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Column(children: [
              Image.asset('assets/images/logo.png'),
              SizedBox(
                height: 10,
              ),
              Text('$status'),
            ]),
          );
        }
        RxConfig config = GetIt.I.get<RxConfig>();
        return MaterialApp(
          localizationsDelegates: const [
            location_picker.S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const <Locale>[
            Locale('en', ''),
            Locale('ar', ''),
          ],
          navigatorObservers: [BotToastNavigatorObserver()],
          initialRoute: MyApp.initialRoute,
          routes: {
            MyApp.driverNavigationRoute: (context) => DeliveryTrackingRoute(
                  OpenAs.NAVIGATION,
                  fromCoordinate: LatLng(31, 74),
                  toCoordinate: LatLng(40, 80),
                  myLocation: LatLng(42, 85),
                ),
            MyApp.startPage: (context) => StartPage(),
            MyApp.driverHome: (context) => HomeScreenDriver(),
            MyApp.userSignup: (context) => UserSignUpRoute(),
            MyApp.userSignIn: (context) => UserSignInRoute(),
            MyApp.userStartPage: (context) => UserStartPage(),
            MyApp.driverSignup: (context) => DriverSignUpRoute(),
            MyApp.driverSignin: (context) => DriverSignInRoute(),
            MyApp.driverStartPage: (context) => DriverStartPage(),
            MyApp.userHome: (context) => UserHomeRoute(),
            MyApp.verifyEmailRoute: (context) => VerifyEmailRoute(),
            MyApp.selectFromAddress: (context) => SelectFromAddressRoute(),
            // MyApp.receiveItRoute: (context) => StoresRoute(
            //       key: GlobalKey<StoresRouteState>(),
            //       address: MyApp._address,
            //     ),
            // MyApp.storeMainPage: (context) => StoreMainPage(),
            MyApp.partnerStoreHome: (context) => OrderedItemsList(),
            // activeOrderBody: (context) => ActiveOrder(),
            // MyApp.searchPage: (context) => SearchWidget(demo: true,),
            MyApp.notificationWidget: (context) => UserNotificationWidget(),
            // sennitOrderRoute: (context) => SennitOrderRoute({}),
          },
          title: 'Sennit',
          theme: ThemeData(
            backgroundColor: Colors.white,
            fontFamily: 'ArchivoNarrow',
            primaryColor: MyApp.secondaryColor,
            accentColor: MyApp.secondaryColor,
            // buttonColor: primaryColor,
            buttonTheme: ButtonThemeData(
              buttonColor: MyApp.secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(6),
                ),
              ),
            ),
            bottomAppBarColor: Colors.white,
            bottomAppBarTheme: BottomAppBarTheme(
              color: Colors.white,
              elevation: 8,
            ),
            appBarTheme: AppBarTheme(
              iconTheme: IconThemeData(
                color: MyApp.secondaryColor,
              ),
              color: Colors.white,
              textTheme: TextTheme(
                headline6: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ArchivoNarrow',
                  fontSize: 22,
                  color: MyApp.secondaryColor,
                ),
              ),
            ),
            iconTheme: IconThemeData(
              color: MyApp.secondaryColor,
            ),
            textTheme: TextTheme(
              headline6: TextStyle(
                color: MyApp.secondaryColor,
                fontSize: 22,
                fontWeight: FontWeight.normal,
              ),
              headline5: TextStyle(
                color: MyApp.secondaryColor,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
              subtitle1: TextStyle(
                color: MyApp.secondaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              subtitle2: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              bodyText2: TextStyle(
                fontSize: 14,
                decorationColor: Colors.black,
                fontFamily: 'Roboto',
              ),
              button: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              headline4: TextStyle(
                fontSize: 26,
                color: MyApp.secondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          home: snapshot.connectionState == ConnectionState.waiting
              ? Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.white,
                    title: Text(
                      'Sennit',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    centerTitle: true,
                  ),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset('assets/images/logo.png'),
                        SizedBox(height: 40),
                        CircularProgressIndicator(),
                      ],
                    ),
                  ),
                )
              : config.config != null ? UpdateNoticeRoute() : null,
        );
      },
    );
  }
}

class UserSignUp {
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  String streetAddress = '';
  String city = '';
  String state = '';
  String country = '';
}

class SnackbarLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget leading;
  final Widget trailing;
  final Color color;

  SnackbarLayout({
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Colors.white,
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: leading ?? Opacity(opacity: 0),
          ),
          SizedBox(
            width: 15,
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  title ?? '',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  subtitle ?? '',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: trailing ??
                Opacity(
                  opacity: 0,
                ),
          ),
        ],
      ),
    );
  }
}

class Utils {
  static String _apiKey;
  static String _fcmServerKey;

  static Future<String> getAPIKey() async {
    if (_apiKey != null) {
      return _apiKey;
    }
    var key = json.decode(await rootBundle.loadString('assets/secret.json'));
    _apiKey = key['Maps'];
    return _apiKey;
  }

  static Future<String> getFCMServerKey() async {
    if (_fcmServerKey != null) {
      return _fcmServerKey;
    }
    var key = json.decode(await rootBundle.loadString('assets/secret.json'));
    _fcmServerKey = key['fcm_server_key'];
    return _fcmServerKey;
  }

  static Future<Map<String, String>> getUserNameAndPassword(
      {@required BuildContext context}) async {
    var name;
    var password;

    showDialog(
        context: context,
        builder: (context) {
          return CircularProgressIndicator();
        });
    var data = json.decode(await rootBundle.loadString('assets/secret.json'));
    name = data['email'];
    password = data['password'];

    Navigator.pop(context);
    return {'email': name, 'password': password};
  }

  static showWidgetInDialogue(context, Widget widget) {
    showDialog(
        context: context,
        builder: (context) {
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Container(
                height: 400,
                width: MediaQuery.of(context).size.width - 20,
                child: Card(
                  elevation: 8.0,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 40,
                      bottom: 40,
                    ),
                    child: widget,
                  ),
                ),
              ),
            ),
          );
        });
  }

  static showSnackBarError(BuildContext context, String message,
      {Duration duration}) {
    // SnackBar snackBar = SnackBar(
    //   backgroundColor: Colors.red.shade500,
    //   content: Text(
    //     message,
    //     style: TextStyle(color: Colors.white),
    //   ),
    //   duration: Duration(seconds: 4),
    // );

    // Scaffold.of(context).showSnackBar(snackBar);
    BotToast.showCustomNotification(
      toastBuilder: (fn) {
        return Container(
          color: Colors.white,
          // width: MediaQuery.of(context).size.width,
          height: kToolbarHeight,
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Icon(
                Icons.error,
                color: Colors.red,
              )),
              Expanded(
                flex: 3,
                child: Text('$message'),
              ),
              Spacer(),
            ],
          ),
        );
      },
      duration: duration ??
          Duration(
            seconds: 3,
          ),
    );

    // BotToast.showNotification(
    //   title: (_) {
    //     return Text("Error!");
    //   },
    //   align: Alignment.bottomCenter,
    //   subtitle: (_) => Text("$message"),
    //   // trailing: (_) => RaisedButton(
    //   //   color: Theme.of(context).primaryColor,
    //   //   child: Text(
    //   //     'Shop now',
    //   //     style: TextStyle(color: Colors.white),
    //   //   ),
    //   //   onPressed: () {
    //   //     Navigator.popUntil(context, (route) {
    //   //       return route.settings.name == 'receiveIt';
    //   //     });
    //   //   },
    //   // ),
    // );
  }

  static showSnackBarErrorUsingKey(GlobalKey<ScaffoldState> key, String message,
      {Duration duration}) {
    // SnackBar snackBar = SnackBar(
    //   backgroundColor: Colors.red.shade500,
    //   content: Text(
    //     message,
    //     style: TextStyle(color: Colors.white),
    //   ),
    //   duration: Duration(seconds: 4),
    // );

    // key.currentState.showSnackBar(snackBar);

    BotToast.showCustomNotification(
      toastBuilder: (fn) {
        return SnackbarLayout(
          leading: Icon(
            Icons.error,
            color: Colors.red,
          ),
          color: Colors.white,
          title: 'Error',
          subtitle: '$message',
        );
      },
      duration: duration ??
          Duration(
            seconds: 3,
          ),
    );

    // BotToast.showNotification(
    //   title: (_) {
    //     return Text("Error!");
    //   },
    //   align: Alignment.bottomCenter,
    //   subtitle: (_) => Text("$message"),
    //   // trailing: (_) => RaisedButton(
    //   //   color: Theme.of(context).primaryColor,
    //   //   child: Text(
    //   //     'Shop now',
    //   //     style: TextStyle(color: Colors.white),
    //   //   ),
    //   //   onPressed: () {
    //   //     Navigator.popUntil(context, (route) {
    //   //       return route.settings.name == 'receiveIt';
    //   //     });
    //   //   },
    //   // ),
    // );
  }

  static showSnackBarWarning(BuildContext context, String message,
      [Duration duration]) {
    BotToast.showCustomNotification(
      toastBuilder: (fn) {
        return SnackbarLayout(
          leading: Icon(
            Icons.warning,
            color: Colors.yellow[400],
          ),
          color: Colors.white,
          title: 'Warning',
          subtitle: '$message',
        );
      },
      duration: duration ??
          Duration(
            seconds: 4,
          ),
    );
  }

  static showSnackBarWarningUsingKey(
      GlobalKey<ScaffoldState> key, String message,
      {Duration duration}) {
    BotToast.showCustomNotification(
        toastBuilder: (fn) {
          return SnackbarLayout(
            leading: Icon(
              Icons.warning,
              color: Colors.yellow[400],
            ),
            color: Colors.white,
            title: 'Warning',
            subtitle: '$message',
          );
        },
        duration: duration ??
            Duration(
              seconds: 3,
            ));
  }

  static showSnackBarSuccess(BuildContext context, String message,
      {Duration duration}) {
    BotToast.showCustomNotification(
      toastBuilder: (fn) {
        return SnackbarLayout(
          leading: Icon(
            Icons.check_circle,
            color: Colors.green,
          ),
          color: Colors.white,
          title: 'Success',
          subtitle: '$message',
        );
      },
      duration: duration ??
          Duration(
            seconds: 3,
          ),
    );
  }

  static showSnackBarSuccessUsingKey(
      GlobalKey<ScaffoldState> key, String message,
      {Duration duration}) {
    BotToast.showCustomNotification(
      toastBuilder: (fn) {
        return SnackbarLayout(
          leading: Icon(
            Icons.check_circle,
            color: Colors.green,
          ),
          color: Colors.white,
          title: 'Success',
          subtitle: '$message',
        );
      },
      duration: duration ??
          Duration(
            seconds: 3,
          ),
    );
  }

  static void showSuccessDialog(String message) {
    BotToast.showEnhancedWidget(toastBuilder: (a) {
      return Center(
        child: Container(
          width: 300,
          height: 230,
          padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Spacer(),
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 36,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  '$message',
                  style: TextStyle(
                    color: Color.fromARGB(255, 87, 89, 152),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      );
    });
  }

  static void showInfoDialog(String message) {
    BotToast.showEnhancedWidget(toastBuilder: (a) {
      return Center(
        child: Container(
          width: 300,
          height: 230,
          padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Spacer(),
                Icon(
                  Icons.info,
                  color: MyApp.primaryColor,
                  size: 36,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  '$message',
                  style: TextStyle(
                    color: Color.fromARGB(255, 87, 89, 152),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      );
    });
    Future.delayed(Duration(seconds: 2), () {
      BotToast.cleanAll();
    });
  }

  static double calculateDistance(LatLng latlng1, LatLng latlng2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((latlng2.latitude - latlng1.latitude) * p) / 2 +
        c(latlng1.latitude * p) *
            c(latlng2.latitude * p) *
            (1 - c((latlng2.longitude - latlng1.longitude) * p)) /
            2;
    return (12742 * asin(sqrt(a))).abs();
  }

  static double calculateDistanceFromCoordinates(
      Coordinates coordinates1, Coordinates coordinates2) {
    LatLng latlng1 = LatLng(coordinates1.latitude, coordinates1.longitude);
    LatLng latlng2 = LatLng(coordinates2.latitude, coordinates2.longitude);
    return calculateDistance(latlng1, latlng2);
  }

  static showPlacePicker(BuildContext context,
      {@required LatLng initialLocation}) async {
    String apiKey = await getAPIKey();
    LatLng latlng = Utils.latLngFromCoordinates(
        GetIt.I.get<RxAddress>().currentMyAddress.coordinates);
    // LocationPicker(apiKey);
    Map<String, LocationResult> map =
        Map<String, LocationResult>.from((await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LocationPicker(
                  apiKey,
                  automaticallyAnimateToCurrentLocation: false,
                  initialCenter:
                      initialLocation ?? latlng ?? LatLng(30.5595, 22.9375),
                  requiredGPS: true,
                  myLocationButtonEnabled: true,
                  layersButtonEnabled: false,
                ),
                maintainState: true,
              ),
            )) ??
            {});
    if (map.isEmpty) {
      return null;
    }
    var keys = map.keys.toList();
    return map[keys[0]];
  }

  // static Future<LatLng> getMyLocation(
  //     {location.LocationAccuracy accuracy =
  //         location.LocationAccuracy.BALANCED}) async {
  //   final RxAddress addressService = GetIt.I.get<RxAddress>();
  //   final _location = Location()..changeSettings(accuracy: accuracy);
  //   if (await _location.hasPermission() != PermissionStatus.GRANTED) {
  //     var result = await _location.requestPermission();
  //     if (result != PermissionStatus.GRANTED) {
  //       Utils.showSnackBarError(null,
  //           'This App Needs Location Permission to work. Please give permission.');
  //     }
  //     return null;
  //   }
  //   Coordinates myLocation =
  //       await _location.getLocation().then<Coordinates>((data) {
  //     return Coordinates(data.latitude, data.longitude);
  //   });
  //   Address myAddress;
  //   if (myLocation != null) {
  //     myAddress = await Geocoder.google(await Utils.getAPIKey())
  //         .findAddressesFromCoordinates(myLocation)
  //         .then<Address>((value) => value[0]);
  //   }
  //   addressService.setMyAddress(myAddress);
  //   return Utils.latLngFromCoordinates(myAddress.coordinates);
  // }

  static Address getLastKnowAddress() {
    return GetIt.I.get<RxAddress>().currentMyAddress;
  }

  static Future<LatLng> getLatestLocation(
      {location.LocationAccuracy accuracy =
          location.LocationAccuracy.balanced}) async {
    // Location location = Location();
    // if (await location.hasPermission() == PermissionStatus.GRANTED) {
    //   LocationData data = await location.getLocation();
    //   Address myAddress = (await Geocoder.google(await Utils.getAPIKey())
    //       .findAddressesFromCoordinates(
    //           Coordinates(data.latitude, data.longitude)))[0];
    //   GetIt.I.get<RxAddress>().setMyAddress(myAddress);
    //   return LatLng(data.latitude, data.longitude);
    // } else {
    //   Utils.showSnackBarError(
    //     null,
    //     'Location Permission Denied: This App may misbehave.',
    //   );
    //   return null;
    // }
    final RxAddress addressService = GetIt.I.get<RxAddress>();
    return Utils.latLngFromCoordinates(
        addressService.currentMyAddress.coordinates);
    // final _location = Location()..changeSettings(accuracy: accuracy);
    // if (await _location.hasPermission() != PermissionStatus.GRANTED) {
    //   var result = await _location.requestPermission();
    //   if (result != PermissionStatus.GRANTED) {
    //     Utils.showSnackBarError(null,
    //         'This App Needs Location Permission to work. Please give permission.');
    //   }
    //   return null;
    // }
    // Coordinates myLocation =
    //     await _location.getLocation().then<Coordinates>((data) {
    //   return Coordinates(data.latitude, data.longitude);
    // });
    // Address myAddress;
    // if (myLocation != null) {
    //   myAddress = await Geocoder.google(await Utils.getAPIKey())
    //       .findAddressesFromCoordinates(myLocation)
    //       .then<Address>((value) => value[0]);
    // }
    // addressService.setMyAddress(myAddress);
    // return Utils.latLngFromCoordinates(myAddress.coordinates);
  }

  static LatLng latLngFromString(String latlng) {
    if (latlng == null) {
      return null;
    }
    List<String> splitedValues = latlng.split(',');
    double latitude = double.parse(splitedValues[0]);
    double longitude = double.parse(splitedValues[1]);
    return LatLng(latitude, longitude);
  }

  static LatLng latLngFromCoordinates(Coordinates coordinates) {
    if (coordinates == null) return null;
    return LatLng(coordinates.latitude, coordinates.longitude);
  }

  static Coordinates coordinatesFromLatLng(LatLng latlng) {
    if (latlng == null) return null;
    return Coordinates(latlng.latitude, latlng.longitude);
  }

  static String genderToString(Gender gender) {
    switch (gender) {
      case Gender.male:
        return "MALE";
      case Gender.female:
        return "FEMALE";
      default:
        return "OTHER";
    }
  }

  static Gender getGenderFromString(String name) {
    switch (name.toUpperCase()) {
      case "MALE":
        return Gender.male;
      case "FEMALE":
        return Gender.female;
      default:
        return Gender.other;
    }
  }

  static String latLngToString(LatLng latLng) {
    if (latLng == null) {
      return null;
    }
    return "${latLng.latitude},${latLng.longitude}";
  }

  static String boxSizeToString(BoxSize boxsSize) {
    switch (boxsSize) {
      case BoxSize.small:
        return "Small";
      case BoxSize.medium:
        return "Medium";
      default:
        return "Large";
    }
  }

  static BoxSize getBoxSizeFromString(String boxSize) {
    switch (boxSize.toUpperCase()) {
      case 'SMALL':
        return BoxSize.small;
      case 'MEDIUM':
        return BoxSize.medium;
      default:
        return BoxSize.large;
    }
  }

  static void showLoadingDialog(BuildContext context, [bool dismissible]) {
    // showDialog(
    //     context: context,
    //     barrierDismissible: dismissible ?? true,
    //     builder: (context) {
    //       return Center(
    //         child: CircularProgressIndicator(
    //           strokeWidth: 2,
    //         ),
    //       );
    //     });
    BotToast.showLoading(crossPage: false, clickClose: dismissible ?? false);
  }

  static bool isEmailCorrect(String email) {
    if (email.isEmpty) {
      return false;
    } else {
      // RegExp re = RegExp(
      //     r'^[a-zA-Z]+(([a-zA-Z0-9])*)+(((\.([a-zA-Z0-9])+)*(_([a-zA-Z0-9])+)*)*)*@[a-zA-Z]+(\.[a-zA-Z]+)+$',
      //     caseSensitive: false,
      //     multiLine: false);
      RegExp re = RegExp(
        r'^[^@]+@[^@.]+(\.[^@.]+)+$',
        caseSensitive: false,
        multiLine: false,
      );
      if (!re.hasMatch(email)) {
        return false;
      }
    }
    return true;
  }

  static Future signOutUser(context) async {
    BotToast.showLoading();
    // Navigator.of(context).popUntil((route) => route.isFirst);
    FirebaseMessaging fcm = FirebaseMessaging();
    GetIt.I.get<RxReceiveItTab>().index.add(0);
    User user = Session.data['user'];
    if (user == null) {
      Session.data.clear();
      BotToast.closeAllLoading();
      Navigator.of(context)
          .pushNamedAndRemoveUntil(MyApp.startPage, (route) => false);
      return;
    } else {
      Session.data.clear();
      BotToast.closeAllLoading();
      Future unRegisteringTokens = Firestore.instance
          .collection('users')
          .document(user.userId)
          .collection('tokens')
          .document(await fcm.getToken())
          .delete()
          .catchError((error) {
        print(error.toString());
      }).timeout(Duration(seconds: 12), onTimeout: () {
        // Navigator.pop(context);
      });
      await unRegisteringTokens;
      // Navigator.pop(context);
      // MyAppState.navigatorKey.currentState.pop();
      await FirebaseAuth.instance.signOut();
      Navigator.of(context)
          .pushNamedAndRemoveUntil(MyApp.startPage, (route) => false);
    }
  }

  static Future<DocumentSnapshot> getFirebaseDocument(
      DocumentReference ref) async {
    return ref.get().then(
      (snapshot) {
        return snapshot;
      },
    ).timeout(
      Duration(seconds: 15),
      onTimeout: () {
        Utils.showSnackBarError(null, 'Request Timed Out');
        return null;
      },
    ).catchError((_) {
      Utils.showSnackBarError(null, _.toString());
      return null;
    });
  }

  static Future<dynamic> onResume(payload) async {
    final uid = (await FirebaseAuth.instance.currentUser()).uid;
    Map data = Platform.isIOS ? payload : payload['data'];
    if (data.containsKey('type') && data['type'] == 'partnerStoreOrder') {
      return;
    }
    if (uid == null) return;
    if (uid == data['userId']) {
      await Firestore.instance.collection('users').document(uid).get().then(
        (userData) async {
          if (userData == null ||
              !userData.exists ||
              userData.data == null ||
              userData.data.length <= 0) {
            MyAppState?.navigatorKey?.currentState?.pop();
            Utils.showSnackBarError(
              null,
              "User not found",
            );
            return;
          }
          User user = User.fromMap(userData.data);
          user.userId = uid;
          Session.data.update(
            'user',
            (a) {
              return user;
            },
            ifAbsent: () {
              return user;
            },
          );
          if (!data.containsKey('driverId') || data['driverId'] == null) {
            return;
          }
          MyAppState?.navigatorKey?.currentState?.push(
            MaterialPageRoute(
              builder: (context) {
                print(data);
                return ReviewWidget(
                  orderId: data['orderId'],
                  user: user,
                  itemId: null,
                  isDriver: true,
                  driverId: data['driverId'],
                  userId: uid,
                );
              },
            ),
          );
        },
      );
    }
  }

  static Future<dynamic> onLaunch(payload) async {
    final uid = (await FirebaseAuth.instance.currentUser()).uid;
    final data = Platform.isIOS ? payload : payload['data'];
    if (data.containsKey('type') && data['type'] == 'partnerStoreOrder') {
      return;
    }
    if (uid == null) return;
    if (uid == data['userId']) {
      Firestore.instance.collection('users').document(uid).get().then(
        (userData) async {
          if (userData == null ||
              !userData.exists ||
              userData.data == null ||
              userData.data.length <= 0) {
            Utils.showSnackBarError(
              null,
              "User not found",
            );
            return;
          }
          User user = User.fromMap(userData.data);
          user.userId = uid;
          Session.data.update(
            'user',
            (a) {
              return user;
            },
            ifAbsent: () {
              return user;
            },
          );
          if (!data.containsKey('driverId') || data['driverId'] == null) {
            return;
          }
          MyAppState.navigatorKey?.currentState
              ?.push(MaterialPageRoute(builder: (ctx) {
            return ReviewWidget(
              orderId: data['orderId'],
              isDriver: true,
              driverId: data['driverId'],
              fromNotification: true,
              userId: uid,
              user: user,
              itemId: null,
              comment: "",
            );
          }));
        },
      );
    }
  }

  static Future<dynamic> backgroundMessageHandler(
      Map<String, dynamic> message) async {
    MyAppState.showNotificationWithDefaultSound(message);
  }
}

class Session {
  static Map<String, dynamic> data = Map<String, dynamic>();
  static num version = 45;
  static String versionName = '2.2.5';
  static getCart() {
    if (data.containsKey('cart')) {
      return data['cart'];
    } else {
      data.putIfAbsent('cart', () {
        return UserCart(
          itemsData: StoreToReceiveItOrderItems(
            itemDetails: {},
          ),
        );
      });
      return data['cart'];
    }
  }
  // static get variables => _;
}
