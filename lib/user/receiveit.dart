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
import 'package:get_it/get_it.dart';
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
import 'package:sennit/rx_models/rx_config.dart';
import 'package:sennit/rx_models/rx_connectivity.dart';
import 'package:sennit/rx_models/rx_receiveit_tab.dart';
import 'package:sennit/rx_models/rx_storesAndItems.dart';
import 'package:sennit/rx_models/rx_searchbar_title.dart';
import 'package:sennit/user/past_orders.dart';
import 'package:shortid/shortid.dart';
import '../main.dart';
import 'package:sennit/rx_models/rx_address.dart';
import 'generic_tracking_screen.dart';

class ReceiveItRoute extends StatelessWidget {
  final drawerNameController = TextEditingController();
  static List<Widget> _tabs;
  final bool demo;
  final TabController tabController;
  // static int currentTab = 0;
  static Future<void> _authCheck;
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
    // await MyApp.futureCart;
  }

  ReceiveItRoute({
    @required this.demo,
    @required this.tabController,
  }) {
    _tabs = [];
    Session.data.putIfAbsent(
      'cart',
      () => UserCart(
        itemsData: model.StoreToReceiveItOrderItems(
          itemDetails: {},
        ),
      ),
    );
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
              // key: storesRouteKey,
              // address: null,
              isDemo: demo,
            ),
          )
          ..add(
            SearchWidget(
              demo: demo,
              backPressed: () {
                GetIt.I.get<RxReceiveItTab>().index.add(0);
                _BodyState._controller?.animateTo(0);
              },
            ),
          );
      });
    } else {
      drawerNameController.text = ((Session.data['user']) as User).fullName;
      _tabs
        ..add(
          StoresRoute(
            // key: storesRouteKey,
            // address: null,
            isDemo: demo,
          ),
        )
        ..add(SearchWidget(
          demo: demo,
          backPressed: () {
            GetIt.I.get<RxReceiveItTab>().index.add(0);
            _BodyState._controller?.animateTo(0);
          },
        ))
        ..add(
          UserNotificationWidget(
            backPressed: () {
              GetIt.I.get<RxReceiveItTab>().index.add(0);
              _BodyState._controller?.animateTo(0);
            },
          ),
        )
        ..add(
          PastOrdersRoute(
            backPressed: () {
              GetIt.I.get<RxReceiveItTab>().index.add(0);
              _BodyState._controller?.animateTo(0);
            },
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = Session.data['user'];
    // RxReceiveItTab rxReceiveItTab = GetIt.I.get<RxReceiveItTab>();
    // print('currentTab: $currentTab ${titles[currentTab]}');
    return Scaffold(
      appBar: MySearchAppBar(
        // key: searchBarKey,
        centerTitle: true,
        onQuery: (text) {
          // filtered.clear();
          RxStoresAndItems rxStoresAndItems = GetIt.I.get<RxStoresAndItems>();
          // rxStoresAndItems.queryStores.add(text);
          rxStoresAndItems.setStoreQuery(text);
        },
        leading: InkWell(
          onTap: () {
            if (demo) {
              tabController?.animateTo(0);
            } else {
              RxReceiveItTab rxReceiveItTab = GetIt.I.get<RxReceiveItTab>();
              if (rxReceiveItTab.currentIndex != 0) {
                rxReceiveItTab.index.add(0);
                _BodyState._controller.animateTo(0);
              } else {
                Navigator.of(context).pop();
              }
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
        onPressed: () async {
          Address address = Utils.getLastKnowAddress();
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShoppingCartRoute(
                  // onAddressChange: (address) {},
                  toAddress: address,
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
              // onTabChange: (index) {
              //   GetIt.I.get<RxReceiveItTab>().setCurrentIndex(index);
              // },
              );
        },
      ),
    );
  }
}

class MySearchAppBar extends StatefulWidget with PreferredSizeWidget {
  final Widget leading;
  final bool centerTitle;
  final Function(String searchString) onQuery;

  MySearchAppBar({
    Key key,
    this.leading,
    this.centerTitle,
    this.onQuery,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MySearchAppBarState();
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class MySearchAppBarState extends State<MySearchAppBar> {
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

  MySearchAppBarState();

  @override
  Widget build(BuildContext context) {
    RxReceiveItSearchBarTitle barTitle =
        GetIt.I.get<RxReceiveItSearchBarTitle>();
    RxReceiveItTab rxReceiveItTab = GetIt.I.get<RxReceiveItTab>();
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.centerRight,
      children: <Widget>[
        AppBar(
          title: StreamBuilder<String>(
            stream: barTitle.title$,
            builder: (context, snapshot) {
              return Text(snapshot?.data ?? '');
            },
          ),
          centerTitle: widget.centerTitle ?? false,
          leading: widget.leading,
          actions: <Widget>[
            StreamBuilder<int>(
              stream: rxReceiveItTab.index$,
              initialData: 0,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data == 0) {
                  return FlatButton(
                    onPressed: () {
                      this.showSearchBar();
                    },
                    child: Icon(Icons.search),
                  );
                } else
                  return Opacity(opacity: 0);
              },
            ),
            // searchEnabled
            //     ? FlatButton(
            //         onPressed: () {
            //           this.showSearchBar();
            //         },
            //         child: Icon(Icons.search),
            //       )
            //     : SizedBox(
            //         height: 0,
            //         width: 0,
            //       ),
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

class _Body extends StatefulWidget {
  // final List<Widget> tabs = [];
  // final Function(int) onTabChange;

  const _Body();

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
      initialIndex: GetIt.I.get<RxReceiveItTab>().currentIndex,
    );
    _controller.addListener(_handleTabChange);

    super.initState();
  }

  void _handleTabChange() {
    // _BottomNavigationState._index = _controller.index;
    var rxReceiveItTab = GetIt.I.get<RxReceiveItTab>();
    rxReceiveItTab.setCurrentIndex(_controller.index);
    // widget.onTabChange(_controller.index);
    // try {
    //   _BottomNavigationState._bottomNavigationState.rebuild();
    // } on dynamic catch (_) {
    //   print(_);
    // }
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

  // setState() {
  //   _key?.currentState?.rebuild();
  // }
}

class _BottomNavigationState extends State<_StatefulBottomNavigation> {
  // static int _index;
  final bool demo;
  static _BottomNavigationState _bottomNavigationState;
  _BottomNavigationState(this.demo);

  // rebuild() {
  //   setState(() {});
  // }

  @override
  void initState() {
    _bottomNavigationState = this;
    // _index = GetIt.I.get<RxReceiveItTab>().currentIndex;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _bottomNavigationState = null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        initialData: GetIt.I.get<RxReceiveItTab>().currentIndex,
        stream: GetIt.I.get<RxReceiveItTab>().index$,
        builder: (context, snapshot) {
          int _index = snapshot.data;
          return BottomNavigationBar(
            currentIndex: _index,
            onTap: (index) {
              if (index != _index) {
                _BodyState._controller.animateTo(index);
                GetIt.I.get<RxReceiveItTab>().index.add(index);
                // setState(() {
                //   _index = index;
                // });
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
                      title:
                          Text('Search', style: TextStyle(color: Colors.black)),
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
                      title: Text('Notification',
                          style: TextStyle(color: Colors.black)),
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
                      title: Text('Past Order',
                          style: TextStyle(color: Colors.black)),
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
                      title:
                          Text('Search', style: TextStyle(color: Colors.black)),
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
        });
  }
}

class StoresRoute extends StatefulWidget {
  // final Address address;
  final bool isDemo;
  StoresRoute({
    Key key,
    // @required this.address,
    @required this.isDemo,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StoresRouteState();
  }
}

class StoresRouteState extends State<StoresRoute> {
  StoresRouteState();
  RxAddress addressService = GetIt.I.get<RxAddress>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, Store>>(
      stream: GetIt.I.get<RxStoresAndItems>().filteredStores.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Unable to Fetch Stores. Please Check you Network Connection',
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        Map<String, Store> allStores = snapshot?.data ?? {};
        var keys = allStores?.keys?.toList() ?? [];
        RxAddress rxAddress = GetIt.I.get<RxAddress>();
        Map<String, dynamic> config = GetIt.I.get<RxConfig>().config.value;
        return StreamBuilder<Map<String, Address>>(
          stream: rxAddress.stream$,
          builder: (context, addressSnapshot) {
            if (addressSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child:
                      CircularProgressIndicator(backgroundColor: Colors.black));
            }
            Map<String, Store> filtered = {};
            var filteredKeys = [];
            for (String key in keys) {
              LatLng storeLatLng = allStores[key].storeLatLng;
              LatLng myLatLng = Utils.latLngFromCoordinates(
                  addressSnapshot.data['myAddress'].coordinates);
              if (Utils.calculateDistance(storeLatLng, myLatLng) <=
                      config['receiveItMinimumStoreDistance'] ??
                  15) {
                filteredKeys.add(key);
                filtered.putIfAbsent(key, () => allStores[key]);
              }
            }
            return (filtered?.length ?? 0) <= 0
                ? Center(child: Text('No Stores Available Near You '))
                : SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: List.generate(
                        filtered.length,
                        (int i) {
                          String storeKey = filteredKeys[i];
                          return IgnorePointer(
                            ignoring: !filtered[storeKey].isOpened,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return StoreMainPage(
                                        store: filtered[storeKey],
                                        demo: widget.isDemo ?? false,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 10),
                                child: StoreItem(
                                  store: filtered[storeKey],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
          },
        );
      },
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
}

class StoreItem extends StatelessWidget {
  // final bool dummyPic;
  final Store store;
  final demo;
  StoreItem({this.store, this.demo});

  @override
  Widget build(BuildContext context) {
    RxStoresAndItems storesAndItems = GetIt.I.get<RxStoresAndItems>();
    Map<String, model.StoreItem> items = storesAndItems?.items?.value ?? {};
    return IgnorePointer(
      ignoring: !(store?.isOpened ?? false),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Card(
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
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
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
                          itemCount:
                              store.items.length > 5 ? 5 : store.items.length,
                          itemBuilder: (context, index) {
                            print(store.toString());
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
                                              '${(items[store.items[index]]?.images == null || items[store.items[index]].images.length == 0) ? '' : items[store.items[index]].images[0]}',
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
                                              items[store.items[index]]
                                                  .itemName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1,
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              "R${items[store.items[index]].price.toInt()}",
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
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ItemDetailsRoute(
                                          item: items[store.items[index]],
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
          ),
          (store?.isOpened ?? false)
              ? Opacity(opacity: 0)
              : Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.grey[100].withAlpha(120),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.grey,
                      height: 40.0,
                      alignment: Alignment.center,
                      child: Text(
                        'Store is Closed',
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
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
                  toAddress: Utils.getLastKnowAddress(),
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
                      style: Theme.of(context).textTheme.headline6,
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
          items: widget.store.items,
          isDemo: widget.isDemo ?? false,
        ),
      ],
    );
  }
}

class MenuCategorize extends StatelessWidget {
  final List<String> items;
  final bool isDemo;
  final RxStoresAndItems storesAndItems = GetIt.I.get<RxStoresAndItems>();
  MenuCategorize({
    Key key,
    @required this.items,
    @required this.isDemo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, model.StoreItem> allItems = storesAndItems.items.value;
    return Column(
      children: List.generate(items.length, (index) {
        return InkWell(
          child: MenuItem(
            item: allItems[items[index]],
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return ItemDetailsRoute(
                    item: allItems[items[index]],
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
                    style: Theme.of(context).textTheme.subtitle1,
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
  Future<DocumentSnapshot> refreshStore;
  BottomSheetButtonState();
  @override
  void initState() {
    super.initState();
    isInCart = searchItemInCart();
    refreshStore = initialize();
  }

  searchItemInCart() {
    model.StoreItem item = ItemDetailsRoute._item;
    UserCart cart = Session.data['cart'];
    if (cart == null) {
      return false;
    }
    bool found = false;
    if ((cart?.itemsData?.itemDetails ?? {})[item.storeId]
            ?.itemDetails
            ?.containsKey(item.itemId) ??
        false) {
      found = true;
    }
    return found;
  }

  Future<DocumentSnapshot> initialize() async {
    return await Firestore.instance
        .collection('stores')
        .document(ItemDetailsRoute._item.storeId)
        .get(
          source: Source.server,
        )
        .catchError((error) {
      Utils.showSnackBarError(null, error.toString());
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: refreshStore,
        builder: (context, snapshot) {
          if (snapshot.data == null) {}
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: Center(
                child: Text('Loading.....'),
              ),
            );
          }
          Store store = Store.fromMap(snapshot?.data?.data ?? {});
          return Padding(
            padding: EdgeInsets.all(0),
            child: StreamBuilder<DocumentSnapshot>(
                stream: Firestore.instance
                    .collection('items')
                    .document(ItemDetailsRoute._item.itemId)
                    .snapshots(),
                builder: (context, itemSnapshot) {
                  bool isWaiting = false;
                  bool error = false;
                  model.StoreItem item;
                  if (itemSnapshot.connectionState == ConnectionState.waiting &&
                      !itemSnapshot.hasData) {
                    isWaiting = true;
                  } else if (!itemSnapshot.hasData || itemSnapshot.hasError) {
                    error = true;
                  } else {
                    item = model.StoreItem.fromMap(itemSnapshot.data.data);
                  }
                  bool inStock = (item?.remainingInStock ?? 0) > 0;
                  return InkWell(
                    child: Container(
                      color: (store?.isOpened ?? false)
                          ? isWaiting
                              ? Colors.white
                              : error
                                  ? Colors.red
                                  : !inStock
                                      ? Colors.red
                                      : isInCart ? Colors.green : Colors.white
                          : Colors.red,
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: addingToCart
                          ? CircularProgressIndicator()
                          : Text(
                              (store?.isOpened ?? false)
                                  ? isWaiting
                                      ? 'Checking stock'
                                      : error
                                          ? 'Error Fetching Stock ...'
                                          : !inStock
                                              ? 'Out of Stock'
                                              : isInCart
                                                  ? 'Added to Cart'
                                                  : 'Add to Cart'
                                  : 'Store is Closed',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                    ),
                    onTap: (isWaiting || error || !inStock)
                        ? null
                        : () async {
                            if (!(store?.isOpened ?? false)) {
                              return;
                            }
                            setState(() {
                              addingToCart = true;
                            });

                            UserCart cart = Session.data['cart'];
                            if (cart == null) {
                              cart = UserCart(
                                  itemsData: model.StoreToReceiveItOrderItems(
                                itemDetails: {},
                              ));
                              Session.data.putIfAbsent('cart', () {
                                return cart;
                              });
                            }
                            if (!isInCart) {
                              cart.itemsData.itemDetails.putIfAbsent(
                                ItemDetailsRoute._item.storeId,
                                () => model.ReceiveItOrderItem(itemDetails: {}),
                              );
                              cart
                                  .itemsData
                                  .itemDetails[ItemDetailsRoute._item.storeId]
                                  .itemDetails
                                  .update(
                                ItemDetailsRoute._item.itemId,
                                (x) => model.ReceiveItOrderItemDetails(
                                  flavour: '',
                                  quantity: 1,
                                ),
                                ifAbsent: () => model.ReceiveItOrderItemDetails(
                                  flavour: '',
                                  quantity: 1,
                                ),
                              );
                              // cart.items.add(ItemDetailsRoute._item);
                              setState(() {
                                addingToCart = false;
                                isInCart = true;
                              });
                            } else {
                              // cart.items.removeWhere(
                              //   (item) => item.itemId == ItemDetailsRoute._item.itemId,
                              // );
                              cart
                                  .itemsData
                                  .itemDetails[ItemDetailsRoute._item.storeId]
                                  .itemDetails
                                  .removeWhere(
                                (key, value) =>
                                    key == ItemDetailsRoute._item.itemId,
                              );
                              // cart.quantities.removeAt(index);
                              setState(() {
                                addingToCart = false;
                                isInCart = false;
                              });
                            }
                          },
                  );
                }),
          );
        });
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
      floatingActionButton: FloatingMenu(
        onRouteChange: () {
          // setState(() {});
        },
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
  final Function() onRouteChange;
  FloatingMenu({
    Key key,
    @required this.onRouteChange,
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
                },
        ),
        SpeedDialChild(
          child: Icon(Icons.shopping_cart),
          backgroundColor: Colors.white,
          foregroundColor: Theme.of(context).primaryColor,
          label: 'Goto Cart',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () async {
            Address address = Utils.getLastKnowAddress();
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShoppingCartRoute(
                  toAddress: address,
                  demo: widget.demo,
                ),
                maintainState: false,
              ),
            );
            widget.onRouteChange();
          },
        ),
      ],
    );
  }
}

class _ItemDetailsBody extends StatefulWidget {
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
                  style: Theme.of(context).textTheme.headline6,
                ),
                collapseMode: CollapseMode.pin,
                background: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        enlargeCenterPage: true,
                      ),
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
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
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
                                style: Theme.of(context).textTheme.headline6,
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
                              style: Theme.of(context).textTheme.bodyText2,
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
                            .get()
                            .catchError((error) {
                          BotToast.showText(text: error.toString());
                          throw error;
                        }),
                        builder: (context,
                            AsyncSnapshot<DocumentSnapshot> asyncData) {
                          if (asyncData.connectionState ==
                              ConnectionState.waiting) {
                            return widget._getProgressBar();
                          } else if (asyncData.hasData) {
                            List<String> keys =
                                asyncData.data?.data?.keys?.toList() ?? [];
                            if (keys.length <= 0) {
                              return Center(child: Text('No Review Yet'));
                            }
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
                                                borderRadius: BorderRadius.all(
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
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    '${review.reviewedBy}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle1,
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
                          } else if (asyncData.hasError) {
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
                          } else {
                            return Center(child: Text('No Review Yet'));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
}

class ShoppingCartRoute extends StatefulWidget {
  final Address toAddress;
  final bool demo;
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  ShoppingCartRoute({
    @required this.toAddress,
    @required this.demo,
    // @required this.onAddressChange,
  });
  @override
  State<StatefulWidget> createState() {
    return ShoppingCartRouteState();
  }
}

class ShoppingCartRouteState extends State<ShoppingCartRoute> {
  ShoppingCartRouteState();
  var _shoppingCartRouteBodyKey = GlobalKey<ShoppingCartRouteBodyState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _shoppingCartRouteBodyKey = null;
  }

  @override
  Widget build(BuildContext context) {
    Address toAddress = GetIt.I.get<RxAddress>().currentToAddress;
    Map<String, dynamic> config = GetIt.I.get<RxConfig>().config.value;
    return Scaffold(
      key: widget._key,
      appBar: AppBar(
        actions: <Widget>[
          ((widget.demo == null || !widget.demo) &&
                  config['maintenanceNotice'] == null)
              ? FlatButton(
                  onPressed: () async {
                    RxConfig config = GetIt.I.get<RxConfig>();
                    if (config.config.value['maintenanceNotice'] != null) {
                      Utils.showInfoDialog(
                          "We Are Sorry!\nThe app is undergoing maintenance on ${config.config.value['maintenanceNotice']}. New Orders are closed.");
                      return;
                    }
                    try {
                      bool networkState =
                          GetIt.I.get<RxConnectivity>().currentState;
                      if (!networkState) {
                        Utils.showSnackBarError(
                            context, 'No Internet Connection');
                        return;
                      }
                      Utils.showLoadingDialog(context);
                      NavigatorState navigator = Navigator.of(context);
                      ShoppingCartRouteBodyState state =
                          _shoppingCartRouteBodyKey.currentState;
                      String email = state._emailController?.text?.trim() ?? '';
                      String phoneNumber =
                          state._phoneNumberController?.text?.trim() ?? '';
                      String house = state._houseController?.text?.trim() ?? '';
                      UserCart cart = Session.data['cart'];
                      if (email == null || email.isEmpty) {
                        Utils.showSnackBarErrorUsingKey(
                          null,
                          'Please Provide your email Address',
                        );
                        BotToast.closeAllLoading();
                        // Navigator.pop(context);
                        return;
                      } else if (phoneNumber == "" || phoneNumber == null) {
                        Utils.showSnackBarErrorUsingKey(
                          null,
                          'Please Provide your Phone Number',
                        );
                        BotToast.closeAllLoading();
                        // Navigator.pop(context);
                        return;
                      } else if (phoneNumber.length != 10 ||
                          !phoneNumber.startsWith('0')) {
                        Utils.showSnackBarErrorUsingKey(
                          null,
                          'The Phone number Should start with 0 and Should Contain total of 10 digits',
                        );
                        BotToast.closeAllLoading();
                        // Navigator.pop(context);
                        return;
                      } else if (!Utils.isEmailCorrect(email)) {
                        Utils.showSnackBarErrorUsingKey(
                          null,
                          'Invalid Email Format',
                        );
                        BotToast.closeAllLoading();
                        // Navigator.pop(context);
                        return;
                      } else if (cart.itemsData == null ||
                          cart.itemsData.itemDetails.length == 0) {
                        BotToast.closeAllLoading();
                        // Navigator.pop(context);

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
                              BotToast.closeAllLoading();
                              navigator.popUntil((route) {
                                return route.settings.name == 'receiveIt';
                              });
                            },
                          ),
                        );
                        return;
                      } else if (toAddress == null) {
                        Utils.showSnackBarError(
                          null,
                          'Please Select a Destination First!',
                        );
                        BotToast.closeAllLoading();

                        return;
                      }
                      Utils.showLoadingDialog(context);

                      model.StoreToReceiveItOrderItems
                          storeToReceiveItOrderItems = cart.itemsData;

                      var storeIds =
                          storeToReceiveItOrderItems.itemDetails.keys;

                      List<model.StoreItem> itemModified = [];

                      for (var storeId in storeIds) {
                        Map<String, model.ReceiveItOrderItemDetails> details =
                            storeToReceiveItOrderItems
                                .itemDetails[storeId].itemDetails;
                        final itemIds = details.keys;
                        for (var itemId in itemIds) {
                          try {
                            var itemRef = Firestore.instance
                                .collection('items')
                                .document(itemId);
                            await Firestore.instance
                                .runTransaction((transaction) async {
                              int quantity = storeToReceiveItOrderItems
                                  .itemDetails[storeId]
                                  .itemDetails[itemId]
                                  .quantity;
                              var data = await transaction.get(itemRef);
                              print("Got Data:${data.data.toString()}");
                              // if (!data.exists) {
                              //   throw PlatformException(
                              //     code: "Error finding Document",
                              //     message: "Data not found",
                              //   );
                              // }
                              if (quantity > (data.data['remainingInStock'])) {
                                // transaction.set(itemRef, data.data);
                                throw PlatformException(
                                  code: "Transaction Failed",
                                  message:
                                      "Available items are less than items Ordered",
                                );
                              } else {
                                model.StoreItem item =
                                    model.StoreItem.fromMap(data.data);
                                item.remainingInStock -= quantity;
                                transaction
                                    .set(itemRef, item.toMap())
                                    .then((value) => itemModified.add(item));
                              }
                              return {};
                            });
                          } catch (ex) {
                            for (final item in itemModified) {
                              Firestore.instance
                                  .runTransaction((transaction) async {
                                final itemRef = Firestore.instance
                                    .collection('items')
                                    .document(item.itemId);
                                var data = await transaction.get(itemRef);
                                if (data.exists) {
                                  model.StoreItem newItem =
                                      model.StoreItem.fromMap(data.data);
                                  newItem.remainingInStock +=
                                      storeToReceiveItOrderItems
                                          .itemDetails[item.storeId]
                                          .itemDetails[item.itemId]
                                          .quantity;
                                  transaction.set(itemRef, newItem.toMap());
                                }
                              });
                            }
                            Utils.showSnackBarError(context, ex.toString());
                            print(ex.runtimeType == PlatformException
                                ? ex.message
                                : ex.toString());
                            return;
                          }
                        }
                      }

                      BotToast.closeAllLoading();

                      double totalCharges =
                          state.totalPrice;
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
                            null, 'Payment Cancelled');
                        // navigator.pop();
                        await fixStock();
                        BotToast.closeAllLoading();
                        return;
                      } else if (result['status'] == RaveStatus.error) {
                        Utils.showSnackBarErrorUsingKey(
                          null,
                          result['errorMessage'],
                        );
                        await fixStock();
                        BotToast.closeAllLoading();
                        return;
                      } else {
                        Utils.showSnackBarSuccessUsingKey(
                            null, 'Payment Successful');
                      }

                      User user = Session.data['user'];
                      model.OrderFromReceiveIt order =
                          model.OrderFromReceiveIt();
                      // List<model.StoreItem> items = cart.items;
                      // double price = totalCharges;

                      List<LatLng> pickups = [];
                      StoreToReceiveItOrderItems itemsData = cart.itemsData;
                      order.pickups = pickups;
                      // List<String> stores = [];
                      List<double> pricePerItem = [];
                      List<double> totalPricePerItem = [];
                      RxStoresAndItems storesAndItems =
                          GetIt.I.get<RxStoresAndItems>();
                      Map<String, model.StoreItem> itemsMap =
                          storesAndItems.items.value;
                      // order.stores = stores;
                      for (var storeId in itemsData.itemDetails.keys) {
                        for (var itemId in itemsData
                            .itemDetails[storeId].itemDetails.keys) {
                          model.StoreItem item = itemsMap[itemId];
                          itemsData.itemDetails[storeId].itemDetails[itemId]
                              .price = item.price;
                          // price += item.price *
                          //     (itemsData.itemDetails[item.itemId]
                          //             .itemDetails['quantity'] as num)
                          //         .toDouble();
                          pickups.add(item.latlng);
                          pricePerItem.add(item.price);
                          totalPricePerItem.add(
                            item.price *
                                itemsData.itemDetails[storeId]
                                    .itemDetails[itemId].quantity,
                          );
                        }
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
                      order.price = totalCharges;
                      order.status = 'Pending';
                      order.destination = LatLng(
                        toAddress?.coordinates?.latitude ?? 0,
                        toAddress?.coordinates?.longitude ?? 0,
                      );
                      String otp = randomAlphaNumeric(6).toUpperCase();
                      var url =
                          "https://www.budgetmessaging.com/sendsms.ashx?user=sennit2020&password=29200613&cell=${order.phoneNumber}&msg=Hello Your Sennit OTP is \n$otp\n";
                      var response = post(
                        url,
                      ).catchError((_) {
                        print(_.toString());
                      });
                      // final response = Response('', 200);

                      // if (response.statusCode == 200 ||
                      //     response.statusCode == 201 ||
                      //     response.statusCode == 202) {
                      // } else {
                      //   int count = 0;
                      //   while (response.statusCode != 200 &&
                      //       response.statusCode != 201 &&
                      //       response.statusCode != 202 &&
                      //       count < 0) {
                      //     count++;
                      //     Utils.showSnackBarErrorUsingKey(
                      //         null, 'Unable to send OTP! Retrying!');
                      //     BotToast.showNotification(
                      //       title: (_) {
                      //         return Text("Otp Sending Failed");
                      //       },
                      //       duration: Duration(seconds: 4),
                      //       align: Alignment.bottomCenter,
                      //       subtitle: (_) => Text("Retrying Attempt: $count"),
                      //     );

                      //     var url =
                      //         "https://www.budgetmessaging.com/sendsms.ashx?user=sennit2020&password=29200613&cell=${order.phoneNumber}&msg=Hello Your Sennit OTP is \n$otp\n";
                      //     response = await post(
                      //       url,
                      //     ).catchError((_) {});
                      //   }
                      //   if (count >= 1) {
                      //     BotToast.showNotification(
                      //       title: (_) {
                      //         return Text("Otp Sending Failed");
                      //       },
                      //       duration: Duration(seconds: 4),
                      //       align: Alignment.bottomCenter,
                      //       subtitle: (_) => Text(
                      //           "Please Manually send the OTP\nYour OTP is $otp."),
                      //     );
                      //   }
                      // }

                      var now = DateTime.now().toUtc();
                      String orderId =
                          '${user.userId}${now.millisecondsSinceEpoch ~/ 1000}';

                      order.orderId = orderId;
                      String shortId = shortid.generate();
                      order.shortId = shortId;
                      // Map<String, dynamic> orderData = order.toMap();
                      order.otp = otp;
                      order.stores = order.itemsData.itemDetails.keys.toList();
                      // orderData.putIfAbsent(
                      //   'stores',
                      //   () => order.itemsData.itemDetails.keys.toList(),
                      // );
                      // StoreToReceiveItOrderItems storeToReceiveItOrderItems =
                      //     order.itemsData;
                      Map<String, Store> allStores =
                          GetIt.I.get<RxStoresAndItems>().stores.value;
                      List<String> deviceTokens = [];
                      List<String> allItemsInOrder = [];
                      storeToReceiveItOrderItems.itemDetails
                          .forEach((key, value) {
                        List<String> itemKeys = value.itemDetails.keys.toList();
                        allItemsInOrder.addAll(itemKeys);
                        deviceTokens.addAll(allStores[key].deviceTokens);
                      });
                      Map<String, dynamic> orderData = order.toMap();
                      orderData.putIfAbsent('itemKeys', () => allItemsInOrder);
                      String _fcmServerKey = await Utils.getFCMServerKey();
                      Future request = post(
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
                              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                              'orderId': '${order.orderId}',
                              'status': 'posted',
                              'userId': order.userId,
                            },
                            'registration_ids': deviceTokens,
                          },
                        ),
                      );
                      // orderData.putIfAbsent('status', () => 'Pending');
                      await Firestore.instance
                          .collection('orders')
                          .document(order.orderId)
                          .setData(orderData);
                      await request;

                      BotToast.closeAllLoading();
                      await response;
                      cart.itemsData.itemDetails.clear();
                      try {
                        navigator.pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) {
                              return OrderTracking(
                                type: OrderTrackingType.RECEIVE_IT,
                                data: orderData,
                              );
                            },
                            settings: RouteSettings(name: OrderTracking.NAME),
                          ),
                          (route) {
                            if (route?.settings?.name == null) {
                              return false;
                            }
                            return route.settings.name == 'receiveIt';
                          },
                        );
                      } catch (ex) {
                        navigator.pop();
                        print(ex.toString());
                      }

                      // var postedOrderRef = Firestore.instance
                      //     .collection('postedOrders')
                      //     .document(orderId);
                      // var batch = Firestore.instance.batch();
                      // batch.setData(postedOrderRef, orderData);
                      // var userOrderRef = Firestore.instance
                      //     .collection("users")
                      //     .document(user.userId)
                      //     .collection('orders')
                      //     .document(orderId);

                      // batch.setData(
                      //   userOrderRef,
                      //   orderData,
                      //   merge: true,
                      // );
                      // Map<String, dynamic> storeOrders = {};
                      // List<String> deviceIds = [];

                      // for (model.StoreItem item in items) {
                      //   final itemKey = item.itemId;
                      //   if (storeOrders.containsKey(item.storeId)) {
                      //     double price = storeOrders[item.storeId]['price'];
                      //     price += item.price *
                      //         itemsData.itemDetails[item.storeId]
                      //             .itemDetails[item.itemId].quantity;
                      //     storeOrders[item.storeId].update(
                      //         'price', (old) => price,
                      //         ifAbsent: () => price);
                      //     storeOrders[item.storeId]['pricePerItem']
                      //         .add(item.price);
                      //     storeOrders[item.storeId]['totalPricePerItem'].add(
                      //       item.price *
                      //           itemsData.itemDetails[item.storeId]
                      //               .itemDetails[item.itemId].quantity,
                      //     );
                      //     (storeOrders[item.storeId]['itemsData']
                      //             as Map<String, Map<String, dynamic>>)
                      //         .putIfAbsent(
                      //       itemKey,
                      //       () => itemsData[itemKey],
                      //     );
                      //   } else {
                      //     RxStoresAndItems storesAndItems =
                      //         GetIt.I.get<RxStoresAndItems>();
                      //     if (item.store == null) {
                      //       var store =
                      //           storesAndItems.stores.value[item.storeId];
                      //       item.store = store;
                      //       deviceIds.addAll(item.store.deviceTokens);
                      //     } else if (item?.store?.deviceTokens != null &&
                      //         item.store.deviceTokens.length > 0) {
                      //       deviceIds.addAll(item.store.deviceTokens);
                      //     } else {
                      //       var store =
                      //           storesAndItems.stores.value[item.storeId];
                      //       item.store = store;
                      //       deviceIds.addAll(item.store.deviceTokens);
                      //     }
                      //     OrderFromReceiveIt receiveIt = OrderFromReceiveIt(
                      //       destination: Utils.latLngFromString(
                      //           orderData['destination']),
                      //       date: now,
                      //       deliveryTime: null,
                      //       email: order.email,
                      //       house: order.house,
                      //       price: item.price *
                      //           (itemsData[item.itemId]['quantity'] as num)
                      //               .toInt(),
                      //       orderId: orderId,
                      //       pricePerItem: [item.price],
                      //       totalPricePerItem: [
                      //         item.price *
                      //             (itemsData[item.itemId]['quantity'] as num)
                      //                 .toInt()
                      //       ],
                      //       itemsData: model.StoreToReceiveItOrderItems(
                      //           itemDetails: {
                      //             item.storeId:
                      //                 model.ReceiveItOrderItem(itemDetails: {
                      //               itemKey: model.ReceiveItOrderItemDetails(
                      //                 flavour: itemsData[itemKey]['flavour'],
                      //                 quantity: (itemsData[itemKey]
                      //                         ['quantity'] as num)
                      //                     .toInt(),
                      //               ),
                      //             }),
                      //           }),
                      //       phoneNumber: order.phoneNumber,
                      //       userId: order.userId,
                      //       shortId: order.shortId,
                      //     );
                      //     Map<String, dynamic> tempOrder = receiveIt.toMap();
                      //     tempOrder.putIfAbsent(
                      //       'storeId',
                      //       () => item.storeId,
                      //     );
                      //     tempOrder.putIfAbsent(
                      //         'storeName', () => item.storeName);
                      //     tempOrder.putIfAbsent(
                      //         'storeAddress', () => item.storeAddress);
                      //     tempOrder.putIfAbsent(
                      //       'storeLatLng',
                      //       () =>
                      //           Utils.latLngToString(item.store.storeLatLng),
                      //     );
                      //     storeOrders.putIfAbsent(
                      //       item.storeId,
                      //       () {
                      //         return tempOrder;
                      //       },
                      //     );
                      //   }
                      // }
                      // List<Future<Response>> requests = [];
                      // final _fcmServerKey = await Utils.getFCMServerKey();
                      // storeOrders.forEach((k, v) {
                      //   var storeOrderRef = Firestore.instance
                      //       .collection('stores')
                      //       .document(k)
                      //       .collection('pendingOrderedItems')
                      //       .document(orderData['orderId']);

                      //   batch.setData(
                      //     storeOrderRef,
                      //     v,
                      //     merge: true,
                      //   );
                      //   // deviceIds.forEach((id) {
                      //   var request = post(
                      //     'https://fcm.googleapis.com/fcm/send',
                      //     headers: <String, String>{
                      //       'Content-Type': 'application/json',
                      //       'Authorization': 'key=$_fcmServerKey',
                      //     },
                      //     body: jsonEncode(
                      //       <String, dynamic>{
                      //         'notification': <String, dynamic>{
                      //           'body': 'An Order is just Arrived',
                      //           'title': 'Order'
                      //         },
                      //         'type': 'partnerStoreOrder',
                      //         'priority': 'high',
                      //         'data': <String, dynamic>{
                      //           'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                      //           'orderId': '${order.orderId}',
                      //           'status': 'posted',
                      //           'userId': order.userId,
                      //         },
                      //         'registration_ids': deviceIds,
                      //       },
                      //     ),
                      //   );
                      //   requests.add(request);
                      //   // });
                      // });
                      // await batch.commit();
                      // for (var request in requests) {
                      //   var _ = await request;
                      // }
                      // Utils.showSnackBarSuccess(context, 'Order Submitted');
                      // Navigator.pop(context);
                      // Session.data['cart'] = UserCart(itemsData: {});
                      // Utils.showSuccessDialog('Your Order is on its way!');
                      // Future.delayed(Duration(seconds: 2)).then((_) {
                      //   BotToast.cleanAll();
                      // });
                      // try {
                      //   navigator.pushAndRemoveUntil(
                      //     MaterialPageRoute(
                      //       builder: (context) {
                      //         return OrderTracking(
                      //           type: OrderTrackingType.RECEIVE_IT,
                      //           data: orderData,
                      //         );
                      //       },
                      //       settings: RouteSettings(name: OrderTracking.NAME),
                      //     ),
                      //     (route) {
                      //       if (route?.settings?.name == null) {
                      //         return false;
                      //       }
                      //       return route.settings.name == 'receiveIt';
                      //     },
                      //   );
                      // } on dynamic catch (_) {
                      //   navigator.pop();
                      //   BotToast.showText(
                      //       text: _.toString(),
                      //       duration: Duration(
                      //         seconds: 10,
                      //       ));
                      // }

                    } on dynamic catch (ex) {
                      print(ex.toString());
                      debugPrint(ex.toString());
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
        demo: widget.demo,
        key: _shoppingCartRouteBodyKey,
      ),
      bottomSheet: (widget.demo != null && widget.demo)
          ? BottomAppBar(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Login to Checkout',
                    style: Theme.of(context).textTheme.headline6.copyWith(
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
    );
  }

  performTransaction(context, amount) async {
    RxConfig config = GetIt.I.get<RxConfig>();
    bool testing = config.config.value['testing'] ?? false;
    User user = Session.data['user'];
    DateTime time = DateTime.now();
    var initializer = RavePayInitializer(
      amount: amount,
      publicKey: testing
          ? 'FLWPUBK-fc9fc6e2a846ce0acde3e09e6ee9d11a-X' //Testing
          : 'FLWPUBK-dd01d6fa251fe0ce8bb95b03b0406569-X', //Live
      encryptionKey: testing
          ? '27e4c95e939cba30b53d9105' /**Testing */ : 'eded539f04b38a2af712eb7d', //Live
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
      ..companyName =
          Text('Sennit', style: Theme.of(context).textTheme.subtitle1)
      ..staging = testing
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

    return <String, dynamic>{
      'status': response.status,
      'errorMessage': response.message,
    };
  }

  Future<void> fixStock() async {
    UserCart cart = Session.getCart();
    Map<String, ReceiveItOrderItem> storeIdToItsItems =
        cart.itemsData.itemDetails;
    await Firestore.instance.runTransaction((trx) async {
      for (var storeId in storeIdToItsItems.keys) {
        for (var itemId in storeIdToItsItems[storeId].itemDetails.keys) {
          var itemRef = Firestore.instance.collection('items').document(itemId);
          var data = await trx.get(itemRef);
          model.StoreItem item = model.StoreItem.fromMap(data.data);
          item.remainingInStock +=
              storeIdToItsItems[storeId].itemDetails[itemId].quantity;
          trx.set(itemRef, item.toMap());
        }
      }
    });
  }
}

class ShoppingCartRouteBody extends StatefulWidget {
  final bool demo;
  final GlobalKey<ShoppingCartRouteBodyState> key;
  ShoppingCartRouteBody({
    this.key,
    @required this.demo,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ShoppingCartRouteBodyState(
      demo: demo,
    );
  }
}

class ShoppingCartRouteBodyState extends State<ShoppingCartRouteBody> {
  bool pickFromDoor = true;
  bool deliverToDoor = true;
  double cardMargin = 10;
  double cardPadding = 20;
  double groupMargin = 30;
  double itemMargin = 10;
  // List<TextEditingController> _controllers;
  // List<TextEditingController> _flavourControllers;
  TextEditingController _emailController;
  TextEditingController _houseController;
  TextEditingController _phoneNumberController;
  bool boxSizeSmall = true;
  bool boxSizeMedium = false;
  bool boxSizeLarge = false;
  bool sleeveNeeded = false;
  bool demo;
  bool newOrdersClosed = false;

  double totalDeliveryCharges = 0;
  double totalPrice = 0;

  Map<String, Map<String, Map<String, dynamic>>> controllersAndConfigs = {};

  // List<bool> isAnimationVisibleList = [];
  // List<bool> isItemDeleteConfirmationVisibleList = [];
  // List<bool> isButtonActiveList = [];
  Future<void> initializeCart;

  ShoppingCartRouteBodyState({
    @required this.demo,
  }) {
    _emailController = TextEditingController();
    _houseController = TextEditingController();
    _phoneNumberController = TextEditingController();
  }

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> config = GetIt.I.get<RxConfig>().config.value;
    if (config['maintenanceNotice'] != null) {
      newOrdersClosed = true;
      try {
        BotToast.showNotification(
          align: Alignment.topCenter,
          title: (fn) => Text('Maintenance Notice'),
          duration: Duration(seconds: 10),
          crossPage: true,
          subtitle: (fn) => Text(
            'This App is undergoing maintenance on ${config['maintenanceNotice']}.\n Please Don\'t make any new orders.\n For More Details Contact Customer Support.',
          ),
        );
      } catch (ex) {
        print(ex.toString());
      }
    } else {
      initializeCart = initialize();
    }
  }

  @override
  void dispose() {
    super.dispose();
    totalDeliveryCharges = 0;
    totalPrice = 0;
  }

  // Map<String, model.Store> stores = {};

  Future<void> initialize() async {
    if (demo == null || !widget.demo) {
      User user = Session.data['user'];
      _emailController.text = user.email;
      _phoneNumberController.text = user.phoneNumber;
    }
    // _phoneNumberController.addListener(() {
    //   if (_phoneNumberController.text == null ||
    //       _phoneNumberController.text == "") {
    //     // _phoneNumberController.text = '27';
    //   }
    // });
    totalDeliveryCharges = 0;
    totalPrice = 0;
    UserCart cart = Session.getCart();
    StoreToReceiveItOrderItems storeAndItsItems = cart.itemsData;

    RxStoresAndItems storesAndItems = GetIt.I.get<RxStoresAndItems>();

    // List<Future<DocumentSnapshot>> requests = [];
    controllersAndConfigs = {};
    for (var storeId in storeAndItsItems.itemDetails.keys) {
      ReceiveItOrderItem orderItems = storeAndItsItems.itemDetails[storeId];
      // var request = Firestore.instance
      //     .collection('stores')
      //     .document(storeId)
      //     .get(source: Source.server);
      // requests.add(request);
      for (var itemId in orderItems.itemDetails.keys) {
        final TextEditingController controller = TextEditingController();
        final TextEditingController flavourController = TextEditingController();
        controller.text =
            '${storeAndItsItems?.itemDetails[storeId]?.itemDetails[itemId]?.quantity ?? 1}';
        flavourController.text =
            '${storeAndItsItems?.itemDetails[storeId]?.itemDetails[itemId]?.flavour ?? ''}';
        controllersAndConfigs.putIfAbsent(storeId, () => {});
        controllersAndConfigs[storeId].putIfAbsent(
          itemId,
          () => {
            'item': storesAndItems.items.value[itemId],
            'quantityController': controller,
            'flavourController': flavourController,
            'animationVisible': false,
            'itemDeletionVisible': false,
            'buttonActive': false,
          },
        );
      }
    }

    // for (var key in cart.itemsData.keys) {
    //   final TextEditingController controller = TextEditingController();
    //   final TextEditingController flavourController = TextEditingController();
    //   _controllers.add(controller);
    //   _flavourControllers.add(flavourController);
    //   controller.text = cart.itemsData[key]['quantity'].toInt().toString();
    //   flavourController.text = cart.itemsData[key]['flavour'];
    //   isAnimationVisibleList.add(false);
    //   isItemDeleteConfirmationVisibleList.add(false);
    //   isButtonActiveList.add(false);
    // }
    // bool removed = false;
    // UserCart cart = Session.data['cart'];
    // final itemsData = cart.itemsData.itemDetails;
    // final items = cart.items;
    // if (items == null || items.length <= 0) {
    //   return;
    // }
    // List<Future<DocumentSnapshot>> requests = [];
    // Map<String, String> idsDone = {};
    // for (var storeItem in items) {
    //   if (!idsDone.containsKey(storeItem.storeId)) {
    //     var request = Firestore.instance
    //         .collection('stores')
    //         .document(storeItem.storeId)
    //         .get(source: Source.server);
    //     requests.add(request);
    //     idsDone.putIfAbsent(storeItem.storeId, () => 'done');
    //   }
    // }
    // for (var request in requests) {
    //   var snapshot = await request;
    //   model.Store store = model.Store.fromMap(snapshot.data);
    //   storesAndItems.stores.value.update(
    //     snapshot.documentID,
    //     (value) => store,
    //   );
    //   if (store.isOpened ?? false) {
    //     itemsData.remove(store.storeId);
    //   }
    //   // stores.putIfAbsent(
    //   //     snapshot.documentID, () => model.Store.fromMap(snapshot.data));
    // }
    // final tempStoreItems = List<model.StoreItem>.from();
    // for (int i = 0; i < tempStoreItems.length; i++) {
    //   if (!((stores[tempStoreItems[i].storeId]?.isOpened) ?? false)) {
    //     items.remove(tempStoreItems[i]);
    //     itemsData.remove(tempStoreItems[i].itemId);
    //     removed = true;
    //   }
    // }

    // if (removed) {
    //   Utils.showSnackBarWarning(
    //     context,
    //     '''Removed Some Items from Cart, Because their respective Store is Closed''',
    //     Duration(
    //       seconds: 6,
    //     ),
    //   );
    // }
    return;
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    if (newOrdersClosed ?? false) {
      Map<String, dynamic> config = GetIt.I.get<RxConfig>().config.value;
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Sorry',
            style: textTheme.headline5,
          ),
          SizedBox(height: 10),
          Text(
            'App is Soon going under maintenance on ${config['maintenanceNotice']}. New Orders are closed.',
            style: textTheme.subtitle1,
            textAlign: TextAlign.center,
          ),
        ],
      ));
    }
    return FutureBuilder<void>(
        future: initializeCart,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
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
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        Opacity(
                          opacity: 0,
                          child: Container(
                            height: itemMargin,
                          ),
                        ),
                        StreamBuilder<Map<String, Address>>(
                            stream: GetIt.I.get<RxAddress>().stream$,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              var toAddress = snapshot.data['toAddress'];
                              return ListTile(
                                onTap: () async {
                                  Coordinates destination =
                                      toAddress?.coordinates;
                                  LatLng latlng = destination == null
                                      ? null
                                      : LatLng(
                                          destination.latitude,
                                          destination.longitude,
                                        );
                                  LocationResult result =
                                      await Utils.showPlacePicker(
                                    context,
                                    initialLocation: latlng,
                                  );
                                  if (result != null) {
                                    Coordinates coordinates = Coordinates(
                                      result.latLng.latitude,
                                      result.latLng.longitude,
                                    );
                                    GetIt.I
                                        .get<RxAddress>()
                                        .setToAddress(Address(
                                          addressLine: result.address,
                                          coordinates: coordinates,
                                        ));
                                  }
                                },
                                leading: Icon(
                                  Icons.location_on,
                                  color: Theme.of(context).accentColor,
                                ),
                                title: Text(
                                  ((toAddress?.coordinates?.latitude ?? 0) ==
                                              0 &&
                                          (toAddress?.coordinates?.longitude ??
                                                  0) ==
                                              0)
                                      ? 'Address Not Set'
                                      : toAddress?.addressLine ??
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
                              );
                            }),
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
        });
  }

  // List<model.StoreItem> items;
  // Map<String, Map<String, dynamic>> itemsData;

  closeStore(Store store) {
    UserCart cart = Session.getCart();
    model.StoreToReceiveItOrderItems storeToItsItemsMap = cart.itemsData;
    storeToItsItemsMap.itemDetails.remove(store.storeId);
    controllersAndConfigs.remove(store.storeId);
    Utils.showSnackBarWarning(
      context,
      "Removed all items of ${store.storeName} from cart. Because the store is now Closed.",
      Duration(seconds: 12),
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) setState(() {});
    });
  }

  Widget _getCartItems() {
    return StreamBuilder<Map<String, Address>>(
        stream: GetIt.I.get<RxAddress>().stream$,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          Address toAddress;
          if (snapshot.data == null) {
            toAddress = null;
          } else {
            toAddress = snapshot.data['toAddress'];
          }
          UserCart cart = Session.data['cart'];
          Map<String, ReceiveItOrderItem> itemsData =
              cart.itemsData.itemDetails;
          // bool itemFound = false;
          // items = cart.items;

          if (itemsData.keys.length <= 0) {
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
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
              ),
            );
          }
          totalDeliveryCharges = 0;
          totalPrice = 0;

          List<Widget> cartItems = [];

          RxStoresAndItems storesAndItems = GetIt.I.get<RxStoresAndItems>();
          Map<String, Store> storesMap = storesAndItems.stores.value;
          Map<String, model.StoreItem> itemsMap = storesAndItems.items.value;
          String deliveryChargesAsString = getDeliveryCharges(toAddress);
          LatLng toLatLng = Utils.latLngFromCoordinates(toAddress?.coordinates);
          totalPrice += totalDeliveryCharges;
          for (var storeId in itemsData.keys) {
            Store store = storesMap[storeId];
            LatLng storeLatLng = store.storeLatLng;
            String distance = 'N/A';
            if (toLatLng != null) {
              distance =
                  '${Utils.calculateDistance(storeLatLng, toLatLng).toStringAsFixed(1)} Km';
            }
            cartItems.add(SizedBox(
              height: 16.0,
            ));
            cartItems.add(
              StreamBuilder<DocumentSnapshot>(
                  stream: Firestore.instance
                      .collection('stores')
                      .document(store.storeId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    Store newStore;
                    if (!snapshot.hasData ||
                        snapshot.hasError ||
                        snapshot.data?.data == null) {
                      newStore = store;
                    } else {
                      newStore = Store.fromMap(snapshot.data.data);
                    }
                    store = newStore;
                    if (!(store.isOpened ?? false)) {
                      closeStore(store);
                    }
                    return Row(
                      children: <Widget>[
                        Text(
                          '   ${store.storeName}',
                          style: Theme.of(context).textTheme.subtitle2.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Transform.rotate(
                            angle: 45,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.navigation,
                              size: 16,
                            ),
                          ),
                        ),
                        Text(
                          ' $distance',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    );
                  }),
            );
            cartItems.add(SizedBox(
              height: 8.0,
            ));

            // controllersAndConfigs.putIfAbsent(storeId, () => {});

            for (var itemId in itemsData[storeId].itemDetails.keys) {
              GlobalKey<CartItemState> cartItemKey = GlobalKey<CartItemState>();
              controllersAndConfigs[storeId].putIfAbsent(itemId, () => {});
              controllersAndConfigs[storeId][itemId]
                  .putIfAbsent('cartItemKey', () => cartItemKey);
              totalPrice += itemsMap[itemId].price *
                  itemsData[storeId].itemDetails[itemId].quantity;
              Widget widget = Stack(
                children: <Widget>[
                  StreamBuilder<DocumentSnapshot>(
                      stream: Firestore.instance
                          .collection('items')
                          .document(itemId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        model.StoreItem item;
                        if (!snapshot.hasData ||
                            snapshot.hasError ||
                            snapshot.data?.data == null) {
                          item = itemsMap[itemId];
                        } else {
                          // itemsMap.update(itemId, (old) => item,
                          //     ifAbsent: () => item);
                          item = model.StoreItem.fromMap(snapshot.data.data);
                        }
                        if (item.remainingInStock <= 0) {
                          cart.itemsData.itemDetails[storeId]?.itemDetails
                              ?.remove(itemId);
                          controllersAndConfigs[storeId].remove(itemId);
                          if (controllersAndConfigs[storeId].length <= 0) {
                            controllersAndConfigs?.remove(storeId);
                            cart.itemsData?.itemDetails?.remove(storeId);
                          }
                          WidgetsBinding.instance
                              .addPostFrameCallback((timeout) {
                            if (mounted) setState(() {});
                          });
                          return Opacity(
                            opacity: 0,
                          );
                        }
                        return CartItem(
                          key: cartItemKey,
                          onDelete: ([silent, message]) {
                            if (silent ?? false) {
                              itemsData[storeId].itemDetails.remove(itemId);
                              if (itemsData[storeId].itemDetails.length <= 0) {
                                itemsData.remove(storeId);
                              }
                              setState(() {
                                controllersAndConfigs[storeId].remove(itemId);
                                if (controllersAndConfigs[storeId].length <=
                                    0) {
                                  controllersAndConfigs.remove(storeId);
                                }
                                // isButtonActiveList[index] =
                                //     false;
                                // isItemDeleteConfirmationVisibleList[
                                //     index] = false;
                                // // items.removeAt(index);
                                // _controllers
                                //     .removeAt(index);
                                // _flavourControllers
                                //     .removeAt(index);
                              });
                              return;
                            }
                            controllersAndConfigs[storeId][itemId].update(
                              'animationVisible',
                              (old) => true,
                              ifAbsent: () => true,
                            );
                            Future.delayed(Duration(milliseconds: 100)).then(
                              (_) {
                                controllersAndConfigs[storeId][itemId].update(
                                  'itemDeletionVisible',
                                  (old) => true,
                                  ifAbsent: () => true,
                                );
                                // isItemDeleteConfirmationVisibleList[index] = true;
                                setState(() {});
                              },
                            );
                            setState(() {});
                          },
                          onFlavourChange: (value) async {
                            itemsData[storeId].itemDetails[itemId].flavour =
                                value;
                            // itemsData.update(items[index].itemId, (a) {
                            //   return {
                            //     'quantity': (items[index]?.quantity ?? 0) == 0
                            //         ? 1
                            //         : items[index].quantity,
                            //     'flavour': value ?? '',
                            //   };
                            // }, ifAbsent: () {
                            //   return {
                            //     'quantity': (items[index]?.quantity ?? 0) == 0
                            //         ? 1
                            //         : items[index].quantity,
                            //     'flavour': value ?? '',
                            //   };
                            // });
                          },
                          onQuantityChange: (value) async {
                            if (value == null || value == 0) {
                              return;
                            }
                            // items[index].quantity = value.toDouble();
                            // itemsData.update(items[index].itemId, (a) {
                            //   return {
                            //     'quantity': value?.toDouble() ?? 1,
                            //     'flavour': items[index].flavour ?? '',
                            //   };
                            // });
                            itemsData[storeId].itemDetails[itemId].quantity =
                                value;
                            totalPrice = 0;

                            for (var storeId in itemsData.keys) {
                              for (var itemId
                                  in itemsData[storeId].itemDetails.keys) {
                                model.StoreItem item = itemsMap[itemId];
                                int quantity = itemsData[storeId]
                                    .itemDetails[itemId]
                                    .quantity;
                                totalPrice += item.price * quantity;
                              }
                            }

                            // for (var item in items) {
                            //   totalPrice +=
                            //       item.price * itemsData[item.itemId]['quantity'];
                            // }
                            totalPrice += totalDeliveryCharges;
                            setState(() {});
                          },
                          item: item,
                          controller: controllersAndConfigs[storeId][itemId]
                              ['quantityController'],
                          flavourController: controllersAndConfigs[storeId]
                              [itemId]['flavourController'],
                          // itemIndex: index,
                        );
                      }),
                  controllersAndConfigs[storeId][itemId]['animationVisible'] ??
                          false
                      ? Positioned(
                          left: 0,
                          right: 0,
                          top: 4,
                          bottom: 4,
                          child: AnimatedOpacity(
                              duration: Duration(milliseconds: 800),
                              opacity: controllersAndConfigs[storeId][itemId]
                                      ['itemDeletionVisible']
                                  ? 1
                                  : 0,
                              onEnd: () {
                                if (controllersAndConfigs[storeId][itemId]
                                    ['itemDeletionVisible']) {
                                  controllersAndConfigs[storeId][itemId].update(
                                      'animationVisible', (old) => true,
                                      ifAbsent: () => true);
                                  // isAnimationVisibleList[index] = true;

                                  controllersAndConfigs[storeId][itemId].update(
                                      'buttonActive', (old) => true,
                                      ifAbsent: () => true);
                                  // isButtonActiveList[index] = true;
                                } else {
                                  controllersAndConfigs[storeId][itemId].update(
                                    'animationVisible',
                                    (old) => false,
                                    ifAbsent: () => false,
                                  );
                                }
                                setState(() {});
                              },
                              child: Container(
                                color: Colors.white.withAlpha(240),
                                padding: EdgeInsets.only(
                                    top: 8,
                                    bottom: 8,
                                    left:
                                        MediaQuery.of(context).size.width * 0.2,
                                    right: MediaQuery.of(context).size.width *
                                        0.2),
                                child: Row(
                                  children: <Widget>[
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        IconButton(
                                          splashColor:
                                              Theme.of(context).primaryColor,
                                          tooltip: "Cancel",
                                          onPressed: controllersAndConfigs[
                                                      storeId][itemId]
                                                  ['buttonActive']
                                              ? () {
                                                  controllersAndConfigs[storeId]
                                                          [itemId]
                                                      .update(
                                                    'buttonActive',
                                                    (old) => false,
                                                    ifAbsent: () => false,
                                                  );
                                                  controllersAndConfigs[storeId]
                                                          [itemId]
                                                      .update(
                                                    'itemDeletionVisible',
                                                    (old) => false,
                                                    ifAbsent: () => false,
                                                  );
                                                  setState(() {});
                                                }
                                              : null,
                                          icon: Icon(
                                            Icons.close,
                                            color:
                                                Theme.of(context).primaryColor,
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
                                              .subtitle1,
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        IconButton(
                                          tooltip: "Confirm",
                                          splashColor:
                                              Theme.of(context).primaryColor,
                                          onPressed:
                                              controllersAndConfigs[storeId]
                                                      [itemId]['buttonActive']
                                                  ? () async {
                                                      // cart.items.remove(
                                                      //   items[index].itemId,
                                                      // );
                                                      itemsData[storeId]
                                                          .itemDetails
                                                          .remove(itemId);
                                                      if (itemsData[storeId]
                                                              .itemDetails
                                                              .length <=
                                                          0) {
                                                        itemsData
                                                            .remove(storeId);
                                                      }
                                                      setState(() {
                                                        controllersAndConfigs[
                                                                storeId]
                                                            .remove(itemId);
                                                        if (controllersAndConfigs[
                                                                    storeId]
                                                                .length <=
                                                            0) {
                                                          controllersAndConfigs
                                                              .remove(storeId);
                                                        }
                                                        // isButtonActiveList[index] =
                                                        //     false;
                                                        // isItemDeleteConfirmationVisibleList[
                                                        //     index] = false;
                                                        // // items.removeAt(index);
                                                        // _controllers
                                                        //     .removeAt(index);
                                                        // _flavourControllers
                                                        //     .removeAt(index);
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
                                              .subtitle1
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
              cartItems.add(
                widget,
              );
              cartItems.add(SizedBox(height: 4));
            }
          }

          return Card(
            margin: EdgeInsets.only(
              top: groupMargin,
            ),
            elevation: 5,
            child: Container(
              padding: EdgeInsets.only(
                top: cardPadding,
                bottom: cardPadding,
                left: 10,
                right: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: Text(
                      'Items In Cart',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: cartItems,
                    // List<Widget>.generate(items.length, (index) {
                    //   // globalKeysForCartItem.add(GlobalKey<CartItemState>());
                    //   // model.StoreItem item = items[index];
                    //   totalPrice += items[index].price *
                    //       itemsData[items[index].itemId]['quantity'];
                    //   if (toAddress != null) {
                    //     print(
                    //         'To Coordinates: ${toAddress?.coordinates ?? ''}');
                    //     print(
                    //       'Item: ${items[index]?.latlng ?? ''}',
                    //     );
                    //   }
                    //   return Stack(
                    //     children: <Widget>[
                    //       CartItem(
                    //         key: globalKeysForCartItem[index],
                    //         onDelete: () {
                    //           isAnimationVisibleList[index] = true;
                    //           Future.delayed(Duration(milliseconds: 100)).then(
                    //             (_) {
                    //               isItemDeleteConfirmationVisibleList[index] =
                    //                   true;
                    //               setState(() {});
                    //             },
                    //           );
                    //           setState(() {});
                    //         },
                    //         onFlavourChange: (index, value) async {
                    //           items[index].flavour = value;
                    //           itemsData.update(items[index].itemId, (a) {
                    //             return {
                    //               'quantity': (items[index]?.quantity ?? 0) == 0
                    //                   ? 1
                    //                   : items[index].quantity,
                    //               'flavour': value ?? '',
                    //             };
                    //           }, ifAbsent: () {
                    //             return {
                    //               'quantity': (items[index]?.quantity ?? 0) == 0
                    //                   ? 1
                    //                   : items[index].quantity,
                    //               'flavour': value ?? '',
                    //             };
                    //           });
                    //         },
                    //         onQuantityChange: (value, index) async {
                    //           if (value == null || value == 0) {
                    //             return;
                    //           }
                    //           items[index].quantity = value.toDouble();
                    //           itemsData.update(items[index].itemId, (a) {
                    //             return {
                    //               'quantity': value?.toDouble() ?? 1,
                    //               'flavour': items[index].flavour ?? '',
                    //             };
                    //           });
                    //           totalPrice = 0;
                    //           for (var item in items) {
                    //             totalPrice += item.price *
                    //                 itemsData[item.itemId]['quantity'];
                    //           }
                    //           totalPrice += totalDeliveryCharges;
                    //           setState(() {});
                    //         },
                    //         item: items[index],
                    //         controller: _controllers[index],
                    //         flavourController: _flavourControllers[index],
                    //         itemIndex: index,
                    //       ),
                    //       isAnimationVisibleList[index]
                    //           ? Positioned(
                    //               left: 0,
                    //               right: 0,
                    //               top: 4,
                    //               bottom: 4,
                    //               child: AnimatedOpacity(
                    //                   duration: Duration(milliseconds: 800),
                    //                   opacity:
                    //                       isItemDeleteConfirmationVisibleList[
                    //                               index]
                    //                           ? 1
                    //                           : 0,
                    //                   onEnd: () {
                    //                     if (isItemDeleteConfirmationVisibleList[
                    //                         index]) {
                    //                       isAnimationVisibleList[index] = true;
                    //                       isButtonActiveList[index] = true;
                    //                     } else {
                    //                       isAnimationVisibleList[index] = false;
                    //                     }
                    //                     setState(() {});
                    //                   },
                    //                   child: Container(
                    //                     color: Colors.white.withAlpha(240),
                    //                     padding: EdgeInsets.only(
                    //                         top: 8,
                    //                         bottom: 8,
                    //                         left: MediaQuery.of(context)
                    //                                 .size
                    //                                 .width *
                    //                             0.2,
                    //                         right: MediaQuery.of(context)
                    //                                 .size
                    //                                 .width *
                    //                             0.2),
                    //                     child: Row(
                    //                       children: <Widget>[
                    //                         Column(
                    //                           mainAxisSize: MainAxisSize.min,
                    //                           children: <Widget>[
                    //                             IconButton(
                    //                               splashColor: Theme.of(context)
                    //                                   .primaryColor,
                    //                               tooltip: "Cancel",
                    //                               onPressed:
                    //                                   isButtonActiveList[index]
                    //                                       ? () {
                    //                                           isButtonActiveList[
                    //                                                   index] =
                    //                                               false;
                    //                                           isItemDeleteConfirmationVisibleList[
                    //                                                   index] =
                    //                                               false;
                    //                                           setState(() {});
                    //                                         }
                    //                                       : null,
                    //                               icon: Icon(
                    //                                 Icons.close,
                    //                                 color: Theme.of(context)
                    //                                     .primaryColor,
                    //                                 size: 36,
                    //                               ),
                    //                             ),
                    //                             SizedBox(
                    //                               height: 4,
                    //                             ),
                    //                             Text(
                    //                               'Cancel',
                    //                               style: Theme.of(context)
                    //                                   .textTheme
                    //                                   .subtitle1,
                    //                             ),
                    //                           ],
                    //                         ),
                    //                         Spacer(),
                    //                         Column(
                    //                           mainAxisSize: MainAxisSize.min,
                    //                           children: <Widget>[
                    //                             IconButton(
                    //                               tooltip: "Confirm",
                    //                               splashColor: Theme.of(context)
                    //                                   .primaryColor,
                    //                               onPressed: isButtonActiveList[
                    //                                       index]
                    //                                   ? () async {
                    //                                       UserCart cart =
                    //                                           Session
                    //                                               .data['cart'];
                    //                                       cart.items.remove(
                    //                                         items[index].itemId,
                    //                                       );
                    //                                       cart.itemsData
                    //                                           .removeWhere(
                    //                                               (key, value) {
                    //                                         if (key ==
                    //                                             items[index]
                    //                                                 .itemId) {
                    //                                           return true;
                    //                                         }
                    //                                         return false;
                    //                                       });
                    //                                       setState(() {
                    //                                         isButtonActiveList[
                    //                                             index] = false;
                    //                                         isItemDeleteConfirmationVisibleList[
                    //                                             index] = false;
                    //                                         items.removeAt(
                    //                                             index);
                    //                                         _controllers
                    //                                             .removeAt(
                    //                                                 index);
                    //                                         _flavourControllers
                    //                                             .removeAt(
                    //                                                 index);
                    //                                       });
                    //                                     }
                    //                                   : null,
                    //                               icon: Icon(
                    //                                 Icons.check,
                    //                                 color: Colors.red,
                    //                                 size: 36,
                    //                               ),
                    //                             ),
                    //                             SizedBox(
                    //                               height: 4,
                    //                             ),
                    //                             Text(
                    //                               'Yes',
                    //                               style: Theme.of(context)
                    //                                   .textTheme
                    //                                   .subtitle1
                    //                                   .copyWith(
                    //                                     color: Colors.red,
                    //                                   ),
                    //                             ),
                    //                           ],
                    //                         ),
                    //                       ],
                    //                     ),
                    //                   )),
                    //             )
                    //           : Opacity(opacity: 0),
                    //     ],
                    //   );
                    // }),
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
                          style: Theme.of(context).textTheme.subtitle1,
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
                            '''${toAddress == null ? 'Select a Destination' : ((toAddress?.coordinates?.latitude ?? 0) == 0 && (toAddress?.coordinates?.longitude ?? 0) == 0) ? 'Select a Destination' : deliveryChargesAsString}''',
                            style: Theme.of(context).textTheme.subtitle2,
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
                          'Total\nR${totalDeliveryCharges.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.subtitle1,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total: R${(totalPrice).toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.headline6.copyWith(
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
        });
  }

  String getDeliveryCharges(Address toAddress) {
    if (toAddress == null) {
      return '';
    }
    String finalString = '';
    double total = 0;
    // int index = 0;
    Map<String, ReceiveItOrderItem> cartEachStoreItemsMap =
        (Session.data['cart'] as UserCart).itemsData.itemDetails;
    Map<String, dynamic> uniqueStores = {};
    RxStoresAndItems storesAndItems = GetIt.I.get<RxStoresAndItems>();

    for (var storeId in cartEachStoreItemsMap.keys) {
      Store store = storesAndItems.stores.value[storeId];
      Coordinates coordinates = toAddress?.coordinates ?? Coordinates(0, 0);
      double distance = Utils.calculateDistance(
          LatLng(coordinates.latitude, coordinates.longitude),
          store.storeLatLng);
      uniqueStores.putIfAbsent(store.storeLatLng.toString(), () {
        return {
          'distance': distance,
        };
      });
    }

    Map<String, dynamic> configValues = GetIt.I.get<RxConfig>()?.config?.value;

    double deliveryChargesForEachKilometerExtra =
        (configValues ?? {})['receiveItPricePerExtraKilometer'] ?? 4.5;
    double deliveryChargesFor5Km =
        (configValues ?? {})['receiveItPriceFor5Km'] ?? 30;
    uniqueStores.forEach((k, v) {
      final distance = v['distance'];
      double charges = deliveryChargesFor5Km;
      final tempDistance = distance - 5;
      if (tempDistance <= 0) {
        v.putIfAbsent('charges', () => charges);
      } else {
        charges +=
            ((tempDistance as double) * deliveryChargesForEachKilometerExtra);
        v.putIfAbsent('charges', () => charges);
      }

      total += v['charges'];

      if (finalString.isEmpty) {
        finalString += 'R${(v['charges'] as double).toStringAsFixed(1)}';
      } else {
        finalString += ' + R${(v['charges'] as double).toStringAsFixed(1)}';
      }
    });
    totalDeliveryCharges = total;
    return finalString;
  }
}

class CartItem extends StatefulWidget {
  final TextEditingController controller;
  final model.StoreItem item;
  final Function([bool silent, String message]) onDelete;
  // final int itemIndex;
  final Function(int value) onQuantityChange;
  final Function(String value) onFlavourChange;
  final _quantityFocusNode = FocusNode();
  // final _flavourFocusNode = FocusNode();
  final GlobalKey<CartItemState> key;
  final TextEditingController flavourController;
  CartItem({
    this.key,
    this.item,
    this.controller,
    this.flavourController,
    // this.itemIndex,
    @required this.onQuantityChange,
    @required this.onDelete,
    @required this.onFlavourChange,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return CartItemState();
  }
}

class CartItemState extends State<CartItem> {
  bool isPressed = false;

  CartItemState();

  @override
  void initState() {
    super.initState();

    Map<String, ReceiveItOrderItem> cartItemsGroupByStores =
        (Session.data['cart'] as UserCart).itemsData.itemDetails;
    // controller.removeListener(() {});
    // flavourController.removeListener((){});
    widget.controller.addListener(() {
      if (widget.controller.text == null || widget.controller.text.isEmpty) {
        return;
      }
      int value = int.parse(widget.controller.text);
      if (value <= 0) {
        widget.controller.text = '1';
        cartItemsGroupByStores[widget.item.storeId]
            .itemDetails[widget.item.itemId]
            .quantity = 1;
        widget.onQuantityChange(1);
      } else if (value > widget.item.remainingInStock) {
        Utils.showSnackBarWarning(
            context, 'Cannot Order more Items than in Stock.');
        widget.controller.text = '${widget.item.remainingInStock}';
        cartItemsGroupByStores[widget.item.storeId]
            .itemDetails[widget.item.itemId]
            .quantity = widget.item.remainingInStock;
        widget.onQuantityChange(widget.item.remainingInStock);
      } else {
        cartItemsGroupByStores[widget.item.storeId]
            .itemDetails[widget.item.itemId]
            .quantity = value;
        widget.onQuantityChange(value);
      }
    });
    widget._quantityFocusNode.addListener(() {
      if (widget.controller.text == '') {
        widget.controller.text = '1';
        setState(() {});
      }
    });
    // widget._flavourFocusNode.addListener(() {
    //   if (!widget._flavourFocusNode.hasFocus) {
    //     cartItemsGroupByStores[widget.item.storeId]
    //         .itemDetails[widget.item.itemId]
    //         .flavour = widget.flavourController?.text ?? '';
    //     widget.onFlavourChange(widget.flavourController?.text ?? '');
    //     setState(() {});
    //   }
    // });
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 8,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.item.itemName,
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
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
                              flex: 8,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        'In Stock: ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        '${widget.item.remainingInStock}',
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 80,
                                        child: Row(
                                          children: <Widget>[
                                            InkWell(
                                              child: Text(
                                                ' - ',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .accentColor,
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: 28,
                                                    fontFamily: "Roboto"),
                                              ),
                                              onTap: () {
                                                var value = int.parse(
                                                    widget.controller.text);
                                                if (int.parse(widget
                                                        .controller.text) ==
                                                    1) {
                                                  return;
                                                }
                                                setState(() {
                                                  widget.controller.text =
                                                      '${value - 1}';
                                                });
                                              },
                                            ),
                                            Container(
                                              width: 30,
                                              child: TextField(
                                                enabled: false,
                                                focusNode:
                                                    widget._quantityFocusNode,
                                                controller: widget.controller,
                                                textAlign: TextAlign.center,
                                                keyboardType:
                                                    TextInputType.number,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                inputFormatters: <
                                                    TextInputFormatter>[
                                                  LengthLimitingTextInputFormatter(
                                                      2),
                                                  WhitelistingTextInputFormatter
                                                      .digitsOnly,
                                                  BlacklistingTextInputFormatter
                                                      .singleLineFormatter,
                                                ],
                                              ),
                                            ),
                                            InkWell(
                                              child: Text(
                                                ' + ',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .accentColor,
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: 20,
                                                    fontFamily: "Roboto"),
                                              ),
                                              onTap: () {
                                                var value = int.parse(
                                                    widget.controller.text);
                                                if (int.parse(widget
                                                        .controller.text) ==
                                                    99) {
                                                  return;
                                                }
                                                setState(() {
                                                  widget.controller.text =
                                                      '${value + 1}';
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
                                              Future.delayed(
                                                      Duration(seconds: 1))
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
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Align(
                          child: Text(
                            'Price: R${widget.item.price.toInt()} x ${int.tryParse(widget.controller.text) ?? '1'} = ${(widget.item.price * (int.tryParse(widget.controller.text) ?? 1)).toInt()}',
                            style: Theme.of(context).textTheme.subtitle1,
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
              // focusNode: widget._flavourFocusNode,
              onChanged: (text) {
                Map<String, ReceiveItOrderItem> cartItemsGroupByStores =
                    (Session.data['cart'] as UserCart).itemsData.itemDetails;
                cartItemsGroupByStores[widget.item.storeId]
                    .itemDetails[widget.item.itemId]
                    .flavour = widget.flavourController?.text ?? '';
                widget
                    .onFlavourChange(/*widget.flavourController?.*/ text ?? '');
              },
              // onChanged: (value) {
              //   widget.onFlavourChange(value ?? '');
              // },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Flavour',
                helperText:
                    'Add your Flavour here. If Applicable. For Food Deliveries Only',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
