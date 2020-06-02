import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sennit/main.dart';
import 'package:sennit/models/models.dart';
import 'package:sennit/rx_models/rx_storesAndItems.dart';
import 'package:sennit/user/generic_tracking_screen.dart';

class OrderTile extends StatelessWidget {
  final data;
  final isStore;
  final status;
  final isCompleted;
  // final userOrderRef;

  const OrderTile({
    Key key,
    this.data,
    this.isStore = false,
    this.status = "Pending",
    this.isCompleted = false,
    // this.userOrderRef,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        dense: true,
        isThreeLine: true,
        onTap: () async {
          if (!data.containsKey('numberOfSleevesNeeded') ||
              data['numberOfSleevesNeeded'] == null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return ReceiveItOrderDetailsRoute(
                    data: data,
                    isStore: isStore,
                    isCompleted: isCompleted,
                    status: status,
                    // userOrderRef: userOrderRef,
                  );
                },
              ),
            );
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) {
                return SennitOrderDetailsRoute(
                  data: data,
                );
              }),
            );
          }
        },
        leading: Icon(
          FontAwesomeIcons.shoppingBag,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          '${data['numberOfSleevesNeeded'] == null ? 'Receive it' : 'Sennit'}',
          style: Theme.of(context).textTheme.headline6,
        ),
        subtitle: Text.rich(
          TextSpan(
            text: 'OrderId: ',
            style: Theme.of(context).textTheme.subtitle1,
            children: [
              TextSpan(
                text: '${data['shortId']}\n',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              TextSpan(
                text: 'Date: ',
              ),
              TextSpan(
                text:
                    '''${DateFormat("dd/MM/yyyy").format(DateTime.fromMillisecondsSinceEpoch(data['date']))}\n''',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              TextSpan(
                text: 'Status: ',
              ),
              TextSpan(
                text:
                    '${(data['status'] ?? status) == 'Accepted' ? 'Preparing' : (data['status'] ?? status)}',
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ],
          ),
        ),
        trailing: Text(
          'R${(data['price'] as double).toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.subtitle1,
        ),
      ),
    );
  }
}

class SennitOrderDetailsRoute extends StatelessWidget {
  final data;

  const SennitOrderDetailsRoute({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double strutHeight = 1.5;
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
        centerTitle: true,
      ),
      body: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              // Center(
              //   child: Text(
              //     'Sennit',
              //     style: textTheme.title,
              //   ),
              // ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  Text(
                    'OrderId: ',
                    style: textTheme.subtitle1,
                    strutStyle: StrutStyle(height: strutHeight),
                  ),
                  Text(
                    '${data['shortId']}',
                    strutStyle: StrutStyle(height: strutHeight),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'PickUp Address: ',
                    style: textTheme.subtitle1,
                    strutStyle: StrutStyle(height: strutHeight),
                  ),
                  Expanded(
                    child: Text(
                      '${(data['senderHouse'] ?? "")}${((data['senderHouse'] != null && data['senderHouse'] != '') ? ', ' : '')}${data['pickUpAddress']}',
                      strutStyle: StrutStyle(height: strutHeight),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Delivery Address: ',
                    style: textTheme.subtitle1,
                    strutStyle: StrutStyle(height: strutHeight),
                  ),
                  Expanded(
                    child: Text(
                      '${data['receiverHouse'] ?? ""}${((data['receiverHouse'] != null && data['receiverHouse'] != '') ? ', ' : '')}${data['dropOffAddress']}',
                      strutStyle: StrutStyle(height: strutHeight),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Text(
                    'Boxes: ',
                    style: textTheme.subtitle1,
                    strutStyle: StrutStyle(height: strutHeight),
                  ),
                  Text(
                    '${data['numberOfBoxes']} ${data['boxSize'] + ' ' + (data['numberOfBoxes'] > 1 ? 'Boxes' : 'Box')}',
                    strutStyle: StrutStyle(height: strutHeight),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Text(
                    'Status: ',
                    style: textTheme.subtitle1,
                    strutStyle: StrutStyle(height: strutHeight),
                  ),
                  Expanded(
                    child: Text(
                      '${data['status'] == 'Accepted' ? 'Preparing' : data['status']}',
                      strutStyle: StrutStyle(height: strutHeight),
                    ),
                  ),
                  Text(
                    'Date: ',
                    style: textTheme.subtitle1,
                    strutStyle: StrutStyle(height: strutHeight),
                  ),
                  Expanded(
                    child: Text(
                      '''${DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).format(
                        DateTime.fromMillisecondsSinceEpoch(
                          data['date'],
                        ),
                      )}''',
                      strutStyle: StrutStyle(height: strutHeight),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              data['driverId'] != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Driver: ',
                          style: textTheme.subtitle1,
                          strutStyle: StrutStyle(height: strutHeight),
                        ),
                        Text(
                          '${data['driverName']}',
                          strutStyle: StrutStyle(height: strutHeight),
                        ),
                      ],
                    )
                  : Opacity(
                      opacity: 0,
                    ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ),
                  data['status'] != "Delivered"
                      ? RaisedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderTracking(
                                  type: OrderTrackingType.SENNIT,
                                  data: Map<String, dynamic>.from(data),
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'Track Your Order',
                            style:
                                Theme.of(context).textTheme.subtitle2.copyWith(
                                      color: Colors.white,
                                    ),
                          ),
                        )
                      : Opacity(
                          opacity: 0,
                        ),
                  Spacer(),
                  Text(
                    'Total: R${(data['price'] as double).toStringAsFixed(2)}',
                    style: textTheme.headline6,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReceiveItOrderDetailsRoute extends StatelessWidget {
  final Map<String, dynamic> data;
  final isStore;
  final status;
  final isCompleted;
  // final DocumentReference userOrderRef;
  const ReceiveItOrderDetailsRoute({
    Key key,
    this.data,
    this.isStore = false,
    this.isCompleted = false,
    this.status = "Pending",
    // this.userOrderRef,
  }) : super(key: key);

  Future<Address> _getAddressFromLatLng(LatLng latlng) async {
    Coordinates coordinates = Coordinates(latlng.latitude, latlng.longitude);
    return Geocoder.google(await Utils.getAPIKey())
        .findAddressesFromCoordinates(coordinates)
        .then((addresses) {
      return addresses[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    double strutHeight = 1.5;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
        centerTitle: true,
        actions: (isStore && !isCompleted)
            ? <Widget>[
                FlatButton(
                  child: Text('Served'),
                  onPressed: () async {
                    Utils.showLoadingDialog(context);
                    final batch = Firestore.instance.batch();

                    var orderRef = Firestore.instance
                        .collection('orders')
                        .document(data['orderId']);
                    // var pendingRef = Firestore.instance
                    //     .collection('stores')
                    //     .document(Session.data['partnerStore'].storeId)
                    //     .collection('pendingOrderedItems')
                    //     .document(data['orderId']);
                    batch.setData(
                      orderRef,
                      {
                        Session.data['partnerStore'].storeId: 'Served',
                      },
                      merge: true,
                    );
                    // batch.setData(servedRef, data);
                    // batch.delete(pendingRef);
                    await batch.commit().timeout(Duration(seconds: 20),
                        onTimeout: () {
                      Utils.showSnackBarError(context, 'Request Timed out!');
                      return null;
                    }).catchError((_) {
                      Utils.showSnackBarError(context, 'Something went wrong!');
                      return null;
                    });
                    BotToast.closeAllLoading();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      MyApp.partnerStoreHome,
                      (route) => false,
                    );
                  },
                ),
              ]
            : null,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Container(
              // height: MediaQuery.of(context).size.height - 80,
              padding: EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      // Center(
                      //   child: Text(
                      //     'ReceiveIt',
                      //     style: textTheme.headline5,
                      //   ),
                      // ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            'OrderId: ',
                            style: textTheme.subtitle1,
                            strutStyle: StrutStyle(height: strutHeight),
                          ),
                          Text(
                            '${data['shortId']}',
                            strutStyle: StrutStyle(height: strutHeight),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      isStore
                          ? Opacity(opacity: 0)
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Delivered To: ',
                                  style: textTheme.subtitle1,
                                  strutStyle: StrutStyle(height: strutHeight),
                                ),
                                Expanded(
                                  child: FutureBuilder<Address>(
                                      future: _getAddressFromLatLng(
                                        Utils.latLngFromString(
                                          data['destination'],
                                        ),
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Text(
                                            'Loading .....',
                                            strutStyle: StrutStyle(
                                              height: strutHeight,
                                            ),
                                          );
                                        }
                                        return Text(
                                          '${data['house'] ?? ''}${((data['house'] != null && data['house'] != '') ? ', ' : '')}${snapshot.data.addressLine}',
                                          strutStyle: StrutStyle(
                                            height: strutHeight,
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            ),
                      SizedBox(
                        height: 10,
                      ),
                      Wrap(
                        direction: Axis.horizontal,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.start,
                        children: <Widget>[
                          Text(
                            'Date: ',
                            style: textTheme.subtitle1,
                            strutStyle: StrutStyle(
                              height: strutHeight,
                            ),
                          ),
                          Text(
                            '''${DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).format(
                              DateTime.fromMillisecondsSinceEpoch(
                                data['date'],
                              ),
                            )}''',
                            strutStyle: StrutStyle(
                              height: strutHeight,
                            ),
                          ),
                          SizedBox(width: 20),
                          Text(
                            'Status: ',
                            style: textTheme.subtitle1,
                            strutStyle: StrutStyle(
                              height: strutHeight,
                            ),
                          ),
                          Text(
                            '${(data['status'] ?? status) == 'Accepted' ? 'Preparing' : (data['status'] ?? status)}',
                            strutStyle: StrutStyle(
                              height: strutHeight,
                            ),
                          ),
                          data['driverName'] == null || data['driverName'] == ''
                              ? Opacity(
                                  opacity: 0,
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Driver: ',
                                      style: textTheme.subtitle1,
                                      strutStyle: StrutStyle(
                                        height: strutHeight,
                                      ),
                                    ),
                                    Text(
                                      '${data['driverName'] ?? 'N/A'}',
                                      strutStyle: StrutStyle(
                                        height: strutHeight,
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      FutureBuilder<Map<String, StoreItem>>(
                        future: getItemDetails(isStore),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final order = OrderFromReceiveIt.fromMap(data);
                          Map<String, Store> storesMap =
                              GetIt.I.get<RxStoresAndItems>().stores.value;
                          Map<String, StoreItem> itemsMap = snapshot.data;
                          StoreToReceiveItOrderItems
                              storeToReceiveItOrderItems = order.itemsData;

                          List<Widget> widgets = [];

                          if (!isStore) {
                            for (String storeId in storeToReceiveItOrderItems
                                .itemDetails.keys) {
                              Store store = storesMap[storeId];
                              widgets.add(SizedBox(
                                height: 32.0,
                              ));
                              widgets.add(Text(
                                store?.storeName ?? 'storeName',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ));
                              widgets.add(SizedBox(
                                height: 16.0,
                              ));
                              Map<String, ReceiveItOrderItemDetails>
                                  orderItems = storeToReceiveItOrderItems
                                      .itemDetails[storeId].itemDetails;
                              for (String itemId in orderItems.keys) {
                                StoreItem item = itemsMap[itemId];
                                ReceiveItOrderItemDetails details =
                                    orderItems[itemId];
                                widgets.add(
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Container(
                                            height: 80,
                                            width: 80,
                                            color: Colors.black,
                                            child: Image.network(
                                              item.images[0],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 6.0,
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Text(
                                                  item.itemName,
                                                  style: textTheme.subtitle1,
                                                ),
                                                // Spacer(),
                                                // Expanded(
                                                //   child: Text(
                                                //     item.storeName.substring(
                                                //       0,
                                                //       item.storeName.length > 24
                                                //           ? 24
                                                //           : item
                                                //               .storeName.length,
                                                //     ),
                                                //     style: Theme.of(context)
                                                //         .textTheme
                                                //         .subtitle1
                                                //         .copyWith(
                                                //           fontSize: (22 -
                                                //               item.storeName
                                                //                       .length /
                                                //                   1.8),
                                                //         ),
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 2.0,
                                            ),
                                            Text(
                                              'Flavour: ${(details?.flavour ?? '') == '' ? 'N/A' : details.flavour}',
                                            ),
                                            Row(children: [
                                              Spacer(),
                                              Text(
                                                '''Price: R${item.price.toStringAsFixed(1)} R x ${details.quantity} = ${(item.price * details.quantity).toStringAsFixed(1)} R''',
                                                style: textTheme.subtitle1,
                                              ),
                                            ]),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                widgets.add(SizedBox(
                                  height: 16.0,
                                ));
                              }
                            }
                          } else {
                            String storeId =
                                Session.data['partnerStore'].storeId;

                            ReceiveItOrderItem receiveItOrderItem =
                                storeToReceiveItOrderItems.itemDetails[storeId];
                            widgets.add(SizedBox(
                              height: 32.0,
                            ));
                            for (String itemId
                                in receiveItOrderItem.itemDetails.keys) {
                              StoreItem item = itemsMap[itemId];
                              ReceiveItOrderItemDetails details =
                                  receiveItOrderItem.itemDetails[itemId];
                              widgets.add(
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Container(
                                          height: 80,
                                          width: 80,
                                          color: Colors.black,
                                          child: Image.network(
                                            item.images[0],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 6.0,
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                item.itemName,
                                                style: textTheme.subtitle1,
                                              ),
                                              //   Spacer(),
                                              //   Expanded(
                                              //     child: Text(
                                              //       item.storeName.substring(
                                              //         0,
                                              //         item.storeName.length > 24
                                              //             ? 24
                                              //             : item.storeName.length,
                                              //       ),
                                              //       style: Theme.of(context)
                                              //           .textTheme
                                              //           .subtitle1
                                              //           .copyWith(
                                              //             fontSize: (22 -
                                              //                 item.storeName
                                              //                         .length /
                                              //                     1.8),
                                              //           ),
                                              //     ),
                                              //   ),
                                              //
                                            ],
                                          ),
                                          SizedBox(
                                            height: 2.0,
                                          ),
                                          Text(
                                            'Flavour: ${(details?.flavour ?? '') == '' ? 'N/A' : details.flavour}',
                                          ),
                                          Row(children: [
                                            Spacer(),
                                            Text(
                                              '''Price: R${item.price.toStringAsFixed(1)} R x ${details.quantity} = ${(item.price * details.quantity).toStringAsFixed(1)} R''',
                                              style: textTheme.subtitle1,
                                            ),
                                          ]),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              widgets.add(SizedBox(
                                height: 16.0,
                              ));
                            }
                            widgets.add(SizedBox(
                              height: 14.0,
                            ));
                          }

                          return Container(
                            constraints: BoxConstraints.loose(Size(
                                MediaQuery.of(context).size.width,
                                MediaQuery.of(context).size.height * 0.3)),
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: widgets,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      // Align(
                      //   alignment: Alignment.bottomRight,
                      //   child: Text(
                      //     'Total: R${data['price']}',
                      //     style: textTheme.title,
                      //   ),
                      // ),
                      isStore
                          ? Opacity(
                              opacity: 0,
                            )
                          : Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 10,
                                ),
                                (data['status'] != null &&
                                        (data['status'] as String)
                                                .toUpperCase() !=
                                            'Delivered'.toUpperCase())
                                    ? RaisedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OrderTracking(
                                                type: OrderTrackingType
                                                    .RECEIVE_IT,
                                                data: Map<String, dynamic>.from(
                                                    data),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Track Your Order',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2
                                              .copyWith(
                                                color: Colors.white,
                                              ),
                                        ),
                                      )
                                    : Spacer(),
                                Spacer(),
                                Text(
                                  'Total: R${(data['price'] as double).toStringAsFixed(2)}',
                                  style: textTheme.headline6,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          StreamBuilder<DocumentSnapshot>(
              stream: Firestore.instance
                  .collection('orders')
                  .document(data['orderId'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Card(
                    margin: EdgeInsets.all(8),
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.1,
                      // margin: EdgeInsets.all(8),
                      // padding: EdgeInsets.all(8),
                      child: Center(
                        heightFactor: 2,
                        child: Row(
                          children: <Widget>[
                            Text(
                              ' Fetching Driver Details .... ',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            SizedBox(
                              height: 10,
                              width: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else if ((snapshot.connectionState == ConnectionState.done ||
                        snapshot.connectionState == ConnectionState.none) &&
                    !snapshot.data.exists) {
                  return Opacity(
                    opacity: 0,
                  );
                }
                final orderData = snapshot.data.data;
                String driverImage = orderData['driverImage'];
                String driverName = orderData['driverName'];
                String driverLicencePlateNumber =
                    orderData['driverLicencePlateNumber'];
                String driverPhoneNumber = orderData['driverPhoneNumber'];
                String driverId = orderData['driverId'];

                if (driverId == null || driverId.trim() == '') {
                  return Card(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          'Waiting for Driver To Accept',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                    ),
                  );
                }

                return Card(
                  margin: EdgeInsets.all(8),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.1,
                    // margin: EdgeInsets.all(8),
                    // padding: EdgeInsets.all(8),
                    child: ListTile(
                      leading: driverImage == null || driverImage == ''
                          ? Icon(
                              Icons.account_circle,
                              size: 40,
                              color: Theme.of(context).primaryColor,
                            )
                          : FadeInImage.assetNetwork(
                              placeholder: 'assets/images/user.png',
                              image: driverImage,
                              width: 80,
                              height: 80,
                            ),
                      title: Text(driverName),
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            driverLicencePlateNumber ?? 'Not Registered',
                            style:
                                Theme.of(context).textTheme.headline6.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Phone: ',
                                  style: Theme.of(context).textTheme.subtitle2,
                                ),
                                TextSpan(
                                  text: driverPhoneNumber ?? 'Not Available',
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

  /**
  this Function returns
  {
    'items': <StoreItem>[],
    itemId: ReceiveItOrderItemDetails,
    itemId2: ReceiveItOrderItemDetails,
    itemId3: ReceiveItOrderItemDetails,
    itemId4: ReceiveItOrderItemDetails,
    itemIdn: ReceiveItOrderItemDetails,
  }
  **/
  Future<Map<String, StoreItem>> getItemDetails(bool isStore) async {
    OrderFromReceiveIt order = OrderFromReceiveIt.fromMap(data);
    Firestore firestore = Firestore.instance;
    RxStoresAndItems storesAndItems = GetIt.I.get<RxStoresAndItems>();
    Map<String, StoreItem> itemsMap = storesAndItems.items.value;
    Map<String, StoreItem> result = {};
    // result.putIfAbsent('items', () => []);
    if (isStore) {
      String storeId = (Session.data['partnerStore'] as Store).storeId;
      Map<String, ReceiveItOrderItemDetails> itemsData =
          order.itemsData.itemDetails[storeId].itemDetails;
      for (var itemId in itemsData.keys) {
        if (!itemsMap.containsKey(itemId)) {
          final snapshot =
              await firestore.collection('items').document(itemId).get();
          result.putIfAbsent(
            itemId,
            () => StoreItem.fromMap(snapshot.data),
          );
        } else {
          result.putIfAbsent(itemId, () => itemsMap[itemId]);
        }
        // result.update(
        //   itemId,
        //   (old) => itemsData[itemId],
        //   ifAbsent: () => itemsData[itemId],
        // );
      }
    } else {
      Map<String, ReceiveItOrderItem> storeToOrderItem =
          order.itemsData.itemDetails;
      for (String storeId in storeToOrderItem.keys) {
        Map<String, ReceiveItOrderItemDetails> itemsData =
            storeToOrderItem[storeId].itemDetails;

        for (String itemId in itemsData.keys) {
          if (!itemsMap.containsKey(itemId)) {
            final snapshot =
                await firestore.collection('items').document(itemId).get();
            result.putIfAbsent(itemId, () => StoreItem.fromMap(snapshot.data));
          } else {
            result.putIfAbsent(itemId, () => itemsMap[itemId]);
          }
          // result.update(
          //   itemId,
          //   (old) => itemsData[itemId],
          //   ifAbsent: () => itemsData[itemId],
          // );
        }
      }
    }
    return result;
  }
}
