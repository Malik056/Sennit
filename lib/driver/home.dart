import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sennit/driver/active_order.dart';

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
    controller = TabController(length: 2, vsync: this);
    controller.addListener(() {
      setState(() {
        index = controller.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            controller.index == 0 ? 'Notifications' : 'History',
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
            ],
          ),
        ),
        body: TabBarView(
          controller: controller,
          children: <Widget>[
            _NotificationPage(),
            _HistoryPage(),
          ],
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
    return SingleChildScrollView(
      child: Column(
        children: [
          DeliveryTile(),
          DeliveryTile(),
          DeliveryTile(),
          DeliveryTile(),
          DeliveryTile(),
          DeliveryTile(),
          DeliveryTile(),
          DeliveryTile(),
        ],
      ),
    );
  }
}

class DeliveryTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pick Up Available',
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.subhead,
              ),
              Text.rich(
                TextSpan(
                  text: 'Pick Location: ',
                  style: Theme.of(context).textTheme.subtitle,
                  children: [
                    TextSpan(
                        text: 'Building, Street 1, City',
                        style: Theme.of(context).textTheme.body1),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: 'Coordinates: ',
                  style: Theme.of(context).textTheme.subtitle,
                  children: [
                    TextSpan(
                        text: '80.009203, 99.223134',
                        style: Theme.of(context).textTheme.body1),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: 'Drop Location: ',
                  style: Theme.of(context).textTheme.subtitle,
                  children: [
                    TextSpan(
                        text: 'Building, Street 1, City',
                        style: Theme.of(context).textTheme.body1),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: 'Coordinates: ',
                  style: Theme.of(context).textTheme.subtitle,
                  children: [
                    TextSpan(
                        text: '80.009203, 99.223134',
                        style: Theme.of(context).textTheme.body1),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: 'Number of Boxes: ',
                  style: Theme.of(context).textTheme.subtitle,
                  children: [
                    TextSpan(
                      text: '4',
                      style: Theme.of(context).textTheme.body1,
                    ),
                    TextSpan(
                      text: '\    Boxes\'s Size: ',
                      style: Theme.of(context).textTheme.subtitle,
                      children: [
                        TextSpan(
                          text: 'Medium',
                          style: Theme.of(context).textTheme.body1,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: 'Sleeves Required: ',
                  style: Theme.of(context).textTheme.subtitle,
                  children: [
                    TextSpan(
                        text: 'Yes', style: Theme.of(context).textTheme.body1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        final page = ActiveOrder();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return page;
            },
          ),
        );
      },
    );
  }
}
