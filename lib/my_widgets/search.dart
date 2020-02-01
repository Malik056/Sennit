import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:sennit/models/models.dart' as model;
import 'package:sennit/user/recieveIt.dart';

class SearchWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SearchWidgetState();
  }
}

class SearchWidgetState extends State<SearchWidget> {
  Future<List<model.StoreItem>> initialize() async {
    List<model.StoreItem> items = [];
    QuerySnapshot snapshot =
        await Firestore.instance.collection('items').getDocuments();
    for (DocumentSnapshot snapshot in snapshot.documents) {
      items.add(model.StoreItem.fromMap(snapshot.data));
    }
    return items;
  }

  List<model.StoreItem> items;
  Future<List<model.StoreItem>> search(String query) async {
    List<model.StoreItem> filtered = [];
    final storeItems = items;
    for (model.StoreItem item in storeItems) {
      if (item.itemName.toLowerCase().contains(query.toLowerCase())) {
        filtered.add(item);
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
          child: FutureBuilder<List<model.StoreItem>>(
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
                }
                items = snapshot.data;
                return SearchBar<model.StoreItem>(
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
                    children: List<Widget>.generate(items.length, (index) {
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
                    );
                  },
                );
              }),
        ),
      ),
    );
  }
}
