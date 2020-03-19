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
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_map_location_picker/generated/i18n.dart'
    as location_picker;
import 'package:location/location.dart';
import 'package:path/path.dart';
// import 'package:place_picker/place_picker.dart';
import 'package:sennit/driver/delivery_navigation.dart';
import 'package:sennit/driver/driver_startpage.dart';
import 'package:sennit/driver/home.dart';
import 'package:sennit/driver/signin.dart';
import 'package:sennit/my_widgets/notification.dart';
import 'package:sennit/my_widgets/review.dart';
import 'package:sennit/my_widgets/search.dart';
import 'package:sennit/my_widgets/verify_email_route.dart';
import 'package:sennit/partner_store/home.dart';
import 'package:sennit/start_page.dart';
import 'package:sennit/user/home.dart';
import 'package:sennit/user/receiveit.dart';
import 'package:sennit/user/sendit.dart';
import 'package:sennit/user/signin.dart';
import 'package:sennit/user/signup.dart';
import 'database/mydatabase.dart';
import 'driver/signup.dart';
import 'models/models.dart';
import 'user/user_startpage.dart';

Future<void> locationInitializer() async {
  Location _location = Location();
  PermissionStatus locationPermission = await _location.requestPermission();
  if (locationPermission == PermissionStatus.GRANTED) {
    // == PermissionStatus.GRANTED) {
    MyApp._lastKnowLocation = _location.getLocation().then((data) {
      return LatLng(data.latitude, data.longitude);
    });
    final data = await MyApp._lastKnowLocation;
    MyApp._initialLocation = data;
    MyApp._address = (await Geocoder.google(await Utils.getAPIKey())
        .findAddressesFromCoordinates(
            Coordinates(data.latitude, data.longitude)))[0];
  } else {
    SystemNavigator.pop();
  }
}

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

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await locationInitializer();
  await databaseInitializer();
  Utils.getFCMServerKey();
  Utils.getAPIKey();

  // await initializeDateFormatting('en_ZA');
  final user = await FirebaseAuth.instance.currentUser();
  if (user != null) {
    final result =
        await Firestore.instance.collection('users').document(user.uid).get();
    if (result != null &&
        result.data != null &&
        result.data.length > 0 &&
        result.exists) {
      Session.data.update('user', (a) {
        return User.fromMap(result.data);
      }, ifAbsent: () {
        return User.fromMap(result.data);
      });
      if (user.isEmailVerified) {
        MyApp.initialRoute = MyApp.userHome;
      } else {
        MyApp.initialRoute = MyApp.verifyEmailRoute;
      }
    } else {
      final driverResult = await Firestore.instance
          .collection('drivers')
          .document(user.uid)
          .get();
      if (driverResult != null &&
          driverResult.data != null &&
          driverResult.data.length > 0 &&
          driverResult.exists) {
        driverResult.data
            .update('driverId', (old) => user.uid, ifAbsent: () => user.uid);
        Session.data.update('driver', (a) {
          return Driver.fromMap(driverResult.data);
        }, ifAbsent: () {
          return Driver.fromMap(driverResult.data);
        });
        if (user.isEmailVerified) {
          MyApp.initialRoute = MyApp.driverHome;
        } else {
          MyApp.initialRoute = MyApp.verifyEmailRoute;
        }
      } else {
        final partnerStoreResult = await Firestore.instance
            .collection('partnerStores')
            .document(user.uid)
            .get();

        if (partnerStoreResult != null &&
            partnerStoreResult.data != null &&
            partnerStoreResult.data.length > 0 &&
            partnerStoreResult.exists) {
          Session.data.update('partnerStore', (a) {
            return partnerStoreResult.data;
          }, ifAbsent: () {
            return partnerStoreResult.data;
          });
          MyApp.initialRoute = MyApp.partnerStoreHome;
        }
      }
    }
  }
  runApp(MyApp());
}

databaseInitializer() async {
  await DatabaseHelper.iniitialize();
}

class MyApp extends StatefulWidget with WidgetsBindingObserver {
  static const String startPage = 'startPage';
  static String initialRoute = startPage;
  static const String searchPage = 'searchPage';
  static Future<void> futureCart;
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
  static const String receiveItRoute = 'receiveItRoute';
  static const String storeMainPage = 'storeMainPage';
  static const String partnerStoreHome = 'partnerStoreHome';
  static const String driverHome = 'driverHome';
  static const String driverNavigationRoute = 'driverNavigationRoute';
  static const String activeOrderBody = 'activeOrderBody';
  static const String reviewWidget = 'reviewWidget';
  static const String notificationWidget = 'notificationWidget';
  static const String sennitOrderRoute = 'sennitOrderRoute';

  final Color secondaryColor = Color.fromARGB(255, 57, 59, 82);
  final Color primaryColor = Color.fromARGB(255, 87, 89, 152);
  static Color disabledPrimaryColor =
      Color.fromARGB(255, 87 + 40, 89 + 40, 152 + 40);
  static Address _address;
  // static Location _location;
  static Future<LatLng> _lastKnowLocation;

  static LatLng _initialLocation;

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('logo');
    var initializationSettingsIOS = new IOSInitializationSettings();
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
        priority: Priority.High);
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
  @override
  Widget build(BuildContext context) {
    return BotToastInit(
      child: MaterialApp(
        navigatorKey: navigatorKey,
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
          // '/': (context) => StartPage(),
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
          MyApp.verifyEmailRoute: (context) => VerifyEmailRoute(
                context: context,
              ),
          MyApp.selectFromAddress: (context) =>
              SelectFromAddressRoute(MyApp._address),
          MyApp.receiveItRoute: (context) => StoresRoute(
                address: MyApp._address,
              ),
          MyApp.storeMainPage: (context) => StoreMainPage(),
          MyApp.partnerStoreHome: (context) => OrderedItemsList(),
          // activeOrderBody: (context) => ActiveOrder(),
          MyApp.searchPage: (context) => SearchWidget(),
          MyApp.notificationWidget: (context) => UserNotificationWidget(),
          // sennitOrderRoute: (context) => SennitOrderRoute({}),
        },
        title: 'Sennit',
        theme: ThemeData(
          backgroundColor: Colors.white,
          fontFamily: 'ArchivoNarrow',
          primaryColor: widget.secondaryColor,
          accentColor: widget.secondaryColor,
          // buttonColor: primaryColor,
          buttonTheme: ButtonThemeData(
            buttonColor: widget.secondaryColor,
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
              color: widget.secondaryColor,
            ),
            color: Colors.white,
            textTheme: TextTheme(
              title: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'ArchivoNarrow',
                fontSize: 22,
                color: widget.secondaryColor,
              ),
            ),
          ),
          iconTheme: IconThemeData(
            color: widget.secondaryColor,
          ),
          textTheme: TextTheme(
              title: TextStyle(
                color: widget.secondaryColor,
                fontSize: 22,
                fontWeight: FontWeight.normal,
              ),
              headline: TextStyle(
                color: widget.secondaryColor,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
              subhead: TextStyle(
                color: widget.secondaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              subtitle: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              body1: TextStyle(
                fontSize: 14,
                decorationColor: Colors.black,
                fontFamily: 'Roboto',
              ),
              body2: TextStyle(
                fontSize: 14,
                decorationColor: Colors.black,
                fontFamily: 'Roboto',
                fontStyle: FontStyle.italic,
              ),
              button: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              display1: TextStyle(
                fontSize: 26,
                color: widget.secondaryColor,
                fontWeight: FontWeight.bold,
              )),
        ),
      ),
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

  static showSnackBarError(BuildContext context, String message) {
    SnackBar snackBar = SnackBar(
      backgroundColor: Colors.red.shade500,
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: 4),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  static showSnackBarErrorUsingKey(
      GlobalKey<ScaffoldState> key, String message) {
    SnackBar snackBar = SnackBar(
      backgroundColor: Colors.red.shade500,
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: 4),
    );

    key.currentState.showSnackBar(snackBar);
  }

  static showSnackBarWarning(BuildContext context, String message) {
    SnackBar snackBar = SnackBar(
      backgroundColor: Colors.yellow.shade700,
      content: Text(
        message,
        style: TextStyle(color: Colors.black),
      ),
      duration: Duration(seconds: 4),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  static showSnackBarWarningUsingKey(
      GlobalKey<ScaffoldState> key, String message,
      {Duration duration}) {
    SnackBar snackBar = SnackBar(
      backgroundColor: Colors.yellow.shade700,
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      duration: duration ?? Duration(seconds: 4),
    );

    key.currentState.showSnackBar(snackBar);
  }

  static showSnackBarSuccess(BuildContext context, String message) {
    SnackBar snackBar = SnackBar(
      backgroundColor: Colors.green.shade700,
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: 2),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  static showSnackBarSuccessUsingKey(
      GlobalKey<ScaffoldState> key, String message) {
    SnackBar snackBar = SnackBar(
      backgroundColor: Colors.green.shade700,
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: 4),
    );

    key.currentState.showSnackBar(snackBar);
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
    // LocationPicker(apiKey);
    Map<String, LocationResult> map =
        Map<String, LocationResult>.from((await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LocationPicker(
                  apiKey,
                  automaticallyAnimateToCurrentLocation: false,
                  initialCenter: initialLocation ?? Utils.getLastKnowLocation(),
                  requiredGPS: true,
                  myLocationButtonEnabled: true,
                  layersButtonEnabled: false,
                ),
              ),
            )) ??
            {});
    if (map.isEmpty) {
      return null;
    }
    var keys = map.keys.toList();
    return map[keys[0]];
  }

  static Future<LatLng> getMyLocation(
      {LocationAccuracy accuracy = LocationAccuracy.BALANCED}) async {
    final _location = Location()..changeSettings(accuracy: accuracy);
    MyApp._lastKnowLocation = _location.getLocation().then((data) {
      return LatLng(data.latitude, data.longitude);
    });

    return MyApp._lastKnowLocation
      ..then((a) {
        MyApp._initialLocation = a;
      });
  }

  static LatLng getLastKnowLocation() {
    return MyApp._initialLocation;
  }

  static Address getLastKnowAddress() {
    return MyApp._address;
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

  static void showLoadingDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          );
        });
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
    Utils.showLoadingDialog(context);
    // Navigator.of(context).popUntil((route) => route.isFirst);
    FirebaseMessaging fcm = FirebaseMessaging();
    User user = Session.data['user'];
    Future unRegisteringTokens = Firestore.instance
        .collection('users')
        .document(user.userId)
        .collection('tokens')
        .document(await fcm.getToken())
        .delete()
        .timeout(Duration(seconds: 12), onTimeout: () {
      Navigator.pop(context);
    });
    await unRegisteringTokens;
    await FirebaseAuth.instance.signOut();
    Session.data..removeWhere((key, value) => true);
    Navigator.of(context)
        .pushNamedAndRemoveUntil(MyApp.startPage, (route) => false);
  }
}

class Session {
  static Map<String, dynamic> data = Map<String, dynamic>();
  static getCart() {
    if (data.containsKey('cart')) {
      return data['cart'];
    } else {
      data.putIfAbsent('cart', () {
        return UserCart(itemsData: {});
      });
      return data['cart'];
    }
  }
  // static get variables => _;
}
