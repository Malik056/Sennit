import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:place_picker/place_picker.dart';
import 'package:sennit/driver/driver_startpage.dart';
import 'package:sennit/driver/signin.dart';
import 'package:sennit/start_page.dart';
import 'package:sennit/user/home.dart';
import 'package:sennit/user/sendit.dart';
import 'package:sennit/user/signin.dart';
import 'package:sennit/user/signup.dart';
import 'driver/signup.dart';
import 'user/user_startpage.dart';

Future<void> locationInitializer() async {
  MyApp.location = Location();
  bool locationPermission = await MyApp.location.requestPermission();
  if(locationPermission)
    // MyApp.locationData = await MyApp.location.getLocation();
    MyApp.locationData = MyApp.location.onLocationChanged();
    LocationData data = (await MyApp.locationData.last);
    MyApp.address = (await Geocoder.local.findAddressesFromCoordinates(Coordinates(data.latitude, data.longitude)))[0];
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await locationInitializer();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final String startPage = '/startPage';
  // static final String startPage2 = '/startPage2';
  static final String userSignup = '/userSignup';
  static final String userSignin = '/userSignin';
  static final String driverSignup = '/driverSignup';
  static final String userStartPage = '/userStartPage';
  static final String driverStartPage = '/driverStartPage';
  static final String driverSignin = '/driverSignin';
  static final String userHome = '/userHome';
  static final String selectFromAddress = '/sendItSourceRoute';
  static final String deliverToAddresses = '/sendItDestinationRoute';
  static final String addAddressFrom = '/addAddressFrom';
  static final String addAddressToForSennit = '/addAddressToSennit';
  static final String addAddressToRecieveIt = '/addAddressToRecieveIt';
  static final String senditCartPage = '/sendItCartPage';

  final Color secondaryColor = Color.fromARGB(255, 57, 59, 82);
  final Color primaryColor = Color.fromARGB(255, 87, 89, 152);
  static Stream<LocationData> locationData;
  static Address address;
  static Location location;
  MyApp() {
    // WidgetsFlutterBinding.ensureInitialized();
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: startPage,

      routes: {
        startPage: (context) => StartPage(),
        // startPage2: (context) => StartPage2(),
        userSignup: (context) => UserSignUpRoute(),
        userSignin: (context) => UserSignInRoute(),
        userStartPage: (context) => UserStartPage(),
        driverSignup: (context) => DriverSignUpRoute(),
        driverSignin: (context) => DriverSignInRoute(),
        driverStartPage: (context) => DriverStartPage(),
        userHome: (context) => UserHomeRoute(),
        selectFromAddress: (context) => SelectFromAddressRoute(MyApp.address),
        // addAddressFrom: (context) => AddressAddingRoute(SourcePage.addressSelectionFrom, MyApp.addAddressFrom),
        // addAddressToForSennit: (context) => AddressAddingRoute(SourcePage.addressSelectionDestination),
        // addAddressToRecieveIt: (context) => AddressAddingRoute(SourcePage.recieveIt),
        
        // senditCartPage: (context) => SendItCartRoute(),
        // deliverToAddresses: (context) => DeliverToAddressRoute(),
      },
      title: 'Think Couriers',
      theme: ThemeData(
        primaryColor: secondaryColor,
        accentColor: secondaryColor,
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(
            color: secondaryColor,
          ),
          color: Colors.white,
          textTheme: TextTheme(
            title: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: secondaryColor,
            ),
          ),
        ),
        textTheme: TextTheme(
          title: TextStyle(
              color: secondaryColor,
              fontSize: 22,
              fontWeight: FontWeight.normal),
          headline: TextStyle(
            color: secondaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          subhead: TextStyle(),
          body1: TextStyle(
            fontSize: 16,
            decorationColor: secondaryColor,
          ),
          button: TextStyle(
            fontSize: 16,
          ),
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
  static getAPIkey() async {
    if(_apiKey == null) {
    var key = json.decode(await rootBundle.loadString('assets/secret.json'));
    _apiKey = key['Maps'];
    }
    return _apiKey;
  }

  static showPlacePicker(BuildContext context) async {
    LocationResult result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            PlacePicker(getAPIkey()),
      ),
    );
    return result;
  }
}