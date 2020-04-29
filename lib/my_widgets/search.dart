import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sennit/main.dart';
import 'package:sennit/models/models.dart' as model;
import 'package:sennit/user/receiveit.dart';

class SearchWidget extends StatefulWidget {
  final bool demo;
  SearchWidget({@required this.demo});
  @override
  State<StatefulWidget> createState() {
    return SearchWidgetState();
  }
}

class SearchWidgetState extends State<SearchWidget>
    with SingleTickerProviderStateMixin {
  TabController controller;
  List<model.StoreItem> items;
  List<model.Store> stores;

  @override
  void initState() {
    super.initState();
    controller = TabController(
      length: 2,
      vsync: this,
      initialIndex: 0,
    );
  }

  Future<Map<String, dynamic>> initialize() async {
    List<model.StoreItem> items = [];
    List<model.Store> stores = [];
    // LatLng myLatLng = (await Utils.getMyLocation());

    QuerySnapshot snapshot =
        await Firestore.instance.collection('items').getDocuments(
              source: Source.serverAndCache,
            );

    QuerySnapshot storesSnapshot =
        await Firestore.instance.collection('stores').getDocuments(
              source: Source.serverAndCache,
            );

    for (DocumentSnapshot snapshot in snapshot.documents) {
      // if (Utils.calculateDistance(
      //       myLatLng,
      //       Utils.latLngFromString(
      //         snapshot.data['latlng'],
      //       ),
      //     ) <=
      //     8 * 1.6) {
      items.add(model.StoreItem.fromMap(snapshot.data));
      // }
    }

    for (DocumentSnapshot snapshot in storesSnapshot.documents) {
      model.Store store = model.Store.fromMap(snapshot.data);
      for (var item in items) {
        if (item.storeName.toLowerCase() == store.storeName.toLowerCase()) {
          // store.items.add(
          //   item.itemId,
          // );
          store.storeItems.add(item);
        }
      }
      stores.add(store);
    }
    return {
      'items': items,
      'stores': stores,
    };
  }

  Future<List<model.StoreItem>> search(String query) async {
    List<model.StoreItem> filtered = [];
    final storeItems = items;
    for (model.StoreItem item in storeItems) {
      if (item.itemName.toLowerCase().contains(query.toLowerCase()) ||
          query.toLowerCase().contains(item.itemName.toLowerCase()) ||
          query.toLowerCase().contains(item.storeName.toLowerCase()) ||
          item.storeName.toLowerCase().contains(query.toLowerCase())) {
        filtered.add(item);
      }
    }
    return filtered;
  }

  Future<List<model.Store>> searchStore(String query) async {
    List<model.Store> filtered = [];
    final allStores = stores;
    for (model.Store store in allStores) {
      if (store.storeName.toLowerCase().contains(query.toLowerCase()) ||
          query.toLowerCase().contains(store.storeName.toLowerCase())) {
        filtered.add(store);
      }
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: FutureBuilder<Map<String, dynamic>>(
              future: initialize(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.data == null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.replay),
                        SizedBox(
                          height: 4,
                        ),
                        GestureDetector(
                          child: Text('Tap to reload'),
                          onTap: () {
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.data.length == 0) {
                  return Center(
                      child: Text(
                    'No Items Found Near You!',
                    style: Theme.of(context).textTheme.title.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ));
                }
                items = snapshot.data['items'];
                stores = snapshot.data['stores'];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TabBar(
                      indicatorColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.grey,
                      labelColor: Theme.of(context).primaryColor,
                      controller: controller,
                      tabs: <Widget>[
                        Tab(
                          child: Text('Search Store'),
                        ),
                        Tab(
                          child: Text('Search Item'),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: controller,
                        children: [
                          SearchBar<model.Store>(
                            onSearch: searchStore,
                            hintText: "Search Store",
                            emptyWidget: Center(
                              child: Text(
                                'No Store Found',
                                style: Theme.of(context).textTheme.title,
                              ),
                            ),
                            loader: Center(
                              child: CircularProgressIndicator(),
                            ),
                            placeHolder: ListView(
                              physics: BouncingScrollPhysics(),
                              children:
                                  List<Widget>.generate(stores.length, (index) {
                                return GestureDetector(
                                  child: StoreItem(
                                    store: stores[index],
                                  ),
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return StoreMainPage(
                                        demo: widget.demo,
                                        store: stores[index],
                                      );
                                    }));
                                  },
                                );
                              }),
                            ),
                            onItemFound: (model.Store item, index) {
                              return GestureDetector(
                                child: /** */ StoreItem(store: item),
                                // MenuItem(item: item),
                                // onTap: () {
                                //   Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //       builder: (context) {
                                //         return ItemDetailsRoute(
                                //           item: items[index],
                                //         );
                                //       },
                                //     ),
                                //   );
                                // },
                              );
                            },
                          ),
                          SearchBar<model.StoreItem>(
                            onSearch: search,
                            hintText: "Search",
                            emptyWidget: Center(
                              child: Text(
                                'No Items Found',
                                style: Theme.of(context).textTheme.title,
                              ),
                            ),
                            loader: Center(
                              child: CircularProgressIndicator(),
                            ),
                            placeHolder: ListView(
                              physics: BouncingScrollPhysics(),
                              children:
                                  List<Widget>.generate(items.length, (index) {
                                return GestureDetector(
                                  child: MenuItem(
                                    item: items[index],
                                  ),
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return ItemDetailsRoute(
                                        item: items[index],
                                      );
                                    }));
                                  },
                                );
                              }),
                            ),
                            onItemFound: (model.StoreItem item, index) {
                              return GestureDetector(
                                child: MenuItem(item: item),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ItemDetailsRoute(
                                          item: items[index],
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
