import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sennit/driver/active_order.dart';
import 'package:sennit/main.dart';
import 'package:sennit/models/models.dart';
import 'package:sennit/user/recieveIt.dart' as receiveIt;

class Delivery {
  final LatLng pickUp;
  final LatLng dropOff;
  final String customerName;
  final String driverName;
  final double cost;

  Delivery({
    this.pickUp,
    this.dropOff,
    this.customerName,
    this.driverName,
    this.cost,
  });
}

class HomeScreenDriver extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreenDriver>
    with TickerProviderStateMixin {
  TabController controller;
  int index = 0;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    controller.addListener(() {
      setState(() {
        index = controller.index;
      });
    });
  }

  static var _willExit = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_willExit) {
          SystemNavigator.pop();
        } else {
          BotToast.showText(text: 'Press Again to Exit');
          _willExit = true;
          Future.delayed(Duration(seconds: 3)).then((value) {
            _willExit = false;
          });
        }
        return false;
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              controller.index == 0
                  ? 'Notifications'
                  : controller.index == 1 ? 'History' : 'Profile',
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            elevation: 10,
            child: TabBar(
              labelColor: Theme.of(context).accentColor,
              indicatorColor: Theme.of(context).accentColor,
              indicator:
                  // BoxDecoration(
                  //   border: Border(
                  //     left: BorderSide(color: Theme.of(context).accentColor, width: 2), // provides to left side
                  //     right: BorderSide(color: Theme.of(context).accentColor, width: 2), // for right side
                  //   ),
                  // ),
                  UnderlineTabIndicator(
                insets: EdgeInsets.only(bottom: 47, left: 20, right: 20),
                borderSide: BorderSide(
                  color: Theme.of(context).accentColor,
                  width: 2,
                ),
              ),
              controller: controller,
              tabs: [
                Tab(
                  icon: Icon(Icons.notifications),
                  // child: Container(
                  //   child: IconButton(
                  //     icon: Center(
                  //       child: Icon(Icons.notifications),
                  //     ),
                  //     onPressed: () {},
                  //   ),
                  //   decoration: BoxDecoration(
                  //     border: Border(
                  //         right: BorderSide(color: Theme.of(context).accentColor)),
                  //   ),
                  // ),
                ),
                Tab(
                  icon: Icon(Icons.history),
                  // child: Container(
                  //   child: IconButton(
                  //     icon: Center(
                  //       child: Icon(Icons.history),
                  //     ),
                  //     onPressed: () {},
                  //   ),
                  //   decoration: BoxDecoration(
                  //     border: Border(
                  //         left: BorderSide(color: Theme.of(context).accentColor)),
                  //   ),
                  // ),
                ),
                Tab(
                  icon: Icon(Icons.person),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: controller,
            children: <Widget>[
              _NotificationPage(),
              _HistoryPage(),
              _ProfilePage(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HistoryPageState();
  }
}

class _HistoryPageState extends State<_HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("I'm History Page"),
    );
  }
}

class _NotificationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NotificationPageState();
  }
}

class _NotificationPageState extends State<_NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("postedOrders").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.replay),
                Text('An Error Occurred'),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data == null) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.replay),
                Text('Unable To Load'),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data.documents.isEmpty) {
          return Center(
            child: Text(
              'No Notifications',
              style: Theme.of(context).textTheme.title,
            ),
          );
        }

        var documents = snapshot.data.documents;

        return SingleChildScrollView(
          child: Column(
              children: List.generate(documents.length, (index) {
            documents[index].data.update("orderId", (value) {
              return documents[index].documentID;
            }, ifAbsent: () {
              return documents[index].documentID;
            });
            if (documents[index].data.containsKey("numberOfBoxes")) {
              return SennitNotificationTile(data: documents[index].data);
            } else {
              return ReceiveItNotificationTile(documents[index].data);
            }
          })),
        );
      },
    );
  }
}

class SennitNotificationTile extends StatelessWidget {
  final Map<String, dynamic> data;
  SennitNotificationTile({this.data});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        child: Container(
          margin: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Sennit',
                style: Theme.of(context).textTheme.display1,
              ),
              SizedBox(
                height: 14.0,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 4.0,
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Order ID',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(
                          height: 6.0,
                        ),
                        Text(
                          data['orderId'],
                          textAlign: TextAlign.start,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Center(
                    child: Container(
                      height: 50,
                      width: 1,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Price',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(
                            height: 6.0,
                          ),
                          Text(
                            "${data['orderPrice']}R",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Center(
                    child: Container(
                      height: 50,
                      width: 1,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '# of Boxes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(
                            height: 6.0,
                          ),
                          Text(
                            '${data['numberOfBoxes']} ${data['boxSize']} Boxes',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                ],
              ),
              SizedBox(
                height: 14.0,
              ),
              Row(
                children: <Widget>[
                  Icon(Icons.location_on),
                  SizedBox(
                    width: 2,
                  ),
                  Expanded(
                    child: Text(
                      data['pickUpAddress'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        elevation: 10,
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return ActiveOrder(
              orderData: data,
            );
          },
        ));
      },
    );
  }
}

class ReceiveItNotificationTile extends StatelessWidget {
  final data;

  ReceiveItNotificationTile(this.data);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        child: Container(
          margin: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Recieve it',
                style: Theme.of(context).textTheme.display1,
              ),
              SizedBox(
                height: 14.0,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 4.0,
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Order ID',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(
                          height: 6.0,
                        ),
                        Text(
                          data['orderId'],
                          textAlign: TextAlign.start,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Center(
                    child: Container(
                      height: 50,
                      width: 1,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Price',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(
                            height: 6.0,
                          ),
                          Text(
                            "${data['price']}R",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Center(
                    child: Container(
                      height: 50,
                      width: 1,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(
                            height: 6.0,
                          ),
                          Text(
                            '${data['pickups'].length} ${data['pickups'].length == 1 ? 'item' : 'items'}',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                ],
              ),
              SizedBox(
                height: 14.0,
              ),
              Row(
                children: <Widget>[
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Icon(Icons.location_on),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0, bottom: 10.0),
                        child: Icon(
                          Icons.location_on,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 10),
                        child: Icon(
                          Icons.location_on,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List<Widget>.generate(
                      data['stores'].length,
                      (index) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(data['stores'][index]),
                            SizedBox(
                              height: 5.0,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Text(
                      data['pickups'][0],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        elevation: 10,
      ),
      onTap: () {
        OrderItemRoute(
          items: data['items'],
        );
      },
    );
  }
}

class OrderItemRoute extends StatelessWidget {
  final List<String> items;
  final Map<String, dynamic> data;
  const OrderItemRoute({Key key, this.items, this.data}) : super(key: key);

  Future<List<StoreItem>> getItems() async {
    List<StoreItem> storeItems = [];
    var documents = await Firestore.instance.collection("items").getDocuments();
    for (DocumentSnapshot snapshot in documents.documents) {
      StoreItem item = StoreItem.fromMap(snapshot.data);
      storeItems.add(item);
    }
    return storeItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Itmes'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<StoreItem>>(
          future: getItems(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (!snapshot.hasData || snapshot.data.length == 0) {
              return Text('No Item Available');
            }
            var items = snapshot.data;
            return SingleChildScrollView(
                child: Column(
              children: List.generate(items.length, (index) {
                return InkWell(
                  child: receiveIt.MenuItem(
                    item: items[index],
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      data.update('storeItems', (a) {
                        return items;
                      }, ifAbsent: () {
                        return items;
                      });
                      return ActiveOrder(
                        orderData: data,
                      );
                    }));
                  },
                );
              }),
            ));
          }),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          CircleAvatar(
            radius: 80,
            backgroundColor: Theme.of(context).primaryColor,
            backgroundImage: NetworkImage(
              'https://picsum.photos/1200',
              // fit: BoxFit.fitWidth,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'My Name',
            style: Theme.of(context).textTheme.subhead,
          ),
          SizedBox(
            height: 6,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Tooltip(
                child: Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: 14,
                ),
                message: "rating",
              ),
              Text(' 4.5'),
              SizedBox(
                width: 10,
              ),
              Container(
                color: Colors.black,
                width: 1,
                child: Text(''),
              ),
              SizedBox(
                width: 10,
              ),
              Tooltip(
                child: Icon(
                  Icons.person,
                  size: 14,
                ),
                message: "rated by users",
              ),
              Text(' 200'),
            ],
          ),
          SizedBox(
            height: 40,
          ),
          Align(
            child: Text(
              'Reviews',
              style: Theme.of(context).textTheme.display1,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Column(
            children: getReviews(),
          ),
        ],
      ),
    );
  }

  List<Widget> getReviews() {
    List<Widget> reviews = List();
    for (var i = 0; i < 10; i++) {
      Widget review = ListTile(
        title: Text('Some User $i'),
        subtitle: Text(
            'This is some Long lenght review. I want it to be long so I can see how it looks. Dont read thi completely as I am just filling up space. blah blah blah blah.........'),
        trailing: Column(
          children: <Widget>[
            Icon(
              Icons.star,
              color: Colors.yellow,
            ),
            SizedBox(
              height: 2,
            ),
            Text('4.2'),
          ],
        ),
      );
      Widget review1 = ListTile(
        title: Text('Some User $i'),
        subtitle: Text('This is a very short lenght review.'),
        trailing: Column(
          children: <Widget>[
            Icon(
              Icons.star,
              color: Colors.yellow,
            ),
            SizedBox(
              height: 2,
            ),
            Text('4.2'),
          ],
        ),
      );
      Widget review2 = ListTile(
        title: Text('Some User $i'),
        subtitle: Text(
            'This is some medium lenght review. I want it to check how app looks.'),
        trailing: Column(
          children: <Widget>[
            Icon(
              Icons.star,
              color: Colors.yellow,
            ),
            SizedBox(
              height: 2,
            ),
            Text('4.2'),
          ],
        ),
      );
      reviews
        ..add(review)
        ..add(
          SizedBox(
            height: 10,
          ),
        )
        ..add(review2)
        ..add(
          SizedBox(
            height: 10,
          ),
        )
        ..add(review1);
    }
    return reviews;
  }
}
