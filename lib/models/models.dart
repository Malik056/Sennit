import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sennit/main.dart';

enum BoxSize {
  small,
  medium,
  large,
}

enum Gender {
  male,
  female,
  other,
}

class User {
  String userId;
  String firstName;
  String lastName;
  String homeLocationAddress;
  LatLng homeLocationLatLng;
  String officeLocationAddress;
  LatLng officeLocationLatLng;
  DateTime userCreatedOn;
  String email;
  String phoneNumber;
  DateTime dateOfBirth;
  Gender gender;
  String rank;
  String profilePicture;

  String get fullname => "$firstName $lastName";

  User({
    this.userId,
    this.firstName,
    this.lastName,
    this.homeLocationAddress,
    this.homeLocationLatLng,
    this.officeLocationAddress,
    this.officeLocationLatLng,
    this.userCreatedOn,
    this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.rank,
    this.profilePicture,
  });

  User copyWith({
    String userID,
    String firstName,
    String lastName,
    String homeLocationAddress,
    LatLng homeLocationLatLng,
    String officeLocationAddress,
    LatLng officeLocationLatLng,
    DateTime userCreatedOn,
    String email,
    String phoneNumber,
    DateTime dateOfBirth,
    Gender gender,
    String rank,
    String profilePicture,
  }) {
    return User(
      userId: userID ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      homeLocationAddress: homeLocationAddress ?? this.homeLocationAddress,
      homeLocationLatLng: homeLocationLatLng ?? this.homeLocationLatLng,
      officeLocationAddress:
          officeLocationAddress ?? this.officeLocationAddress,
      officeLocationLatLng: officeLocationLatLng ?? this.officeLocationLatLng,
      userCreatedOn: userCreatedOn ?? this.userCreatedOn,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      rank: rank ?? this.rank,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'homeLocationAddress': homeLocationAddress,
      'homeLocationLatLng': Utils.latLngToString(homeLocationLatLng),
      'officeLocationAddress':
          officeLocationAddress == null ? null : officeLocationAddress,
      'officeLocationLatLng': officeLocationLatLng == null
          ? null
          : Utils.latLngToString(officeLocationLatLng),
      'userCreatedOn': userCreatedOn.millisecondsSinceEpoch,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth.millisecondsSinceEpoch,
      'gender': Utils.genderToString(gender),
      'rank': rank,
      'profilePicture': profilePicture,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return User(
      userId: map['userId'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      homeLocationAddress: map['homeLocationAddress'],
      homeLocationLatLng: Utils.latLngFromString(map['homeLocationLatLng']),
      officeLocationAddress: map['officeLocationAddress'],
      officeLocationLatLng: map['officeLocationLatLng'],
      userCreatedOn: DateTime.fromMillisecondsSinceEpoch(map['userCreatedOn']),
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      dateOfBirth: DateTime.fromMillisecondsSinceEpoch(map['dateOfBirth']),
      gender: Utils.getGenderFromString(map['gender']),
      profilePicture: map['profilePicture'],
      rank: map['rank'],
    );
  }

  String toJson() => json.encode(toMap());

  static User fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'User userId: $userId, firstName: $firstName, lastName: $lastName, homeLocationAddress: $homeLocationAddress, latLng: ${Utils.latLngToString(homeLocationLatLng)}, officeLocationAddress: $officeLocationAddress, officeLocationLatLng: ${Utils.latLngToString(officeLocationLatLng)}, userCreatedOn: $userCreatedOn, email: $email, phoneNumber: $phoneNumber, dateOfBirth: $dateOfBirth, gender: $gender, rank: $rank, profilePicture: $profilePicture';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return (o is User && o.userId == userId) || (o is String && o == userId);
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        homeLocationAddress.hashCode ^
        homeLocationLatLng.hashCode ^
        officeLocationAddress.hashCode ^
        officeLocationLatLng.hashCode ^
        userCreatedOn.hashCode ^
        email.hashCode ^
        phoneNumber.hashCode ^
        dateOfBirth.hashCode ^
        gender.hashCode ^
        rank.hashCode ^
        profilePicture.hashCode;
  }
}

class Driver {
  String driverId;
  String firstName;
  String lastName;
  String homeLocationAddress;
  LatLng homeLocationLatLng;
  DateTime userCreatedOn;
  String email;
  String phoneNumber;
  String profilePicture;
  DateTime dateOfBirth;
  Gender gender;
  String rank;
  double balance;
  Driver({
    this.driverId,
    this.firstName,
    this.lastName,
    this.homeLocationAddress,
    this.homeLocationLatLng,
    this.userCreatedOn,
    this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.rank,
    this.profilePicture,
    this.balance,
  });

  Driver copyWith({
    String driverId,
    String firstName,
    String lastName,
    String homeLocationAddress,
    LatLng homeLocationLatLng,
    DateTime userCreatedOn,
    String email,
    String phoneNumber,
    DateTime dateOfBirth,
    Gender gender,
    String rank,
    double balance,
    String profilePicture,
  }) {
    return Driver(
      driverId: driverId ?? this.driverId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      homeLocationAddress: homeLocationAddress ?? this.homeLocationAddress,
      homeLocationLatLng: homeLocationLatLng ?? this.homeLocationLatLng,
      userCreatedOn: userCreatedOn ?? this.userCreatedOn,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      rank: rank ?? this.rank,
      profilePicture: profilePicture ?? this.profilePicture,
      balance: balance ?? this.balance,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'firstName': firstName,
      'lastName': lastName,
      'homeLocationAddress': homeLocationAddress,
      'homeLocationLatLng': Utils.latLngToString(homeLocationLatLng),
      'userCreatedOn': userCreatedOn.millisecondsSinceEpoch,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth.millisecondsSinceEpoch,
      'gender': Utils.genderToString(gender),
      'rank': rank,
      'profilePicture': profilePicture,
      'balance': balance,
    };
  }

  static Driver fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Driver(
      driverId: map['driverId'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      homeLocationAddress: map['homeLocationAddress'],
      homeLocationLatLng: Utils.latLngFromString(map['homeLocationLatLng']),
      userCreatedOn: DateTime.fromMillisecondsSinceEpoch(map['userCreatedOn']),
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      dateOfBirth: DateTime.fromMillisecondsSinceEpoch(map['dateOfBirth']),
      gender: Utils.getGenderFromString(map['gender']),
      rank: map['rank'],
      profilePicture: map['profilePicture'],
      balance: map['balance'],
    );
  }

  String toJson() => json.encode(toMap());

  static Driver fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'Driver driverId: $driverId, firstName: $firstName, lastName: $lastName, homeLocationAddress: $homeLocationAddress, homeLocationLatLng: $homeLocationLatLng, userCreatedOn: $userCreatedOn, email: $email, phoneNumber: $phoneNumber, dateOfBirth: $dateOfBirth, gender: $gender, rank: $rank, balance: $balance';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return (o is Driver && o.driverId == driverId) ||
        (o is String && o == driverId);
  }

  @override
  int get hashCode {
    return driverId.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        homeLocationAddress.hashCode ^
        homeLocationLatLng.hashCode ^
        userCreatedOn.hashCode ^
        email.hashCode ^
        phoneNumber.hashCode ^
        dateOfBirth.hashCode ^
        gender.hashCode ^
        rank.hashCode ^
        balance.hashCode;
  }
}

class OrderFromReceiveIt {
  List<String> items;
  String email;
  String phoneNumber;
  String house;
  LatLng destination;
  String userId;
  String driverId;
  double price;
  DateTime orderDate;
  DateTime deliveryTime;
  OrderFromReceiveIt({
    this.items,
    this.email,
    this.phoneNumber,
    this.house,
    this.destination,
    this.userId,
    this.driverId,
    this.price,
    this.orderDate,
    this.deliveryTime,
  });

  OrderFromReceiveIt copyWith({
    List<String> items,
    String email,
    String phoneNumber,
    String house,
    LatLng destination,
    String userId,
    String driverId,
    double price,
    DateTime orderDate,
    DateTime deliveryTime,
  }) {
    return OrderFromReceiveIt(
      items: items ?? this.items,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      house: house ?? this.house,
      destination: destination ?? this.destination,
      userId: userId ?? this.userId,
      driverId: driverId ?? this.driverId,
      price: price ?? this.price,
      orderDate: orderDate ?? this.orderDate,
      deliveryTime: deliveryTime ?? this.deliveryTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'items': List<dynamic>.from(items.map((x) => x)),
      'email': email,
      'phoneNumber': phoneNumber,
      'house': house,
      'destination': Utils.latLngToString(destination),
      'userId': userId,
      'driverId': driverId,
      'price': price,
      'orderDate': orderDate.millisecondsSinceEpoch,
      'deliveryTime': deliveryTime.millisecondsSinceEpoch,
    };
  }

  static OrderFromReceiveIt fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return OrderFromReceiveIt(
      items: List<String>.from(map['items']),
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      house: map['house'],
      destination: Utils.latLngFromString(map['destination']),
      userId: map['userId'],
      driverId: map['driverId'],
      price: map['price'],
      orderDate: DateTime.fromMillisecondsSinceEpoch(map['orderDate']),
      deliveryTime: DateTime.fromMillisecondsSinceEpoch(map['deliveryTime']),
    );
  }

  String toJson() => json.encode(toMap());

  static OrderFromReceiveIt fromJson(String source) =>
      fromMap(json.decode(source));

  @override
  String toString() {
    return 'OrderFromReceiveIt items: $items, email: $email, phoneNumber: $phoneNumber, house: $house, destination: $destination, userId: $userId, driverId: $driverId, price: $price, orderDate: $orderDate, deliveryTime: $deliveryTime';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is OrderFromReceiveIt &&
        o.items == items &&
        o.email == email &&
        o.phoneNumber == phoneNumber &&
        o.house == house &&
        o.destination == destination &&
        o.userId == userId &&
        o.driverId == driverId &&
        o.price == price &&
        o.orderDate == orderDate &&
        o.deliveryTime == deliveryTime;
  }

  @override
  int get hashCode {
    return items.hashCode ^
        email.hashCode ^
        phoneNumber.hashCode ^
        house.hashCode ^
        destination.hashCode ^
        userId.hashCode ^
        driverId.hashCode ^
        price.hashCode ^
        orderDate.hashCode ^
        deliveryTime.hashCode;
  }
}
// class OrderFromReceiveIt {}
//   String storeName;
//   String storeLocationAddress;
//   LatLng storeLatLng;
//   String dropOffAddress;
//   LatLng dropOffLatLng;
//   String orderId;
//   DateTime dateOrdered;
//   double orderPrice;
//   String userId;
//   String driverId;
//   OrderFromRecieveIt({
//     this.storeName,
//     this.storeLocationAddress,
//     this.storeLatLng,
//     this.dropOffAddress,
//     this.dropOffLatLng,
//     this.orderId,
//     this.dateOrdered,
//     this.orderPrice,
//     this.userId,
//     this.driverId,
//   });

//   OrderFromRecieveIt copyWith({
//     String storeName,
//     String storeLocationAddress,
//     LatLng storeLatLng,
//     String dropOffAddress,
//     LatLng dropOffLatLng,
//     String orderId,
//     DateTime dateOrdered,
//     double orderPrice,
//     String userId,
//     String driverId,
//   }) {
//     return OrderFromRecieveIt(
//       storeName: storeName ?? this.storeName,
//       storeLocationAddress: storeLocationAddress ?? this.storeLocationAddress,
//       storeLatLng: storeLatLng ?? this.storeLatLng,
//       dropOffAddress: dropOffAddress ?? this.dropOffAddress,
//       dropOffLatLng: dropOffLatLng ?? this.dropOffLatLng,
//       orderId: orderId ?? this.orderId,
//       dateOrdered: dateOrdered ?? this.dateOrdered,
//       orderPrice: orderPrice ?? this.orderPrice,
//       userId: userId ?? this.userId,
//       driverId: driverId ?? this.driverId,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'storeName': storeName,
//       'storeLocationAddress': storeLocationAddress,
//       'storeLatLng': Utils.latLngToString(storeLatLng),
//       'dropOffAddress': dropOffAddress,
//       'dropOffLatLng': Utils.latLngToString(dropOffLatLng),
//       'orderId': orderId,
//       'dateOrdered': dateOrdered.millisecondsSinceEpoch,
//       'orderPrice': orderPrice,
//       'userId': userId,
//       'driverId': driverId,
//     };
//   }

//   static OrderFromRecieveIt fromMap(Map<String, dynamic> map) {
//     if (map == null) return null;

//     return OrderFromRecieveIt(
//       storeName: map['storeName'],
//       storeLocationAddress: map['storeLocationAddress'],
//       storeLatLng: Utils.latLngFromString(map['storeLatLng']),
//       dropOffAddress: map['dropOffAddress'],
//       dropOffLatLng: Utils.latLngFromString(map['dropOffLatLng']),
//       orderId: map['orderId'],
//       dateOrdered: DateTime.fromMillisecondsSinceEpoch(map['dateOrdered']),
//       orderPrice: map['orderPrice'],
//       userId: map['userId'],
//       driverId: map['driverId'],
//     );
//   }

//   String toJson() => json.encode(toMap());

//   static OrderFromRecieveIt fromJson(String source) =>
//       fromMap(json.decode(source));

//   @override
//   String toString() {
//     return 'OrderFromRecieveIt storeName: $storeName, storeLocationAddress: $storeLocationAddress, storeLatLng: $storeLatLng, dropOffAddress: $dropOffAddress, dropOffLatLng: $dropOffLatLng, orderId: $orderId, dateOrdered: $dateOrdered, orderPrice: $orderPrice, userId: $userId, driverId: $driverId';
//   }

//   @override
//   bool operator ==(Object o) {
//     if (identical(this, o)) return true;

//     return (o is OrderFromRecieveIt && o.orderId == orderId) ||
//         (o is String && o == orderId);
//   }

//   @override
//   int get hashCode {
//     return storeName.hashCode ^
//         storeLocationAddress.hashCode ^
//         storeLatLng.hashCode ^
//         dropOffAddress.hashCode ^
//         dropOffLatLng.hashCode ^
//         orderId.hashCode ^
//         dateOrdered.hashCode ^
//         orderPrice.hashCode ^
//         userId.hashCode ^
//         driverId.hashCode;
//   }
// }

class OrderFromSennit {
  String orderId;
  DateTime dateOrdered;
  double orderPrice;
  LatLng pickUpLatLng;
  String pickUpAddress;
  String dropOffAddress;
  LatLng dropOffLatLng;
  double serviceCharges;
  String userId;
  String receiverName;
  String receiverPhone;
  String receiverEmail;
  String driverId;
  BoxSize boxSize;
  int numberOfBoxes;
  bool sleevesRequired;

  OrderFromSennit({
    this.orderId,
    this.dateOrdered,
    this.orderPrice,
    this.pickUpLatLng,
    this.pickUpAddress,
    this.dropOffAddress,
    this.dropOffLatLng,
    this.serviceCharges,
    this.userId,
    this.receiverName,
    this.receiverPhone,
    this.receiverEmail,
    this.driverId,
    this.boxSize,
    this.numberOfBoxes,
    this.sleevesRequired,
  });

  OrderFromSennit copyWith({
    String orderId,
    DateTime dateOrdered,
    double orderPrice,
    LatLng pickUpLatLng,
    String pickUpAddress,
    String dropOffAddress,
    LatLng dropOffLatLng,
    double serviceCharges,
    String userId,
    String receiverName,
    String receiverPhone,
    String receiverEmail,
    String driverId,
    BoxSize boxSize,
    int numberOfBoxes,
    bool sleevesRequired,
  }) {
    return OrderFromSennit(
      orderId: orderId ?? this.orderId,
      dateOrdered: dateOrdered ?? this.dateOrdered,
      orderPrice: orderPrice ?? this.orderPrice,
      pickUpLatLng: pickUpLatLng ?? this.pickUpLatLng,
      pickUpAddress: pickUpAddress ?? this.pickUpAddress,
      dropOffAddress: dropOffAddress ?? this.dropOffAddress,
      dropOffLatLng: dropOffLatLng ?? this.dropOffLatLng,
      serviceCharges: serviceCharges ?? this.serviceCharges,
      userId: userId ?? this.userId,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      receiverEmail: receiverEmail ?? this.receiverEmail,
      driverId: driverId ?? this.driverId,
      boxSize: boxSize ?? this.boxSize,
      numberOfBoxes: numberOfBoxes ?? this.numberOfBoxes,
      sleevesRequired: sleevesRequired ?? this.sleevesRequired,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'dateOrdered': dateOrdered.millisecondsSinceEpoch,
      'orderPrice': orderPrice,
      'pickUpLatLng': Utils.latLngToString(pickUpLatLng),
      'pickUpAddress': pickUpAddress,
      'dropOffAddress': dropOffAddress,
      'dropOffLatLng': Utils.latLngToString(dropOffLatLng),
      'serviceCharges': serviceCharges,
      'userId': userId,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'receiverEmail': receiverEmail,
      'driverId': driverId,
      'boxSize': Utils.boxSizeToString(boxSize),
      'numberOfBoxes': numberOfBoxes,
      'sleevesRequired': sleevesRequired,
    };
  }

  static OrderFromSennit fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return OrderFromSennit(
      orderId: map['orderId'],
      dateOrdered: DateTime.fromMillisecondsSinceEpoch(map['dateOrdered']),
      orderPrice: map['orderPrice'],
      pickUpLatLng: Utils.latLngFromString(map['pickUpLatLng']),
      pickUpAddress: map['pickUpAddress'],
      dropOffAddress: map['dropOffAddress'],
      dropOffLatLng: Utils.latLngFromString(map['dropOffLatLng']),
      serviceCharges: map['serviceCharges'],
      userId: map['userId'],
      receiverName: map['receiverName'],
      receiverPhone: map['receiverPhone'],
      receiverEmail: map['receiverEmail'],
      driverId: map['driverId'],
      boxSize: Utils.getBoxSizeFromString(map['boxSize']),
      numberOfBoxes: map['numberOfBoxes'],
      sleevesRequired: map['sleevesRequired'],
    );
  }

  String toJson() => json.encode(toMap());

  static OrderFromSennit fromJson(String source) =>
      fromMap(json.decode(source));

  @override
  String toString() {
    return 'OrderFromSennit orderId: $orderId, dateOrdered: $dateOrdered, orderPrice: $orderPrice, pickUpLatLng: $pickUpLatLng, pickUpAddress: $pickUpAddress, dropOffAddress: $dropOffAddress, dropOffLatLng: $dropOffLatLng, serviceCharges: $serviceCharges, userId: $userId, receiverName: $receiverName, receiverPhone: $receiverPhone, receiverEmail: $receiverEmail, driverId: $driverId, boxSize: $boxSize, numberOfBoxes: $numberOfBoxes, sleevesRequired: $sleevesRequired';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is OrderFromSennit && o.orderId == orderId;
  }

  @override
  int get hashCode {
    return orderId.hashCode ^
        dateOrdered.hashCode ^
        orderPrice.hashCode ^
        pickUpLatLng.hashCode ^
        pickUpAddress.hashCode ^
        dropOffAddress.hashCode ^
        dropOffLatLng.hashCode ^
        serviceCharges.hashCode ^
        userId.hashCode ^
        receiverName.hashCode ^
        receiverPhone.hashCode ^
        receiverEmail.hashCode ^
        driverId.hashCode ^
        boxSize.hashCode ^
        numberOfBoxes.hashCode ^
        sleevesRequired.hashCode;
  }
}
// class OrderItemForSennit {
//   String orderItemId;
//   double price;
//   String itemId;
//   String orderId;
//   bool sleevesRequred;
//   BoxSize boxSize;
//   int numberOfBoxes;
//   OrderItemForSennit({
//     this.orderItemId,
//     this.price,
//     this.itemId,
//     this.orderId,
//     this.sleevesRequred,
//     this.boxSize,
//     this.numberOfBoxes,
//   });

//   OrderItemForSennit copyWith({
//     String orderItemId,
//     double price,
//     String itemId,
//     String orderId,
//     bool sleevesRequred,
//     BoxSize boxSize,
//     int numberOfBoxes,
//   }) {
//     return OrderItemForSennit(
//       orderItemId: orderItemId ?? this.orderItemId,
//       price: price ?? this.price,
//       itemId: itemId ?? this.itemId,
//       orderId: orderId ?? this.orderId,
//       sleevesRequred: sleevesRequred ?? this.sleevesRequred,
//       boxSize: boxSize ?? this.boxSize,
//       numberOfBoxes: numberOfBoxes ?? this.numberOfBoxes,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'orderItemId': orderItemId,
//       'price': price,
//       'itemId': itemId,
//       'orderId': orderId,
//       'sleevesRequred': sleevesRequred,
//       'boxSize': Utils.boxSizeToString(boxSize),
//       'numberOfBoxes': numberOfBoxes,
//     };
//   }

//   static OrderItemForSennit fromMap(Map<String, dynamic> map) {
//     if (map == null) return null;

//     return OrderItemForSennit(
//       orderItemId: map['orderItemId'],
//       price: map['price'],
//       itemId: map['itemId'],
//       orderId: map['orderId'],
//       sleevesRequred: map['sleevesRequred'],
//       boxSize: Utils.getBoxSizeFromString(map['boxSize']),
//       numberOfBoxes: map['numberOfBoxes'],
//     );
//   }

//   String toJson() => json.encode(toMap());

//   static OrderItemForSennit fromJson(String source) =>
//       fromMap(json.decode(source));

//   @override
//   String toString() {
//     return 'OrderItemForSennit orderItemId: $orderItemId, price: $price, itemId: $itemId, orderId: $orderId, sleevesRequred: $sleevesRequred, boxSize: $boxSize, numberOfBoxes: $numberOfBoxes';
//   }

//   @override
//   bool operator ==(Object o) {
//     if (identical(this, o)) return true;

//     return (o is OrderItemForSennit && o.orderItemId == orderItemId) ||
//         (o is String && o == orderItemId);
//   }

//   @override
//   int get hashCode {
//     return orderItemId.hashCode ^
//         price.hashCode ^
//         itemId.hashCode ^
//         orderId.hashCode ^
//         sleevesRequred.hashCode ^
//         boxSize.hashCode ^
//         numberOfBoxes.hashCode;
//   }
// }

class OrderItemForReceiveIt {
  String orderItemId;
  String orderId;
  String itemId;
  int quantity;
  double price;
  String itemProperyId;
  OrderItemForReceiveIt({
    this.orderItemId,
    this.orderId,
    this.itemId,
    this.quantity,
    this.price,
    this.itemProperyId,
  });

  OrderItemForReceiveIt copyWith({
    String orderItemId,
    String orderId,
    String itemId,
    int quantity,
    double price,
    String itemProperyId,
  }) {
    return OrderItemForReceiveIt(
      orderItemId: orderItemId ?? this.orderItemId,
      orderId: orderId ?? this.orderId,
      itemId: itemId ?? this.itemId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      itemProperyId: itemProperyId ?? this.itemProperyId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderItemId': orderItemId,
      'orderId': orderId,
      'itemId': itemId,
      'quantity': quantity,
      'price': price,
      'itemProperyId': itemProperyId,
    };
  }

  static OrderItemForReceiveIt fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return OrderItemForReceiveIt(
      orderItemId: map['orderItemId'],
      orderId: map['orderId'],
      itemId: map['itemId'],
      quantity: map['quantity'],
      price: map['price'],
      itemProperyId: map['itemProperyId'],
    );
  }

  String toJson() => json.encode(toMap());

  static OrderItemForReceiveIt fromJson(String source) =>
      fromMap(json.decode(source));

  @override
  String toString() {
    return 'OrderItemForReceiveIt orderItemId: $orderItemId, orderId: $orderId, itemId: $itemId, quantity: $quantity, price: $price, itemProperyId: $itemProperyId';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return (o is OrderItemForReceiveIt && o.orderItemId == orderItemId) ||
        (o is String && o == orderItemId);
  }

  @override
  int get hashCode {
    return orderItemId.hashCode ^
        orderId.hashCode ^
        itemId.hashCode ^
        quantity.hashCode ^
        price.hashCode ^
        itemProperyId.hashCode;
  }
}

class OrderOtherCharges {
  String chargesId;
  String chargesName;
  String chargesPrice;
  String orderId;
  OrderOtherCharges({
    this.chargesId,
    this.chargesName,
    this.chargesPrice,
    this.orderId,
  });

  OrderOtherCharges copyWith({
    String chargesId,
    String chargesName,
    String chargesPrice,
    String orderId,
  }) {
    return OrderOtherCharges(
      chargesId: chargesId ?? this.chargesId,
      chargesName: chargesName ?? this.chargesName,
      chargesPrice: chargesPrice ?? this.chargesPrice,
      orderId: orderId ?? this.orderId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chargesId': chargesId,
      'chargesName': chargesName,
      'chargesPrice': chargesPrice,
      'orderId': orderId,
    };
  }

  static OrderOtherCharges fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return OrderOtherCharges(
      chargesId: map['chargesId'],
      chargesName: map['chargesName'],
      chargesPrice: map['chargesPrice'],
      orderId: map['orderId'],
    );
  }

  String toJson() => json.encode(toMap());

  static OrderOtherCharges fromJson(String source) =>
      fromMap(json.decode(source));

  @override
  String toString() {
    return 'OrderOtherCharges chargesId: $chargesId, chargesName: $chargesName, chargesPrice: $chargesPrice, orderId: $orderId';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is OrderOtherCharges &&
        o.chargesId == chargesId &&
        o.chargesName == chargesName &&
        o.chargesPrice == chargesPrice &&
        o.orderId == orderId;
  }

  @override
  int get hashCode {
    return chargesId.hashCode ^
        chargesName.hashCode ^
        chargesPrice.hashCode ^
        orderId.hashCode;
  }
}

// class Item {
//   String itemId;
//   String name;
//   String baseCategory;
//   String subCategory;
//   String orderId;
//   double price;

//   ItemProperty itemProperty;

//   Item({
//     this.itemId,
//     this.name,
//     this.baseCategory,
//     this.subCategory,
//     this.orderId,
//     this.price,
//   });

//   Item copyWith({
//     String itemId,
//     String name,
//     String baseCategory,
//     String subCategory,
//     String orderId,
//     double price,
//   }) {
//     return Item(
//       itemId: itemId ?? this.itemId,
//       name: name ?? this.name,
//       baseCategory: baseCategory ?? this.baseCategory,
//       subCategory: subCategory ?? this.subCategory,
//       orderId: orderId ?? this.orderId,
//       price: price ?? this.price,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'itemId': itemId,
//       'name': name,
//       'baseCategory': baseCategory,
//       'subCategory': subCategory,
//       'orderId': orderId,
//       'price': price,
//     };
//   }

//   static Item fromMap(Map<String, dynamic> map) {
//     if (map == null) return null;

//     return Item(
//       itemId: map['itemId'],
//       name: map['name'],
//       baseCategory: map['baseCategory'],
//       subCategory: map['subCategory'],
//       orderId: map['orderId'],
//       price: map['price'],
//     );
//   }

//   String toJson() => json.encode(toMap());

//   static Item fromJson(String source) => fromMap(json.decode(source));

//   @override
//   String toString() {
//     return 'Item itemId: $itemId, name: $name, baseCategory: $baseCategory, subCategory: $subCategory, orderId: $orderId, price: $price';
//   }

//   @override
//   bool operator ==(Object o) {
//     if (identical(this, o)) return true;

//     return o is Item &&
//         o.itemId == itemId &&
//         o.name == name &&
//         o.baseCategory == baseCategory &&
//         o.subCategory == subCategory &&
//         o.orderId == orderId &&
//         o.price == price;
//   }

//   @override
//   int get hashCode {
//     return itemId.hashCode ^
//         name.hashCode ^
//         baseCategory.hashCode ^
//         subCategory.hashCode ^
//         orderId.hashCode ^
//         price.hashCode;
//   }
// }

// class ItemImage {
//   String imageId;
//   String itemId;
//   String url;
//   ItemImage({
//     this.imageId,
//     this.itemId,
//     this.url,
//   });

//   ItemImage copyWith({
//     String imageId,
//     String itemId,
//     String url,
//   }) {
//     return ItemImage(
//       imageId: imageId ?? this.imageId,
//       itemId: itemId ?? this.itemId,
//       url: url ?? this.url,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'imageId': imageId,
//       'itemId': itemId,
//       'url': url,
//     };
//   }

//   static ItemImage fromMap(Map<String, dynamic> map) {
//     if (map == null) return null;

//     return ItemImage(
//       imageId: map['imageId'],
//       itemId: map['itemId'],
//       url: map['url'],
//     );
//   }

//   String toJson() => json.encode(toMap());

//   static ItemImage fromJson(String source) => fromMap(json.decode(source));

//   @override
//   String toString() =>
//       'ItemImage imageId: $imageId, itemId: $itemId, url: $url';

//   @override
//   bool operator ==(Object o) {
//     if (identical(this, o)) return true;

//     return (o is ItemImage && o.imageId == imageId) ||
//         (o is String && o == imageId);
//   }

//   @override
//   int get hashCode => imageId.hashCode ^ itemId.hashCode ^ url.hashCode;
// }

class UserCart {
  String cartId;
  String userId;
  List<StoreItem> items = List();
  UserCart({
    this.cartId,
    this.userId,
  });

  UserCart copyWith({
    String cartId,
    String userId,
    double totalPrice,
  }) {
    return UserCart(
      cartId: cartId ?? this.cartId,
      userId: userId ?? this.userId,
      // totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cartId': cartId,
      'userId': userId,
    };
  }

  static UserCart fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return UserCart(
      cartId: map['cartId'],
      userId: map['userId'],
    );
  }

  String toJson() => json.encode(toMap());

  static UserCart fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() => 'UserCart cartId: $cartId, userId: $userId';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is UserCart && o.cartId == cartId;
  }

  @override
  int get hashCode => cartId.hashCode ^ userId.hashCode;
}

class UserLocationHistory {
  String address;
  LatLng latLng;
  String userId;
  DateTime lastUsed;
  UserLocationHistory({
    this.address,
    this.latLng,
    this.userId,
    this.lastUsed,
  });

  UserLocationHistory copyWith({
    String address,
    LatLng latLng,
    String userId,
    DateTime lastUsed,
  }) {
    return UserLocationHistory(
      address: address ?? this.address,
      latLng: latLng ?? this.latLng,
      userId: userId ?? this.userId,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'latLng': Utils.latLngToString(latLng),
      'userId': userId,
      'lastUsed': lastUsed.millisecondsSinceEpoch,
    };
  }

  static UserLocationHistory fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return UserLocationHistory(
      address: map['address'],
      latLng: Utils.latLngFromString(map['latLng']),
      userId: map['userId'],
      lastUsed: DateTime.fromMillisecondsSinceEpoch(map['lastUsed']),
    );
  }

  String toJson() => json.encode(toMap());

  static UserLocationHistory fromJson(String source) =>
      fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserLocationHistory address: $address, latLng: $latLng, userId: $userId, lastUsed: $lastUsed';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is UserLocationHistory &&
        o.address == address &&
        o.latLng == latLng &&
        o.userId == userId &&
        o.lastUsed == lastUsed;
  }

  @override
  int get hashCode {
    return address.hashCode ^
        latLng.hashCode ^
        userId.hashCode ^
        lastUsed.hashCode;
  }
}

class UserNotification {
  String notificationId;
  String title;
  String orderId;
  String description;
  bool isNotificationForOrderComplete;

  UserNotification({
    this.notificationId,
    this.title,
    this.orderId,
    this.description,
    this.isNotificationForOrderComplete,
  });

  UserNotification copyWith({
    String notificationId,
    String title,
    String orderId,
    String description,
    bool isNotificationForOrderComplete,
  }) {
    return UserNotification(
      notificationId: notificationId ?? this.notificationId,
      title: title ?? this.title,
      orderId: orderId ?? this.orderId,
      description: description ?? this.description,
      isNotificationForOrderComplete:
          isNotificationForOrderComplete ?? this.isNotificationForOrderComplete,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'title': title,
      'orderId': orderId,
      'description': description,
      'isNotificationForOrderComplete': isNotificationForOrderComplete ? 1 : 0,
    };
  }

  static UserNotification fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return UserNotification(
      notificationId: map['notificationId'],
      title: map['title'],
      orderId: map['orderId'],
      description: map['description'],
      isNotificationForOrderComplete:
          map['isNotificationForOrderComplete'] == 1 ? true : false,
    );
  }

  String toJson() => json.encode(toMap());

  static UserNotification fromJson(String source) =>
      fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserNotification notificationId: $notificationId, title: $title, orderId: $orderId, description: $description, isNotificationForOrderComplete: $isNotificationForOrderComplete';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return (o is UserNotification && o.notificationId == notificationId) ||
        (o is String && o == notificationId);
  }

  @override
  int get hashCode {
    return notificationId.hashCode ^
        title.hashCode ^
        orderId.hashCode ^
        description.hashCode ^
        isNotificationForOrderComplete.hashCode;
  }
}

class DriverNotification {
  String notificationId;
  String pickUpAddress;
  LatLng pickUpLatLng;
  LatLng dropOffLatLng;
  String orderId;
  DriverNotification({
    this.notificationId,
    this.pickUpAddress,
    this.pickUpLatLng,
    this.dropOffLatLng,
    this.orderId,
  });

  DriverNotification copyWith({
    String notificationId,
    String pickUpAddress,
    LatLng pickUpLatLng,
    LatLng dropOffLatLng,
    String orderId,
  }) {
    return DriverNotification(
      notificationId: notificationId ?? this.notificationId,
      pickUpAddress: pickUpAddress ?? this.pickUpAddress,
      pickUpLatLng: pickUpLatLng ?? this.pickUpLatLng,
      dropOffLatLng: dropOffLatLng ?? this.dropOffLatLng,
      orderId: orderId ?? this.orderId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'pickUpAddress': pickUpAddress,
      'pickUpLatLng': Utils.latLngToString(pickUpLatLng),
      'dropOffLatLng': Utils.latLngToString(dropOffLatLng),
      'orderId': orderId,
    };
  }

  static DriverNotification fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return DriverNotification(
      notificationId: map['notificationId'],
      pickUpAddress: map['pickUpAddress'],
      pickUpLatLng: Utils.latLngFromString(map['pickUpLatLng']),
      dropOffLatLng: Utils.latLngFromString(map['dropOffLatLng']),
      orderId: map['orderId'],
    );
  }

  String toJson() => json.encode(toMap());

  static DriverNotification fromJson(String source) =>
      fromMap(json.decode(source));

  @override
  String toString() {
    return 'DriverNotification notificationId: $notificationId, pickUpAddress: $pickUpAddress, pickUpLatLng: $pickUpLatLng, dropOffLatLng: $dropOffLatLng, orderId: $orderId';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return (o is DriverNotification && o.notificationId == notificationId) ||
        (o is String && o == notificationId);
  }

  @override
  int get hashCode {
    return notificationId.hashCode ^
        pickUpAddress.hashCode ^
        pickUpLatLng.hashCode ^
        dropOffLatLng.hashCode ^
        orderId.hashCode;
  }
}

class ItemProperty {
  String itemPropertyId;
  String propertyName;
  String propertyValue;
  double price;
  String itemId;
  ItemProperty({
    this.itemPropertyId,
    this.propertyName,
    this.propertyValue,
    this.price,
    this.itemId,
  });

  ItemProperty copyWith({
    String itemPropertyId,
    String propertyName,
    String propertyValue,
    double price,
    String itemId,
  }) {
    return ItemProperty(
      itemPropertyId: itemPropertyId ?? this.itemPropertyId,
      propertyName: propertyName ?? this.propertyName,
      propertyValue: propertyValue ?? this.propertyValue,
      price: price ?? this.price,
      itemId: itemId ?? this.itemId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemPropertyId': itemPropertyId,
      'propertyName': propertyName,
      'propertyValue': propertyValue,
      'price': price,
      'itemId': itemId,
    };
  }

  static ItemProperty fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return ItemProperty(
      itemPropertyId: map['itemPropertyId'],
      propertyName: map['propertyName'],
      propertyValue: map['propertyValue'],
      price: map['price'],
      itemId: map['itemId'],
    );
  }

  String toJson() => json.encode(toMap());

  static ItemProperty fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'ItemProperty itemPropertyId: $itemPropertyId, propertyName: $propertyName, propertyValue: $propertyValue, price: $price, itemId: $itemId';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ItemProperty &&
        o.itemPropertyId == itemPropertyId &&
        o.propertyName == propertyName &&
        o.propertyValue == propertyValue &&
        o.price == price &&
        o.itemId == itemId;
  }

  @override
  int get hashCode {
    return itemPropertyId.hashCode ^
        propertyName.hashCode ^
        propertyValue.hashCode ^
        price.hashCode ^
        itemId.hashCode;
  }
}

class StoreItem {
  String itemId;
  List<String> images;
  double price;
  String description;
  String itemName;
  StoreItem({
    this.itemId,
    this.images,
    this.price,
    this.description,
    this.itemName,
  });

  StoreItem copyWith({
    String itemId,
    List<String> images,
    double price,
    String description,
    String itemName,
  }) {
    return StoreItem(
      itemId: itemId ?? this.itemId,
      images: images ?? this.images,
      price: price ?? this.price,
      description: description ?? this.description,
      itemName: itemName ?? this.itemName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'images': List<dynamic>.from(images.map((x) => x)),
      'price': price,
      'description': description,
      'itemName': itemName,
    };
  }

  static StoreItem fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return StoreItem(
      itemId: map['itemId'],
      images: List<String>.from(map['images']),
      price: (map['price'] as int).toDouble(),
      description: map['description'],
      itemName: map['itemName'],
    );
  }

  String toJson() => json.encode(toMap());

  static StoreItem fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'StoreItem itemId: $itemId, images: $images, price: $price, description: $description, itemName: $itemName';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is StoreItem &&
        o.itemId == itemId &&
        o.images == images &&
        o.price == price &&
        o.description == description &&
        o.itemName == itemName;
  }

  @override
  int get hashCode {
    return itemId.hashCode ^
        images.hashCode ^
        price.hashCode ^
        description.hashCode ^
        itemName.hashCode;
  }
}

class Store {
  String storeId;
  String storeName;
  List<String> items;
  List<StoreItem> storeItems = [];
  String storeImage;
  String storeMoto;
  Store({
    this.storeId,
    this.storeName,
    this.items,
    this.storeImage,
    this.storeMoto,
  });

  Store copyWith({
    String storeId,
    String storeName,
    List<String> items,
    String storeImage,
    String storeMoto,
  }) {
    return Store(
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      items: items ?? this.items,
      storeImage: storeImage ?? this.storeImage,
      storeMoto: storeMoto ?? this.storeMoto,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'storeName': storeName,
      'items': List<dynamic>.from(items.map((x) => x)),
      'storeImage': storeImage,
      'storeMoto': storeMoto,
    };
  }

  static Store fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Store(
      storeId: map['storeId'],
      storeName: map['storeName'],
      items: List<String>.from(map['items']),
      storeImage: map['storeImage'],
      storeMoto: map['storeMoto'],
    );
  }

  String toJson() => json.encode(toMap());

  static Store fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'Store storeId: $storeId, storeName: $storeName, items: $items, storeImage: $storeImage, storeMoto: $storeMoto';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Store &&
        o.storeId == storeId &&
        o.storeName == storeName &&
        o.items == items &&
        o.storeImage == storeImage &&
        o.storeMoto == storeMoto;
  }

  @override
  int get hashCode {
    return storeId.hashCode ^
        storeName.hashCode ^
        items.hashCode ^
        storeImage.hashCode ^
        storeMoto.hashCode;
  }
}

class ReviewForDriver {
  String userId;
  String reviewedBy;
  String reviewDescription;
  String driverid;
  DateTime createdOn;
  double rating;
  DateTime lastUpdated;
  ReviewForDriver({
    this.userId,
    this.reviewedBy,
    this.reviewDescription,
    this.driverid,
    this.createdOn,
    this.rating,
    this.lastUpdated,
  });

  ReviewForDriver copyWith({
    String userId,
    String reviewedBy,
    String reviewDescription,
    String driverid,
    DateTime createdOn,
    double rating,
    DateTime lastUpdated,
  }) {
    return ReviewForDriver(
      userId: userId ?? this.userId,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewDescription: reviewDescription ?? this.reviewDescription,
      driverid: driverid ?? this.driverid,
      createdOn: createdOn ?? this.createdOn,
      rating: rating ?? this.rating,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'reviewedBy': reviewedBy,
      'reviewDescription': reviewDescription,
      'driverid': driverid,
      'createdOn': createdOn.millisecondsSinceEpoch,
      'rating': rating,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  static ReviewForDriver fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return ReviewForDriver(
      userId: map['userId'],
      reviewedBy: map['reviewedBy'],
      reviewDescription: map['reviewDescription'],
      driverid: map['driverid'],
      createdOn: DateTime.fromMillisecondsSinceEpoch(map['createdOn']),
      rating: map['rating'],
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated']),
    );
  }

  String toJson() => json.encode(toMap());

  static ReviewForDriver fromJson(String source) =>
      fromMap(json.decode(source));

  @override
  String toString() {
    return 'ReviewForDriver userId: $userId, reviewedBy: $reviewedBy, reviewDescription: $reviewDescription, driverid: $driverid, createdOn: $createdOn, rating: $rating, lastUpdated: $lastUpdated';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ReviewForDriver &&
        o.userId == userId &&
        o.reviewedBy == reviewedBy &&
        o.reviewDescription == reviewDescription &&
        o.driverid == driverid &&
        o.createdOn == createdOn &&
        o.rating == rating &&
        o.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        reviewedBy.hashCode ^
        reviewDescription.hashCode ^
        driverid.hashCode ^
        createdOn.hashCode ^
        rating.hashCode ^
        lastUpdated.hashCode;
  }
}

class Review {
  String userId;
  String reviewedBy;
  String reviewDescription;
  String itemId;
  DateTime createdOn;
  double rating;
  DateTime lastUpdated;

  Review({
    this.userId,
    this.reviewedBy,
    this.reviewDescription,
    this.itemId,
    this.createdOn,
    this.rating,
    this.lastUpdated,
  });

  Review copyWith({
    String userId,
    String reviewedBy,
    String reviewDescription,
    String itemId,
    DateTime createdOn,
    double rating,
    DateTime lastUpdated,
  }) {
    return Review(
      userId: userId ?? this.userId,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewDescription: reviewDescription ?? this.reviewDescription,
      itemId: itemId ?? this.itemId,
      createdOn: createdOn ?? this.createdOn,
      rating: rating ?? this.rating,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'reviewedBy': reviewedBy,
      'reviewDescription': reviewDescription,
      'itemId': itemId,
      'createdOn': createdOn.millisecondsSinceEpoch,
      'rating': rating,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  static Review fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Review(
      userId: map['userId'],
      reviewedBy: map['reviewedBy'],
      reviewDescription: map['reviewDescription'],
      itemId: map['itemId'],
      createdOn: DateTime.fromMillisecondsSinceEpoch(map['createdOn']),
      rating: map['rating'],
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated']),
    );
  }

  String toJson() => json.encode(toMap());

  static Review fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'Review userId: $userId, reviewedBy: $reviewedBy, reviewDescription: $reviewDescription, itemId: $itemId, createdOn: $createdOn, rating: $rating, lastUpdated: $lastUpdated';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Review &&
        o.userId == userId &&
        o.reviewedBy == reviewedBy &&
        o.reviewDescription == reviewDescription &&
        o.itemId == itemId &&
        o.createdOn == createdOn &&
        o.rating == rating &&
        o.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        reviewedBy.hashCode ^
        reviewDescription.hashCode ^
        itemId.hashCode ^
        createdOn.hashCode ^
        rating.hashCode ^
        lastUpdated.hashCode;
  }
}
