import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:place_picker/place_picker.dart';
import 'package:sennit/main.dart';
import 'package:sennit/models/models.dart';

enum SourcePage { addressSelectionFrom, addressSelectionDestination, recieveIt }

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
              sourcePage == SourcePage.recieveIt
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
  Color defaultHeighlightedColor = Color.fromARGB(0xff, 0x5d, 0x5d, 0x5d);
  Color defaultBtnBackgroundColor = Colors.white;
  double btnPaddingTop;
  double btnPaddingBottom;
  double btnPaddingLeft;
  double btnPaddingRight;
  double cardPadding;
  String dateInitialText;
  bool dateSelected = false;
  bool customAddress = true;

  Color defaultHeighlightedColorDOB = Color.fromARGB(255, 57, 59, 82);
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
    // defaultHeighlightedColorDOB = Theme.of(context).accentColor;
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
                  ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: Theme.of(context).accentColor,
                    ),
                    title: Text('Pick A location'),
                    onTap: () async {
                      LocationResult result =
                          await Utils.showPlacePicker(context);
                      if (result != null) {
                        Coordinates coordinates = Coordinates(
                            result.latLng.latitude, result.latLng.longitude);
                        if (widget.sourcePage ==
                            SourcePage.addressSelectionDestination) {
                          AddressAddingRoute._toAddress = (await Geocoder.local
                              .findAddressesFromCoordinates(coordinates))[0];
                        } else {
                          AddressAddingRoute._fromAddress = (await Geocoder
                              .local
                              .findAddressesFromCoordinates(coordinates))[0];
                        }
                        setState(() {});
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.my_location,
                      color: Theme.of(context).accentColor,
                    ),
                    title: Text('Selected Location',
                        style: TextStyle(color: Theme.of(context).accentColor)),
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
                    onTap: () {},
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
          Card(
            margin: EdgeInsets.all(0),
            elevation: 5,
            child: Container(
              padding: EdgeInsets.all(cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '  Saved Addreses',
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
                          (await Geocoder.local.findAddressesFromCoordinates(
                        Coordinates(user.homeLocationLatLng.latitude,
                            user.homeLocationLatLng.longitude),
                      ))[0];
                      widget.sourcePage == SourcePage.recieveIt
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
                            Address selectedAddress = (await Geocoder.local
                                .findAddressesFromCoordinates(
                              Coordinates(user.officeLocationLatLng.latitude,
                                  user.officeLocationLatLng.longitude),
                            ))[0];
                            widget.sourcePage == SourcePage.recieveIt
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
                                Address selectedAddress = (await Geocoder.local
                                    .findAddressesFromCoordinates(
                                  Coordinates(
                                      locationHistory[index].latLng.latitude,
                                      locationHistory[index].latLng.longitude),
                                ))[0];
                                widget.sourcePage == SourcePage.recieveIt
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

  SendItCartRoute(fromAddress, toAddress) {
    _fromAddress = fromAddress;
    _toAddress = toAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              Utils.showLoadingDialog(context);
              OrderFromSennit sennitOrder = OrderFromSennit();
              sennitOrder.boxSize = SendItCartRouteState.selectedBoxSize;
              sennitOrder.dateOrdered = DateTime.now();
              sennitOrder.userId = (Session.data['user'] as User).userId;
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
              sennitOrder.orderPrice = 200;
              sennitOrder.sleevesRequired = SendItCartRouteState.sleeveNeeded;
              sennitOrder.serviceCharges = 0;
              sennitOrder.receiverEmail =
                  SendItCartRouteState.receiverEmailController.text;
              sennitOrder.receiverPhone =
                  SendItCartRouteState.receiverPhoneNumberController.text;
              sennitOrder.senderEmail =
                  SendItCartRouteState.senderEmailController.text;
              sennitOrder.senderPhone =
                  SendItCartRouteState.senderPhoneNumberController.text;
              await Firestore.instance
                  .collection("postedOrders")
                  .add(sennitOrder.toMap());
              BotToast.showEnhancedWidget(toastBuilder: (a) {
                return Center(
                  child: Container(
                    width: 300,
                    height: 230,
                    padding:
                        EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
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
              Navigator.popUntil(context, ModalRoute.withName(MyApp.userHome));
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

  static bool sleeveNeeded = false;
  static BoxSize selectedBoxSize = BoxSize.small;

  static final senderEmailController = TextEditingController();
  static final senderPhoneNumberController = TextEditingController();
  static final receiverEmailController = TextEditingController();
  static final receiverPhoneNumberController = TextEditingController();
  static final numberOfBoxesController = TextEditingController();

  SendItCartRouteState();

  @override
  void initState() {
    User user = Session.data['user'];
    senderEmailController.text = user.email;
    senderPhoneNumberController.text = user.phoneNumber;
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
                      LocationResult result =
                          await Utils.showPlacePicker(context);
                      if (result != null) {
                        Coordinates coordinates = Coordinates(
                            result.latLng.latitude, result.latLng.longitude);
                        SendItCartRoute._fromAddress = (await Geocoder.local
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
                          decoration: InputDecoration(
                              labelText: 'Apt/Suite/Floor/Building Name'),
                        ),
                        TextField(
                          decoration: InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          controller: senderEmailController,
                        ),
                        TextField(
                          decoration:
                              InputDecoration(labelText: 'Phone Number'),
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
                      LocationResult result =
                          await Utils.showPlacePicker(context);
                      if (result != null) {
                        Coordinates coordinates = Coordinates(
                            result.latLng.latitude, result.latLng.longitude);
                        SendItCartRoute._toAddress = (await Geocoder.local
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
                          decoration: InputDecoration(
                              labelText: 'Apt/Suite/Floor/Building Name'),
                        ),
                        TextField(
                          decoration:
                              InputDecoration(labelText: 'Phone Number'),
                          keyboardType: TextInputType.phone,
                          controller: receiverPhoneNumberController,
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
                  GestureDetector(
                    child: ListTile(
                      trailing: Icon(
                        sleeveNeeded
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: Theme.of(context).accentColor,
                      ),
                      title: Text('Sleeves Required'),
                    ),
                    onTap: () {
                      setState(() {
                        sleeveNeeded = !sleeveNeeded;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.only(
              top: 10,
            ), //, left: cardMargin, right: cardMargin),
            elevation: 5,
            child: Container(
              padding: EdgeInsets.only(top: cardPadding),
              child: Column(
                children: <Widget>[
                  Align(alignment: Alignment.centerRight, child: Text('')),
                  ListTile(
                    leading: Icon(
                      Icons.credit_card,
                    ),
                    title: Text(
                      'Check Out',
                    ),
                    trailing: Icon(Icons.navigate_next),
                    onTap: () {
                      var pickupLatLng = LatLng(
                        SendItCartRoute._fromAddress.coordinates.latitude,
                        SendItCartRoute._fromAddress.coordinates.longitude,
                      );
                      var dropOffLatLng = LatLng(
                        SendItCartRoute._toAddress.coordinates.latitude,
                        SendItCartRoute._toAddress.coordinates.longitude,
                      );
                      var orderId =
                          "order${Session.data['user'].userId}${DateTime.now().millisecondsSinceEpoch}";
                      OrderFromSennit order = OrderFromSennit(
                        orderId: orderId,
                        boxSize: selectedBoxSize,
                        dateOrdered: DateTime.now(),
                        driverId: null,
                        pickUpAddress: SendItCartRoute._fromAddress.addressLine,
                        dropOffAddress: SendItCartRoute._toAddress.addressLine,
                        pickUpLatLng: pickupLatLng,
                        dropOffLatLng: dropOffLatLng,
                      );

                      dynamic distance =
                          Utils.calculateDistance(pickupLatLng, dropOffLatLng)
                              as dynamic;

                      Firestore.instance
                          .collection("orders")
                          .firestore
                          .collection("postedOrders")
                          .document(orderId)
                          .setData(order.toMap()
                            ..update('distance', distance, ifAbsent: () {
                              return distance;
                            }))
                          .then((_) {
                        Utils.showSnackBarSuccess(
                            context, 'Your Order has been Placed');
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
