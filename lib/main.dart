import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:place_picker/place_picker.dart';
import 'package:sennit/driver/delivery_navigation.dart';
import 'package:sennit/driver/driver_startpage.dart';
import 'package:sennit/driver/home.dart';
import 'package:sennit/driver/signin.dart';
import 'package:sennit/my_widgets/notification.dart';
import 'package:sennit/my_widgets/search.dart';
import 'package:sennit/my_widgets/verify_email_route.dart';
import 'package:sennit/start_page.dart';
import 'package:sennit/user/home.dart';
import 'package:sennit/user/recieveIt.dart';
import 'package:sennit/user/sendit.dart';
import 'package:sennit/user/signin.dart';
import 'package:sennit/user/signup.dart';
import 'database/mydatabase.dart';
import 'driver/signup.dart';
import 'models/models.dart';
import 'user/user_startpage.dart';

Future<void> locationInitializer() async {
  Location _location = Location();
  bool locationPermission = await _location.requestPermission();
  if (locationPermission) {
    MyApp._lastKnowLocation = _location.getLocation().then((data) {
      return LatLng(data.latitude, data.longitude);
    });
    final data = await MyApp._lastKnowLocation;
    MyApp._initialLocation = data;
    MyApp._address = (await Geocoder.local.findAddressesFromCoordinates(
        Coordinates(data.latitude, data.longitude)))[0];
  } else {
    SystemNavigator.pop();
  }
}

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  locationInitializer();
  await databaseInitializer();
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
        Session.data.update('driver', (a) {
          return Driver.fromMap(result.data);
        }, ifAbsent: () {
          return Driver.fromMap(result.data);
        });
        if (user.isEmailVerified) {
          MyApp.initialRoute = MyApp.driverHome;
        } else {
          MyApp.initialRoute = MyApp.verifyEmailRoute;
        }
      }
    }
  }
  runApp(MyApp());
}

databaseInitializer() async {
  await DatabaseHelper.iniitialize();
}

class MyApp extends StatelessWidget with WidgetsBindingObserver {
  static final String startPage = 'startPage';
  static String initialRoute = startPage;
  static final String searchPage = 'searchPage';
  static Future<void> futureCart;
  // static final String startPage2 = '/startPage2';
  static final String userSignup = '$userStartPage/userSignup';
  static final String userSignin = '$userStartPage/userSignin';
  static final String driverSignup = '$driverStartPage/driverSignup';
  static final String userStartPage = '$startPage/userStartPage';
  static final String driverStartPage = '$startPage/driverStartPage';
  static final String driverSignin = '$driverStartPage/driverSignin';
  static final String verifyEmailRoute = 'verifyEmailRoute';
  static final String userHome = 'userHome';
  static final String selectFromAddress = 'sendItSourceRoute';
  static final String deliverToAddresses = 'sendItDestinationRoute';
  static final String addAddressFrom = 'addAddressFrom';
  static final String addAddressToForSennit = 'addAddressToSennit';
  static final String addAddressToRecieveIt = 'addAddressToRecieveIt';
  static final String senditCartPage = 'sendItCartPage';
  static final String recieveItRoute = 'recieveItRoute';
  static final String storeMainPage = 'storeMainPage';
  static final String driverHome = 'driverHome';
  static final String driverNavigationRoute = 'driverNavigationRoute';
  static final String activeOrderBody = 'activeOrderBody';
  static final String reviewWidget = 'reviewWidget';
  static final String notificationWidget = 'notificationWidget';
  static final String sennitOrderRoute = 'sennitOrderRoute';

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      DatabaseHelper.getDatabase().close();
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BotToastInit(
      child: MaterialApp(
        navigatorObservers: [BotToastNavigatorObserver()],
        initialRoute: initialRoute,
        routes: {
          // '/': (context) => StartPage(),
          driverNavigationRoute: (context) => DeliveryTrackingRoute(
                OpenAs.NAVIGATION,
                fromCoordinate: LatLng(31, 74),
                toCoordinate: LatLng(40, 80),
                myLocation: LatLng(42, 85),
              ),
          startPage: (context) => StartPage(),
          driverHome: (context) => HomeScreenDriver(),
          userSignup: (context) => UserSignUpRoute(),
          userSignin: (context) => UserSignInRoute(),
          userStartPage: (context) => UserStartPage(),
          driverSignup: (context) => DriverSignUpRoute(),
          driverSignin: (context) => DriverSignInRoute(),
          driverStartPage: (context) => DriverStartPage(),
          userHome: (context) => UserHomeRoute(),
          verifyEmailRoute: (context) => VerifyEmailRoute(
                context: context,
              ),
          selectFromAddress: (context) =>
              SelectFromAddressRoute(MyApp._address),
          recieveItRoute: (context) => StoresRoute(
                address: _address,
              ),
          storeMainPage: (context) => StoreMainPage(),
          // activeOrderBody: (context) => ActiveOrder(),
          searchPage: (context) => SearchWidget(),
          notificationWidget: (context) => UserNotificationWidget(),
          // sennitOrderRoute: (context) => SennitOrderRoute({}),
        },
        title: 'Sennit',
        theme: ThemeData(
          backgroundColor: Colors.white,
          fontFamily: 'ArchivoNarrow',
          primaryColor: secondaryColor,
          accentColor: secondaryColor,
          // buttonColor: primaryColor,
          buttonTheme: ButtonThemeData(
            buttonColor: secondaryColor,
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
              color: secondaryColor,
            ),
            color: Colors.white,
            textTheme: TextTheme(
              title: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'ArchivoNarrow',
                fontSize: 22,
                color: secondaryColor,
              ),
            ),
          ),
          iconTheme: IconThemeData(
            color: secondaryColor,
          ),
          textTheme: TextTheme(
              title: TextStyle(
                color: secondaryColor,
                fontSize: 22,
                fontWeight: FontWeight.normal,
              ),
              headline: TextStyle(
                color: secondaryColor,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
              subhead: TextStyle(
                color: secondaryColor,
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
                color: secondaryColor,
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
  static Future<String> getAPIkey({@required BuildContext context}) async {
    if (_apiKey != null) {
      return _apiKey;
    }
    showDialog(
        context: context,
        builder: (context) {
          return CircularProgressIndicator();
        });
    var key = json.decode(await rootBundle.loadString('assets/secret.json'));
    _apiKey = key['Maps'];

    Navigator.pop(context);
    return _apiKey;
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

  static showWidgetInDialoge(context, Widget widget) {
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
      GlobalKey<ScaffoldState> key, String message) {
    SnackBar snackBar = SnackBar(
      backgroundColor: Colors.yellow.shade700,
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: 4),
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
    return 12742 * asin(sqrt(a));
  }

  static showPlacePicker(BuildContext context) async {
    String apiKey = await getAPIkey(context: context);
    LocationResult result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlacePicker(apiKey),
      ),
    );
    return result;
  }

  static Future<LatLng> getMyLocation(
      {LocationAccuracy accuracy = LocationAccuracy.BALANCED}) async {
    final _location = Location()..changeSettings(accuracy: accuracy);
    MyApp._lastKnowLocation = _location.getLocation().then((data) {
      return LatLng(data.latitude, data.longitude);
    });
    return MyApp._lastKnowLocation;
  }

  static LatLng getLastKnowLocation() {
    return MyApp._initialLocation;
  }

  static Address getLastKnowAddress() {
    return MyApp._address;
  }

  static LatLng latLngFromString(String latlng) {
    List<String> splittedValues = latlng.split(',');
    double lattitude = double.parse(splittedValues[0]);
    double longitude = double.parse(splittedValues[1]);
    return LatLng(lattitude, longitude);
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
      RegExp re = RegExp(
          r'^[a-zA-Z0-9]+(._([a-zA-Z0-9])+)*[a-zA-Z0-9]+@[a-zA-Z]+(.[a-zA-Z]+)+$',
          caseSensitive: false,
          multiLine: false);
      if (!re.hasMatch(email)) {
        return false;
      }
    }
    return true;
  }
}

class Session {
  static Map data = Map<String, dynamic>();
  static getCart() {
    if (data.containsKey('cart')) {
      return data['cart'];
    } else {
      data.putIfAbsent('cart', () {
        return UserCart(itemIds: [], quantities: []);
      });
      return data['cart'];
    }
  }
  // static get variables => _;
}
