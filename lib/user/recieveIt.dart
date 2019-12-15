import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:place_picker/place_picker.dart';
import 'package:sennit/user/sendit.dart';

import '../main.dart';

class StoresRoute extends StatefulWidget {
  final Address address;
  StoresRoute({@required this.address});

  @override
  State<StatefulWidget> createState() {
    return StoresRouteState(address);
  }
}

class StoresRouteState extends State<StoresRoute> {
  Address selectedAddress;
  StoresRouteState(this.selectedAddress);

  @override
  void initState() {
    super.initState();
  }

  void appBarTap() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return AddressAddingRoute(SourcePage.recieveIt, selectedAddress);
    })).then((value) {
      setState(() {
        selectedAddress = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stores'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Tooltip(
              child: Icon(Icons.settings),
              message: 'Delivery Settigns',
            ),
            onPressed: appBarTap,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            title: Text('Home'),
            icon: Icon(
              Icons.store,
              color: Colors.black54,
            ),
            activeIcon: Icon(
              Icons.store,
              color: Theme.of(context).accentColor,
            ),
          ),
          BottomNavigationBarItem(
            title: Text('Search'),
            icon: Icon(
              Icons.search,
              color: Colors.black54,
            ),
            activeIcon: Icon(
              Icons.search,
              color: Theme.of(context).accentColor,
            ),
          ),
          BottomNavigationBarItem(
            title: Text('Past Orders'),
            icon: Icon(
              Icons.bookmark,
              color: Colors.black54,
            ),
            activeIcon: Icon(
              Icons.bookmark,
              color: Theme.of(context).accentColor,
            ),
          ),
          BottomNavigationBarItem(
            title: Text('Notifications'),
            icon: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications,
                  color: Colors.black54,
                ),
                Positioned(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                        gradient: RadialGradient(radius: 0.5, colors: [
                          Color.fromARGB(255, 0xff, 0x88, 0x88),
                          Colors.redAccent
                        ]),
                      ),
                    ),
                    top: 0,
                    right: 1),
              ],
            ),
            activeIcon: Icon(
              Icons.notifications,
              color: Theme.of(context).accentColor,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.shopping_cart,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShoppingCartRoute(null),
              ));
        },
        backgroundColor: Theme.of(context).accentColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            InkWell(
                child: StoreItem(
                  dummyPic: true,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return StoreMainPage();
                      },
                    ),
                  );
                }),
            SizedBox(
              height: 10,
            ),
            StoreItem(),
            SizedBox(
              height: 10,
            ),
            StoreItem(),
            SizedBox(
              height: 10,
            ),
            StoreItem(),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class StoreItem extends StatelessWidget {
  final bool dummyPic;
  StoreItem({this.dummyPic = false});
  final images = [
    'body_cream.jpeg',
    'body_lotion.jpg',
    'body_wash.jpeg',
    'glcerin_soaps.jpeg',
    'lip_butter.jpeg',
  ];
  final names = [
    'Body Cream',
    'Body Lotion',
    'Body Wash',
    'Glycerin Soaps',
    'Lip Butter'
  ];
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Stack(
            children: <Widget>[
              dummyPic
                  ? Image.asset('assets/images/cocologo.jpeg')
                  : Image.network(
                      'https://picsum.photos/500',
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                      fit: BoxFit.fitWidth,
                    ),
              Positioned(
                top: 0,
                child: Container(
                  padding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
                  decoration: BoxDecoration(
                    // Box decoration takes a gradient
                    gradient: LinearGradient(
                      // Where the linear gradient begins and ends
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      // Add one stop for each color. Stops should increase from 0 to 1
                      stops: [0, 0.8, 1],
                      colors: [
                        // Colors are easy thanks to Flutter's Colors class.
                        Colors.white,
                        Colors.white24,
                        Color.fromARGB(0, 255, 255, 255),
                      ],
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dummyPic ? "Coco" : 'McDonalds',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'BebasNeue',
                        ),
                      ),
                      Text(
                        dummyPic ? '' : "I'm Lovin it",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          Container(
            padding: EdgeInsets.only(bottom: 2, top: 10),
            height: 100,
            child: ListView.builder(
              padding: EdgeInsets.only(right: 20),
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              itemBuilder: (context, index) {
                return Card(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        index < 5
                            ? Image.asset('assets/images/${images[index % 5]}')
                            : Image.network(
                                'https://picsum.photos/500',
                                height: 100,
                                fit: BoxFit.fitHeight,
                              ),
                        SizedBox(
                          width: 8,
                        ),
                        ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: 100, minWidth: 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                index < 5
                                    ? '${names[index % 5]}'
                                    : 'Item $index',
                                style: Theme.of(context).textTheme.subhead,
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                index < 5 ? 'R45' : 'R${40 * index}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(fontSize: 20),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Click to View',
                style: TextStyle(fontSize: 15),
              ),
              Icon(Icons.navigate_next),
            ],
          ),
        ],
      ),
    );
  }
}

class StoreMainPage extends StatelessWidget {
  final int index;

  StoreMainPage({this.index = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrooled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 250,
              floating: true,
              pinned: true,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  return FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    centerTitle: true,
                    title: Text(
                      index == 0 ? "Coco" : "McDonald's",
                      style: Theme.of(context).textTheme.title,
                    ),
                    background: Stack(
                      children: [
                        index == 0
                            ? Image.asset("assets/images/cocologo.jpeg")
                            : Image.network(
                                "https://images.pexels.com/photos/396547/pexels-photo-396547.jpeg?auto=compress&cs=tinysrgb&h=350",
                                fit: BoxFit.cover,
                              ),
                        Container(
                          decoration: BoxDecoration(
                            // Box decoration takes a gradient
                            gradient: LinearGradient(
                              // Where the linear gradient begins and ends
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              // Add one stop for each color. Stops should increase from 0 to 1
                              stops: [0, 0.2, 1],
                              colors: [
                                // Colors are easy thanks to Flutter's Colors class.
                                Color.fromARGB(0, 255, 255, 255),
                                Colors.white24,
                                Colors.white,
                              ],
                            ),
                          ),
                          width: constraints.biggest.width,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          child: StoreMenu(),
        ),
      ),
    );
  }
}

class StoreMenu extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StoreMenuState();
  }
}

class StoreMenuState extends State<StoreMenu> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 20),
                height: 1,
                color: Color.fromARGB(128, 128, 128, 128),
              ),
            ),
            Text(
              '  MENU  ',
              style: TextStyle(
                fontSize: 24,
                color: Color.fromARGB(128, 128, 128, 128),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(right: 20),
                height: 1,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        MenuCategorize(),
      ],
    );
  }
}

class MenuCategorize extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          child: MenuItem(
            name: 'Body Cream',
            image: 'assets/images/body_cream.jpeg',
            storeItem: true,
            price: 'R45',
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return ItemDetailsRoute(
                    name: 'Body Cream',
                    image: 'assets/images/body_cream.jpeg',
                    price: 'R45',
                  );
                },
              ),
            );
          },
        ),
        InkWell(
          child: MenuItem(
            name: 'Body Lotion',
            image: 'assets/images/body_lotion.jpg',
            storeItem: true,
            price: 'R80',
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return ItemDetailsRoute(
                    name: 'Body Lotion',
                    image: 'assets/images/body_lotion.jpg',
                    price: 'R80',
                  );
                },
              ),
            );
          },
        ),
        InkWell(
          child: MenuItem(
            name: 'Body Wash',
            image: 'assets/images/body_wash.jpeg',
            storeItem: true,
            price: 'R80',
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return ItemDetailsRoute(
                    name: 'Body Wash',
                    image: 'assets/images/body_wash.jpeg',
                    price: 'R80',
                  );
                },
              ),
            );
          },
        ),
        InkWell(
          child: MenuItem(
            name: 'Glycerin Soap',
            image: 'assets/images/glcerin_soaps.jpeg',
            storeItem: true,
            price: 'R40',
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return ItemDetailsRoute(
                    name: 'Glycerin Soap',
                    image: 'assets/images/glcerin_soaps.jpeg',
                    price: 'R40',
                  );
                },
              ),
            );
          },
        ),
        InkWell(
          child: MenuItem(
            name: 'Lip Butter',
            image: 'assets/images/lip_butter.jpeg',
            storeItem: true,
            price: 'R45',
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return ItemDetailsRoute(
                    name: 'Lip Butter',
                    image: 'assets/images/lip_butter.jpeg',
                    price: 'R45',
                  );
                },
              ),
            );
          },
        ),
        MenuItem(
          price: 'R20',
        ),
        MenuItem(
          price: 'R203',
        ),
        MenuItem(
          price: 'R80',
        ),
        MenuItem(
          price: 'R80',
        ),
        MenuItem(
          price: 'R80',
        ),
        MenuItem(
          price: 'R80',
        ),
        MenuItem(
          price: 'R80',
        ),
        MenuItem(
          price: 'R80',
        ),
      ],
    );
  }
}

class MenuItem extends StatelessWidget {
  final String name;
  final String image;
  final String price;
  final bool storeItem;
  MenuItem({
    this.name = "Store Item",
    this.image = 'https://picsum.photos/500',
    this.storeItem = false,
    @required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            !storeItem
                ? Image.network(
                    image,
                    height: 100,
                    fit: BoxFit.fitHeight,
                  )
                : Image.asset(
                    image,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    'This Items is very expensive order it now. Lorem Ipsum gypsum kripson dipson frispon',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              child: Container(),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.only(right: 5),
                child: Tooltip(
                  message: price,
                  child: AutoSizeText(
                    '$price',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemDetailsRoute extends StatelessWidget {
  final String image;
  final String name;
  final bool network;
  final String price;

  const ItemDetailsRoute(
      {Key key,
      this.image,
      this.name,
      @required this.price,
      this.network = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      bottomSheet: BottomSheet(
        elevation: 40,
        onClosing: () {},
        builder: (conext) {
          return Padding(
            padding: EdgeInsets.all(0),
            child: InkWell(
              child: Container(
                padding: EdgeInsets.all(10),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: Text(
                  'Add to Cart',
                  style: Theme.of(context).textTheme.subhead,
                ),
              ),
              onTap: () {},
            ),
          );
        },
      ),
      // persistentFooterButtons: <Widget>[
      //   Container(
      //     width: MediaQuery.of(context).size.width,
      //     child: FlatButton(
      //       child: Text(
      //         'Add to Cart',
      //         style: Theme.of(context).textTheme.subhead,
      //       ),
      //       onPressed: () {},
      //     ),
      //   ),
      // ],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(MyApp.reviewWidget);
        },
        child: Icon(Icons.rate_review),
        tooltip: "Write a review",
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: _ItemDetailsBody(
        image: image,
        name: name,
        network: network,
        price: price,
      ),
    );
  }
}

class _ItemDetailsBody extends StatefulWidget {
  // final ItemDetails itemDetails;
  final String image;
  final String name;
  final bool network;
  final String price;

  _ItemDetailsBody({this.image, this.name, this.network, this.price});
  @override
  State<StatefulWidget> createState() {
    return _ItemDetailsBodyState();
  }

  Widget _getProgressBar() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
  Future<ItemDetails> getItemDetails(int itemId) async {
    // await Future.delayed(Duration(seconds: 3));
    return ItemDetails(
        itemId: 0,
        description: "this is the Item",
        itemName: name,
        picUrl: image,
        price: price,
        specifications: {"weight": "500 g"},
        reviews: []);
  }
}

class _ItemDetailsBodyState extends State<_ItemDetailsBody>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  var autoplay = true;
  _ItemDetailsBodyState() {
    _tabController = TabController(vsync: this, length: 3);
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: NestedScrollView(
        headerSliverBuilder: (context, constriant) {
          return [
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 250,
              flexibleSpace: FlexibleSpaceBar(
                background: GestureDetector(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CarouselSlider(
                        autoPlay: autoplay,
                        initialPage: 0,
                        scrollDirection: Axis.horizontal,
                        // viewportFraction: 1.0,
                        enlargeCenterPage: true,
                        height: 250.0,
                        items: [1, 2, 3, 4, 5].map(
                          (i) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(widget.image),
                                          fit: BoxFit.fitHeight)),
                                );
                              },
                            );
                          },
                        ).toList(),
                      ),
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  stops: [0, 0.6, 1],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.white10,
                                    Colors.white,
                                  ])),
                        ),
                        onTapDown: (details) {
                          autoplay = false;
                          setState(() {});
                          print('overlay Clicked');
                        },
                        onTapUp: (details) {
                          autoplay = true;
                          setState(() {});
                        },
                        onTapCancel: () {
                          autoplay = true;
                          setState(() {});
                        },
                        onHorizontalDragStart: (details) {},
                      ),
                    ],
                  ),
                  onTap: () {
                    print('tap detected');
                  },
                  onVerticalDragStart: (aa) {
                    print('Vertical Drag started');
                  },
                ),
                title: Text(
                  widget.name,
                  style: Theme.of(context).textTheme.title,
                ),
                centerTitle: true,
                collapseMode: CollapseMode.pin,
              ),
              // bottom: TabBar(
              //     controller: _tabController,
              //     labelColor: Theme.of(context).accentColor,
              //     indicatorColor: Theme.of(context).accentColor,
              //     unselectedLabelColor: Colors.black,
              //     tabs: _getTabs()),
            ),
          ];
        },
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                alignment: Alignment.center,
                color: Color.fromARGB(255, 0xfa, 0xfa, 0xfa),
              ),
            ),
            Column(
              children: [
                Container(
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Theme.of(context).accentColor,
                      indicatorColor: Theme.of(context).accentColor,
                      // indicatorPadding: EdgeInsets.only(top: 80),
                      unselectedLabelColor: Colors.black,
                      tabs: _getTabs(),
                    ),
                    color: Colors.white),
                SizedBox(
                  height: 10,
                ),
                // Row(
                //   // mainAxisSize: MainAxisSize.min,
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: <Widget>[
                //     Icon(
                //       Icons.thumb_up,
                //       size: 14,
                //     ),
                //     SizedBox(
                //       width: 5,
                //     ),
                //     Text(
                //       '1234',
                //       style: TextStyle(fontSize: 12),
                //     ),
                //     SizedBox(
                //       width: 20,
                //     ),
                //     Container(
                //       width: 1,
                //       color: Colors.black,
                //       child: Text(''),
                //     ),
                //     SizedBox(
                //       width: 20,
                //     ),
                //     Icon(Icons.thumb_down, size: 12,),
                //     SizedBox(
                //       width: 5,
                //     ),
                //     Text(
                //       '1234',
                //       style: TextStyle(fontSize: 12),
                //     )
                //   ],
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   mainAxisSize: MainAxisSize.max,
                //   children: <Widget>[
                //     Spacer(),
                //     // Center(
                //     //   child:
                //     Column(
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         IconButton(
                //           icon: Icon(
                //             Icons.thumb_up,
                //             size: 18,
                //           ),
                //           onPressed: () {},
                //         ),
                //         Text('1034'),
                //       ],
                //       // ),
                //     ),
                //     SizedBox(
                //       width: 20,
                //     ),
                //     // Spacer(),
                //     // Center(
                //     //   child:
                //     Column(
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         IconButton(
                //           icon: Icon(
                //             Icons.thumb_down,
                //             size: 18,
                //           ),
                //           onPressed: () {},
                //         ),
                //         Text('1034'),
                //       ],
                //     ),
                //     // ),
                //     Spacer(
                //       flex: 8,
                //     ),
                //   ],
                // ),
                Expanded(
                  flex: 8,
                  child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                'Price: ${widget.price}',
                                style: Theme.of(context).textTheme.title,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              "Lorem ipsum ipsum lorem gypsum pipsum. Lorem Ipsum pipsum Gibson priston fiston. Ipsum Lorem is pist fist wrist.",
                              style: Theme.of(context).textTheme.body1,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                      FutureBuilder(
                          initialData: null,
                          future: widget.getItemDetails(0),
                          builder: (context, asyncData) {
                            if (asyncData.data == null) {
                              return widget._getProgressBar();
                            } else {
                              if (asyncData.connectionState ==
                                  ConnectionState.done) {
                                return SingleChildScrollView(
                                  child: Column(
                                    children: _getAllSpecifications(),
                                  ),
                                );
                              } else {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.replay),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      Text('Unable to Load Data'),
                                    ],
                                  ),
                                );
                              }
                            }
                          }),
                      FutureBuilder(
                          initialData: null,
                          future: widget.getItemDetails(0),
                          builder: (context, asyncData) {
                            if (asyncData.data == null) {
                              return widget._getProgressBar();
                            } else {
                              if (asyncData.connectionState ==
                                  ConnectionState.done) {
                                return _getReviews();
                              } else {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(Icons.replay),
                                        onPressed: () {
                                          setState(() {});
                                        },
                                      ),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      Text('Unable to Load Data'),
                                    ],
                                  ),
                                );
                              }
                            }
                          }),
                    ],
                  ),
                ),
                // FloatingActionButton(
                //   child: Tooltip(
                //     child: Icon(Icons.rate_review),
                //     message: 'Leave a review',
                //   ),
                //   onPressed: () {

                //   },
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getAllSpecifications() {
    return [
      SizedBox(
        height: 20,
      ),
      Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Text(
            'Spec1: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: Container(
              // color: Colors.pink,
              child: Text(
                'Value of Spec 1',
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ],
      ),
      SizedBox(
        height: 10,
      ),
      Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Text(
            'Spec1: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: Container(
              // color: Colors.pink,
              child: Text(
                'Value of Spec 1',
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ],
      ),
      SizedBox(
        height: 10,
      ),
      Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Text(
            'Spec1: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: Container(
              // color: Colors.pink,
              child: Text(
                'Value of Spec 1',
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ],
      ),
      SizedBox(
        height: 10,
      ),
      Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Text(
            'Spec1: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: Container(
              // color: Colors.pink,
              child: Text(
                'Value of Spec 1',
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ],
      ),
      SizedBox(
        height: 10,
      ),
    ];
  }

  List<Tab> _getTabs() {
    return <Tab>[
      Tab(
        text: 'Description',
      ),
      Tab(
        text: 'Specification',
      ),
      Tab(
        text: 'Reviews',
      ),
    ];
  }

  Widget _getReviews() {
    List<Widget> reviews = List();
    for (var i = 0; i < 10; i++) {
      Widget review2 = Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 8,
            right: 8,
            top: 16,
            bottom: 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(right: 4),
                  // decoration: ShapeDecoration(
                  //   shape: Border(
                  //     right: BorderSide(width: 1, color: Colors.black),
                  //   ),
                  // ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Some User $i',
                        style: Theme.of(context).textTheme.subhead,
                      ),
                      // mainAxisSize: MainAxisSize.max,
                      Text(
                          'This is some medium lenght review. I want it to check how app looks.\n'),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 12,
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                width: 1,
                height: 80,
                color: Colors.black,
              ),
              SizedBox(
                width: 12,
              ),
              Column(
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
              SizedBox(
                width: 8,
              ),
            ],
          ),
        ),
      );
      Widget review = Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 8,
            right: 8,
            top: 16,
            bottom: 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(right: 4),
                  // decoration: ShapeDecoration(
                  //   shape: Border(
                  //     right: BorderSide(width: 1, color: Colors.black),
                  //   ),
                  // ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Some User $i',
                        style: Theme.of(context).textTheme.subhead,
                      ),
                      // mainAxisSize: MainAxisSize.max,
                      Text(
                          'This is some medium lenght review. I want it to check how app looks. This is some medium lenght review. I want it to check how app looks. This is some medium lenght review. I want it to check how app looks.\n'),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 12,
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                width: 1,
                height: 80,
                color: Colors.black,
              ),
              SizedBox(
                width: 12,
              ),
              Column(
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
              SizedBox(
                width: 8,
              ),
            ],
          ),
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
        );
      // ..add(review1);
    }
    return ListView(
      children: reviews,
    );
  }

  // Widget _getReviews() {
  //   return ListView(
  //     children: <Widget>[
  //       ListTile(
  //         leading: Icon(
  //           Icons.person,
  //           size: 40,
  //         ),
  //         title: Text('person 1'),
  //         subtitle: Text('This item is great'),
  //       ),
  //       ListTile(
  //         leading: Icon(
  //           Icons.person,
  //           size: 40,
  //         ),
  //         title: Text('person 1'),
  //         subtitle: Text('This item is great'),
  //       ),
  //       ListTile(
  //         leading: Icon(
  //           Icons.person,
  //           size: 40,
  //         ),
  //         title: Text('person 1'),
  //         subtitle: Text('This item is great'),
  //       ),
  //       ListTile(
  //         leading: Icon(
  //           Icons.person,
  //           size: 40,
  //         ),
  //         title: Text('person 1'),
  //         subtitle: Text('This item is great'),
  //       ),
  //       ListTile(
  //         leading: Icon(
  //           Icons.person,
  //           size: 40,
  //         ),
  //         title: Text('person 1'),
  //         subtitle: Text('This item is great'),
  //       ),
  //       ListTile(
  //         leading: Icon(
  //           Icons.person,
  //           size: 40,
  //         ),
  //         title: Text('person 1'),
  //         subtitle: Text('This item is great'),
  //       ),
  //     ],
  //   );
  // }
}

class ShoppingCartRoute extends StatelessWidget {
  // static Address _fromAddress;
  static Address _toAddress;

  ShoppingCartRoute(toAddress) {
    // _fromAddress = fromAddress;
    _toAddress = toAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          FlatButton(
            onPressed: () {},
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
      body: ShoppingCartRouteBody(),
      // backgroundColor: Theme.of(context).accentColor,
    );
  }
}

class ShoppingCartRouteBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ShoppingCartRouteState();
  }
}

class ShoppingCartRouteState extends State<ShoppingCartRouteBody> {
  bool pickFromDoor = true;
  bool deliverToDoor = true;
  double cardMargin = 10;
  double cardPadding = 20;
  double groupMargin = 30;
  double itemMargin = 10;

  bool boxSizeSmall = true;
  bool boxSizeMedium = false;
  bool boxSizeLarge = false;
  bool sleeveNeeded = false;

  ShoppingCartRouteState();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            // margin: EdgeInsets.only(
            //   top: groupMargin,
            // ), //, left: cardMargin, right: cardMargin),
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
                        setState(() async {
                          Coordinates coordinates = Coordinates(
                              result.latLng.latitude, result.latLng.longitude);
                          ShoppingCartRoute._toAddress = (await Geocoder.local
                              .findAddressesFromCoordinates(coordinates))[0];
                        });
                      }
                    },
                    leading: Icon(
                      Icons.location_on,
                      color: Theme.of(context).accentColor,
                    ),
                    title: Text(
                      ShoppingCartRoute._toAddress != null
                          ? ShoppingCartRoute._toAddress.addressLine
                          : 'Address Not Set',
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
                        ),
                        TextField(
                          decoration: InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
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
          _getCartItems(),
          Card(
            margin: EdgeInsets.only(
                top: 10), //, left: cardMargin, right: cardMargin),
            elevation: 5,
            child: Container(
              padding: EdgeInsets.only(top: cardPadding),
              child: Column(
                children: <Widget>[
                  Row(
                    children: [
                      Text(
                        '    Payment Method',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.cashRegister,
                      color: Theme.of(context).accentColor,
                    ),
                    title: Text('Cash'),
                    trailing: Icon(
                      Icons.radio_button_checked,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.credit_card,
                    ),
                    title: Text(
                      'Selct payment method',
                    ),
                    trailing: Icon(Icons.navigate_next),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  var count = [0, 0, 0, 0];

  _getCartItems() {
    return Card(
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
                'Items In Cart',
                style: Theme.of(context).textTheme.headline,
              ),
            ),
            getCartItem(0),
            getCartItem(1),
            getCartItem(2),
            getCartItem(3),
          ],
        ),
      ),
    );
  }

  getCartItem(var index, {imageUrl, name, description, quantity}) {
    return Card(
      child: Row(
        children: [
          Expanded(
            child: Image.asset('assets/images/cocologo.jpeg'),
            flex: 3,
          ),
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Item',
                  style: Theme.of(context).textTheme.title,
                ),
                Text(
                  'Lorem ipsum gypsum gibson dipson fispon Lorem ipsum gypsum gibson dipson fispon Lorem ipsum gypsum gibson dipson fispon Lorem ipsum gypsum gibson dipson fispon Lorem ipsum gypsum gibson dipson fispon Lorem ipsum gypsum gibson dipson fispon Lorem ipsum gypsum gibson dipson fispon ',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: <Widget>[
                    InkWell(
                      child: Text(
                        ' - ',
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontStyle: FontStyle.normal,
                            fontSize: 28,
                            fontFamily: "Roboto"),
                      ),
                      onTap: () {
                        if (count[index] == 99) {
                          return;
                        }
                        count[index]--;
                        setState(() {});
                      },
                    ),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(2),
                          WhitelistingTextInputFormatter.digitsOnly,
                          BlacklistingTextInputFormatter.singleLineFormatter,
                          BlacklistingTextInputFormatter(RegExp(r'\n|-|.')),
                        ],
                      ),
                    ),
                    InkWell(
                      child: Text(
                        ' +',
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontStyle: FontStyle.normal,
                            fontSize: 20,
                            fontFamily: "Roboto"),
                      ),
                      onTap: () {
                        if (count[index] == 99) {
                          return;
                        }
                        count[index]++;
                        setState(() {});
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  // alignment: Alignment.bottomRight,
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Price R45',
                    style: Theme.of(context).textTheme.subhead,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    // Container(
    //     width: MediaQuery.of(context).size.width,
    //     child: Row(
    //       children: <Widget>[
    //         Expanded(
    //           child: Column(
    //             children: <Widget>[
    //               Row(
    //                 children: <Widget>[
    //                   Expanded(
    //                     child: ListTile(
    //                       title: Text('Item'),
    //                       subtitle: Text(
    //                         'Lorem ipsum gypsum gibson dipson fispon Lorem ipsum gypsum gibson dipson fispon Lorem ipsum gypsum gibson dipson fispon Lorem ipsum gypsum gibson dipson fispon Lorem ipsum gypsum gibson dipson fispon Lorem ipsum gypsum gibson dipson fispon Lorem ipsum gypsum gibson dipson fispon ',
    //                         maxLines: 3,
    //                         overflow: TextOverflow.ellipsis,
    //                       ),
    //                       trailing: Row(
    //                         mainAxisSize: MainAxisSize.min,
    //                         children: <Widget>[
    //                           FlatButton(
    //                             child: Text('-'),
    //                             onPressed: () {
    //                               if (count[index] == 99) {
    //                                 return;
    //                               }
    //                               count[index]--;
    //                               setState(() {});
    //                             },
    //                           ),
    //                           FocusScope(
    //                             autofocus: false,
    //                             onFocusChange: (focused) {
    //                               if (!focused) {
    //                                 if (count[index] == 0) {
    //                                   count[index] = 1;
    //                                   setState(() {});
    //                                 }
    //                               }
    //                             },
    //                             child: SizedBox(
    //                               width: 20,
    //                               child: TextField(
    //                                 keyboardType: TextInputType.number,
    //                                 inputFormatters: <TextInputFormatter>[
    //                                   LengthLimitingTextInputFormatter(2),
    //                                   WhitelistingTextInputFormatter.digitsOnly,
    //                                   BlacklistingTextInputFormatter
    //                                       .singleLineFormatter,
    //                                   BlacklistingTextInputFormatter(
    //                                       RegExp(r'\n|-|.')),
    //                                 ],
    //                               ),
    //                             ),
    //                           ),
    //                           FlatButton(
    //                             child: Text('+'),
    //                             onPressed: () {
    //                               if (count[index] == 99) {
    //                                 return;
    //                               }
    //                               count[index]++;
    //                               setState(() {});
    //                             },
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               Align(
    //                 alignment: Alignment.bottomRight,
    //                 child: Text(
    //                   'Price R45',
    //                   style: Theme.of(context).textTheme.subhead,
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ],
    //     ));
  }
}
