import 'dart:convert';
import 'dart:io';
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
import 'package:random_string/random_string.dart';
import 'package:rave_flutter/rave_flutter.dart';
import 'package:sennit/models/models.dart' as model;
import 'package:sennit/models/models.dart';
import 'package:sennit/my_widgets/changePassword.dart';
import 'package:sennit/my_widgets/notification.dart';
import 'package:sennit/my_widgets/pdf_viewer.dart';
import 'package:sennit/my_widgets/review.dart';
import 'package:sennit/my_widgets/search.dart';
import 'package:sennit/user/past_orders.dart';
import 'package:sennit/user/signin.dart';
import 'package:sennit/user/signup.dart';
import '../main.dart';
import 'generic_tracking_screen.dart';

class ReceiveItRoute extends StatelessWidget {
  final drawerNameController = TextEditingController();
  final GlobalKey<MySearchAppBarState> searchBarKey =
      GlobalKey<MySearchAppBarState>();
  final GlobalKey<StoresRouteState> storesRouteKey =
      GlobalKey<StoresRouteState>();
  static List<Widget> _tabs;
  final bool demo;
  final TabController tabController;
  static int currentTab = 0;
  static Future<void> _authCheck;
  static List<String> titles = [
    'Stores',
    'Search',
    'Notifications',
    'Past Orders'
  ];
  // final StatefulText appBarTitle;
  static const String NAME = "ReceiveIt";

  Future<void> initialize() async {
    if (_authCheck != null) {
      await _authCheck;
    } else {
      await FirebaseAuth.instance.currentUser().then((value) {
        if (value == null) {
          FirebaseAuth.instance.signInWithEmailAndPassword(
            email: 'demo@sennit.com',
            password: '123456',
          );
        }
      });
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
      currentTab = 0;
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
              key: storesRouteKey,
              address: null,
              isDemo: demo,
            ),
          )
          ..add(SearchWidget(
            demo: demo,
          ));
      });
    } else {
      drawerNameController.text = ((Session.data['user']) as User).fullName;
      _tabs
        ..add(
          StoresRoute(
            key: storesRouteKey,
            address: null,
            isDemo: demo,
          ),
        )
        ..add(SearchWidget(
          demo: demo,
        ))
        ..add(UserNotificationWidget())
        ..add(PastOrdersRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = Session.data['user'];
    print('currentTab: $currentTab ${titles[currentTab]}');
    return Scaffold(
      appBar: MySearchAppBar(
        titles[currentTab],
        key: searchBarKey,
        centerTitle: true,
        onQuery: (text) {
          if (text == null || text.isEmpty) {
            storesRouteKey.currentState.filterStores('');
          } else {
            storesRouteKey.currentState.filterStores(text);
          }
        },
        leading: InkWell(
          onTap: () {
            if (demo) {
              tabController?.animateTo(0);
            } else {
              Navigator.pop(context);
            }
          },
          child: Icon(
            Platform.isIOS ? CupertinoIcons.back : Icons.arrow_back,
          ),
        ),
      ),
      endDrawer: !demo
          ? Drawer(
              child: ListView(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    arrowColor: Colors.white,
                    accountName: Text(user.fullName),
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) {
                              return PDFViewerRoute();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.exit_to_app),
                      title: Text('Logout'),
                      onTap: () async {
                        Utils.signOutUser(context);
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
          return _Body(
            onTabChange: (index) {
              searchBarKey?.currentState?.changeTitle(titles[index]);
            },
          );
        },
      ),
    );
  }
}

class MySearchAppBar extends StatefulWidget with PreferredSizeWidget {
  final String title;
  final Widget leading;
  final bool centerTitle;
  final Function(String searchString) onQuery;

  MySearchAppBar(
    this.title, {
    key,
    this.leading,
    this.centerTitle,
    this.onQuery,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MySearchAppBarState(title);
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class MySearchAppBarState extends State<MySearchAppBar> {
  String title;
  bool searchEnabled = true;
  bool searchBarVisible = false;
  double searchBarWidth = 0;
  double searchBarHeight = 0;
  TextEditingController _searchController;
  String previousSearchString = '';

  @override
  void initState() {
    super.initState();
    searchBarHeight = widget.preferredSize.height;
    _searchController = TextEditingController();
  }

  changeTitle(String title) {
    this.title = title;
    if (!title.toLowerCase().contains('stores')) {
      disableSearch();
    } else {
      enableSearch();
    }
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }
  }

  disableSearch() {
    if (!searchEnabled) return;
    searchEnabled = false;
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }
  }

  enableSearch() {
    if (searchEnabled) return;
    searchEnabled = true;
    setState(() {});
  }

  showSearchBar() {
    searchBarVisible = true;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchBarWidth = MediaQuery.of(context).size.width;
      setState(() {});
    });
  }

  MySearchAppBarState(this.title);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.centerRight,
      children: <Widget>[
        AppBar(
          title: Text(title),
          centerTitle: widget.centerTitle ?? false,
          leading: widget.leading,
          actions: <Widget>[
            searchEnabled
                ? FlatButton(
                    onPressed: () {
                      this.showSearchBar();
                    },
                    child: Icon(Icons.search),
                  )
                : SizedBox(
                    height: 0,
                    width: 0,
                  ),
          ],
        ),
        Positioned(
          right: 0,
          top: MediaQuery.of(context).padding.top,
          child: AnimatedContainer(
            color: Colors.white,
            width: searchBarWidth,
            height: searchBarHeight,
            duration: Duration(milliseconds: 500),
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (_) {
                // if (_searchController.text.length >= 1) {
                widget.onQuery(_searchController.text.trim());
                // } else {
                //   widget.onQuery('');
                // }
              },
              decoration: InputDecoration(
                hintText: 'Store Name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    searchBarWidth = 0;
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// class StatefulText extends StatefulWidget {
//   StatefulText({
//     this.title,
//   }) : super(key: _key);
//   static GlobalKey<_StatefulTextState> _key = GlobalKey<_StatefulTextState>();
//   final title;

//   changeTitle(title) {
//     _key?.currentState?.changeTitle(title);
//   }

//   @override
//   _StatefulTextState createState() => _StatefulTextState();
// }

// class _StatefulTextState extends State<StatefulText> {
//   String title;

//   changeTitle(String title) {
//     this.title = title;
//     if (mounted) {
//       setState(() {});
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     title = widget.title;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Text(title ?? '');
//   }
// }

class _Body extends StatefulWidget {
  // final List<Widget> tabs = [];
  final Function(int) onTabChange;

  const _Body({this.onTabChange});
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
      initialIndex: ReceiveItRoute.currentTab,
    );
    _controller.addListener(_handleTabChange);

    super.initState();
  }

  void _handleTabChange() {
    _BottomNavigationState._index = _controller.index;
    ReceiveItRoute.currentTab = _controller.index;
    widget.onTabChange(ReceiveItRoute.currentTab);
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
  _StatefulBottomNavigation(this.demo) : super(key: _key);

  static GlobalKey<_BottomNavigationState> _key =
      GlobalKey<_BottomNavigationState>();

  @override
  State<StatefulWidget> createState() {
    return _BottomNavigationState(demo);
  }

  setState() {
    _key?.currentState?.rebuild();
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
    _index = ReceiveItRoute.currentTab;
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
  final bool isDemo;
  StoresRoute({
    @required key,
    @required this.address,
    @required this.isDemo,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StoresRouteState(address);
  }
}

class StoresRouteState extends State<StoresRoute> {
  Address selectedAddress;
  List<Store> stores;
  List<Store> filtered;

  filterStores(String query) {
    filtered.clear();
    stores.forEach((store) {
      if (store.storeName.toLowerCase().contains(query.toLowerCase())) {
        filtered.add(store);
      }
    });
    setState(() {});
  }

  StoresRouteState(this.selectedAddress);

  bool initialized = false;
  bool requestTimedOut = false;

  @override
  void initState() {
    super.initState();
    initialized = false;
    requestTimedOut = false;
    getStoresWidget();
  }

  @override
  Widget build(BuildContext context) {
    return requestTimedOut
        ? InkWell(
            onTap: () {
              initialized = false;
              requestTimedOut = false;
              initialize();
              setState(() {});
            },
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.replay),
                  SizedBox(
                    height: 2,
                  ),
                  Text('Reload'),
                ],
              ),
            ),
          )
        : initialized
            ? filtered.length <= 0
                ? Center(child: Text('No Stores Available Near You '))
                : SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: List.generate(
                        filtered.length,
                        (index) {
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return StoreMainPage(
                                      store: filtered[index],
                                      demo: widget.isDemo ?? false,
                                    );
                                  },
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: StoreItem(
                                store: filtered[index],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
            : Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.white.withAlpha(90),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
  }

  @override
  setState(void Function() fn) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((duration) {
        super.setState(fn);
      });
    }
  }

  Future<void> initialize() async {
    stores = [];
    filtered = [];
    var querySnapshot = await Firestore.instance
        .collection('stores')
        .getDocuments(
          source: Source.serverAndCache,
        )
        .timeout(
      Duration(
        seconds: 10,
      ),
      onTimeout: () async {
        requestTimedOut = true;
        print('Request Timed Out');
        Utils.showSnackBarError(context, 'Request Timed out');
        if (mounted) {
          setState(() {});
        }
        return null;
      },
    ).catchError((_) async {
      print(_);
      Utils.showSnackBarError(
        context,
        _.toString(),
      );
    });
    if (querySnapshot == null) return;
    LatLng latlng = await Utils.getMyLocation().then<LatLng>((latlng) {
      return latlng;
    }).timeout(Duration(seconds: 1), onTimeout: () {
      LatLng latlng = Utils.getLastKnowLocation();
      return latlng ?? LatLng(0, 0);
    });
    for (var documentSnapshot in querySnapshot.documents) {
      if (documentSnapshot.data.containsKey('storeName')) {
        Store store;
        var storeId = documentSnapshot.documentID;
        var storeAsMap = documentSnapshot.data;
        storeAsMap.putIfAbsent('storeId', () {
          return storeId;
        });
        store = Store.fromMap(storeAsMap);

        if (Utils.calculateDistance(store.storeLatLng, latlng) <= 8 * 1.6) {
          var itemIds = storeAsMap['items'];
          List<Future<DocumentSnapshot>> requests = [];
          for (String itemId in itemIds) {
            var request =
                Firestore.instance.collection('items').document(itemId).get();
            requests.add(request);
          }
          for (var request in requests) {
            var item = await request;
            model.StoreItem storeItem = model.StoreItem.fromMap(item.data);
            storeItem.store = store;
            store.storeItems.add(storeItem);
          }
          stores.add(store);
          filtered.add(store);
        }
      }
    }
    return;
  }

  void getStoresWidget() async {
    await initialize();
    // if (mounted) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    setState(() {
      initialized = true;
      // });
    });
    // }
  }
}

class StoreItem extends StatelessWidget {
  // final bool dummyPic;
  final Store store;
  final demo;
  StoreItem({this.store, this.demo});

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
                        store.storeMotto ?? '',
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
                                        '${(store.storeItems[index].images == null || store.storeItems[index].images.length == 0) ? '' : store.storeItems[index].images[0]}',
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
                                        "R${store.storeItems[index].price.toInt()}",
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
                                    isDemo: demo);
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
    @required this.demo,
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
                      fit: StackFit.expand,
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
              StoreMenu(store: store, isDemo: demo),
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
  final isDemo;
  const StoreMenu({
    Key key,
    @required this.store,
    @required this.isDemo,
  }) : super(key: key);
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
          isDemo: widget.isDemo ?? false,
        ),
      ],
    );
  }
}

class MenuCategorize extends StatelessWidget {
  final List<model.StoreItem> items;
  final bool isDemo;
  MenuCategorize({
    Key key,
    @required this.items,
    @required this.isDemo,
  }) : super(key: key);

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
                  return ItemDetailsRoute(
                    item: items[index],
                    isDemo: isDemo ?? false,
                  );
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
                  message: ("R${item.price.toInt()}"),
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
          FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
          User user = Session.data['user'] ??
              User(
                email: fUser.email,
                userId: fUser.uid,
              );
          UserCart cart = Session.data['cart'];
          if (cart == null) {
            cart = UserCart(itemsData: {});
            Session.data.putIfAbsent('cart', () {
              return cart;
            });
          }
          if (!isInCart) {
            Firestore.instance
                .collection('carts')
                .document(user.userId)
                .setData(
              {
                'itemsData': {
                  ItemDetailsRoute._item.itemId: {
                    'quantity': 1,
                    'flavour': '',
                  }
                },
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
                (x) => {
                  'quantity': 1,
                  'flavour': '',
                },
                ifAbsent: () => {
                  'quantity': 1,
                  'flavour': '',
                },
              );
              cart.items.add(ItemDetailsRoute._item);
              setState(() {
                addingToCart = false;
                isInCart = true;
              });
            });
          } else {
            var itemsData =
                Map<String, Map<String, dynamic>>.from(cart.itemsData);
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
              cart.itemsData.removeWhere(
                  (key, value) => key == ItemDetailsRoute._item.itemId);
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
  static GlobalKey<ItemDetailsRouteState> _key =
      GlobalKey<ItemDetailsRouteState>();
  static model.StoreItem _item;
  final bool isDemo;
  ItemDetailsRoute({
    @required model.StoreItem item,
    @required this.isDemo,
  }) : super(key: _key) {
    _item = item;
  }

  @override
  State<StatefulWidget> createState() {
    return ItemDetailsRouteState();
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
          //When Demo Following code can show login and sign in buttons instead of Add to Cart Button
          // if (widget.isDemo) {
          //   return GestureDetector(
          //     child: Card(
          //       child: Padding(
          //         padding: const EdgeInsets.all(4),
          //         child: Row(
          //           children: <Widget>[
          //             FlatButton(
          //               onPressed: () {
          //                 Navigator.pushNamed(
          //                   context,
          //                   MyApp.userSignup,
          //                 );
          //               },
          //               child: Text('Signup'),
          //             ),
          //             Spacer(),
          //             FlatButton(
          //               color: Theme.of(context).primaryColor,
          //               onPressed: () {
          //                 Navigator.pushNamed(
          //                   context,
          //                   MyApp.userSignIn,
          //                 );
          //               },
          //               child: Text('Login'),
          //             ),
          //             Spacer(),
          //           ],
          //         ),
          //       ),
          //     ),
          //   );
          // }
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
        demo: widget.isDemo,
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
    @required this.demo,
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
          onTap: widget.demo ?? false
              ? () {
                  Utils.showSnackBarWarning(context, 'Login to Review');
                }
              : () async {
                  await Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return ReviewWidget(
                      orderId: "",
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
  static GlobalKey<_ItemDetailsBodyState> _key =
      GlobalKey<_ItemDetailsBodyState>();

  _ItemDetailsBody({this.item}) : super(key: _key);
  @override
  State<StatefulWidget> createState() {
    return _ItemDetailsBodyState();
  }

  void setState() {
    _key?.currentState?.reBuild();
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
                            fit: StackFit.expand,
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
                                    // gradient: RadialGradient(
                                    //   // begin: Alignment.topCenter,
                                    //   // end: Alignment.bottomCenter,
                                    //   colors: [
                                    //     Colors.transparent,
                                    //     Colors.white30,
                                    //   ],
                                    //   center: Alignment.center,
                                    //   radius: .4,
                                    //   tileMode: TileMode.clamp,
                                    // ),
                                    ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
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
                                'Price: R${widget.item.price.toInt()}',
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
                      (widget.item.specifications != null &&
                              widget.item.specifications.length > 0)
                          ? ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                var key = widget.item.specifications.keys
                                    .toList()[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: index == 0
                                          ? BorderSide(width: 1)
                                          : BorderSide.none,
                                      bottom: BorderSide(width: 1),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Spacer(),
                                      Text(
                                        key,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      Spacer(
                                        flex: 1,
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Container(
                                          child: Text(
                                            widget.item.specifications[key],
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
                              itemCount: widget.item.specifications.keys.length,
                            )
                          : Center(
                              child: Text("No Specifications Available"),
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
}

class ShoppingCartRoute extends StatelessWidget {
  // static Address _fromAddress;
  static Address _toAddress;
  final bool demo;
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  final _shoppingCartRouteBodyKey = GlobalKey<ShoppingCartRouteState>();
  ShoppingCartRoute(
    toAddress, {
    @required this.demo,
  }) {
    // _fromAddress = fromAddress;

    if (toAddress != null) {
      _toAddress = toAddress;
    } else if (_toAddress == null) {
      _toAddress = Utils.getLastKnowAddress();
    }
  }
  // : body = ShoppingCartRouteBody(demo: demo) {
  //   // _fromAddress = fromAddress;

  //   if (toAddress != null) {
  //     _toAddress = toAddress;
  //   } else if (_toAddress == null) {
  //     _toAddress = Utils.getLastKnowAddress();
  //   }
  // }

  // final ShoppingCartRouteBody body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        actions: <Widget>[
          (demo == null || !demo)
              ? FlatButton(
                  onPressed: () async {
                    try {
                      Utils.showLoadingDialog(context);
                      NavigatorState navigator = Navigator.of(context);
                      ShoppingCartRouteState state =
                          _shoppingCartRouteBodyKey.currentState;
                      String email = state._emailController?.text?.trim() ?? '';
                      String phoneNumber =
                          state._phoneNumberController?.text?.trim() ?? '';
                      String house = state._houseController?.text?.trim() ?? '';
                      UserCart cart = Session.data['cart'];
                      if (email == null || email.isEmpty) {
                        Utils.showSnackBarErrorUsingKey(
                          _key,
                          'Please Provide your email Address',
                        );
                        Navigator.pop(context);
                        return;
                      } else if (phoneNumber == "" || phoneNumber == null) {
                        Utils.showSnackBarErrorUsingKey(
                          _key,
                          'Please Provide your Phone Number',
                        );
                        Navigator.pop(context);
                        return;
                      } else if (phoneNumber.length != 10 ||
                          !phoneNumber.startsWith('0')) {
                        Utils.showSnackBarErrorUsingKey(
                          _key,
                          'The Phone number Should start with 0 and Should Contain total of 10 digits',
                        );
                        Navigator.pop(context);
                        return;
                      } else if (!Utils.isEmailCorrect(email)) {
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
                              navigator.popUntil((route) {
                                return route.settings.name == 'receiveIt';
                              });
                            },
                          ),
                        );

                        // BotToast.showText(
                        //     text: "Your Cart is Empty", duration: Duration(seconds: 2));
                        return;
                      } else if (ShoppingCartRoute._toAddress == null ||
                          ((ShoppingCartRoute
                                          ._toAddress.coordinates?.latitude ??
                                      0) ==
                                  0 &&
                              (ShoppingCartRoute
                                          ._toAddress.coordinates?.longitude ??
                                      0) ==
                                  0)) {
                        BotToast.showText(
                            text: 'Please Select a Destination First!',
                            duration: Duration(seconds: 2));
                        // Utils.showSnackBarError(context, 'Please Select a Destination');
                        navigator.pop();
                        return;
                      }

                      double totalCharges =
                          state.totalPrice + state.totalDeliveryCharges;
                      Map<String, dynamic> result = await performTransaction(
                        context,
                        totalCharges,
                      );
                      // Map<String, dynamic> result = {
                      //   'status': RaveStatus.success,
                      //   'errorMessage': 'someMessage'
                      // };

                      if (result['status'] == RaveStatus.cancelled) {
                        Utils.showSnackBarWarningUsingKey(
                            _key, 'Payment Cancelled');
                        navigator.pop();
                        return;
                      } else if (result['status'] == RaveStatus.error) {
                        Utils.showSnackBarErrorUsingKey(
                          _key,
                          result['errorMessage'],
                        );
                        navigator.pop();
                        return;
                      } else {
                        Utils.showSnackBarSuccessUsingKey(
                            _key, 'Payment Successful');
                      }

                      User user = Session.data['user'];
                      model.OrderFromReceiveIt order =
                          model.OrderFromReceiveIt();
                      List<model.StoreItem> items = cart.items;
                      double price = totalCharges;

                      List<LatLng> pickups = [];
                      Map<String, Map<String, dynamic>> itemsData =
                          cart.itemsData;
                      order.pickups = pickups;
                      List<String> stores = [];
                      List<double> pricePerItem = [];
                      List<double> totalPricePerItem = [];
                      order.stores = stores;
                      for (model.StoreItem item in items) {
                        // price += item.price * itemsData[item.itemId];
                        pickups.add(item.latlng);
                        stores.add(item.storeName);
                        pricePerItem.add(item.price);
                        totalPricePerItem.add(
                          (item.price * itemsData[item.itemId]['quantity']
                                  as num)
                              .toDouble(),
                        );
                      }
                      order.pricePerItem = pricePerItem;
                      order.totalPricePerItem = totalPricePerItem;
                      // order.quantities = quantities;
                      order.date = DateTime.now();
                      order.userId = user.userId;
                      order.email = email;
                      order.phoneNumber = phoneNumber;
                      order.house = house;
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
                      ).catchError((_) {
                        // Utils.showSnackBarErrorUsingKey(
                        //     _key, 'Error While Sending sms');
                      });
                      // final response = Response('', 200);

                      if (response.statusCode == 200 ||
                          response.statusCode == 201 ||
                          response.statusCode == 202) {
                      } else {
                        int count = 0;
                        while (response.statusCode != 200 &&
                            response.statusCode != 201 &&
                            response.statusCode != 202 &&
                            count < 0) {
                          count++;
                          Utils.showSnackBarErrorUsingKey(
                              _key, 'Unable to send OTP! Retrying!');
                          BotToast.showNotification(
                            title: (_) {
                              return Text("Otp Sending Failed");
                            },
                            duration: Duration(seconds: 4),
                            align: Alignment.bottomCenter,
                            subtitle: (_) => Text("Retrying Attempt: $count"),
                            // trailing: (_) => RaisedButton(
                            //   color: Theme.of(context).primaryColor,
                            //   child: Text(
                            //     'Shop now',
                            //     style: TextStyle(color: Colors.white),
                            //   ),
                            //   onPressed: () {
                            //     Navigator.popUntil(context, (route) {
                            //       return route.settings.name == 'receiveIt';
                            //     });
                            //   },
                            // ),
                          );

                          var url =
                              "https://www.budgetmessaging.com/sendsms.ashx?user=sennit2020&password=29200613&cell=${order.phoneNumber}&msg=Hello Your Sennit OTP is \n$otp\n";
                          response = await post(
                            url,
                          ).catchError((_) {});
                        }
                        if (count >= 1) {
                          BotToast.showNotification(
                            title: (_) {
                              return Text("Otp Sending Failed");
                            },
                            duration: Duration(seconds: 4),
                            align: Alignment.bottomCenter,
                            subtitle: (_) => Text(
                                "Please Manually send the OTP\nYour OTP is $otp."),
                            // trailing: (_) => RaisedButton(
                            //   color: Theme.of(context).primaryColor,
                            //   child: Text(
                            //     'Shop now',
                            //     style: TextStyle(color: Colors.white),
                            //   ),
                            //   onPressed: () {
                            //     Navigator.popUntil(context, (route) {
                            //       return route.settings.name == 'receiveIt';
                            //     });
                            //   },
                            // ),
                          );
                        }
                        // print('Response status: ${response.statusCode}');
                        // print('Response body: ${response.body}');
                        // print('Response reason: ${response.reasonPhrase}');
                      }
                      {
                        // Utils.showSnackBarSuccessUsingKey(
                        //     _key, 'Successfully Message Sent');
                        // if (true) {
                        Map<String, dynamic> orderData = order.toMap()
                          ..putIfAbsent('otp', () => otp);
                        Firestore.instance
                            .collection('postedOrders')
                            .add(orderData)
                            .catchError((error) {
                          Utils.showSnackBarErrorUsingKey(
                              _key, 'Error Posting Order');
                        }).then((data) async {
                          orderData.update('orderId', (old) => data.documentID,
                              ifAbsent: () => data.documentID);
                          var batch = Firestore.instance.batch();
                          var userOrderRef = Firestore.instance
                              .collection("users")
                              .document(user.userId)
                              .collection('orders')
                              .document(data.documentID);

                          batch.setData(
                            userOrderRef,
                            orderData,
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
                          var now = DateTime.now();

                          Map<String, dynamic> storeOrders = {};
                          List<String> deviceIds = [];

                          for (model.StoreItem item in items) {
                            final itemKey = item.itemId;
                            if (storeOrders.containsKey(item.storeId)) {
                              double price = storeOrders[item.storeId]['price'];
                              price += item.price *
                                  itemsData[item.itemId]['quantity'];
                              storeOrders[item.storeId].update(
                                  'price', (old) => price,
                                  ifAbsent: () => price);
                              storeOrders[item.storeId]['pricePerItem']
                                  .add(item.price);
                              storeOrders[item.storeId]['totalPricePerItem']
                                  .add(item.price *
                                      itemsData[item.itemId]['quantity']);
                              (storeOrders[item.storeId]['itemsData']
                                      as Map<String, Map<String, dynamic>>)
                                  .putIfAbsent(
                                itemKey,
                                () => itemsData[itemKey],
                              );
                            } else {
                              if (item.store == null) {
                                var snapshot = await Firestore.instance
                                    .collection('stores')
                                    .document(item.storeId)
                                    .get();
                                item.store = Store.fromMap(snapshot.data);
                                deviceIds.addAll(item.store.deviceTokens);
                              } else if (item?.store?.deviceTokens != null &&
                                  item.store.deviceTokens.length > 0) {
                                deviceIds.addAll(item.store.deviceTokens);
                              } else {
                                var snapshot = await Firestore.instance
                                    .collection('stores')
                                    .document(item.storeId)
                                    .get();
                                item.store = Store.fromMap(snapshot.data);
                                deviceIds.addAll(item.store.deviceTokens);
                              }
                              OrderFromReceiveIt receiveIt = OrderFromReceiveIt(
                                destination: Utils.latLngFromString(
                                    orderData['destination']),
                                date: now,
                                deliveryTime: null,
                                email: order.email,
                                house: order.house,
                                price: item.price *
                                    itemsData[item.itemId]['quantity'],
                                orderId: orderData['orderId'],
                                pricePerItem: [item.price],
                                totalPricePerItem: [
                                  item.price *
                                      itemsData[item.itemId]['quantity']
                                ],
                                itemsData: {
                                  itemKey: itemsData[itemKey],
                                },
                                phoneNumber: order.phoneNumber,
                                userId: order.userId,
                              );
                              Map<String, dynamic> tempOrder =
                                  receiveIt.toMap();
                              tempOrder.putIfAbsent(
                                'storeId',
                                () => item.storeId,
                              );
                              tempOrder.putIfAbsent(
                                  'storeName', () => item.storeName);
                              tempOrder.putIfAbsent(
                                  'storeAddress', () => item.storeAddress);
                              tempOrder.putIfAbsent(
                                'storeLatLng',
                                () => Utils.latLngToString(
                                    item.store.storeLatLng),
                              );
                              storeOrders.putIfAbsent(
                                item.storeId,
                                () {
                                  return tempOrder;
                                },
                              );
                            }
                            // Map<String, dynamic> item = (await Firestore
                            //         .instance
                            //         .collection('items')
                            //         .document(itemKey)
                            //         .get())
                            // .data;
                            // LatLng latLng = Utils.latLngFromString(
                            //     orderData['destination']);
                            // String address = (await Geocoder.google(
                            //             await Utils.getAPIKey())
                            //         .findAddressesFromCoordinates(Coordinates(
                            //             latLng.latitude, latLng.longitude)))[0]
                            //     .addressLine;
                          }
                          Future<Response> request;
                          final _fcmServerKey = await Utils.getFCMServerKey();
                          storeOrders.forEach((k, v) {
                            var storeOrderRef = Firestore.instance
                                .collection('stores')
                                .document(k)
                                .collection('pendingOrderedItems')
                                .document(orderData['orderId']);

                            batch.setData(
                              storeOrderRef,
                              v,
                              merge: true,
                            );

                            // deviceIds.forEach((id) {
                            request = post(
                              'https://fcm.googleapis.com/fcm/send',
                              headers: <String, String>{
                                'Content-Type': 'application/json',
                                'Authorization': 'key=$_fcmServerKey',
                              },
                              body: jsonEncode(
                                <String, dynamic>{
                                  'notification': <String, dynamic>{
                                    'body': 'An Order is just Arrived',
                                    'title': 'Order'
                                  },
                                  'type': 'partnerStoreOrder',
                                  'priority': 'high',
                                  'data': <String, dynamic>{
                                    'click_action':
                                        'FLUTTER_NOTIFICATION_CLICK',
                                    'orderId': '${order.orderId}',
                                    'status': 'posted',
                                    'userId': order.userId,
                                  },
                                  'registration_ids': deviceIds,
                                },
                              ),
                            );
                            // });
                          });
                          var cartRef = Firestore.instance
                              .collection('carts')
                              .document(user.userId);
                          batch.delete(cartRef);
                          batch.commit().catchError((error) {
                            Utils.showSnackBarErrorUsingKey(
                                _key, 'error clearing cart');
                          }).then(
                            (_) async {
                              await Firestore.instance
                                  .collection('carts')
                                  .document(user.userId)
                                  .setData({}).catchError((error) {
                                Utils.showSnackBarErrorUsingKey(
                                    _key, 'error re initializing cart');
                              });
                              await request;
                              // Utils.showSnackBarSuccess(context, 'Order Submitted');
                              // Navigator.pop(context);
                              Session.data['cart'] = UserCart(itemsData: {});
                              Utils.showSuccessDialog(
                                  'Your Order is on its way!');
                              Future.delayed(Duration(seconds: 2)).then((_) {
                                BotToast.cleanAll();
                              });
                              try {
                                navigator.pushAndRemoveUntil(
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
                                  (route) {
                                    if (route?.settings?.name == null) {
                                      return false;
                                    }
                                    return route.settings.name == 'receiveIt';
                                  },
                                );
                              } on dynamic catch (_) {
                                navigator.pop();
                                BotToast.showText(
                                    text: _.toString(),
                                    duration: Duration(
                                      seconds: 10,
                                    ));
                              }
                            },
                          );
                        });
                      }
                    } on dynamic catch (ex) {
                      BotToast.showText(
                          text: ex.toString(), duration: Duration(seconds: 10));
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
      body: ShoppingCartRouteBody(
        demo: demo,
        key: _shoppingCartRouteBodyKey,
      ),
      bottomSheet: (demo != null && demo)
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
                            Navigator.pushNamed(context, MyApp.userSignIn);
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
      // 'FLWPUBK-fc9fc6e2a846ce0acde3e09e6ee9d11a-X', //<-Test //Live-> Version: 'FLWPUBK-dd01d6fa251fe0ce8bb95b03b0406569-X',
      encryptionKey: 'eded539f04b38a2af712eb7d',
      // '27e4c95e939cba30b53d9105' //<-Test ,//Live-> 'eded539f04b38a2af712eb7d',
    )
      ..country = "ZA"
      ..currency = "ZAR"
      ..displayEmail = true
      ..displayAmount = true
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
      ..companyName = Text('Sennit', style: Theme.of(context).textTheme.subhead)
      ..staging = false
      ..isPreAuth = false
      ..displayFee = true;

    // Initialize and get the transaction result
    RaveResult response = await RavePayManager()
        .prompt(context: context, initializer: initializer)
        .catchError((_) {
      // Utils.showSnackBarErrorUsingKey(_key, 'Error In RavePayManager');
      print("Unexpected Error in RavePayManager");
      return _;
    });
    print(response.message);

    // Utils.showSnackBarErrorUsingKey(
    //     _key, 'Error: ${response.status}, Message: ${response.message}');

    return <String, dynamic>{
      'status': response.status,
      'errorMessage': response.message,
    };
  }
}

class ShoppingCartRouteBody extends StatefulWidget {
  final bool demo;
  ShoppingCartRouteBody({Key key, @required this.demo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ShoppingCartRouteState(
      demo: demo,
    );
  }
}

class ShoppingCartRouteState extends State<ShoppingCartRouteBody> {
  bool pickFromDoor = true;
  bool deliverToDoor = true;
  double cardMargin = 10;
  double cardPadding = 20;
  double groupMargin = 30;
  double itemMargin = 10;
  List<TextEditingController> _controllers;
  List<TextEditingController> _flavourControllers;
  TextEditingController _emailController;
  TextEditingController _houseController;
  TextEditingController _phoneNumberController;
  bool boxSizeSmall = true;
  bool boxSizeMedium = false;
  bool boxSizeLarge = false;
  bool sleeveNeeded = false;
  bool demo;

  List<bool> isAnimationVisibleList = [];
  List<bool> isItemDeleteConfirmationVisibleList = [];

  List<bool> isButtonActiveList = [];

  var isLoadingBarVisibleList = [];

  ShoppingCartRouteState({
    @required this.demo,
  }) {
    _controllers = [];
    _flavourControllers = [];
    _emailController = TextEditingController();
    _houseController = TextEditingController();
    _phoneNumberController = TextEditingController();
  }

  @override
  void initState() {
    super.initState();
    if (demo == null || !widget.demo) {
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
      final TextEditingController flavourController = TextEditingController();
      _controllers.add(controller);
      _flavourControllers.add(flavourController);
      controller.text = cart.itemsData[key]['quantity'].toInt().toString();
      flavourController.text = cart.itemsData[key]['flavour'];
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
                          await Utils.getAPIKey(),
                        ).findAddressesFromCoordinates(coordinates))[0];
                        // if (mounted) {
                        // WidgetsBinding.instance.addPostFrameCallback((_) {
                        // if (mounted) {
                        try {
                          setState(() {});
                        } catch (ex) {
                          Future.delayed(Duration(seconds: 3), () {
                            if (mounted) {
                              setState(() {});
                            }
                          });
                        }
                        // }
                        // });
                        // }
                      }
                    },
                    leading: Icon(
                      Icons.location_on,
                      color: Theme.of(context).accentColor,
                    ),
                    title: Text(
                      ((ShoppingCartRoute._toAddress?.coordinates?.latitude ??
                                      0) ==
                                  0 &&
                              (ShoppingCartRoute
                                          ._toAddress?.coordinates?.longitude ??
                                      0) ==
                                  0)
                          ? 'Address Not Set'
                          : ShoppingCartRoute._toAddress?.addressLine ??
                              'Address Not Set',
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
  Map<String, Map<String, dynamic>> itemsData;
  double totalDeliveryCharges = 0;
  double totalPrice = 0;
  List<GlobalKey<CartItemState>> globalKeysForCartItem = [];
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
    // List<double> deliveryCharges = [];
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
                globalKeysForCartItem.add(GlobalKey<CartItemState>());
                // model.StoreItem item = items[index];
                totalPrice += items[index].price *
                    itemsData[items[index].itemId]['quantity'];
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
                      key: globalKeysForCartItem[index],
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
                      onFlavourChange: (index, value) async {
                        items[index].flavour = value;
                        await Firestore.instance
                            .collection('carts')
                            .document((Session.data['user'] as User).userId)
                            .setData(
                          {
                            'itemsData': {
                              items[index].itemId: {
                                'flavour': value,
                                'quantity':
                                    items[index].quantity?.toDouble() ?? 1,
                              },
                            }
                          },
                          merge: true,
                        );
                        itemsData.update(items[index].itemId, (a) {
                          return {
                            'quantity': (items[index]?.quantity ?? 0) == 0
                                ? 1
                                : items[index].quantity,
                            'flavour': value ?? '',
                          };
                        }, ifAbsent: () {
                          return {
                            'quantity': (items[index]?.quantity ?? 0) == 0
                                ? 1
                                : items[index].quantity,
                            'flavour': value ?? '',
                          };
                        });
                      },
                      onQuantityChange: (value, index) async {
                        if (value == null || value == 0) {
                          return;
                        }
                        items[index].quantity = value.toDouble();
                        Firestore.instance
                            .collection('carts')
                            .document((Session.data['user'] as User).userId)
                            .setData(
                          {
                            'itemsData': {
                              items[index].itemId: {
                                'quantity': value?.toDouble() ?? 1,
                                'flavour': items[index]?.flavour ?? '',
                              },
                            }
                          },
                          merge: true,
                        );
                        itemsData.update(items[index].itemId, (a) {
                          return {
                            'quantity': value?.toDouble() ?? 1,
                            'flavour': items[index].flavour ?? '',
                          };
                        });
                        totalPrice = 0;
                        for (var item in items) {
                          totalPrice +=
                              item.price * itemsData[item.itemId]['quantity'];
                        }
                        totalPrice += totalDeliveryCharges;

                        // if (value != null) {
                        //   totalPrice += item.price * value;
                        setState(() {});
                        // }
                      },
                      item: items[index],
                      controller: _controllers[index],
                      flavourController: _flavourControllers[index],
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
                                              mainAxisSize: MainAxisSize.min,
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
                                                              Map<String,
                                                                  dynamic>>.from(
                                                            cart.itemsData,
                                                          );

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
                                                              items[index]
                                                                  .itemId,
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
                                                              _flavourControllers
                                                                  .removeAt(
                                                                      index);
                                                              print(_controllers
                                                                  .length);
                                                              print(
                                                                  _flavourControllers
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
                      '''${ShoppingCartRoute._toAddress == null ? 'Select a Destination' : ((ShoppingCartRoute._toAddress?.coordinates?.latitude ?? 0) == 0 && (ShoppingCartRoute._toAddress?.coordinates?.longitude ?? 0) == 0) ? 'Select a Destination' : getDeliveryCharges()}''',
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
                    'Total\n${totalDeliveryCharges.toStringAsFixed(2)} R',
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
        Coordinates coordinates =
            ShoppingCartRoute?._toAddress?.coordinates ?? Coordinates(0, 0);
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
  final Function(int value, int index) onQuantityChange;
  final Function(int index, String value) onFlavourChange;
  final _quantityFocusNode = FocusNode();
  final _flavourFocusNode = FocusNode();
  final GlobalKey<CartItemState> key;
  final TextEditingController flavourController;
  CartItem({
    this.key,
    this.item,
    this.controller,
    this.flavourController,
    this.itemIndex,
    @required this.onQuantityChange,
    @required this.onDelete,
    @required this.onFlavourChange,
  }) : super(key: key) {
    UserCart cart = Session.data['cart'];
    // controller.removeListener(() {});
    // flavourController.removeListener((){});
    controller.addListener(() {
      if (controller.text == null || controller.text.isEmpty) {
        return;
      }
      int value = int.parse(controller.text);
      if (value <= 0) {
        controller.text = '1';
        cart.itemsData[item.itemId].update(
          'quantity',
          (old) => 1,
          ifAbsent: () => 1,
        );
        onQuantityChange(1, itemIndex);
      } else if (value > 99) {
        cart.itemsData[item.itemId].update(
          'quantity',
          (old) => 99,
          ifAbsent: () => 99,
        );
        onQuantityChange(99, itemIndex);
      } else {
        cart.itemsData[item.itemId].update(
          'quantity',
          (old) => value.toDouble(),
          ifAbsent: () => value.toDouble(),
        );
        onQuantityChange(value, itemIndex);
      }
    });
    _quantityFocusNode.addListener(() {
      if (controller.text == '') {
        controller.text = '1';
      }
      key?.currentState?.refresh();
    });
    _flavourFocusNode.addListener(() {
      if (!_flavourFocusNode.hasFocus) {
        cart.itemsData[item.itemId].update(
          'flavour',
          (old) => flavourController?.text ?? '',
          ifAbsent: () => flavourController?.text ?? '',
        );
        onFlavourChange(itemIndex, flavourController?.text ?? '');

        key?.currentState?.refresh();
      }
    });
  }

  @override
  State<StatefulWidget> createState() {
    return CartItemState();
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
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
                                      var value =
                                          int.parse(widget.controller.text);
                                      if (int.parse(widget.controller.text) ==
                                          1) {
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
                                        WhitelistingTextInputFormatter
                                            .digitsOnly,
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
                                      var value =
                                          int.parse(widget.controller.text);
                                      if (int.parse(widget.controller.text) ==
                                          99) {
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
                                    Future.delayed(Duration(seconds: 1))
                                        .then((_) {
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
                            'Price: R${widget.item.price.toInt()} per Item',
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
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: widget.flavourController,
              focusNode: widget._flavourFocusNode,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Flavour',
                helperText:
                    'Add your Flavour here. If Applicable. For Food Deliveries Only',
              ),
              // onEditingComplete: () {
              //   widget.onFlavourChange(
              //       widget.itemIndex, widget.flavourController.text ?? '');
              // },
            ),
          ],
        ),
      ),
    );
  }
}
