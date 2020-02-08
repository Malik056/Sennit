import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sennit/main.dart';

class OrderTile extends StatelessWidget {
  final data;

  const OrderTile({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        dense: true,
        isThreeLine: true,
        onTap: () {
          if (!data.containsKey('numberOfSleevesNeeded') || data['numberOfSleevesNeeded'] == null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return ReceiveItOrderDetailsRoute(data: data);
                },
              ),
            );
          } else {
            Navigator.push(
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
          '${data['numberOfSleevesNeeded'] == null ? 'Recieve it' : 'Sennit'}',
          style: Theme.of(context).textTheme.title,
        ),
        subtitle: Text.rich(
          TextSpan(
            text: 'OrderId: ',
            style: Theme.of(context).textTheme.subhead,
            children: [
              TextSpan(
                text: '${data['orderId']}\n',
                style: Theme.of(context).textTheme.body1,
              ),
              TextSpan(
                text: 'Date: ',
              ),
              TextSpan(
                text:
                    '''${DateFormat("dd/MM/yyyy").format(DateTime.fromMillisecondsSinceEpoch(data['date']))}\n''',
                style: Theme.of(context).textTheme.body1,
              ),
              TextSpan(
                text: 'Status: ',
              ),
              TextSpan(
                text: '${data['status']}',
                style: Theme.of(context).textTheme.body1,
              ),
            ],
          ),
        ),
        trailing: Text(
          'R${data['price']}',
          style: Theme.of(context).textTheme.subhead,
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
                    style: textTheme.subhead,
                    strutStyle: StrutStyle(height: strutHeight),
                  ),
                  Text(
                    '${data['orderId']}',
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
                    style: textTheme.subhead,
                    strutStyle: StrutStyle(height: strutHeight),
                  ),
                  Expanded(
                    child: Text(
                      '${data['senderHouse'] ?? "" + ((data['senderHouse'] != null && data['senderHouse'] != '') ? ', ' : '') + data['pickUpAddress']}',
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
                    style: textTheme.subhead,
                    strutStyle: StrutStyle(height: strutHeight),
                  ),
                  Expanded(
                    child: Text(
                      '${data['receiverHouse'] ?? "" + ((data['receiverHouse'] != null && data['receiverHouse'] != '') ? ', ' : '') + data['dropOffAddress']}',
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
                    style: textTheme.subhead,
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
                    style: textTheme.subhead,
                    strutStyle: StrutStyle(height: strutHeight),
                  ),
                  Text(
                    '${data['status']}',
                    strutStyle: StrutStyle(height: strutHeight),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              data['driverId'] != null
                  ? Row(
                      children: <Widget>[
                        Text(
                          'Driver: ',
                          style: textTheme.subhead,
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    'Price: R${data['price']}',
                    style: textTheme.title,
                    strutStyle: StrutStyle(height: strutHeight),
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
  final data;

  const ReceiveItOrderDetailsRoute({Key key, this.data}) : super(key: key);

  Future<Address> _getAddressFromLatLng(LatLng latlng) {
    Coordinates coordinates = Coordinates(latlng.latitude, latlng.longitude);
    return Geocoder.local
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
      ),
      body: Container(
        height: MediaQuery.of(context).size.height - 80,
        padding: EdgeInsets.all(8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                // Center(
                //   child: Text(
                //     'ReceiveIt',
                //     style: textTheme.headline,
                //   ),
                // ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'OrderId: ',
                      style: textTheme.subhead,
                      strutStyle: StrutStyle(height: strutHeight),
                    ),
                    Text(
                      '${data['orderId']}',
                      strutStyle: StrutStyle(height: strutHeight),
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
                      'Delivered To: ',
                      style: textTheme.subhead,
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
                              '${data['house'] + ((data['house'] != null && data['house'] != '') ? ', ' : '') + snapshot.data.addressLine}',
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
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    Text(
                      'Date: ',
                      style: textTheme.subhead,
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
                      style: textTheme.subhead,
                      strutStyle: StrutStyle(
                        height: strutHeight,
                      ),
                    ),
                    Text(
                      '${data['status']}',
                      strutStyle: StrutStyle(
                        height: strutHeight,
                      ),
                    ),
                    data['driverName'] == null || data['driverName'] == ''
                        ? SizedBox(
                            width: 20,
                          )
                        : Opacity(
                            opacity: 0,
                          ),
                    data['driverName'] == null || data['driverName'] == ''
                        ? Opacity(
                            opacity: 0,
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'Driver: ',
                                style: textTheme.subhead,
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
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: getItemDetails(data),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return Container(
                      constraints: BoxConstraints.loose(Size(
                          MediaQuery.of(context).size.width,
                          MediaQuery.of(context).size.height * 0.3)),
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List<Widget>.generate(
                              data['itemsData'].length, (index) {
                            final item = snapshot.data[index];
                            return Column(
                              children: <Widget>[
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
                                            item['images'][0],
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
                                          Text(
                                            item['itemName'],
                                            style: textTheme.subhead,
                                          ),
                                          SizedBox(
                                            height: 2.0,
                                          ),
                                          Text(item['storeAddress']),
                                          SizedBox(
                                            height: 6.0,
                                          ),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                              'Price: R${item['price']} x ${(data['itemsData'][item['itemId']] as double).toInt()}',
                                              style: textTheme.subhead,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    'Total: R${data['price']}',
                    style: textTheme.title,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getItemDetails(data) async {
    Map<String, double> items = Map<String, double>.from(data['itemsData']);
    Firestore firestore = Firestore.instance;
    List<Map<String, dynamic>> result = [];
    for (var item in items.keys) {
      final snapshot = await firestore.collection('items').document(item).get();
      result.add(snapshot.data);
    }
    return result;
  }
}
