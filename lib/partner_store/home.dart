import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sennit/main.dart';

class OrderedItemsList extends StatelessWidget {
  static bool _buttonPressed;
  final _key = GlobalKey<ScaffoldState>();

  OrderedItemsList() {
    _buttonPressed = false;
  }

  @override
  Widget build(BuildContext context) {
    // Future<DocumentSnapshot> futureStoreData = Firestore.instance
    //     .collection('stores')
    //     .document(Session.data['partnerStore']['storeId'])
    //     .get();
    return WillPopScope(
      onWillPop: () async {
        if (!_buttonPressed) {
          _buttonPressed = true;
          Utils.showSnackBarWarningUsingKey(_key, 'Press Again to Exit',
              duration: Duration(seconds: 2));
          Future.delayed(new Duration(seconds: 2)).then((vale) {
            _buttonPressed = false;
          });
          return false;
        } else {
          SystemNavigator.pop();
          return false;
        }
      },
      child: Scaffold(
        // drawer: Drawer(
        //   child: Column(
        //     children: <Widget>[
        //       UserAccountsDrawerHeader(
        //         accountName: FutureBuilder<DocumentSnapshot>(
        //           future: futureStoreData,
        //           builder: (context, snapshot) {
        //             if (snapshot.connectionState == ConnectionState.waiting) {
        //               return Center(
        //                 child: CircularProgressIndicator(
        //                   strokeWidth: 2,
        //                 ),
        //               );
        //             } else {
        //               return Text(snapshot.data.data['storeName']);
        //             }
        //           },
        //         ),
        //         accountEmail: null,
        //       )
        //     ],
        //   ),
        // ),
        key: _key,
        appBar: AppBar(
          title: Text('Orders'),
          centerTitle: true,
          actions: <Widget>[
            FlatButton(
              child: Icon(
                FontAwesomeIcons.signOutAlt,
                // 'Signout',
                // style: Theme.of(context)
                //     .textTheme
                //     .subhead
                //     .copyWith(color: Theme.of(context).primaryColor),
              ),
              onPressed: () async {
                Session.data.removeWhere((_, __) => true);
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, MyApp.startPage);
              },
            )
          ],
        ),
        body: FutureBuilder<QuerySnapshot>(
          future: Firestore.instance
              .collection('stores')
              .document(Session.data['partnerStore']['storeId'])
              .collection('orderedItems')
              .getDocuments()
              .then(
            (value) async {
              if (!Session.data.containsKey('partnerStore')) {
                final partnerStoreId = await FirebaseAuth.instance
                    .currentUser()
                    .then((user) => user.uid);
                final data = await Firestore.instance
                    .collection("partnerStores")
                    .document(partnerStoreId)
                    .get()
                    .then(
                      (dataSnapshot) => dataSnapshot.data,
                    );
                Session.data.putIfAbsent('partnerStore', () => data);
              }
              // keys = Session.data['partnerStore'].keys;
              return value;
            },
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.data.documents.length == 0) {
              return Center(
                child: Text(
                  'No Orders yet!',
                  style: Theme.of(context).textTheme.title.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              );
            }
            List<DocumentSnapshot> data = snapshot.data.documents;
            TextTheme textTheme = Theme.of(context).textTheme;
            return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot snapshot = data[index];
                  int numberOfOrders = snapshot.data.length;
                  return FutureBuilder<Map<String, dynamic>>(
                    future: Firestore.instance
                        .collection('items')
                        .document(snapshot.documentID)
                        .get()
                        .then((data) {
                      return data.data;
                    }),
                    builder: (context, itemSnapshot) {
                      if (itemSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Container(
                          margin: EdgeInsets.all(40),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.only(
                          top: 16,
                          bottom: 14,
                        ),
                        child: Container(
                          // padding: EdgeInsets.all(4),
                          child: InkWell(
                            splashColor:
                                Theme.of(context).primaryColor.withAlpha(200),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ItemOrdersRoute(
                                      data: data[index].data,
                                      imageUrls: List<String>.from(
                                        itemSnapshot.data['images'],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  color: Colors.black,
                                  child: FadeInImage.assetNetwork(
                                    placeholder: 'assets/images/logo.png',
                                    image: itemSnapshot.data['images'][0],
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  // color: Colors.pink,
                                  child: Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      // mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          itemSnapshot.data['itemName'],
                                          style: textTheme.title.copyWith(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        // SizedBox(
                                        //   height: 2,
                                        // ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              'Total Orders: ',
                                              style: textTheme.subhead.copyWith(
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              '$numberOfOrders',
                                              style:
                                                  textTheme.subtitle.copyWith(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: <Widget>[
                                              Text(
                                                'Price: ',
                                                strutStyle:
                                                    StrutStyle(height: 1),
                                                style: textTheme.title.copyWith(
                                                    // fontWeight: FontWeight.bold,
                                                    ),
                                              ),
                                              Text(
                                                '${itemSnapshot.data['price']}  ',
                                                style: textTheme.title.copyWith(
                                                    // fontSize: 18,
                                                    ),
                                                strutStyle:
                                                    StrutStyle(height: 1.5),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ListTile(
                          //   contentPadding: EdgeInsets.all(0),
                          //   leading: Container(
                          //     height: 1000,
                          //     color: Colors.black,
                          //     child: FadeInImage.assetNetwork(
                          //       placeholder: 'assets/images/logo.png',
                          //       image: itemSnapshot.data['images'][0],
                          //       width: 80,
                          //       fit: BoxFit.fitWidth,
                          //     ),
                          //   ),
                          //   title: Text(itemSnapshot.data['itemName']),
                          //   subtitle: Container(
                          //     child: Column(
                          //       mainAxisSize: MainAxisSize.min,
                          //       children: [
                          //         Row(
                          //           mainAxisSize: MainAxisSize.min,
                          //           children: <Widget>[
                          //             Text(
                          //               'Total Orders',
                          //               style: textTheme.subhead,
                          //             ),
                          //             Text('$numberOfOrders'),
                          //           ],
                          //         ),
                          //         SizedBox(
                          //           height: 10,
                          //         ),
                          //         Row(
                          //           mainAxisSize: MainAxisSize.min,
                          //           mainAxisAlignment: MainAxisAlignment.end,
                          //           children: <Widget>[
                          //             Text(
                          //               'Price: ',
                          //               style: textTheme.subhead,
                          //             ),
                          //             Text('${itemSnapshot.data['price']}'),
                          //           ],
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          //   trailing: Icon(Icons.navigate_next),
                          //   onTap: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) {
                          //           return ItemOrdersRoute(
                          //             data: data[index].data,
                          //             imageUrls: List<String>.from(
                          //               itemSnapshot.data['images'],
                          //             ),
                          //           );
                          //         },
                          //       ),
                          //     );
                          //   },
                          // ),
                        ),
                      );
                    },
                  );
                });
          },
        ),
      ),
    );
  }
}

class ItemOrdersRoute extends StatelessWidget {
  final Map<String, dynamic> data;
  final List<String> imageUrls;
  const ItemOrdersRoute({Key key, this.data, this.imageUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    final keys = data.keys.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          // SizedBox(
          //   height: 10,
          // ),
          Container(
            height: 200,
            // margin: EdgeInsets.all(10),
            // color: Colors.white,
            width: MediaQuery.of(context).size.width,
            child: CarouselSlider(
              autoPlay: true,
              height: 200,
              enlargeCenterPage: true,
              // borderRadius: false,
              // showIndicator: false,
              // boxFit: BoxFit.contain,
              items: List.generate(
                imageUrls.length,
                (index) {
                  return FadeInImage.assetNetwork(
                    placeholder: 'assets/images/logo.png',
                    image: imageUrls[index],
                    height: 250,
                    // width: MediaQuery.of(context).size.width-80,
                    fit: BoxFit.contain,
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  keys.length,
                  (index) {
                    return Column(
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        Card(
                          elevation: 8,
                          child: ListTile(
                            isThreeLine: true,
                            // contentPadding: EdgeInsets.all(4),
                            leading: Icon(
                              Icons.shopping_basket,
                              color: Theme.of(context).primaryColor,
                              size: 40,
                            ),
                            // title: Text('Order'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      'ID: ',
                                      style: textTheme.subhead
                                          .copyWith(fontSize: 16),
                                    ),
                                    Text(
                                      keys[index],
                                      style: textTheme.subtitle
                                          .copyWith(fontSize: 14),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      'Date Ordered: ',
                                      style: textTheme.subhead
                                          .copyWith(fontSize: 16),
                                    ),
                                    Text(
                                      DateFormat.yMMMd().format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          data[keys[index]]['dateOrdered'],
                                        ),
                                      ),
                                      style: textTheme.subtitle
                                          .copyWith(fontSize: 14),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      'Date Delivered: ',
                                      style: textTheme.subhead
                                          .copyWith(fontSize: 16),
                                    ),
                                    Text(
                                      DateFormat.yMMMd().format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          data[keys[index]]['dateDelivered'],
                                        ),
                                      ),
                                      style: textTheme.subtitle
                                          .copyWith(fontSize: 14),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      'Quantity: ',
                                      style: textTheme.subhead
                                          .copyWith(fontSize: 16),
                                    ),
                                    Text(
                                      '${data[keys[index]]['quantity']}',
                                      style: textTheme.subtitle
                                          .copyWith(fontSize: 14),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  // mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Delivered To: ',
                                      style: textTheme.subhead
                                          .copyWith(fontSize: 16),
                                    ),
                                    Expanded(
                                      child: Text(
                                        data[keys[index]]['deliveredTo'],
                                        style: textTheme.subtitle
                                            .copyWith(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        'Price: ',
                                        style: textTheme.title.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${data[keys[index]]['price']} per Item',
                                        style: textTheme.subtitle
                                            .copyWith(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
    //     CustomScrollView(
    //   slivers: <Widget>[
    //     SliverAppBar(
    //       // forceElevated: true,
    //       expandedHeight: 200,
    //       title: Text('Details'),
    //       flexibleSpace: Container(
    //         height: 600,
    //         foregroundDecoration: BoxDecoration(
    //           gradient: LinearGradient(
    //             colors: [
    //               Colors.white,
    //               Colors.white38,
    //               Colors.white10,
    //               Colors.transparent,
    //               Colors.transparent
    //             ],
    //             stops: [0, 0.4, 0.6, 0.8, 1],
    //             begin: Alignment.topCenter,
    //             end: Alignment.bottomCenter,
    //           ),
    //         ),
    //         child: FadeInImage.assetNetwork(
    //           placeholder: 'assets/images/logo.png',
    //           image: '${imageUrls[0]}',
    //           height: 800,
    //           fit: BoxFit.fitHeight,
    //         ),
    //       ),
    //       centerTitle: true,
    //       snap: true,
    //       floating: true,
    //       backgroundColor: Colors.white,
    //       elevation: 8,
    //     ),
    //     SliverList(
    //       delegate: SliverChildListDelegate(

    //       ),
    //     ),
    //   ],
    // ));
  }
}
