import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sennit/models/models.dart';

class RxStoresAndItems {
  BehaviorSubject<Map<String, Store>> stores =
      BehaviorSubject<Map<String, Store>>.seeded({});
  Future<Object> initializingStores;
  Future<Object> initializingItems;
  // BehaviorSubject<Map<String, Store>> nearbyStores =
  //     BehaviorSubject<Map<String, Store>>.seeded({});
  BehaviorSubject<Map<String, Store>> filteredStores =
      BehaviorSubject<Map<String, Store>>.seeded({});
  // BehaviorSubject<Map<String, Store>> filteredFromNearbyStores =
  //     BehaviorSubject<Map<String, Store>>.seeded({});
  BehaviorSubject<Map<String, StoreItem>> items =
      BehaviorSubject<Map<String, StoreItem>>.seeded({});
  // BehaviorSubject<Map<String, StoreItem>> filteredItems =
  //     BehaviorSubject<Map<String, StoreItem>>.seeded({});
  // BehaviorSubject<String> queryFromAllStores =
  //     BehaviorSubject<String>.seeded('');
  BehaviorSubject<String> queryStores = BehaviorSubject<String>.seeded('');
  // BehaviorSubject<String> itemQuery = BehaviorSubject<String>.seeded('');

  Stream<Map<String, Store>> get stores$ => stores.stream;
  // Observable<Map<String, Store>> get filteredFromAllStores$ =>
  //     filteredFromAllStores.stream;
  // Observable<Map<String, Store>> get filteredFromNearbyStores$ =>
  //     filteredFromNearbyStores.stream;
  Stream<Map<String, StoreItem>> get items$ => items.stream;
  Stream<String> get queryStores$ => queryStores.stream;
  // Observable<Map<String, StoreItem>> get filteredItems$ => filteredItems.stream;
  // BehaviorSubject<String> get allStoresQuery$ => queryFromAllStores.stream;
  // BehaviorSubject<String> get nearbyStoresQuery$ =>
  //     queryFromNearbyStores.stream;
  // BehaviorSubject<String> get itemQuery$ => queryFromAllStores.stream;

  Future updateFilteredStores() async {
    filteredStores.value.clear();
    stores.value.forEach((key, value) {
      if ('$key${value.storeName}'
              .toLowerCase()
              .contains(queryStores.value.toLowerCase()) ||
          queryStores.value
              .toLowerCase()
              .contains('${value.storeName}'.toLowerCase())) {
        filteredStores.value.putIfAbsent(value.storeId, () => value);
      }
    });
    filteredStores.add(filteredStores.value);
    // filteredFromAllStores.add(tempFilteredStores);
    // filteredFromNearbyStores.add(tempFilteredNearbyStores);
    // if (!storesOnly) {
    //   items.value.forEach((key, value) {
    //     if ('$key${value.storeName}'
    //             .toLowerCase()
    //             .contains(itemQuery.value.toLowerCase()) ||
    //         itemQuery.value
    //             .toLowerCase()
    //             .contains('${value.storeName}'.toLowerCase())) {
    //       tempFilteredStoreItems.putIfAbsent(value.itemId, () => value);
    //     }
    //   });
    // filteredItems.add(tempFilteredStoreItems);
    // }
  }

  void setStoreQuery(String query) {
    filteredStores.value.clear();
    stores.value.forEach((key, value) {
      if ('${value.storeName}'
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          query
              .toLowerCase()
              .contains('${value.storeName}'.toLowerCase())) {
        filteredStores.value.putIfAbsent(key, () => value);
      }
    });
    queryStores.add(query);
    filteredStores.add(filteredStores.value);
  }

  // Future<void> initializeStores() async {}
  // Future<void> initializeItems() async {}

  setStoreChanges(QuerySnapshot event) {
    Map<String, Store> currentValue = stores.value;
    for (var documentChange in event.documentChanges) {
      if (documentChange.type == DocumentChangeType.removed) {
        currentValue.remove(documentChange.document);
      } else {
        Store store = Store.fromMap(documentChange.document.data);
        store.storeId = documentChange.document.documentID;
        currentValue.update(
          documentChange.document.documentID,
          (old) {
            old.storeName = store.storeName;
            old.storeAddress = store.storeAddress;
            old.storeId = store.storeId;
            old.storeImage = store.storeImage;
            old.deviceTokens = store.deviceTokens;
            old.isOpened = store.isOpened;
            old.items = store.items;
            old.storeLatLng = store.storeLatLng;
            old.storeMotto = store.storeMotto;
            return old;
          },
          ifAbsent: () {
            Store store = Store.fromMap(documentChange.document.data);
            store.storeId = documentChange.document.documentID;
            return store;
          },
        );
      }
      updateFilteredStores();
      stores.add(stores.value);
    }
  }

  setItemChanges(QuerySnapshot event) {
    Map<String, StoreItem> currentValue = items.value;
    for (var documentChange in event.documentChanges) {
      String itemId = documentChange.document.documentID;
      String storeId = documentChange.document['storeId'];
      if (documentChange.type == DocumentChangeType.removed) {
        try {
          stores.value[storeId].items.remove(itemId);
          // stores.value[storeId].storeItems.remove(currentValue[itemId]);
          currentValue.remove(itemId);
        } catch (ex) {
          debugPrint(ex);
        }
      } else if (documentChange.type == DocumentChangeType.modified) {
        currentValue.update(
          documentChange.document.documentID,
          (old) {
            StoreItem item = StoreItem.fromMap(documentChange.document.data);
            item.itemId = documentChange.document.documentID;
            old.itemId = item.itemId;
            old.itemName = item.itemName;
            old.description = item.description;
            old.images = item.images;
            old.latlng = item.latlng;
            old.price = item.price;
            old.remainingInStock = item.remainingInStock;
            old.specifications = item.specifications;
            // old.storeAddress = item.storeAddress;
            // old.quantity = item.quantity;
            // Store store = stores.value[item.storeId];
            // if (store != null) {
            //   if (!store.storeItems.contains(old)) {
            //     store.storeItems.add(old);
            //   }
            // }
            return old;
          },
          ifAbsent: () {
            StoreItem item = StoreItem.fromMap(documentChange.document.data);
            item.itemId = documentChange.document.documentID;
            // Store store = stores.value[item.storeId];
            // if (store != null) {
            //   if (store.items.contains(item.itemId)) {
            //     if (!store.storeItems.contains(item)) {
            //       store.storeItems.add(item);
            //     }
            //   }
            // }
            return item;
          },
        );
      } else {
        StoreItem item = StoreItem.fromMap(documentChange.document.data);
        item.itemId = documentChange.document.documentID;
        currentValue.putIfAbsent(item.itemId, () => item);
        Store store = stores.value[item.storeId];
        if (store != null) {
          if (store.items.contains(item.itemId)) {
            // if (!store.storeItems.contains(item)) {
            //   store.storeItems.add(item);
            // }
          } else {
            store.items.add(item.itemId);
            // if (!store.storeItems.contains(item)) {
            //   store.storeItems.add(item);
            // }
          }
        }
      }
    }
    items.add(currentValue);
  }

  Future<Object> initializeStoresAndItems() async {
    initializingStores =
        Firestore.instance.collection('stores').getDocuments().then((value) {
      var documents = value.documents;
      var storesData = stores.value;
      for (var document in documents) {
        Store store = Store.fromMap(document.data);
        store.storeId = document.documentID;
        storesData.putIfAbsent(document.documentID, () => store);
      }
      stores.add(storesData);
      return {};
    }).catchError((error) {
      return null;
    });
    initializingItems =
        Firestore.instance.collection('items').getDocuments().then((value) {
      var documents = value.documents;
      var itemsData = items.value;
      for (var document in documents) {
        StoreItem storeItem = StoreItem.fromMap(document.data);
        storeItem.itemId = document.documentID;
        itemsData.putIfAbsent(document.documentID, () => storeItem);
      }
      items.add(itemsData);
      return {};
    }).catchError((error) {
      return null;
    });
    var result = await initializingStores;
    if (result == null) return null;
    result = await initializingItems;
    if (result == null) return null;
    init();
    return {};
  }

  Future<void> init() async {
    Firestore.instance.collection('stores').snapshots().listen((event) {
      setStoreChanges(event);
    });

    Firestore.instance.collection('items').snapshots().listen((event) {
      setItemChanges(event);
    });
    //     updateFilteredStoresItems();

    //     stores.add(stores.value);
    //     items.add(items.value);
    //   },
    // );

    // RxAddress rxAddress = GetIt.I.get<RxAddress>();
    // RxConfig rxConfig = GetIt.I.get<RxConfig>();
    // StreamSubscription subscription;

    // rxAddress.address.listen((event) {
    //   Coordinates fromCoordinates = event['fromAddress'].coordinates;
    //   LatLng fromLatLng = Utils.latLngFromCoordinates(fromCoordinates);
    //   subscription?.cancel();
    //   subscription = nearbyStores.listen((event) {
    //     Map<String, Store> tempNearbyStores = {};
    //     event.forEach((key, value) {
    //       if (Utils.calculateDistance(value.storeLatLng, fromLatLng) <=
    //               rxConfig
    //                   .config?.value['currentReceiveItMinimumStoreDistance'] ??
    //           8) {
    //         tempNearbyStores.putIfAbsent(key, () => value);
    //       }
    //     });
    //     nearbyStores.add(tempNearbyStores);
    //   });
    // });

    // StreamSubscription nearbyStoreStreamSubscription;
    // // StreamSubscription allStoreStreamSubscription;

    // nearbyStores.listen((storesEvent) {
    //   nearbyStoreStreamSubscription?.cancel();
    //   nearbyStoreStreamSubscription = nearbyStoresQuery$.listen((queryEvent) {
    //     Map<String, Store> tempFilteredFromNearbyStores = {};
    //     storesEvent.forEach((key, value) {
    //       if (value.storeName.contains(queryEvent) ||
    //           queryEvent.contains(value.storeName)) {
    //         tempFilteredFromNearbyStores.putIfAbsent(key, () => value);
    //       }
    //     });
    //     filteredFromNearbyStores
    //         .add(Map<String, Store>.from(tempFilteredFromNearbyStores));
    //   });
    // });

    // stores$.listen((storesEvent) {
    //   allStoreStreamSubscription?.cancel();
    //   allStoreStreamSubscription = queryFromAllStores.listen((queryEvent) {
    //     var tempFilteredFromAllStores = {};
    //     storesEvent.forEach((key, value) {
    //       if (value.storeName.contains(queryEvent) ||
    //           queryEvent.contains(value.storeName)) {
    //         tempFilteredFromAllStores.putIfAbsent(key, () => value);
    //       }
    //     });
    //     // filteredFromAllStores.add(tempFilteredFromAllStores);
    //   });
    // });

    // void setQueryFromAllStores(String query) {
    //   queryFromAllStores.add(query);
    // }

    // void setQueryFromNearbyStores(String query) {
    //   queryFromNearbyStores.add(query);
    // }

    // void setItemQuery(String query) {
    //   itemQuery.add(query);
    // }
  }
}
