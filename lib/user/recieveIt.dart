import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
// import 'package:place_picker/place_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:rave_flutter/rave_flutter.dart';
import 'package:sennit/models/models.dart' as model;
import 'package:sennit/models/models.dart';
import 'package:sennit/my_widgets/changePassword.dart';
import 'package:sennit/my_widgets/notification.dart';
import 'package:sennit/my_widgets/review.dart';
import 'package:sennit/my_widgets/search.dart';
import 'package:sennit/user/past_orders.dart';
import 'package:sennit/user/signin.dart';
import '../main.dart';
import 'generic_tracking_screen.dart';

class ReceiveItRoute extends StatelessWidget {
  final drawerNameController = TextEditingController();
  static List<Widget> _tabs;
  final bool demo;

  final TabController tabController;

  Future<Null> _authCheck;

  Future<void> initialize() async {
    if (_authCheck != null) {
      await _authCheck;
    }
    await MyApp.futureCart;
  }

  ReceiveItRoute({
    @required this.demo,
    @required this.tabController,
  }) {
    _tabs = [];
    if (MyApp.futureCart == null) {
      FirebaseAuth.instance.currentUser().then((user) {
        UserSignIn.initializeCart(user?.uid);
      });
    }
    if (demo) {
      _authCheck = FirebaseAuth.instance.currentUser().then((value) {
        if (value == null) {
          FirebaseAuth.instance.signInWithEmailAndPassword(
            email: 'demo@sennit.com',
            password: '123456',
          );
        }
        _tabs
          ..add(
            StoresRoute(
              address: null,
            ),
          )
          ..add(SearchWidget());
      });
    } else {
      drawerNameController.text = ((Session.data['user']) as User).fullname;
      _tabs
        ..add(
          StoresRoute(
            address: null,
          ),
        )
        ..add(SearchWidget())
        ..add(UserNotificationWidget())
        ..add(PastOrdersRoute());
    }
  }
  @override
  Widget build(BuildContext context) {
    var user = Session.data['user'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Stores'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (demo) {
              tabController?.animateTo(0);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      endDrawer: !demo
          ? Drawer(
              child: ListView(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    arrowColor: Colors.white,
                    accountName: Text(user.fullname),
                    accountEmail: Text("${user.email}"),
                    currentAccountPicture: user.profilePicture != null
                        ? CircleAvatar(
                            child: Image.network(user.profilePicture),
                            backgroundColor: Colors.white,
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Center(
                              child: Icon(Icons.person),
                            ),
                          ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('Change Password'),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (c) {
                          return AuthenticateAgainRoute();
                        }));
                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('Privacy Policy'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.exit_to_app),
                      title: Text('Logout'),
                      onTap: () {
                        // Navigator.of(context).popUntil((route) => route.isFirst);
                        FirebaseAuth.instance.signOut();
                        Session.data..removeWhere((key, value) => true);
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            MyApp.startPage, (route) => false);
                      },
                    ),
                  )
                ],
              ),
            )
          : null,
      bottomNavigationBar: _StatefulBottomNavigation(demo),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.shopping_cart,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShoppingCartRoute(
                  null,
                  demo: this.demo,
                ),
              ));
        },
        backgroundColor: Theme.of(context).accentColor,
      ),
      body: FutureBuilder<void>(
        future: initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return _Body();
        },
      ),
    );
  }
}

class _Body extends StatefulWidget {
  // final List<Widget> tabs = [];
  @override
  State<StatefulWidget> createState() {
    return _BodyState();
  }
}

class _BodyState extends State<_Body> with SingleTickerProviderStateMixin {
  static TabController _controller;
  _BodyState();

  dispose() {
    super.dispose();
    _controller.dispose();
    // ReceiveItRoute._tabs = null;
  }

  @override
  void initState() {
    _controller = TabController(
      length: ReceiveItRoute._tabs.length,
      vsync: this,
      initialIndex: 0,
    );
    _controller.addListener(_handleTabChange);

    super.initState();
  }

  void _handleTabChange() {
    _BottomNavigationState._index = _controller.index;
    try {
      _BottomNavigationState._bottomNavigationState.rebuild();
    } on dynamic catch (_) {
      print(_);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: _controller,
      children: ReceiveItRoute._tabs,
    );
  }
}

class _StatefulBottomNavigation extends StatefulWidget {
  final bool demo;
  _StatefulBottomNavigation(this.demo) : state = _BottomNavigationState(demo);
  final _BottomNavigationState state;
  @override
  State<StatefulWidget> createState() {
    return state;
  }

  setState() {
    state?.rebuild();
  }
}

class _BottomNavigationState extends State<_StatefulBottomNavigation> {
  static int _index;
  final bool demo;
  static _BottomNavigationState _bottomNavigationState;

  _BottomNavigationState(this.demo);
  rebuild() {
    setState(() {});
  }

  @override
  void initState() {
    _bottomNavigationState = this;
    _index = 0;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _bottomNavigationState = null;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _index,
      onTap: (index) {
        if (index != _index) {
          _BodyState._controller.animateTo(index);
          setState(() {
            _index = index;
          });
        }
      },
      items: !demo
          ? [
              BottomNavigationBarItem(
                title: Text(
                  'Home',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600),
                ),
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
                title: Text('Search', style: TextStyle(color: Colors.black)),
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
                title:
                    Text('Notification', style: TextStyle(color: Colors.black)),
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
                      right: 1,
                    ),
                  ],
                ),
                activeIcon: Icon(
                  Icons.notifications,
                  color: Theme.of(context).accentColor,
                ),
              ),
              BottomNavigationBarItem(
                title:
                    Text('Past Order', style: TextStyle(color: Colors.black)),
                icon: Icon(
                  Icons.bookmark,
                  color: Colors.black54,
                ),
                activeIcon: Icon(
                  Icons.bookmark,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ]
          : [
              BottomNavigationBarItem(
                title: Text(
                  'Home',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600),
                ),
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
                title: Text('Search', style: TextStyle(color: Colors.black)),
                icon: Icon(
                  Icons.search,
                  color: Colors.black54,
                ),
                activeIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ],
    );
  }
}

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
  static List<Store> stores;
  StoresRouteState(this.selectedAddress) {
    getStroesWidget();
  }

  // Future<Widget> storeWidget;
  @override
  void initState() {
    super.initState();
  }

  // void appBarTap() {
  //   Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  //     return AddressAddingRoute(SourcePage.recieveIt, selectedAddress);
  //   })).then((value) {
  //     setState(() {
  //       selectedAddress = value;
  //     });
  //   });
  // }

  Widget _body;

  @override
  Widget build(BuildContext context) {
    return _body ??
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white.withAlpha(90),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
  }

  Future<void> initialize() async {
    stores = [];
    var querySnapshot =
        await Firestore.instance.collection('stores').getDocuments();
    for (var documentSnapshot in querySnapshot.documents) {
      Store store;
      var storeId = documentSnapshot.documentID;
      var storeAsMap = documentSnapshot.data;
      storeAsMap.putIfAbsent('storeId', () {
        return storeId;
      });
      store = Store.fromMap(storeAsMap);
      LatLng latlng = await Utils.getMyLocation();

      if (Utils.calculateDistance(store.storeLatLng, latlng) <= 8 * 1.6) {
        var itemIds = storeAsMap['items'];

        for (String itemId in itemIds) {
          var item = await Firestore.instance
              .collection('items')
              .document(itemId)
              .get();
          model.StoreItem storeItem = model.StoreItem.fromMap(item.data);
          store.storeItems.add(storeItem);
        }
        stores.add(store);
      }
    }

    // String cartId = await DatabaseHelper.getUserCartId(Session.data['user']);
    // if (cartId == null) {
    //   UserCart cart = UserCart();
    //   cart.cartId = "order${DateTime.now().millisecondsSinceEpoch.toString()}";
    //   cart.userId = Session.data["user"];
    //   Session.data["cart"] = cart;
    //   Database database = DatabaseHelper.getDatabase();
    //   await database.insert(Tables.USER_CART_TABLE, cart.toMap());
    //   return;
    // }
    return;
  }

  void getStroesWidget() async {
    await initialize();
    _body = stores.length <= 0
        ? Center(child: Text('No Stores Available Near You '))
        : SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: List.generate(
                stores.length,
                (index) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return StoreMainPage(
                              store: stores[index],
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: StoreItem(
                        store: stores[index],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
    try {
      setState(() {});
    } on dynamic catch (_) {
      print(_);
      stores.clear();
    }
  }
}

class StoreItem extends StatelessWidget {
  // final bool dummyPic;
  final Store store;
  StoreItem({this.store});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Stack(
            children: <Widget>[
              store.storeImage == null
                  ? Icon(
                      Icons.store,
                      size: MediaQuery.of(context).size.width,
                      color: Theme.of(context).primaryColor,
                    )
                  : FadeInImage.assetNetwork(
                      placeholder: 'assets/images/logo.png',
                      image: '${store.storeImage}',
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
                        store.storeName,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'BebasNeue',
                        ),
                      ),
                      Text(
                        store.storeMotto,
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
            child: store.items.length <= 0
                ? Opacity(
                    opacity: 0,
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(right: 20),
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    itemCount: store.items.length > 5 ? 5 : store.items.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        child: Card(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  color: Colors.black,
                                  child: FadeInImage.assetNetwork(
                                    placeholder: 'assets/images/logo.png',
                                    image:
                                        '${store.storeItems[index].images[0]}',
                                    height: 100,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Container(
                                  width: 100,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        store.storeItems[index].itemName,
                                        style:
                                            Theme.of(context).textTheme.subhead,
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        "${store.storeItems[index].price}",
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
                        ),
                        onTap: () async {
                          Utils.showLoadingDialog(context);
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return ItemDetailsRoute(
                                  item: store.storeItems[index],
                                );
                              },
                              maintainState: false,
                            ),
                          );
                        },
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
  final Store store;
  final bool demo;
  StoreMainPage({
    this.store,
    this.demo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.shopping_cart),
        label: Text('Goto Cart'),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShoppingCartRoute(
                  null,
                  demo: this.demo,
                ),
              ));
        },
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
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
                      store.storeName,
                      style: Theme.of(context).textTheme.title,
                    ),
                    background: Stack(
                      children: [
                        Image.network(
                          "${store.storeImage}",
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
          child: Column(
            children: <Widget>[
              StoreMenu(
                store: store,
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StoreMenu extends StatefulWidget {
  final Store store;
  const StoreMenu({Key key, @required this.store}) : super(key: key);
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
        MenuCategorize(
          items: widget.store.storeItems,
        ),
      ],
    );
  }
}

class MenuCategorize extends StatelessWidget {
  final List<model.StoreItem> items;
  MenuCategorize({Key key, @required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(items.length, (index) {
        return InkWell(
          child: MenuItem(
            item: items[index],
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return ItemDetailsRoute(item: items[index]);
                },
              ),
            );
          },
        );
      }),
    );
  }
}

class MenuItem extends StatelessWidget {
  final model.StoreItem item;
  MenuItem({@required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Image.network(
              item.images[0],
              height: 100,
              width: 100,
              fit: BoxFit.fitHeight,
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.itemName,
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    item.description == null || item.description == ""
                        ? 'No Description Available\n\n'
                        : item.description,
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
              flex: 3,
              child: Padding(
                padding: EdgeInsets.only(right: 5),
                child: Tooltip(
                  message: ("${item.price}"),
                  child: AutoSizeText(
                    'R${item.price.round()}',
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

class BottomSheetButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BottomSheetButtonState();
  }
}

class BottomSheetButtonState extends State<BottomSheetButton> {
  bool addingToCart = false;
  bool isInCart;
  BottomSheetButtonState() {
    isInCart = searchItemInCart();
  }

  searchItemInCart() {
    model.StoreItem item = ItemDetailsRoute._item;
    UserCart cart = Session.data['cart'];
    if (cart == null) {
      return false;
    }
    bool found = false;
    if (cart.itemsData.containsKey(item.itemId)) {
      found = true;
    }
    return found;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(0),
      child: InkWell(
        child: Container(
          color: isInCart ? Colors.green : Colors.white,
          padding: EdgeInsets.all(10),
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: 50,
          child: addingToCart
              ? CircularProgressIndicator()
              : Text(
                  isInCart ? 'Added to Cart' : 'Add to Cart',
                  style: Theme.of(context).textTheme.subhead,
                ),
        ),
        onTap: () async {
          setState(() {
            addingToCart = true;
          });
          User user = Session.data['user'];
          UserCart cart = Session.data['cart'];
          if (cart == null) {
            Session.data.putIfAbsent('cart', () {
              return UserCart(itemsData: {});
            });
          }
          if (!isInCart) {
            Firestore.instance
                .collection('carts')
                .document(user.userId)
                .setData(
              {
                'itemsData': {ItemDetailsRoute._item.itemId: 1.0},
              },
              merge: true,
            ).catchError((error) {
              Utils.showSnackBarError(
                  context, "Network Problem Occurred! Try Again");
              setState(() {
                addingToCart = false;
              });
            }).then((_) {
              cart.itemsData.update(
                ItemDetailsRoute._item.itemId,
                (x) => 1.0,
                ifAbsent: () => 1.0,
              );
              cart.items.add(ItemDetailsRoute._item);
              setState(() {
                addingToCart = false;
                isInCart = true;
              });
            });
          } else {
            var itemsData = Map<String, double>.from(cart.itemsData);
            // var quantities = List.from(cart.quantities);
            // itemsData.removeWhere(
            //   (Map<String, double> e) {
            //     return e.containsKey(ItemDetailsRoute._item.itemId);
            //   },
            // );

            // itemsData.remove(ItemDetailsRoute._item);
            itemsData.removeWhere(
              (key, value) => key == ItemDetailsRoute._item.itemId,
            );
            // quantities.removeAt(index);
            Firestore.instance
                .collection('carts')
                .document(user.userId)
                .setData(
              {
                'itemsData': itemsData,
                // 'quantities': quantities,
              },
            ).catchError((error) {
              Utils.showSnackBarError(context, error.toString());
              setState(() {
                addingToCart = false;
              });
            }).then((_) {
              cart.items.removeWhere(
                (item) => item.itemId == ItemDetailsRoute._item.itemId,
              );
              cart.itemsData.removeWhere((key, value) {
                if (key == ItemDetailsRoute._item.itemId) {
                  return true;
                }
                return false;
              });
              // cart.quantities.removeAt(index);
              setState(() {
                addingToCart = false;
                isInCart = false;
              });
            });
          }
        },
      ),
    );
  }
}

class ItemDetailsRoute extends StatefulWidget {
  static model.StoreItem _item;
  ItemDetailsRoute({
    Key key,
    @required model.StoreItem item,
  }) : super(key: key) {
    _item = item;
  }
  final state = ItemDetailsRouteState();
  @override
  State<StatefulWidget> createState() {
    return state;
  }
}

class ItemDetailsRouteState extends State<ItemDetailsRoute> {
  @override
  Widget build(BuildContext context) {
    var itemDetailsBody = _ItemDetailsBody(
      item: ItemDetailsRoute._item,
    );
    return Scaffold(
      resizeToAvoidBottomInset: true,
      bottomSheet: BottomSheet(
        elevation: 40,
        onClosing: () {},
        builder: (context) {
          return BottomSheetButton();
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
      floatingActionButton: FloatingMenu(
        itemId: ItemDetailsRoute._item.itemId,
        // onComeBack: () {
        //   setState(() {});
        // }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: itemDetailsBody,
    );
  }
}

class FloatingMenu extends StatefulWidget {
  final itemId;
  // final Function() onComeBack;
  final bool demo;
  FloatingMenu({
    Key key,
    this.itemId,
    this.demo,
    // this.onComeBack,
  }) : super(key: key);

  @override
  _FloatingMenuState createState() => _FloatingMenuState();
}

class _FloatingMenuState extends State<FloatingMenu> {
  // bool opened = false;
  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      // both default to 16
      marginRight: 18,
      marginBottom: 50,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      // this is ignored if animatedIcon is non null
      // child: Icon(Icons.add),
      // If true user is forced to close dial manually
      // by tapping main button and overlay is not rendered.
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      tooltip: 'Speed Dial',
      heroTag: 'speed-dial-hero-tag',
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      elevation: 8.0,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
          child: Icon(Icons.rate_review),
          backgroundColor: Colors.white,
          foregroundColor: Theme.of(context).primaryColor,
          label: 'Review',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () async {
            await Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) {
              return ReviewWidget(
                user: Session.data['user'],
                itemId: widget.itemId,
              );
            }));
            // setState(() {
            // });
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.shopping_cart),
          backgroundColor: Colors.white,
          foregroundColor: Theme.of(context).primaryColor,
          label: 'Goto Cart',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ShoppingCartRoute(null, demo: widget.demo),
                maintainState: false,
              ),
            );

            // setState(() {});
          },
        ),
      ],
    );
  }
}

class _ItemDetailsBody extends StatefulWidget {
  // final ItemDetails itemDetails;
  final model.StoreItem item;
  final itemDetailsBodyState = _ItemDetailsBodyState();

  _ItemDetailsBody({this.item});
  @override
  State<StatefulWidget> createState() {
    return itemDetailsBodyState;
  }

  void setState() {
    itemDetailsBodyState.reBuild();
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
  // Future<model.StoreItem> getSpecificationAndReviews(model.StoreItem storeItem) async {
  //   // await Future.delayed(Duration(seconds: 3))

  //   return storeItem;
  // }
}

class _ItemDetailsBodyState extends State<_ItemDetailsBody>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  List<Review> reviews = [];
  var autoplay = true;

  Stream<DocumentSnapshot> stream;
  _ItemDetailsBodyState() {
    _tabController = TabController(vsync: this, length: 3);
  }
  @override
  void dispose() {
    super.dispose();
  }

  void reBuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: NestedScrollView(
        headerSliverBuilder: (context, constraint) {
          return [
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 250,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  widget.item.itemName,
                  style: Theme.of(context).textTheme.title,
                ),
                collapseMode: CollapseMode.pin,
                background: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CarouselSlider(
                      autoPlay: true,
                      enlargeCenterPage: true,
                      items: List.generate(
                        widget.item.images.length,
                        (index) {
                          return Stack(
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      widget.item.images[index],
                                    ),
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    stops: [0, 0.15, 0.3, 0.8, 0.9, 1],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white,
                                      Colors.white24,
                                      Colors.transparent,
                                      Colors.transparent,
                                      Colors.white24,
                                      Colors.white,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      // dotSize: 4.0,
                      // dotSpacing: 15.0,
                      // dotColor: Theme.of(context).primaryColor,
                      // showIndicator: false,
                      // dotBgColor: Colors.white54,
                      // dotIncreasedColor: Theme.of(context).primaryColor,
                      // moveIndicatorFromBottom: 180.0,
                      // noRadiusForIndicator: false,
                    ),
                    Container(
                        // decoration: BoxDecoration(
                        //   gradient: LinearGradient(
                        //     stops: [0, 0.7, 0.8, 1],
                        //     begin: Alignment.topCenter,
                        //     end: Alignment.bottomCenter,
                        //     colors: [
                        //       Colors.transparent,
                        //       Colors.transparent,
                        //       Colors.white54,
                        //       Colors.white,
                        //     ],
                        //   ),
                        // ),
                        ),
                  ],
                ),
                //Stack(
                //   fit: StackFit.expand,
                //   children: [
                //     CarouselSlider(
                //       autoPlay: autoplay,
                //       initialPage: 0,
                //       scrollDirection: Axis.horizontal,
                //       // viewportFraction: 1.0,
                //       enlargeCenterPage: true,
                //       height: 250.0,
                //       scrollPhysics: BouncingScrollPhysics(),
                //       enableInfiniteScroll: true,
                //       pauseAutoPlayOnTouch: Duration(seconds: 4),
                //       autoPlayInterval: Duration(seconds: 2),
                //       items:
                //           List.generate(widget.item.images.length, (index) {
                //         return Container(
                //           width: MediaQuery.of(context).size.width,
                //           margin: EdgeInsets.symmetric(horizontal: 5.0),
                //           decoration: BoxDecoration(
                //             image: DecorationImage(
                //               image: NetworkImage(widget.item.images[index]),
                //               fit: BoxFit.fitHeight,
                //             ),
                //           ),
                //         );
                //       }),
                //     ),
                //     Container(
                //       decoration: BoxDecoration(
                //           gradient: LinearGradient(
                //               stops: [0, 0.6, 1],
                //               begin: Alignment.topCenter,
                //               end: Alignment.bottomCenter,
                //               colors: [
                //                 Colors.transparent,
                //                 Colors.white10,
                //                 Colors.white,
                //               ])),
                //     ),
                //   ],
                // ),
                // title: Text(
                //   widget.item.itemName,
                //   style: Theme.of(context).textTheme.title,
                // ),
                // centerTitle: true,
                // collapseMode: CollapseMode.pin,
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
                                'Price: ${widget.item.price}',
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
                              widget.item.description == null ||
                                      widget.item.description == ""
                                  ? 'No Description Available'
                                  : widget.item.description,
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
                        future: Firestore.instance
                            .collection("specifications")
                            .document(widget.item.itemId)
                            .get(),
                        builder: (
                          context,
                          AsyncSnapshot<DocumentSnapshot> asyncData,
                        ) {
                          if (asyncData.connectionState ==
                              ConnectionState.done) {
                            if (asyncData.data == null ||
                                !asyncData.data.exists ||
                                asyncData.data.data.length == 0) {
                              return Center(
                                  child: Text('No Specifications Available'));
                            }
                            return ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                var key =
                                    asyncData.data.data.keys.toList()[index];
                                return Container(
                                  margin: EdgeInsets.only(
                                    top: index == 0 ? 20 : 10,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        key,
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
                                            asyncData.data.data[key],
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption,
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              itemCount: asyncData.data.data.keys.length,
                            );
                          } else if (asyncData.connectionState ==
                              ConnectionState.waiting) {
                            return widget._getProgressBar();
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
                        },
                      ),
                      FutureBuilder(
                        initialData: null,
                        future: Firestore.instance
                            .collection("reviews")
                            .document(widget.item.itemId)
                            .get(),
                        builder: (context,
                            AsyncSnapshot<DocumentSnapshot> asyncData) {
                          if (asyncData.data == null ||
                              asyncData.connectionState ==
                                  ConnectionState.waiting) {
                            return widget._getProgressBar();
                          } else {
                            if (asyncData.connectionState ==
                                ConnectionState.done) {
                              if (asyncData.data == null ||
                                  !asyncData.data.exists ||
                                  asyncData.data.data.length == 0) {
                                return Center(child: Text('No Review Yet'));
                              }
                              List<String> keys =
                                  asyncData.data.data.keys.toList();
                              return ListView.builder(
                                  itemBuilder: (context, index) {
                                    var map = Map<String, dynamic>.from(
                                        asyncData.data.data);
                                    Review review = Review.fromMap(Map.from(
                                      map[keys[index]],
                                    ));
                                    return Card(
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
                                            Container(
                                              decoration: ShapeDecoration(
                                                color: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(24),
                                                  ),
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                padding:
                                                    EdgeInsets.only(right: 4),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      '${review.reviewedBy}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subhead,
                                                    ),
                                                    // mainAxisSize: MainAxisSize.max,
                                                    Text(
                                                        '${review.reviewDescription}\n'),
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
                                                Text(
                                                    '${review.rating.toStringAsFixed(1)}'),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: asyncData.data.data.length);
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
                        },
                      ),
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

  // List<Widget> _getAllSpecifications() {
  //   return [
  //     SizedBox(
  //       height: 20,
  //     ),
  //     SizedBox(
  //       height: 10,
  //     ),
  //     Row(
  //       children: <Widget>[
  //         SizedBox(
  //           width: 20,
  //         ),
  //         Text(
  //           'Spec1: ',
  //           style: TextStyle(
  //             fontSize: 12,
  //             fontWeight: FontWeight.bold,
  //             color: Theme.of(context).primaryColor,
  //           ),
  //         ),
  //         SizedBox(
  //           width: 15,
  //         ),
  //         Expanded(
  //           child: Container(
  //             // color: Colors.pink,
  //             child: Text(
  //               'Value of Spec 1',
  //               style: Theme.of(context).textTheme.caption,
  //               textAlign: TextAlign.start,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //     SizedBox(
  //       height: 10,
  //     ),
  //     Row(
  //       children: <Widget>[
  //         SizedBox(
  //           width: 20,
  //         ),
  //         Text(
  //           'Spec1: ',
  //           style: TextStyle(
  //             fontSize: 12,
  //             fontWeight: FontWeight.bold,
  //             color: Theme.of(context).primaryColor,
  //           ),
  //         ),
  //         SizedBox(
  //           width: 15,
  //         ),
  //         Expanded(
  //           child: Container(
  //             // color: Colors.pink,
  //             child: Text(
  //               'Value of Spec 1',
  //               style: Theme.of(context).textTheme.caption,
  //               textAlign: TextAlign.start,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //     SizedBox(
  //       height: 10,
  //     ),
  //     Row(
  //       children: <Widget>[
  //         SizedBox(
  //           width: 20,
  //         ),
  //         Text(
  //           'Spec1: ',
  //           style: TextStyle(
  //             fontSize: 12,
  //             fontWeight: FontWeight.bold,
  //             color: Theme.of(context).primaryColor,
  //           ),
  //         ),
  //         SizedBox(
  //           width: 15,
  //         ),
  //         Expanded(
  //           child: Container(
  //             // color: Colors.pink,
  //             child: Text(
  //               'Value of Spec 1',
  //               style: Theme.of(context).textTheme.caption,
  //               textAlign: TextAlign.start,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //     SizedBox(
  //       height: 10,
  //     ),
  //   ];
  // }

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

  // Widget _getReviews() {
  //   List<Widget> reviews = List();
  //   for (var i = 0; i < 10; i++) {
  //     Widget review2 = Card(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.all(
  //           Radius.circular(4),
  //         ),
  //       ),
  //       child: Padding(
  //         padding: EdgeInsets.only(
  //           left: 8,
  //           right: 8,
  //           top: 16,
  //           bottom: 8,
  //         ),
  //         child: Row(
  //           children: [
  //             Expanded(
  //               child: Container(
  //                 padding: EdgeInsets.only(right: 4),
  //                 // decoration: ShapeDecoration(
  //                 //   shape: Border(
  //                 //     right: BorderSide(width: 1, color: Colors.black),
  //                 //   ),
  //                 // ),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: <Widget>[
  //                     Text(
  //                       'Some User $i',
  //                       style: Theme.of(context).textTheme.subhead,
  //                     ),
  //                     // mainAxisSize: MainAxisSize.max,
  //                     Text(
  //                         'This is some medium length review. I want it to check how app looks.\n'),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             SizedBox(
  //               width: 12,
  //             ),
  //             Container(
  //               margin: EdgeInsets.only(top: 10),
  //               width: 1,
  //               height: 80,
  //               color: Colors.black,
  //             ),
  //             SizedBox(
  //               width: 12,
  //             ),
  //             Column(
  //               children: <Widget>[
  //                 Icon(
  //                   Icons.star,
  //                   color: Colors.yellow,
  //                 ),
  //                 SizedBox(
  //                   height: 2,
  //                 ),
  //                 Text('4.2'),
  //               ],
  //             ),
  //             SizedBox(
  //               width: 8,
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //     Widget review = Card(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.all(
  //           Radius.circular(4),
  //         ),
  //       ),
  //       child: Padding(
  //         padding: EdgeInsets.only(
  //           left: 8,
  //           right: 8,
  //           top: 16,
  //           bottom: 8,
  //         ),
  //         child: Row(
  //           children: [
  //             Expanded(
  //               child: Container(
  //                 padding: EdgeInsets.only(right: 4),
  //                 // decoration: ShapeDecoration(
  //                 //   shape: Border(
  //                 //     right: BorderSide(width: 1, color: Colors.black),
  //                 //   ),
  //                 // ),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: <Widget>[
  //                     Text(
  //                       'Some User $i',
  //                       style: Theme.of(context).textTheme.subhead,
  //                     ),
  //                     // mainAxisSize: MainAxisSize.max,
  //                     Text(
  //                         'This is some medium length review. I want it to check how app looks. This is some medium length review. I want it to check how app looks. This is some medium length review. I want it to check how app looks.\n'),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             SizedBox(
  //               width: 12,
  //             ),
  //             Container(
  //               margin: EdgeInsets.only(top: 10),
  //               width: 1,
  //               height: 80,
  //               color: Colors.black,
  //             ),
  //             SizedBox(
  //               width: 12,
  //             ),
  //             Column(
  //               children: <Widget>[
  //                 Icon(
  //                   Icons.star,
  //                   color: Colors.yellow,
  //                 ),
  //                 SizedBox(
  //                   height: 2,
  //                 ),
  //                 Text('4.2'),
  //               ],
  //             ),
  //             SizedBox(
  //               width: 8,
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //     reviews
  //       ..add(review)
  //       ..add(
  //         SizedBox(
  //           height: 10,
  //         ),
  //       )
  //       ..add(review2)
  //       ..add(
  //         SizedBox(
  //           height: 10,
  //         ),
  //       );
  //     // ..add(review1);
  //   }
  //   reviews.add(SizedBox(height: 100));
  //   return ListView(
  //     children: reviews,
  //   );
  // }

}

class ShoppingCartRoute extends StatelessWidget {
  // static Address _fromAddress;
  static Address _toAddress;
  final bool demo;
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  ShoppingCartRoute(
    toAddress, {
    @required this.demo,
  }) : body = ShoppingCartRouteBody(demo: demo) {
    // _fromAddress = fromAddress;

    if (toAddress != null) {
      _toAddress = toAddress;
    } else if (_toAddress == null) {
      _toAddress = Utils.getLastKnowAddress();
    }
  }

  final ShoppingCartRouteBody body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        actions: <Widget>[
          !demo
              ? FlatButton(
                  onPressed: () async {
                    Utils.showLoadingDialog(context);
                    UserCart cart = Session.data['cart'];
                    if (ShoppingCartRouteState._emailController.text == "" ||
                        ShoppingCartRouteState._emailController.text == null) {
                      Utils.showSnackBarErrorUsingKey(
                        _key,
                        'Please Provide your email Address',
                      );
                      Navigator.pop(context);
                      return;
                    } else if (ShoppingCartRouteState
                                ._phoneNumberController.text ==
                            "" ||
                        ShoppingCartRouteState._phoneNumberController.text ==
                            null) {
                      Utils.showSnackBarErrorUsingKey(
                        _key,
                        'Please Provide your Phone Number',
                      );
                      Navigator.pop(context);
                      return;
                    } else if (ShoppingCartRouteState
                                ._phoneNumberController.text.length !=
                            10 ||
                        !ShoppingCartRouteState._phoneNumberController.text
                            .startsWith('0')) {
                      Utils.showSnackBarErrorUsingKey(
                        _key,
                        'The Phone number Should start with 0 and Should Contain total of 10 digits',
                      );
                      Navigator.pop(context);
                      return;
                    } else if (!Utils.isEmailCorrect(
                        ShoppingCartRouteState._emailController.text)) {
                      Utils.showSnackBarErrorUsingKey(
                        _key,
                        'Invalid Email Format',
                      );
                      Navigator.pop(context);
                      return;
                    } else if (cart.itemsData == null ||
                        cart.itemsData.length == 0) {
                      Navigator.pop(context);

                      BotToast.showNotification(
                        title: (_) {
                          return Text("Your Cart is Empty");
                        },
                        align: Alignment.bottomCenter,
                        subtitle: (_) =>
                            Text("Please Add some items in your cart"),
                        trailing: (_) => RaisedButton(
                          color: Theme.of(context).primaryColor,
                          child: Text(
                            'Shop now',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.popUntil(context, (route) {
                              return route.settings.name == 'receiveIt';
                            });
                          },
                        ),
                      );

                      // BotToast.showText(
                      //     text: "Your Cart is Empty", duration: Duration(seconds: 2));
                      return;
                    } else if (ShoppingCartRoute._toAddress == null) {
                      BotToast.showText(
                          text: 'Please Select a Destination First!',
                          duration: Duration(seconds: 2));
                      // Utils.showSnackBarError(context, 'Please Select a Destination');
                      Navigator.pop(context);
                      return;
                    }

                    Map<String, dynamic> result = await performTransaction(
                        context,
                        ShoppingCartRouteState.totalPrice +
                            ShoppingCartRouteState.totalDeliveryCharges);

                    // Map<String, dynamic> result = {
                    //   'status': RaveStatus.success,
                    //   'errorMessage': 'someMessage'
                    // };

                    if (result['status'] == RaveStatus.cancelled) {
                      Utils.showSnackBarWarningUsingKey(
                          _key, 'Payment Cancelled');
                      Navigator.pop(context);
                      return;
                    } else if (result['status'] == RaveStatus.error) {
                      Utils.showSnackBarErrorUsingKey(
                        _key,
                        result['errorMessage'],
                      );
                      Navigator.pop(context);
                      return;
                    } else {
                      Utils.showSnackBarSuccessUsingKey(
                          _key, 'Payment Successful');
                    }

                    User user = Session.data['user'];
                    model.OrderFromReceiveIt order = model.OrderFromReceiveIt();
                    List<model.StoreItem> items = cart.items;
                    double price = ShoppingCartRouteState.totalPrice +
                        ShoppingCartRouteState.totalDeliveryCharges;

                    List<LatLng> pickups = [];
                    Map<String, double> itemsData = cart.itemsData;
                    order.pickups = pickups;
                    List<String> stores = [];
                    order.stores = stores;
                    for (model.StoreItem item in items) {
                      // price += item.price * itemsData[item.itemId];
                      pickups.add(item.latlng);
                      stores.add(item.storeName);
                    }
                    // order.quantities = quantities;
                    order.date = DateTime.now();
                    order.userId = user.userId;
                    order.email = ShoppingCartRouteState._emailController.text;
                    order.phoneNumber =
                        ShoppingCartRouteState._phoneNumberController.text;
                    order.house = ShoppingCartRouteState._houseController.text;
                    order.itemsData = itemsData;
                    order.price = price;
                    order.status = 'Pending';
                    order.destination = LatLng(
                      ShoppingCartRoute._toAddress.coordinates.latitude,
                      ShoppingCartRoute._toAddress.coordinates.longitude,
                    );
                    String otp = randomAlphaNumeric(6).toUpperCase();
                    var url =
                        "https://www.budgetmessaging.com/sendsms.ashx?user=sennit2020&password=29200613&cell=${order.phoneNumber}&msg=Hello Your Sennit OTP is \n$otp\n";
                    var response = await post(
                      url,
                    );

                    if (response.statusCode == 200 ||
                        response.statusCode == 201 ||
                        response.statusCode == 202) {
                      // if (true) {
                      Map<String, dynamic> orderData = order.toMap()
                        ..putIfAbsent('otp', () => otp);
                      Firestore.instance
                          .collection('postedOrders')
                          .add(orderData)
                          .catchError((error) {})
                          .then((data) async {
                        // Firestore.instance
                        //     .collection("notifications")
                        //     .document(user.userId)
                        //     .setData({
                        //   "${DateTime.now().millisecondsSinceEpoch}": {
                        //     "price": order.price,
                        //     "destination": Utils.latLngToString(order.destination),
                        //     "pickup": order.pickups.map((x) => Utils.latLngToString(x)),
                        //     "items": items.map((x) => x.itemName),
                        //     "sleevesRequired": null,
                        //   }
                        // });
                        orderData.update('orderId', (old) => data.documentID,
                            ifAbsent: () => data.documentID);

                        await Firestore.instance
                            .collection("userOrders")
                            .document(user.userId)
                            .setData(
                          {
                            data.documentID: orderData,
                          },
                          merge: true,
                        );
                        // await Firestore.instance
                        //     .collection("verificationCodes")
                        //     .document(data.documentID)
                        //     .setData(
                        //   {
                        //     "key": otp,
                        //   },
                        // );

                        // print('Response status: ${response.statusCode}');
                        // print('Response body: ${response.body}');
                        // print('Response reason: ${response.reasonPhrase}');
                        // print('${response.request.url}');

                        await Firestore.instance
                            .collection('carts')
                            .document(user.userId)
                            .delete()
                            .catchError((error) {})
                            .then(
                          (_) async {
                            await Firestore.instance
                                .collection('carts')
                                .document(user.userId)
                                .setData({});
                            // Utils.showSnackBarSuccess(context, 'Order Submitted');
                            // Navigator.pop(context);
                            Session.data['cart'] = UserCart(itemsData: {});
                            Utils.showSuccessDialog(
                                'Your Order is on its way!');
                            Future.delayed(Duration(seconds: 2)).then((_) {
                              BotToast.cleanAll();
                            });
                            Navigator.popUntil(
                                context, ModalRoute.withName('receiveIt'));
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return OrderTracking(
                                    type: OrderTrackingType.RECEIVE_IT,
                                    data: orderData,
                                  );
                                },
                                settings:
                                    RouteSettings(name: OrderTracking.NAME),
                              ),
                            );
                          },
                        );
                      });
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
                )
              : Opacity(
                  opacity: 0,
                ),
        ],
        title: Text(
          'Cart',
        ),
        centerTitle: true,
        // backgroundColor: Theme.of(context).accentColor,
      ),
      body: body,
      bottomSheet: demo
          ? BottomAppBar(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Login to Checkout',
                    style: Theme.of(context).textTheme.title.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: <Widget>[
                      Spacer(),
                      Expanded(
                        flex: 2,
                        child: RaisedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, MyApp.userSignup);
                          },
                          child: Text(
                            'Signup',
                            style: Theme.of(context).textTheme.button.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ),
                      Spacer(),
                      Expanded(
                        flex: 2,
                        child: RaisedButton(
                          color: Colors.white,
                          onPressed: () {
                            Navigator.pushNamed(context, MyApp.userSignin);
                          },
                          child: Text(
                            'SignIn',
                            style: Theme.of(context).textTheme.button.copyWith(
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ],
              ),
            )
          : null,
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
        .initialize(context: context, initializer: initializer);
    print(response.message);

    return <String, dynamic>{
      'status': response.status,
      'errorMessage': response.message,
    };
  }
}

class ShoppingCartRouteBody extends StatefulWidget {
  final bool demo;
  final ShoppingCartRouteState state = ShoppingCartRouteState();

  ShoppingCartRouteBody({Key key, @required this.demo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return state;
  }
}

class ShoppingCartRouteState extends State<ShoppingCartRouteBody> {
  bool pickFromDoor = true;
  bool deliverToDoor = true;
  double cardMargin = 10;
  double cardPadding = 20;
  double groupMargin = 30;
  double itemMargin = 10;
  static List<TextEditingController> _controllers;
  static TextEditingController _emailController;
  static TextEditingController _houseController;
  static TextEditingController _phoneNumberController;
  bool boxSizeSmall = true;
  bool boxSizeMedium = false;
  bool boxSizeLarge = false;
  bool sleeveNeeded = false;
  bool demo;

  List<bool> isAnimationVisibleList = [];
  List<bool> isItemDeleteConfirmationVisibleList = [];
  // bool isItemDeleteConfirmationVisible = false;

  // var isAnimationVisible = false;

  List<bool> isButtonActiveList = [];

  var isLoadingBarVisibleList = [];

  ShoppingCartRouteState() {
    _controllers = [];
    _emailController = TextEditingController();
    _houseController = TextEditingController();
    _phoneNumberController = TextEditingController();
  }

  @override
  void initState() {
    super.initState();
    if (!widget.demo) {
      User user = Session.data['user'];
      _emailController.text = user.email;
      _phoneNumberController.text = user.phoneNumber;
    }
    _phoneNumberController.addListener(() {
      if (_phoneNumberController.text == null ||
          _phoneNumberController.text == "") {
        // _phoneNumberController.text = '27';
        setState(() {});
      }
    });
    totalDeliveryCharges = 0;
    totalPrice = 0;
    UserCart cart = Session.getCart();
    for (var key in cart.itemsData.keys) {
      final TextEditingController controller = TextEditingController();
      _controllers.add(controller);
      controller.text = cart.itemsData[key].toInt().toString();
      isAnimationVisibleList.add(false);
      isItemDeleteConfirmationVisibleList.add(false);
      isButtonActiveList.add(false);
      isLoadingBarVisibleList.add(false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    totalDeliveryCharges = 0;
    totalPrice = 0;
    // _emailController.dispose();
    // _houseController.dispose();
    // _phoneNumberController.dispose();
    // _controllers.forEach((c) => c.dispose());
    // _controllers = null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          Card(
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
                      Coordinates destination =
                          ShoppingCartRoute._toAddress?.coordinates;
                      LatLng latlng = destination == null
                          ? null
                          : LatLng(destination.latitude, destination.longitude);
                      LocationResult result = await Utils.showPlacePicker(
                        context,
                        initialLocation: latlng,
                      );
                      if (result != null) {
                        Coordinates coordinates = Coordinates(
                          result.latLng.latitude,
                          result.latLng.longitude,
                        );
                        ShoppingCartRoute._toAddress = (await Geocoder.google(
                          await Utils.getAPIKey(context: context),
                        ).findAddressesFromCoordinates(coordinates))[0];
                        setState(() {});
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
                        color: Theme.of(context).accentColor,
                        fontSize: 16,
                      ),
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
                            labelText: 'Apt/Suite/Floor/Building Name',
                          ),
                          controller: _houseController,
                        ),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            helperText: 'e.g. 0812345678',
                          ),
                          maxLength: 10,
                          maxLines: 1,
                          keyboardType: TextInputType.phone,
                          controller: _phoneNumberController,
                        ),
                        TextField(
                          decoration: InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
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
          SizedBox(
            height: 140,
          ),
          // SizedBox(
          //   height: 10,
          // ),
          // FutureBuilder(
          //   future: getDeliveryCharges(),
          //   builder: (context, snapshot) {

          //   },
          // ),
          // FutureBuilder<Widget>(
          //   future: _getCartItems(),
          //   builder: (context, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return Center(
          //         child: CircularProgressIndicator(),
          //       );
          //     } else if(snapshot.data != null){
          //       return snapshot.data;
          //     }
          //     else {
          //       return Center(child: Text('No Item in Cart'));
          //     }
          //   },
          // // ),

          /***************************************************** */
          //*****************Payment Methods*******************
          //*************************************************** */

          // Card(
          //   margin: EdgeInsets.only(
          //     top: 10,
          //   ), //, left: cardMargin, right: cardMargin),
          //   elevation: 5,
          //   child: Container(
          //     padding: EdgeInsets.only(top: cardPadding),
          //     child: Column(
          //       children: <Widget>[
          //         Row(
          //           children: [
          //             Text(
          //               '    Payment Method',
          //               style: TextStyle(
          //                 fontWeight: FontWeight.bold,
          //               ),
          //               textAlign: TextAlign.left,
          //             ),
          //           ],
          //         ),
          //         ListTile(
          //           leading: Icon(
          //             FontAwesomeIcons.cashRegister,
          //             color: Theme.of(context).accentColor,
          //           ),
          //           title: Text('Cash'),
          //           trailing: Icon(
          //             Icons.radio_button_checked,
          //             color: Theme.of(context).accentColor,
          //           ),
          //         ),
          //         ListTile(
          //           leading: Icon(
          //             Icons.credit_card,
          //           ),
          //           title: Text(
          //             'Select payment method',
          //           ),
          //           trailing: Icon(Icons.navigate_next),
          //           onTap: () {},
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  List<model.StoreItem> items;
  Map<String, double> itemsData;
  static double totalDeliveryCharges = 0;
  static double totalPrice = 0;
  // List<double> quantities;

  // var count = [0, 0, 0, 0];
  // Widget cartItems;

  Widget _getCartItems() {
    UserCart cart = Session.data['cart'];
    itemsData = cart.itemsData;
    items = cart.items;
    if (items.length == 0) {
      return Card(
        child: Container(
          padding: EdgeInsets.only(
            top: 50,
            bottom: 50,
          ),
          child: Center(
            child: Text(
              'Cart is Empty',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline,
            ),
          ),
        ),
      );
    }
    totalDeliveryCharges = 0;
    totalPrice = 0;
    List<double> deliveryCharges = [];
    // for (int i = 0; i < items.length; i++) {
    //   isAnimationVisibleList.add(false);
    //   isItemDeleteConfirmationVisibleList.add(false);
    // }
    return Card(
      margin: EdgeInsets.only(
        top: groupMargin,
      ), //left: cardMargin, right: cardMargin),
      elevation: 5,
      child: Container(
        padding: EdgeInsets.only(top: cardPadding, bottom: cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: Text(
                'Items In Cart',
                style: Theme.of(context).textTheme.headline,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List<Widget>.generate(items.length, (index) {
                // model.StoreItem item = items[index];
                totalPrice +=
                    items[index].price * itemsData[items[index].itemId];
                if (ShoppingCartRoute._toAddress != null) {
                  // double distance = Utils.calculateDistance(
                  //   LatLng(ShoppingCartRoute._toAddress.coordinates.latitude,
                  //       ShoppingCartRoute._toAddress.coordinates.longitude),
                  //   items[index].latlng,
                  // );

                  print(
                      'To Coordinates: ${ShoppingCartRoute._toAddress.coordinates}');
                  print(
                    'Item: ${items[index].latlng}',
                  );

                  // if (distance <= 5) {
                  //   deliveryCharges.add(
                  //     List<double>.generate(
                  //       itemsData[items[index].itemId].toInt(),
                  //       (i) => 30,
                  //     ),
                  //   );
                  // } else {
                  //   distance -= 5;
                  //   double kiloMeters = distance.ceilToDouble();
                  //   deliveryCharges.add(
                  //     List<double>.generate(
                  //       itemsData[items[index].itemId].toInt(),
                  //       (i) => double.parse(
                  //         (30 + (4.5 * kiloMeters)).toStringAsFixed(2),
                  //       ),
                  //     ),
                  //   );
                  // }
                  // deliveryCharges.add()
                }
                return Stack(
                  children: <Widget>[
                    CartItem(
                      onDelete: () {
                        isAnimationVisibleList[index] = true;
                        Future.delayed(Duration(milliseconds: 100)).then(
                          (_) {
                            isItemDeleteConfirmationVisibleList[index] = true;
                            setState(() {});
                          },
                        );
                        setState(() {});
                      },
                      onQuantityChange: (value, index) async {
                        if (value == null || value == 0) {
                          return;
                        }
                        Firestore.instance
                            .collection('carts')
                            .document((Session.data['user'] as User).userId)
                            .setData(
                          {
                            'itemsData': {
                              items[index].itemId: value.toDouble(),
                            }
                          },
                          merge: true,
                        );
                        itemsData.update(items[index].itemId, (a) {
                          return value.toDouble();
                        });
                        totalPrice = 0;
                        for (var item in items) {
                          totalPrice += item.price * itemsData[item.itemId];
                        }
                        totalPrice += totalDeliveryCharges;

                        // if (value != null) {
                        //   totalPrice += item.price * value;
                        setState(() {});
                        // }
                      },
                      item: items[index],
                      controller: _controllers[index],
                      itemIndex: index,
                    ),
                    isAnimationVisibleList[index]
                        ? Positioned(
                            left: 0,
                            right: 0,
                            top: 4,
                            bottom: 4,
                            child: AnimatedOpacity(
                                duration: Duration(milliseconds: 800),
                                opacity:
                                    isItemDeleteConfirmationVisibleList[index]
                                        ? 1
                                        : 0,
                                onEnd: () {
                                  if (isItemDeleteConfirmationVisibleList[
                                      index]) {
                                    isAnimationVisibleList[index] = true;
                                    isButtonActiveList[index] = true;
                                  } else {
                                    isAnimationVisibleList[index] = false;
                                  }
                                  setState(() {});
                                },
                                child: Container(
                                  color: Colors.white.withAlpha(240),
                                  padding: EdgeInsets.only(
                                      top: 8,
                                      bottom: 8,
                                      left: MediaQuery.of(context).size.width *
                                          0.2,
                                      right: MediaQuery.of(context).size.width *
                                          0.2),
                                  child: isLoadingBarVisibleList[index]
                                      ? Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : Row(
                                          children: <Widget>[
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                IconButton(
                                                  splashColor: Theme.of(context)
                                                      .primaryColor,
                                                  tooltip: "Cancel",
                                                  onPressed:
                                                      isButtonActiveList[index]
                                                          ? () {
                                                              isButtonActiveList[
                                                                      index] =
                                                                  false;
                                                              isItemDeleteConfirmationVisibleList[
                                                                      index] =
                                                                  false;
                                                              setState(() {});
                                                            }
                                                          : null,
                                                  icon: Icon(
                                                    Icons.close,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    size: 36,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                  'Cancel',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subhead,
                                                ),
                                              ],
                                            ),
                                            Spacer(),
                                            Column(
                                              children: <Widget>[
                                                IconButton(
                                                  tooltip: "Confirm",
                                                  splashColor: Theme.of(context)
                                                      .primaryColor,
                                                  onPressed: isButtonActiveList[
                                                          index]
                                                      ? () async {
                                                          // isButtonActiveList[index] =
                                                          //     false;
                                                          // isItemDeleteConfirmationVisibleList[
                                                          //     index] = false;
                                                          // setState(() {});

                                                          isLoadingBarVisibleList[
                                                              index] = true;
                                                          setState(() {});

                                                          User user = Session
                                                              .data['user'];
                                                          UserCart cart =
                                                              Session
                                                                  .data['cart'];
                                                          var itemsData = Map<
                                                              String,
                                                              double>.from(
                                                            cart.itemsData,
                                                          );
                                                          // var quantities = List.from(cart.quantities);
                                                          // itemsData.removeWhere(
                                                          //   (Map<String, double> e) {
                                                          //     return e.containsKey(ItemDetailsRoute._item.itemId);
                                                          //   },
                                                          // );

                                                          itemsData.removeWhere(
                                                            (key, value) =>
                                                                key ==
                                                                items[index]
                                                                    .itemId,
                                                          );
                                                          // quantities.removeAt(index);
                                                          Firestore.instance
                                                              .collection(
                                                                  'carts')
                                                              .document(
                                                                  user.userId)
                                                              .setData(
                                                            {
                                                              'itemsData':
                                                                  itemsData,
                                                              // 'quantities': quantities,
                                                            },
                                                          ).catchError((error) {
                                                            Utils.showSnackBarError(
                                                                context,
                                                                error
                                                                    .toString());
                                                            setState(() {
                                                              isButtonActiveList[
                                                                      index] =
                                                                  false;
                                                              isItemDeleteConfirmationVisibleList[
                                                                      index] =
                                                                  false;
                                                              isLoadingBarVisibleList[
                                                                      index] =
                                                                  false;
                                                            });
                                                          }).then((_) {
                                                            cart.items.remove(
                                                              ItemDetailsRoute
                                                                  ._item.itemId,
                                                            );
                                                            cart.itemsData
                                                                .removeWhere(
                                                                    (key,
                                                                        value) {
                                                              if (key ==
                                                                  items[index]
                                                                      .itemId) {
                                                                return true;
                                                              }
                                                              return false;
                                                            });
                                                            // cart.quantities.removeAt(index);
                                                            setState(() {
                                                              isButtonActiveList[
                                                                      index] =
                                                                  false;
                                                              isItemDeleteConfirmationVisibleList[
                                                                      index] =
                                                                  false;
                                                              isLoadingBarVisibleList[
                                                                      index] =
                                                                  false;
                                                              items.removeAt(
                                                                  index);
                                                              _controllers
                                                                  .removeAt(
                                                                      index);
                                                              print(_controllers
                                                                  .length);
                                                            });
                                                          });
                                                        }
                                                      : null,
                                                  icon: Icon(
                                                    Icons.check,
                                                    color: Colors.red,
                                                    size: 36,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                  'Yes',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subhead
                                                      .copyWith(
                                                        color: Colors.red,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                )),
                          )
                        : Opacity(opacity: 0),
                  ],
                );
              }),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    'Delivery\nCharges',
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  Container(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                    height: 40,
                    margin: EdgeInsets.all(8),
                  ),
                  Container(
                    constraints: BoxConstraints(maxWidth: 180),
                    child: Text(
                      '${ShoppingCartRoute._toAddress == null ? 'Select a Destination' : getDeliveryCharges()}',
                      style: Theme.of(context).textTheme.subtitle,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  Container(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                    height: 40,
                    margin: EdgeInsets.all(8),
                  ),
                  Text(
                    'Total\n$totalDeliveryCharges R',
                    style: Theme.of(context).textTheme.subhead,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: ${(totalPrice + totalDeliveryCharges).toStringAsFixed(1)} R ',
                style: Theme.of(context).textTheme.title.copyWith(
                      inherit: true,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }

  String getDeliveryCharges() {
    String finalString = '';
    double total = 0;
    // int index = 0;
    Map<String, Map<String, dynamic>> deliveryCharges = {};
    for (var item in items) {
      if (deliveryCharges.containsKey(item.latlng.toString())) {
        deliveryCharges[item.latlng.toString()].update(
          'count',
          (old) => old + 1,
        );
      } else {
        Coordinates coordinates = ShoppingCartRoute._toAddress.coordinates;
        double distance = Utils.calculateDistance(
            LatLng(coordinates.latitude, coordinates.longitude), item.latlng);
        deliveryCharges.putIfAbsent(
          item.latlng.toString(),
          () {
            return {
              'count': 1,
              'distance': distance,
            };
          },
        );
      }
    }

    deliveryCharges.forEach((k, v) {
      final distance = v['distance'];
      if (v['count'] == 1) {
        double charges = 30;
        final tempDistance = distance - 5;
        if (tempDistance <= 0) {
          v.putIfAbsent('charges', () => charges);
        } else {
          charges += ((tempDistance as double).ceilToDouble()) * 4.5;
          v.putIfAbsent('charges', () => charges);
        }
      } else {
        if (distance <= 10) {
          v.putIfAbsent('charges', () => 60.0);
        } else {
          double charges = 60.0;
          final tempDistance = distance - 10;
          charges += ((tempDistance as double).ceilToDouble()) * 4.5;
          v.putIfAbsent('charges', () => charges);
        }
      }

      total += v['charges'];

      if (finalString.isEmpty) {
        finalString += '${v['charges']}R';
      } else {
        finalString += ' + ${v['charges']}R';
      }
    });

    totalDeliveryCharges = total;
    // for (List<double> value in deliveryCharges) {
    //   total += value[0]; // * value.length;
    //   finalString += '${value[0]}R'; // x ${value.length}';
    //   if (++index < deliveryCharges.length) {
    //     finalString += ' + ';
    //   }
    // }
    // finalString += '$total';
    totalDeliveryCharges = total;
    return finalString;
  }
}

class CartItem extends StatefulWidget {
  final TextEditingController controller;
  final model.StoreItem item;
  final Function onDelete;
  final int itemIndex;
  final Function(int, int) onQuantityChange;
  final _quantityFocusNode = FocusNode();
  CartItem(
      {this.item,
      this.controller,
      this.itemIndex,
      @required this.onQuantityChange,
      @required this.onDelete}) {
    UserCart cart = Session.data['cart'];
    controller.removeListener(() {});
    controller.addListener(() {
      if (controller.text == null || controller.text.isEmpty) {
        return;
      }
      int value = int.parse(controller.text);
      if (value <= 0) {
        cart.itemsData[item.itemId] = 1.0;
        onQuantityChange(1, itemIndex);
      } else if (value > 99) {
        cart.itemsData[item.itemId] = 99.0;
        onQuantityChange(99, itemIndex);
      } else {
        cart.itemsData[item.itemId] = value.toDouble();
        onQuantityChange(value, itemIndex);
      }
    });
    _quantityFocusNode.addListener(() {
      if (controller.text == '') {
        controller.text = '0';
      }
      state?.refresh();
    });
  }

  final state = CartItemState();

  @override
  State<StatefulWidget> createState() {
    return state;
  }
}

class CartItemState extends State<CartItem> {
  // model.StoreItem item;
  // TextEditingController controller;
  // Function(int) onQuantityChange;

  bool isPressed = false;

  CartItemState() {
    // final keys = cart.itemsData.keys;
  }
  @override
  void initState() {
    super.initState();
  }

  void refresh() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: ShapeDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: ClipRRect(
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/images/logo.png',
                    image: widget.item.images[0],
                    height: 80,
                    fit: BoxFit.fitWidth,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.itemName,
                              style: Theme.of(context).textTheme.title,
                            ),
                            Text(
                              widget.item.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Row(
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
                                var value = int.parse(widget.controller.text);
                                if (int.parse(widget.controller.text) == 1) {
                                  return;
                                }
                                setState(() {
                                  widget.controller.text = '${value - 1}';
                                });
                              },
                            ),
                            Container(
                              width: 30,
                              child: TextField(
                                focusNode: widget._quantityFocusNode,
                                controller: widget.controller,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                                inputFormatters: <TextInputFormatter>[
                                  LengthLimitingTextInputFormatter(2),
                                  WhitelistingTextInputFormatter.digitsOnly,
                                  BlacklistingTextInputFormatter
                                      .singleLineFormatter,
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
                                var value = int.parse(widget.controller.text);
                                if (int.parse(widget.controller.text) == 99) {
                                  return;
                                }
                                setState(() {
                                  widget.controller.text = '${value + 1}';
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          onPressed: () {
                            if (!isPressed) {
                              widget.onDelete();
                              isPressed = true;
                              Future.delayed(Duration(seconds: 1)).then((_) {
                                isPressed = false;
                              });
                            }
                          },
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Align(
                    child: Text(
                      'Price: R${widget.item.price.toStringAsFixed(1)} per Item',
                      style: Theme.of(context).textTheme.subhead,
                    ),
                    alignment: Alignment.bottomRight,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
