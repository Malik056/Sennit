import 'dart:math';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:place_picker/place_picker.dart';
import 'package:sennit/models/models.dart' as model;
import 'package:sennit/models/models.dart';
import 'package:sennit/my_widgets/review.dart';
import 'package:sennit/my_widgets/search.dart';
import '../main.dart';

class ReceiveItRoute extends StatelessWidget {
  final drawerNameController = TextEditingController();
  static List<Widget> _tabs;
  ReceiveItRoute() {
    _tabs = [];
    drawerNameController.text = ((Session.data['user']) as User).fullname;
    _tabs
      ..add(
        StoresRoute(
          address: null,
        ),
      )
      ..add(SearchWidget());
  }
  @override
  Widget build(BuildContext context) {
    var user = Session.data['user'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Stores'),
        centerTitle: true,
      ),
      drawer: Drawer(
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
                title: Text('Change Name'),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Change Password'),
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
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: _StatefullBottomNavigation(),
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
      body: FutureBuilder<void>(
        future: MyApp.futureCart,
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
    ReceiveItRoute._tabs = null;
  }

  @override
  void initState() {
    _controller = TabController(
        length: ReceiveItRoute._tabs.length, vsync: this, initialIndex: 0);
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

class _StatefullBottomNavigation extends StatefulWidget {
  final state = _BottomNavigationState();
  @override
  State<StatefulWidget> createState() {
    return state;
  }

  setState() {
    state.rebuild();
  }
}

class _BottomNavigationState extends State<_StatefullBottomNavigation> {
  static int _index;
  static _BottomNavigationState _bottomNavigationState;
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
      items: [
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
          title: Text('Past Order', style: TextStyle(color: Colors.black)),
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
          title: Text('Notification', style: TextStyle(color: Colors.black)),
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
      var itemIds = storeAsMap['items'];

      for (String itemId in itemIds) {
        var item =
            await Firestore.instance.collection('items').document(itemId).get();
        model.StoreItem storeItem = model.StoreItem.fromMap(item.data);
        store.storeItems.add(storeItem);
      }
      stores.add(store);
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
    _body = SingleChildScrollView(
      child: Column(
        children: List.generate(stores.length, (index) {
          return InkWell(
            child: Container(
              child: StoreItem(
                store: stores[index],
              ),
              margin: EdgeInsets.only(bottom: 10),
            ),
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
          );
        }),
      ),
    );
    try {
      setState(() {});
    } on dynamic catch (_) {
      print(_);
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
                  : Image.network(
                      '${store.storeImage}',
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
                        store.storeMoto,
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
              itemCount: 5,
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
                            child: Image.network(
                              '${store.storeItems[index].images[0]}',
                              height: 100,
                              fit: BoxFit.contain,
                            ),
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
                                  store.storeItems[index].itemName,
                                  style: Theme.of(context).textTheme.subhead,
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
                      MaterialPageRoute(builder: (context) {
                        return ItemDetailsRoute(
                          item: store.storeItems[index],
                        );
                      }),
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
  StoreMainPage({this.store});

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
          child: StoreMenu(
            store: store,
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
    if (cart.itemIds.contains(item.itemId)) {
      return true;
    }
    return false;
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
          if (!isInCart) {
            Firestore.instance
                .collection('carts')
                .document(user.userId)
                .setData({
              ItemDetailsRoute._item.itemId: ItemDetailsRoute._item.itemId,
            }, merge: true).catchError((error) {
              Utils.showSnackBarError(
                  context, "Network Problem Occured! Try Again");
              setState(() {
                addingToCart = false;
              });
            }).then((_) {
              cart.itemIds.add(ItemDetailsRoute._item.itemId);
              cart.items.add(ItemDetailsRoute._item);
              setState(() {
                addingToCart = false;
                isInCart = true;
              });
            });
          } else {
            Firestore.instance
                .collection('carts')
                .document(user.userId)
                .updateData({
              ItemDetailsRoute._item.itemId: FieldValue.delete(),
            }).catchError((error) {
              Utils.showSnackBarError(context, error.toString());
              setState(() {
                addingToCart = false;
              });
            }).then((_) {
              cart.itemIds.remove(ItemDetailsRoute._item.itemId);
              cart.items.remove(ItemDetailsRoute._item);
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

class ItemDetailsRoute extends StatelessWidget {
  static model.StoreItem _item;
  ItemDetailsRoute({
    Key key,
    @required model.StoreItem item,
  }) : super(key: key) {
    _item = item;
  }

  @override
  Widget build(BuildContext context) {
    var itemDetailsBody = _ItemDetailsBody(
      item: _item,
    );
    return Scaffold(
      resizeToAvoidBottomInset: true,
      bottomSheet: BottomSheet(
        elevation: 40,
        onClosing: () {},
        builder: (conext) {
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) {
            return ReviewWidget(
              user: Session.data['user'],
              itemId: _item.itemId,
            );
          }));
          (context as Element).markNeedsBuild();
        },
        backgroundColor: Theme.of(context).accentColor,
        child: Icon(
          Icons.rate_review,
          color: Colors.white,
        ),
        tooltip: "Write a review",
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: itemDetailsBody,
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
                        items:
                            List.generate(widget.item.images.length, (index) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(widget.item.images[index]),
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          );
                        }),
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
                          // setState(() {});
                        },
                        onTapCancel: () {
                          autoplay = true;
                          // setState(() {});
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
                  widget.item.itemName,
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
  //                         'This is some medium lenght review. I want it to check how app looks.\n'),
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
  //                         'This is some medium lenght review. I want it to check how app looks. This is some medium lenght review. I want it to check how app looks. This is some medium lenght review. I want it to check how app looks.\n'),
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

  ShoppingCartRoute(toAddress) {
    // _fromAddress = fromAddress;
    _toAddress = toAddress;
  }

  final ShoppingCartRouteBody body = ShoppingCartRouteBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Utils.showLoadingDialog(context);
              if (ShoppingCartRouteState._emailController.text == "" ||
                  ShoppingCartRouteState._emailController.text == null) {
                Utils.showSnackBarError(
                    context, 'Please Provide your email Address');
                Navigator.pop(context);
                return;
              } else if (ShoppingCartRouteState._phoneNumberController.text ==
                      "" ||
                  ShoppingCartRouteState._phoneNumberController.text == null) {
                Utils.showSnackBarError(
                    context, 'Please Provide your phone Number');
                Navigator.pop(context);
                return;
              } else if (ShoppingCartRoute._toAddress == null) {
                BotToast.showText(
                    text: 'Please Select a Destination First!',
                    duration: Duration(seconds: 2));
                // Utils.showSnackBarError(context, 'Please Select a Destination');
                Navigator.pop(context);
                return;
              }

              User user = Session.data['user'];
              model.OrderFromReceiveIt order = model.OrderFromReceiveIt();
              List<TextEditingController> controllers =
                  ShoppingCartRouteState._controllers;
              model.UserCart cart = Session.data['cart'];
              List<model.StoreItem> items = cart.items;

              double price = 0.0;
              List<LatLng> pickups = order.pickups;
              if (pickups == null) {
                pickups = [];
                order.pickups = pickups;
              }
              int i = 0;
              for (model.StoreItem item in items) {
                price += item.price * int.parse(controllers[i++].text);
                pickups.add(item.latlng);
              }
              List<String> itemIds = cart.itemIds;
              order.orderDate = DateTime.now();
              order.userId = user.userId;
              order.email = ShoppingCartRouteState._emailController.text;
              order.phoneNumber =
                  ShoppingCartRouteState._phoneNumberController.text;
              order.house = ShoppingCartRouteState._houseController.text;
              order.items = itemIds;
              order.price = price;
              order.destination = LatLng(
                  ShoppingCartRoute._toAddress.coordinates.latitude,
                  ShoppingCartRoute._toAddress.coordinates.longitude);
              Firestore.instance
                  .collection('postedOrders')
                  .add(order.toMap())
                  .catchError((error) {})
                  .then((_) {
                Firestore.instance
                    .collection('carts')
                    .document(user.userId)
                    .delete()
                    .catchError((error) {})
                    .then(
                  (_) {
                    Firestore.instance
                        .collection('carts')
                        .document(user.userId)
                        .setData({});
                    // Utils.showSnackBarSuccess(context, 'Order Submitted');
                    Navigator.pop(context);
                    Session.data['cart'] = UserCart();
                    Utils.showSuccessDialog('Your Order is on its way!');
                    Future.delayed(Duration(seconds: 2)).then((_) {
                      BotToast.cleanAll();
                    });
                    Navigator.pop(context);
                  },
                );
              });
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
      body: body,
      // backgroundColor: Theme.of(context).accentColor,
    );
  }
}

class ShoppingCartRouteBody extends StatefulWidget {
  final ShoppingCartRouteState state = ShoppingCartRouteState();

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

  ShoppingCartRouteState() {
    _controllers = [];
    _emailController = TextEditingController();
    _houseController = TextEditingController();
    _phoneNumberController = TextEditingController();
    User user = Session.data['user'];
    _emailController.text = user.email;
    _phoneNumberController.text = user.phoneNumber;
  }

  @override
  void initState() {
    super.initState();
    UserCart cart = Session.data['cart'];
    for (var _ in cart.itemIds) {
      final TextEditingController controller = TextEditingController();
      _controllers.add(controller);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _houseController.dispose();
    _phoneNumberController.dispose();
    _controllers = null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                      LocationResult result =
                          await Utils.showPlacePicker(context);
                      if (result != null) {
                        Coordinates coordinates = Coordinates(
                            result.latLng.latitude, result.latLng.longitude);
                        ShoppingCartRoute._toAddress = (await Geocoder.local
                            .findAddressesFromCoordinates(coordinates))[0];

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
                          ),
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
          //             'Selct payment method',
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
  List<String> itemIds;

  var count = [0, 0, 0, 0];
  // Widget cartItems;

  Widget _getCartItems() {
    UserCart cart = Session.data['cart'];
    itemIds = cart.itemIds;
    items = cart.items;

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
                model.StoreItem item = items[index];
                return CartItem(item, _controllers[index]);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItem extends StatefulWidget {
  final controller;
  final model.StoreItem item;
  CartItem(this.item, this.controller);

  @override
  State<StatefulWidget> createState() {
    return CartItemState(item: item, controller: controller);
  }
}

class CartItemState extends State<CartItem> {
  model.StoreItem item;
  TextEditingController controller;
  CartItemState({@required this.item, this.controller}) {
    controller.text = '1';
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
                  child: Image.network(item.images[0],
                      height: 80, fit: BoxFit.fitWidth),
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
                        flex: 7,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.itemName,
                              style: Theme.of(context).textTheme.title,
                            ),
                            Text(
                              item.description,
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
                                var value = int.parse(controller.text);
                                if (int.parse(controller.text) == 1) {
                                  return;
                                }
                                setState(() {
                                  controller.text = '${value - 1}';
                                });
                              },
                            ),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: controller,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  LengthLimitingTextInputFormatter(2),
                                  WhitelistingTextInputFormatter.digitsOnly,
                                  BlacklistingTextInputFormatter
                                      .singleLineFormatter,
                                  // BlacklistingTextInputFormatter(RegExp(r'\n|-|.')),
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
                                var value = int.parse(controller.text);
                                if (int.parse(controller.text) == 99) {
                                  return;
                                }
                                setState(() {
                                  controller.text = '${value + 1}';
                                });
                              },
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
                      'Price: R${item.price.round()}',
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
