import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sennit/models/models.dart' as model;
import 'package:sennit/rx_models/rx_receiveit_tab.dart';
import 'package:sennit/rx_models/rx_storesAndItems.dart';
import 'package:sennit/user/receiveit.dart';

class SearchWidget extends StatefulWidget {
  final bool demo;
  final Function() backPressed;
  SearchWidget({@required this.demo, this.backPressed});
  @override
  State<StatefulWidget> createState() {
    return SearchWidgetState();
  }
}

class SearchWidgetState extends State<SearchWidget>
    with SingleTickerProviderStateMixin {
  TabController controller;
  // List<model.StoreItem> items;
  // List<model.Store> stores;

  @override
  void initState() {
    super.initState();
    controller = TabController(
      length: 2,
      vsync: this,
      initialIndex: 0,
    );
  }

  // Future<Map<String, dynamic>> initialize() async {
  //   List<model.StoreItem> items = [];
  //   List<model.Store> stores = [];
  //   // LatLng myLatLng = (await Utils.getMyLocation());

  //   QuerySnapshot snapshot =
  //       await Firestore.instance.collection('items').getDocuments(
  //             source: Source.serverAndCache,
  //           );

  //   QuerySnapshot storesSnapshot =
  //       await Firestore.instance.collection('stores').getDocuments(
  //             source: Source.serverAndCache,
  //           );

  //   for (DocumentSnapshot snapshot in snapshot.documents) {
  //     // if (Utils.calculateDistance(
  //     //       myLatLng,
  //     //       Utils.latLngFromString(
  //     //         snapshot.data['latlng'],
  //     //       ),
  //     //     ) <=
  //     //     8 * 1.6) {
  //     items.add(model.StoreItem.fromMap(snapshot.data));
  //     // }
  //   }

  //   for (DocumentSnapshot snapshot in storesSnapshot.documents) {
  //     model.Store store = model.Store.fromMap(snapshot.data);
  //     for (var item in items) {
  //       if (item.storeName.toLowerCase() == store.storeName.toLowerCase()) {
  //         // store.items.add(
  //         //   item.itemId,
  //         // );
  //         store.storeItems.add(item);
  //       }
  //     }
  //     stores.add(store);
  //   }
  //   return {
  //     'items': items,
  //     'stores': stores,
  //   };
  // }

  Future<List<model.StoreItem>> search(String query) async {
    var storesAndItems = GetIt.I.get<RxStoresAndItems>();
    List<model.StoreItem> filtered;
    final storeItems = storesAndItems.items.value;
    final keys = storeItems.keys.toList();
    for (var key in keys) {
      model.StoreItem item = storeItems[key];
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
    var stores = GetIt.I.get<RxStoresAndItems>().stores.value;
    final allStores = stores;
    final keys = allStores.keys.toList();
    for (String key in keys) {
      model.Store store = allStores[key];
      if (store.storeName.toLowerCase().contains(query.toLowerCase()) ||
          query.toLowerCase().contains(store.storeName.toLowerCase())) {
        filtered.add(store);
      }
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    RxStoresAndItems storesAndItems = GetIt.I.get<RxStoresAndItems>();
    return WillPopScope(
      onWillPop: () async {
        // GetIt.I.get<RxReceiveItTab>().index.add(0);
        widget.backPressed();
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child:
                // StreamBuilder<Map<String, dynamic>>(
                //     stream: storesAndItems.stores$,
                //     builder: (context, snapshot) {
                // if (snapshot.connectionState == ConnectionState.waiting) {
                //   return Center(
                //     child: CircularProgressIndicator(),
                //   );
                // } else if (snapshot.data == null) {
                //   return Center(
                //     child: Column(
                //       mainAxisSize: MainAxisSize.min,
                //       children: <Widget>[
                //         Icon(Icons.replay),
                //         SizedBox(
                //           height: 4,
                //         ),
                //         GestureDetector(
                //           child: Text('Tap to reload'),
                //           onTap: () {
                //             setState(() {});
                //           },
                //         ),
                //       ],
                //     ),
                //   );
                // } else if (snapshot.data.length == 0) {
                //   return Center(
                //       child: Text(
                //     'No Items Found Near You!',
                //     style: Theme.of(context).textTheme.headline6.copyWith(
                //           fontWeight: FontWeight.bold,
                //         ),
                //   ));
                // }
                // items = stores.c
                // stores = snapshot.data['stores'];
                Column(
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
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        loader: Center(
                          child: CircularProgressIndicator(),
                        ),
                        placeHolder: StreamBuilder<Map<String, model.Store>>(
                            stream: storesAndItems.stores$,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final keys = snapshot.data?.keys?.toList() ?? [];
                              return ListView(
                                physics: BouncingScrollPhysics(),
                                children:
                                    List<Widget>.generate(keys.length, (i) {
                                  String index = keys[i];
                                  return GestureDetector(
                                    child: StoreItem(
                                      store: snapshot.data[index],
                                    ),
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return StoreMainPage(
                                          demo: widget.demo,
                                          store: snapshot.data[index],
                                        );
                                      }));
                                    },
                                  );
                                }),
                              );
                            }),
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
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        loader: Center(
                          child: CircularProgressIndicator(),
                        ),
                        placeHolder:
                            StreamBuilder<Map<String, model.StoreItem>>(
                                stream: storesAndItems.items$,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                  final keys =
                                      snapshot?.data?.keys?.toList() ?? [];
                                  return ListView(
                                    physics: BouncingScrollPhysics(),
                                    children:
                                        List<Widget>.generate(keys.length, (i) {
                                      String index = keys[i];
                                      return GestureDetector(
                                        child: MenuItem(
                                          item: snapshot.data[index],
                                        ),
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return ItemDetailsRoute(
                                              item: snapshot.data[index],
                                              isDemo: widget.demo,
                                            );
                                          }));
                                        },
                                      );
                                    }),
                                  );
                                }),
                        onItemFound: (model.StoreItem item, index) {
                          return GestureDetector(
                            child: MenuItem(item: item),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ItemDetailsRoute(
                                      item: item,
                                      isDemo: widget.demo,
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
            ),
            // }),
          ),
        ),
      ),
    );
  }
}
