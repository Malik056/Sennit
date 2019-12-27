import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:place_picker/place_picker.dart';
import 'package:sennit/driver/active_order.dart';
import 'package:sennit/driver/delivery_navigation.dart';
import 'package:sennit/driver/driver_startpage.dart';
import 'package:sennit/driver/home.dart';
import 'package:sennit/driver/signin.dart';
import 'package:sennit/my_widgets/notification.dart';
import 'package:sennit/my_widgets/search.dart';
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
  MyApp._location = Location();
  bool locationPermission = await MyApp._location.requestPermission();
  if (locationPermission) {
    // MyApp.locationData = await MyApp.location.getLocation();
    MyApp._locationData = MyApp._location.onLocationChanged();
    LocationData data = (await MyApp._locationData.last);
    MyApp._address = (await Geocoder.local.findAddressesFromCoordinates(
        Coordinates(data.latitude, data.longitude)))[0];
  }
}

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  locationInitializer();
  await databaseInitializer();
  runApp(MyApp());
}

databaseInitializer() async {
  await DatabaseHelper.iniitialize();
}

class MyApp extends StatelessWidget with WidgetsBindingObserver {
  static final String startPage = 'startPage';
  static final String searchPage = 'searchPage';
  // static final String startPage2 = '/startPage2';
  static final String userSignup = 'userSignup';
  static final String userSignin = 'userSignin';
  static final String driverSignup = 'driverSignup';
  static final String userStartPage = 'userStartPage';
  static final String driverStartPage = 'driverStartPage';
  static final String driverSignin = 'driverSignin';
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

  final Color secondaryColor = Color.fromARGB(255, 57, 59, 82);
  final Color primaryColor = Color.fromARGB(255, 87, 89, 152);
  static Stream<LocationData> _locationData;
  static Address _address;
  static Location _location;
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
    return MaterialApp(
      initialRoute: notificationWidget,
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
        selectFromAddress: (context) => SelectFromAddressRoute(MyApp._address),
        recieveItRoute: (context) => StoresRoute(
              address: _address,
            ),
        storeMainPage: (context) => StoreMainPage(),
        activeOrderBody: (context) => ActiveOrder(),
        searchPage: (context) => SearchWidget(),
        notificationWidget: (context) => UserNotificationWidget(),
      },
      title: 'Sennit',
      theme: ThemeData(
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

  static Stream<LatLng> getLocationStream() {
    Stream<LatLng> stream = Stream.empty();
    MyApp._locationData
        .transform<LatLng>(StreamTransformer<LocationData, LatLng>((a, b) {}));
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

  static Future<LatLng> getMyLocation() async {
    final data = await MyApp._location.getLocation();
    return LatLng(data.latitude, data.longitude);
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
        return "SMALL";
      case BoxSize.medium:
        return "MEDIUM";
      default:
        return "LARGE";
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
          r'^[a-zA-Z0-9]+(.([a-zA-Z0-9])+)*[a-zA-Z0-9]+@[a-zA-Z]+(.[a-zA-Z]+)+$',
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
  // static get variables => _;
}
