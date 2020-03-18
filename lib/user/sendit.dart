import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:random_string/random_string.dart';
import 'package:rave_flutter/rave_flutter.dart';
import 'package:sennit/main.dart';
import 'package:sennit/models/models.dart';
import 'package:sennit/user/generic_tracking_screen.dart';

enum SourcePage { addressSelectionFrom, addressSelectionDestination, receiveIt }

class SelectFromAddressRoute extends StatelessWidget {
  final Address lastUsedAddress;
  SelectFromAddressRoute(this.lastUsedAddress);

  @override
  Widget build(BuildContext context) {
    return AddressAddingRoute(SourcePage.addressSelectionFrom, lastUsedAddress);
  }
}

class DeliverToAddressRoute extends StatelessWidget {
  final Address address;
  const DeliverToAddressRoute({Key key, this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AddressAddingRoute(SourcePage.addressSelectionDestination, address);
  }
}

class AddressAddingRoute extends StatelessWidget {
  final SourcePage sourcePage;
  AddressAddingRoute(this.sourcePage, address) {
    _fromAddress = address;
  }
  static Address _toAddress;
  static Address _fromAddress;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              sourcePage == SourcePage.receiveIt
                  ? Navigator.of(context).pop(_fromAddress)
                  : sourcePage == SourcePage.addressSelectionDestination
                      ? _toAddress != null
                          ? Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                              return SendItCartRoute(_fromAddress, _toAddress);
                            }))
                          : Utils.showSnackBarError(
                              context, 'Please Select an Address')
                      : _fromAddress != null
                          ? Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                              return DeliverToAddressRoute(
                                address: _fromAddress,
                              );
                            }))
                          : Utils.showSnackBarError(
                              context,
                              'Please Select an Address',
                            );
            },
            child: Text(
              sourcePage == SourcePage.addressSelectionDestination
                  ? 'Goto Cart'
                  : sourcePage == SourcePage.addressSelectionFrom
                      ? 'Next'
                      : 'Done',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
        title: Text(
          sourcePage == SourcePage.addressSelectionFrom
              ? 'Pick From'
              : 'Deliver to',
        ),
        centerTitle: true,
      ),
      body: SafeArea(child: AddressAddingBody(sourcePage, _fromAddress)),
      // backgroundColor: Colors.white,
    );
  }
}

class AddressAddingBody extends StatefulWidget {
  // final _formKey = GlobalKey<FormState>();
  AddressAddingBody(this.sourcePage, this._fromAddress);
  final SourcePage sourcePage;
  final Address _fromAddress;

  @override
  State<StatefulWidget> createState() {
    return AddressAddingState();
  }
}

class AddressAddingState extends State<AddressAddingBody> {
  Color defaultColor = Color.fromARGB(0xff, 0x5d, 0x5d, 0x5d);
  Color defaultHighlightedColor = Color.fromARGB(0xff, 0x5d, 0x5d, 0x5d);
  Color defaultBtnBackgroundColor = Colors.white;
  double btnPaddingTop;
  double btnPaddingBottom;
  double btnPaddingLeft;
  double btnPaddingRight;
  double cardPadding;
  String dateInitialText;
  bool dateSelected = false;
  bool customAddress = true;

  Color defaultHighlightedColorDOB = Color.fromARGB(255, 57, 59, 82);
  String dateText;

  bool tapped = false;
  AddressAddingState();
  @override
  void initState() {
    btnPaddingTop = 10;
    btnPaddingBottom = 10;
    btnPaddingLeft = 20;
    btnPaddingRight = 25;
    cardPadding = 10;
    // dateInitialText = 'Tap to select';
    // dateText = dateInitialText;
    super.initState();
    // defaultHighlightedColorDOB = Theme.of(context).accentColor;
  }

  @override
  Widget build(BuildContext context) {
    User user = Session.data['user'];
    List<UserLocationHistory> locationHistory =
        Session.data['userLocationHistory'];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(0),
            elevation: 5,
            child: Container(
              padding: EdgeInsets.all(cardPadding),
              child: Column(
                children: <Widget>[
                  // ListTile(
                  //   leading: Icon(
                  //     Icons.location_on,
                  //     color: Theme.of(context).accentColor,
                  //   ),
                  //   title: Text('Pick A location'),
                  //   onTap: () async {
                  //     LocationResult result =
                  //         await Utils.showPlacePicker(context);
                  //     if (result != null) {
                  //       Coordinates coordinates = Coordinates(
                  //           result.latLng.latitude, result.latLng.longitude);
                  //       if (widget.sourcePage ==
                  //           SourcePage.addressSelectionDestination) {
                  //         AddressAddingRoute._toAddress = (await Geocoder.local
                  //             .findAddressesFromCoordinates(coordinates))[0];
                  //       } else {
                  //         AddressAddingRoute._fromAddress = (await Geocoder
                  //             .local
                  //             .findAddressesFromCoordinates(coordinates))[0];
                  //       }
                  //       setState(() {});
                  //     }
                  //   },
                  // ),
                  ListTile(
                      leading: Icon(
                        Icons.my_location,
                        color: Theme.of(context).accentColor,
                      ),
                      title: Text('Selected Location',
                          style:
                              TextStyle(color: Theme.of(context).accentColor)),
                      subtitle: Text(
                        widget.sourcePage ==
                                SourcePage.addressSelectionDestination
                            ? (AddressAddingRoute._toAddress != null
                                ? AddressAddingRoute._toAddress.addressLine
                                : 'Please select a Destination')
                            : AddressAddingRoute._fromAddress != null
                                ? AddressAddingRoute._fromAddress.addressLine
                                : 'Select an Address',
                      ),
                      onTap: () async {
                        Coordinates coordinates;
                        widget.sourcePage ==
                                SourcePage.addressSelectionDestination
                            ? coordinates =
                                AddressAddingRoute._toAddress?.coordinates
                            : coordinates =
                                AddressAddingRoute._fromAddress.coordinates;

                        LatLng latlng = coordinates == null
                            ? null
                            : LatLng(
                                coordinates.latitude,
                                coordinates.longitude,
                              );
                        LocationResult result = await Utils.showPlacePicker(
                          context,
                          initialLocation: latlng,
                        );
                        if (result != null) {
                          Coordinates coordinates = Coordinates(
                              result.latLng.latitude, result.latLng.longitude);
                          if (widget.sourcePage ==
                              SourcePage.addressSelectionDestination) {
                            AddressAddingRoute._toAddress = (await Geocoder
                                .local
                                .findAddressesFromCoordinates(coordinates))[0];
                          } else {
                            AddressAddingRoute._fromAddress = (await Geocoder
                                .local
                                .findAddressesFromCoordinates(coordinates))[0];
                          }
                          setState(() {});
                        }
                      }),
                ],
              ),
            ),
          ),
          Opacity(
            opacity: 0.0,
            child: Container(
              height: 30,
            ),
          ),
          Card(
            margin: EdgeInsets.all(0),
            elevation: 5,
            child: Container(
              padding: EdgeInsets.all(cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '  Saved Addresses',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.all(6),
                    leading: Icon(Icons.home),
                    title: Text('Home'),
                    subtitle: Text('${user.homeLocationAddress}'),
                    onTap: () async {
                      Address selectedAddress =
                          (await Geocoder.google(await Utils.getAPIKey())
                              .findAddressesFromCoordinates(
                        Coordinates(user.homeLocationLatLng.latitude,
                            user.homeLocationLatLng.longitude),
                      ))[0];
                      widget.sourcePage == SourcePage.receiveIt
                          ? Navigator.of(context).pop()
                          : widget.sourcePage ==
                                  SourcePage.addressSelectionDestination
                              ? Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return SendItCartRoute(
                                          widget._fromAddress, selectedAddress);
                                    },
                                  ),
                                )
                              : Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                  return DeliverToAddressRoute(
                                    address: selectedAddress,
                                  );
                                }));
                    },
                  ),
                  user.officeLocationAddress != null
                      ? ListTile(
                          contentPadding: EdgeInsets.all(6),
                          leading: Icon(Icons.history),
                          title: Text('Office'),
                          subtitle: Text(user.officeLocationAddress),
                          onTap: () async {
                            Address selectedAddress =
                                (await Geocoder.google(await Utils.getAPIKey())
                                    .findAddressesFromCoordinates(
                              Coordinates(user.officeLocationLatLng.latitude,
                                  user.officeLocationLatLng.longitude),
                            ))[0];
                            widget.sourcePage == SourcePage.receiveIt
                                ? Navigator.of(context).pop()
                                : widget.sourcePage ==
                                        SourcePage.addressSelectionDestination
                                    ? Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return SendItCartRoute(
                                                widget._fromAddress,
                                                selectedAddress);
                                          },
                                        ),
                                      )
                                    : Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                        return DeliverToAddressRoute(
                                          address: selectedAddress,
                                        );
                                      }));
                          },
                        )
                      : Opacity(
                          opacity: 0,
                        ),
                ],
              ),
            ),
          ),
          Opacity(
            opacity: 0.0,
            child: Container(
              height: 30,
            ),
          ),
          locationHistory != null && locationHistory.length > 0
              ? Card(
                  elevation: 5,
                  margin: EdgeInsets.only(bottom: 20),
                  child: Container(
                    padding: EdgeInsets.all(cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '  History',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                        Column(
                          children:
                              List.generate(locationHistory.length, (index) {
                            return ListTile(
                              leading: Icon(Icons.history),
                              subtitle: Text(locationHistory[index].address),
                              onTap: () async {
                                Address selectedAddress =
                                    (await Geocoder.google(
                                            await Utils.getAPIKey())
                                        .findAddressesFromCoordinates(
                                  Coordinates(
                                      locationHistory[index].latLng.latitude,
                                      locationHistory[index].latLng.longitude),
                                ))[0];
                                widget.sourcePage == SourcePage.receiveIt
                                    ? Navigator.of(context).pop()
                                    : widget.sourcePage ==
                                            SourcePage
                                                .addressSelectionDestination
                                        ? Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return SendItCartRoute(
                                                    widget._fromAddress,
                                                    selectedAddress);
                                              },
                                            ),
                                          )
                                        : Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) {
                                            return DeliverToAddressRoute(
                                              address: selectedAddress,
                                            );
                                          }));
                              },
                            );
                          }),
                        )
                      ],
                    ),
                  ),
                )
              : Opacity(
                  opacity: 0,
                ),
        ],
      ),
      //   ),
      // ),
    );
  }
}

class SendItCartRoute extends StatelessWidget {
  static Address _fromAddress;
  static Address _toAddress;
  final _key = GlobalKey<ScaffoldState>();

  SendItCartRoute(fromAddress, toAddress) {
    _fromAddress = fromAddress;
    _toAddress = toAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              if (double.parse(
                          SendItCartRouteState.numberOfBoxesController.text) ==
                      0 &&
                  double.parse(SendItCartRouteState
                          .numberOfSleevesNeededController.text) <=
                      0) {
                Utils.showSnackBarErrorUsingKey(
                  _key,
                  'Please Select at least 1 Sleeve or Box',
                );
                return;
              } else if (SendItCartRouteState
                          .receiverPhoneNumberController.text.length !=
                      10 &&
                  !SendItCartRouteState.receiverPhoneNumberController.text
                      .startsWith('0')) {
                Utils.showSnackBarErrorUsingKey(
                  _key,
                  'Please Enter Valid Receiver Phone Number',
                );
                return;
              } else if (SendItCartRouteState
                          .senderPhoneNumberController.text.length !=
                      10 &&
                  !SendItCartRouteState.senderPhoneNumberController.text
                      .startsWith('0')) {
                Utils.showSnackBarErrorUsingKey(
                  _key,
                  'Please Enter Valid Sender Phone Number',
                );
                return;
              } else if (!Utils.isEmailCorrect(
                  SendItCartRouteState.senderEmailController.text.trim())) {
                Utils.showSnackBarErrorUsingKey(
                  _key,
                  'Please Enter Valid Sender Email Address',
                );
                return;
              } else if (!Utils.isEmailCorrect(
                  SendItCartRouteState.receiverEmailController.text.trim())) {
                Utils.showSnackBarErrorUsingKey(
                  _key,
                  'Please Enter Valid Receiver Email Address',
                );
                return;
              }
              SendItCartRouteState.senderEmailController.text =
                  SendItCartRouteState.senderEmailController.text.trim();
              SendItCartRouteState.receiverEmailController.text =
                  SendItCartRouteState.receiverEmailController.text.trim();

              // Map<String, dynamic> result = await performTransaction(
              //   context,
              //   SendItCartRouteState.totalCharges,
              // );
              Map<String, dynamic> result = {
                'status': RaveStatus.success,
                'errorMessage': "All Good",
              };

              if (result['status'] == RaveStatus.cancelled) {
                Utils.showSnackBarWarningUsingKey(_key, 'Payment Cancelled');
                return;
              } else if (result['status'] == RaveStatus.error) {
                Utils.showSnackBarErrorUsingKey(_key, result['errorMessage']);
                return;
              } else {
                Utils.showSnackBarSuccessUsingKey(_key, 'Payment Succesfull');
              }

              Utils.showLoadingDialog(context);
              OrderFromSennit sennitOrder = OrderFromSennit();
              sennitOrder.senderHouse =
                  SendItCartRouteState.senderHouseController.text;
              sennitOrder.receiverHouse =
                  SendItCartRouteState.receiverHouseController.text;
              sennitOrder.boxSize = SendItCartRouteState.selectedBoxSize;
              sennitOrder.date = DateTime.now();
              sennitOrder.userId = (Session.data['user'] as User).userId;
              sennitOrder.status = 'Pending';
              sennitOrder.dropOffLatLng = LatLng(
                  SendItCartRoute._toAddress.coordinates.latitude,
                  SendItCartRoute._toAddress.coordinates.longitude);
              sennitOrder.dropOffAddress =
                  SendItCartRoute._toAddress.addressLine;
              sennitOrder.pickUpLatLng = LatLng(
                  SendItCartRoute._fromAddress.coordinates.latitude,
                  SendItCartRoute._fromAddress.coordinates.longitude);
              sennitOrder.pickUpAddress =
                  SendItCartRoute._fromAddress.addressLine;
              sennitOrder.dropToDoor = SendItCartRouteState.deliverToDoor;
              sennitOrder.pickupFromDoor = SendItCartRouteState.pickFromDoor;
              sennitOrder.numberOfBoxes =
                  int.parse(SendItCartRouteState.numberOfBoxesController.text);
              sennitOrder.price = SendItCartRouteState.totalCharges;
              sennitOrder.numberOfSleevesNeeded = int.parse(
                SendItCartRouteState.numberOfSleevesNeededController.text,
              );
              sennitOrder.serviceCharges = 0;
              sennitOrder.receiverEmail =
                  SendItCartRouteState.receiverEmailController.text.trim();
              sennitOrder.receiverPhone = SendItCartRouteState
                  .receiverPhoneNumberController.text
                  .trim();
              sennitOrder.senderEmail =
                  SendItCartRouteState.senderEmailController.text.trim();
              sennitOrder.senderPhone =
                  SendItCartRouteState.senderPhoneNumberController.text.trim();

              String otp = randomAlphaNumeric(6).toUpperCase();
              var url =
                  "https://www.budgetmessaging.com/sendsms.ashx?user=sennit2020&password=29200613&cell=${sennitOrder.senderPhone}&msg=Hello Your Sennit OTP is \n$otp\n";
              var response = await post(
                url,
              );
              var url2 =
                  "https://www.budgetmessaging.com/sendsms.ashx?user=sennit2020&password=29200613&cell=${sennitOrder.receiverPhone}&msg=Hello Your Sennit OTP is \n$otp\n";
              var response2 = await post(
                url2,
              );
              if ((response.statusCode == 200 ||
                      response.statusCode == 201 ||
                      response.statusCode == 202) &&
                  (response2.statusCode == 200 ||
                      response2.statusCode == 201 ||
                      response2.statusCode == 202)) {
                // if (true) {
                Map<String, dynamic> orderData = sennitOrder.toMap()
                  ..putIfAbsent('otp', () => otp);

                await Firestore.instance
                    .collection("postedOrders")
                    .add(orderData)
                    .then((_) async {
                  final orderId = _.documentID;
                  // sennitOrder.orderId = orderId;
                  orderData.update(
                    'orderId',
                    (old) => _.documentID,
                    ifAbsent: () => _.documentID,
                  );

                  await Firestore.instance
                      .collection("users")
                      .document(Session.data['user'].userId)
                      .collection('orders')
                      .document(_.documentID)
                      .setData(
                        orderData,
                        merge: true,
                      );

                  //   await Firestore.instance
                  //       .collection("verificationCodes")
                  //       .document(orderId)
                  //       .setData(
                  //     {
                  //       "key": otp,
                  //     },
                  //   );
                });

                BotToast.showEnhancedWidget(toastBuilder: (a) {
                  return Center(
                    child: Container(
                      width: 300,
                      height: 230,
                      padding: EdgeInsets.only(
                          top: 10, left: 20, right: 20, bottom: 10),
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
                              size: 32,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Your Order is on its way!'),
                            Spacer(),
                          ],
                        ),
                      ),
                    ),
                  );
                });
                Future.delayed(Duration(seconds: 2)).then((value) {
                  BotToast.cleanAll();
                });
                Navigator.popUntil(
                    context, ModalRoute.withName(MyApp.userHome));
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return OrderTracking(
                        type: OrderTrackingType.SENNIT,
                        data: orderData,
                      );
                    },
                    settings: RouteSettings(name: OrderTracking.NAME),
                  ),
                );
              } else {
                Utils.showSnackBarErrorUsingKey(
                    _key, 'Unable to send OTP please Try Again!');
                // print('Response status: ${response.statusCode}');
                // print('Response body: ${response.body}');
                // print('Response reason: ${response.reasonPhrase}');
                Navigator.pop(context);
              }
            },
            child: Text(
              'Done',
              style: TextStyle(
                color: Colors.blue,
                // fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        title: Text(
          'Cart',
        ),
        centerTitle: true,
        // backgroundColor: Theme.of(context).accentColor,
      ),
      body: SendItCartRouteBody(),
      // backgroundColor: Theme.of(context).accentColor,
    );
  }

  performTransaction(context, amount) async {
    User user = Session.data['user'];
    DateTime time = DateTime.now();
    var initializer = RavePayInitializer(
        amount: amount,
        publicKey: 'FLWPUBK-dd01d6fa251fe0ce8bb95b03b0406569-X',
        encryptionKey: 'eded539f04b38a2af712eb7d')
      ..country = "ZA"
      ..currency = "ZAR"
      ..displayEmail = false
      ..displayAmount = false
      ..email = "${user.email}"
      ..fName = "${user.firstName}"
      ..lName = "${user.lastName}"
      ..subAccounts = []
      ..narration = ''
      ..txRef = user.userId + time.millisecondsSinceEpoch.toString()
      ..companyLogo = Image.asset(
        'assets/images/logo.png',
      )
      ..acceptMpesaPayments = false
      ..acceptAccountPayments = false
      ..acceptCardPayments = true
      ..acceptAchPayments = false
      ..acceptGHMobileMoneyPayments = false
      ..acceptUgMobileMoneyPayments = false
      ..staging = false
      ..isPreAuth = true
      ..displayFee = true;

    // Initialize and get the transaction result
    RaveResult response = await RavePayManager()
        .prompt(context: context, initializer: initializer);
    print(response.message);

    return <String, dynamic>{
      'status': response.status,
      'errorMessage': response.message,
    };
  }
}

class SendItCartRouteBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SendItCartRouteState();
  }
}

class SendItCartRouteState extends State<SendItCartRouteBody> {
  static bool pickFromDoor = true;
  static bool deliverToDoor = true;
  double cardMargin = 10;
  double cardPadding = 20;
  double groupMargin = 30;
  double itemMargin = 10;
  static double totalCharges = 0;
  // static int sleeveNeeded = 0;

  static BoxSize selectedBoxSize = BoxSize.small;

  static final senderEmailController = TextEditingController();
  static final senderPhoneNumberController = TextEditingController();
  static final receiverEmailController = TextEditingController();
  static final receiverPhoneNumberController = TextEditingController();
  static final numberOfBoxesController = TextEditingController();
  final FocusNode numberOfBoxesFocusNode = FocusNode();
  static final numberOfSleevesNeededController = TextEditingController();
  final FocusNode numberOfSleevesFocusNode = FocusNode();
  static final receiverHouseController = TextEditingController();
  static final senderHouseController = TextEditingController();

  SendItCartRouteState();
  @override
  void initState() {
    User user = Session.data['user'];
    numberOfSleevesNeededController.text = '0';
    numberOfBoxesController.text = '0';
    numberOfBoxesFocusNode.addListener(() {
      // if(numberOfBoxesFocusNode.hasFocus) {
      if (numberOfBoxesController.text == "") {
        numberOfBoxesController.text = '0';
        if (mounted) {
          setState(() {});
        }
      }
      // }
    });
    numberOfSleevesFocusNode.addListener(() {
      // if(numberOfBoxesFocusNode.hasFocus) {
      if (numberOfSleevesNeededController.text == "") {
        numberOfSleevesNeededController.text = '0';
        if (mounted) {
          setState(() {});
        }
      }
      // }
    });
    senderEmailController.text = user.email;
    senderPhoneNumberController.text = user.phoneNumber;
    // senderPhoneNumberController.addListener(() {
    //   if (!mounted) return;
    //   if (senderPhoneNumberController.text == null ||
    //       senderPhoneNumberController.text == "") {
    //     // senderPhoneNumberController.text = '27';
    //     setState(() {});
    //   }
    // });
    // receiverPhoneNumberController.addListener(() {
    //   if (!mounted) return;
    //   if (receiverPhoneNumberController.text == null ||
    //       receiverPhoneNumberController.text == "") {
    //     receiverPhoneNumberController.text = '27';
    //     setState(() {});
    //   }
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.only(),
            elevation: 5,
            child: Container(
              padding: EdgeInsets.only(top: cardPadding),
              child: Column(
                children: <Widget>[
                  Text(
                    'Pick From',
                    style: Theme.of(context).textTheme.headline,
                  ),
                  Opacity(
                    opacity: 0,
                    child: Container(
                      height: itemMargin,
                    ),
                  ),
                  ListTile(
                    onTap: () async {
                      Coordinates coordinates =
                          AddressAddingRoute._fromAddress?.coordinates;
                      LatLng latlng = coordinates == null
                          ? null
                          : LatLng(
                              coordinates.latitude,
                              coordinates.longitude,
                            );
                      LocationResult result = await Utils.showPlacePicker(
                          context,
                          initialLocation: latlng);
                      if (result != null) {
                        Coordinates coordinates = Coordinates(
                            result.latLng.latitude, result.latLng.longitude);
                        SendItCartRoute._fromAddress =
                            (await Geocoder.google(await Utils.getAPIKey())
                                .findAddressesFromCoordinates(coordinates))[0];
                        setState(() {});
                      }
                    },
                    leading: Icon(
                      Icons.location_on,
                      color: Theme.of(context).accentColor,
                    ),
                    title: Text(
                      SendItCartRoute._fromAddress.addressLine,
                      style: TextStyle(
                          color: Theme.of(context).accentColor, fontSize: 16),
                    ),
                    trailing: Icon(
                      Icons.edit,
                      color: Theme.of(context).accentColor,
                      size: 18,
                    ),
                  ),
                  Opacity(
                    opacity: 0,
                    child: Container(
                      height: itemMargin,
                    ),
                  ),
                  GestureDetector(
                    child: ListTile(
                      leading: Icon(
                        pickFromDoor
                            ? FontAwesomeIcons.doorOpen
                            : FontAwesomeIcons.doorClosed,
                        color: pickFromDoor
                            ? Theme.of(context).accentColor
                            : Colors.grey,
                      ),
                      title: Text(
                        'Pick At Door',
                        style: TextStyle(
                          color: pickFromDoor
                              ? Theme.of(context).accentColor
                              : Colors.grey,
                        ),
                      ),
                      trailing: Icon(
                        pickFromDoor
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: pickFromDoor
                            ? Theme.of(context).accentColor
                            : Colors.grey,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        pickFromDoor = true;
                      });
                    },
                  ),
                  GestureDetector(
                    child: ListTile(
                      leading: Icon(
                        pickFromDoor
                            ? FontAwesomeIcons.taxi
                            : FontAwesomeIcons.truckPickup,
                        color: !pickFromDoor
                            ? Theme.of(context).accentColor
                            : Colors.grey,
                      ),
                      title: Text(
                        'Meet at Vehicle',
                        style: TextStyle(
                          color: !pickFromDoor
                              ? Theme.of(context).accentColor
                              : Colors.grey,
                        ),
                      ),
                      trailing: Icon(
                        !pickFromDoor
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: !pickFromDoor
                            ? Theme.of(context).accentColor
                            : Colors.grey,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        pickFromDoor = false;
                      });
                    },
                  ),
                  Container(
                    padding: EdgeInsets.all(itemMargin),
                    child: Column(
                      children: <Widget>[
                        TextField(
                          controller: senderHouseController,
                          decoration: InputDecoration(
                              labelText: 'Apt/Suite/Floor/Building Name'),
                        ),
                        TextField(
                          decoration: InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          controller: senderEmailController,
                        ),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            helperText: 'e.g. 0812345678',
                          ),
                          maxLength: 10,
                          keyboardType: TextInputType.phone,
                          controller: senderPhoneNumberController,
                        ),
                      ],
                    ),
                  ),
                  Opacity(
                    opacity: 0,
                    child: Container(
                      height: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.only(
              top: groupMargin,
            ), //, left: cardMargin, right: cardMargin),
            elevation: 5,
            child: Container(
              padding: EdgeInsets.only(top: cardPadding),
              child: Column(
                children: <Widget>[
                  Text(
                    'Deliver To',
                    style: Theme.of(context).textTheme.headline,
                  ),
                  Opacity(
                    opacity: 0,
                    child: Container(
                      height: itemMargin,
                    ),
                  ),
                  ListTile(
                    onTap: () async {
                      Coordinates coordinates =
                          AddressAddingRoute._toAddress?.coordinates;
                      LatLng latlng = coordinates == null
                          ? null
                          : LatLng(
                              coordinates.latitude,
                              coordinates.longitude,
                            );
                      LocationResult result = await Utils.showPlacePicker(
                        context,
                        initialLocation: latlng,
                      );
                      if (result != null) {
                        Coordinates coordinates = Coordinates(
                            result.latLng.latitude, result.latLng.longitude);
                        SendItCartRoute._toAddress =
                            (await Geocoder.google(await Utils.getAPIKey())
                                .findAddressesFromCoordinates(coordinates))[0];
                        setState(() {});
                      }
                    },
                    leading: Icon(
                      Icons.location_on,
                      color: Theme.of(context).accentColor,
                    ),
                    title: Text(
                      SendItCartRoute._toAddress.addressLine,
                      style: TextStyle(
                          color: Theme.of(context).accentColor, fontSize: 16),
                    ),
                    trailing: Icon(
                      Icons.edit,
                      color: Theme.of(context).accentColor,
                      size: 18,
                    ),
                  ),
                  Opacity(
                    opacity: 0,
                    child: Container(
                      height: itemMargin,
                    ),
                  ),
                  GestureDetector(
                    child: ListTile(
                      leading: Icon(
                        deliverToDoor
                            ? FontAwesomeIcons.doorOpen
                            : FontAwesomeIcons.doorClosed,
                        color: deliverToDoor
                            ? Theme.of(context).accentColor
                            : Colors.grey,
                      ),
                      title: Text(
                        'Deliver to Door',
                        style: TextStyle(
                          color: deliverToDoor
                              ? Theme.of(context).accentColor
                              : Colors.grey,
                        ),
                      ),
                      trailing: Icon(
                        deliverToDoor
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: deliverToDoor
                            ? Theme.of(context).accentColor
                            : Colors.grey,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        deliverToDoor = true;
                      });
                    },
                  ),
                  GestureDetector(
                    child: ListTile(
                      leading: Icon(
                        deliverToDoor
                            ? FontAwesomeIcons.taxi
                            : FontAwesomeIcons.truckPickup,
                        color: !deliverToDoor
                            ? Theme.of(context).accentColor
                            : Colors.grey,
                      ),
                      title: Text(
                        'Meet at Vehicle',
                        style: TextStyle(
                          color: !deliverToDoor
                              ? Theme.of(context).accentColor
                              : Colors.grey,
                        ),
                      ),
                      trailing: Icon(
                        !deliverToDoor
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: !deliverToDoor
                            ? Theme.of(context).accentColor
                            : Colors.grey,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        deliverToDoor = false;
                      });
                    },
                  ),
                  Container(
                    padding: EdgeInsets.all(itemMargin),
                    child: Column(
                      children: <Widget>[
                        TextField(
                          controller: receiverHouseController,
                          decoration: InputDecoration(
                              labelText: 'Apt/Suite/Floor/Building Name'),
                        ),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            helperText: 'e.g. 0812345678',
                          ),
                          keyboardType: TextInputType.phone,
                          controller: receiverPhoneNumberController,
                          maxLength: 10,
                        ),
                        TextField(
                          decoration: InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          controller: receiverEmailController,
                        ),
                      ],
                    ),
                  ),
                  Opacity(
                    opacity: 0,
                    child: Container(
                      height: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.only(
              top: groupMargin,
            ), //, left: cardMargin, right: cardMargin),
            elevation: 5,
            child: Container(
              padding: EdgeInsets.only(
                top: cardPadding,
                bottom: cardPadding,
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    ' Distance ',
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  Spacer(),
                  Text(
                    '${Utils.calculateDistanceFromCoordinates(SendItCartRoute._fromAddress.coordinates, SendItCartRoute._toAddress.coordinates).toStringAsFixed(2)} Km ',
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.only(
              top: groupMargin,
            ), //left: cardMargin, right: cardMargin),
            elevation: 5,
            child: Container(
              padding: EdgeInsets.only(top: cardPadding, bottom: cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                      child: Text(
                    'Package Details',
                    style: Theme.of(context).textTheme.headline,
                  )),
                  ListTile(
                    title: Text('Required # of boxes'),
                    trailing: SizedBox(
                      width: 50,
                      child: TextFormField(
                        controller: numberOfBoxesController,
                        maxLength: 3,
                        maxLines: 1,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          setState(() {});
                        },
                        validator: (text) {
                          RegExp exp = RegExp(r'^[1-9]+$');
                          if (exp.hasMatch(text)) {
                            return null;
                          } else
                            return 'Error';
                        },
                      ),
                    ),
                  ),
                  // Text("    Box's Size", style: TextStyle(fontWeight: FontWeight.bold),),
                  Opacity(
                    opacity: 0,
                    child: Container(
                      height: 6,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FlatButton(
                        // padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: BorderSide(
                                color: Theme.of(context).accentColor)),
                        child: Text(
                          'Small',
                          style: TextStyle(
                              color: selectedBoxSize == BoxSize.small
                                  ? Colors.white
                                  : Theme.of(context).accentColor),
                        ),
                        color: selectedBoxSize == BoxSize.small
                            ? Theme.of(context).accentColor
                            : Colors.white,
                        onPressed: () {
                          setState(() {
                            selectedBoxSize = BoxSize.small;
                          });
                        },
                      ),
                      FlatButton(
                        // padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),

                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: BorderSide(
                                color: Theme.of(context).accentColor)),
                        child: Text(
                          'Medium',
                          style: TextStyle(
                              color: selectedBoxSize == BoxSize.medium
                                  ? Colors.white
                                  : Theme.of(context).accentColor),
                        ),
                        color: selectedBoxSize == BoxSize.medium
                            ? Theme.of(context).accentColor
                            : Colors.white,
                        onPressed: () {
                          setState(() {
                            selectedBoxSize = BoxSize.medium;
                          });
                        },
                      ),
                      FlatButton(
                        // padding: EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),

                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: BorderSide(
                                color: Theme.of(context).accentColor)),
                        child: Text(
                          'Large',
                          style: TextStyle(
                              color: selectedBoxSize == BoxSize.large
                                  ? Colors.white
                                  : Theme.of(context).accentColor),
                        ),
                        color: selectedBoxSize == BoxSize.large
                            ? Theme.of(context).accentColor
                            : Colors.white,
                        onPressed: () {
                          setState(() {
                            selectedBoxSize = BoxSize.large;
                          });
                        },
                      ),
                    ],
                  ),
                  Opacity(
                    opacity: 0,
                    child: Container(
                      height: itemMargin,
                    ),
                  ),
                  ListTile(
                    title: Text('Number of Sleeves'),
                    trailing: SizedBox(
                      width: 50,
                      child: TextFormField(
                        controller: numberOfSleevesNeededController,
                        maxLength: 2,
                        maxLines: 1,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          setState(() {});
                        },
                        validator: (text) {
                          RegExp exp = RegExp(r'^[1-9]+$');
                          if (exp.hasMatch(text)) {
                            return null;
                          } else
                            return 'Error';
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Delivery Charges: R${getCharges()}',
                          style: Theme.of(context).textTheme.subhead,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  getCharges() {
    if (numberOfBoxesController.text == "" ||
        numberOfSleevesNeededController.text == "") {
      return 'N/A';
    }
    final fromCoordinates = SendItCartRoute._fromAddress.coordinates;
    final toCoordinates = SendItCartRoute._toAddress.coordinates;

    double distance = Utils.calculateDistance(
      LatLng(fromCoordinates.latitude, fromCoordinates.longitude),
      LatLng(toCoordinates.latitude, toCoordinates.longitude),
    );
    int numberOfSleeves = int.parse(numberOfSleevesNeededController.text);
    int numberOfBoxes = int.parse(numberOfBoxesController.text);

    int totalItems = numberOfBoxes + numberOfSleeves;
    if (totalItems == 0) {
      return 'N/A';
    }

    double charges = 0;

    if (totalItems == 1) {
      charges = 30;
      distance -= 5;
      if (distance > 0) {
        charges += (distance * 4.50);
      }
    } else if (totalItems == 2 && distance <= 10) {
      charges = 60;
    } else if (totalItems > 2 && distance <= 10) {
      charges = 60 + ((totalItems - 2.0) * 20);
    } else if (totalItems >= 2) {
      double boxCharges;
      if (totalItems <= 10) {
        boxCharges = totalItems * 48.0;
      } else {
        int tempTotalItems = totalItems - 10;
        boxCharges = 480;
        boxCharges += tempTotalItems * 20;
      }
      charges = boxCharges;

      if (distance > 30) {
        charges += (distance.ceilToDouble() - 30.0) * 4.50;
      }
    }

    // double perItemCost = 0;
    // // if (distance <= 5) {
    // perItemCost = 30;
    // // }
    // distance -= 5;
    // double absoluteValue = distance.ceilToDouble();
    // if (absoluteValue < 0) {
    //   absoluteValue = 0;
    // }
    // perItemCost += (absoluteValue * 4.50);
    // totalCharges = perItemCost * totalItems;
    totalCharges = charges;
    return charges.toStringAsFixed(2);
  }
}

class PackageDetailRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Package Details'),
      ),
      body: PackageDetailBody(),
    );
  }
}

class PackageDetailBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PackageDetailState();
  }
}

class PackageDetailState extends State<PackageDetailBody> {
  @override
  Widget build(BuildContext context) {
    return null;
  }
}
