import 'dart:convert';

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
  double rating;
  int totalReviews;
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
    this.profilePicture,
    this.dateOfBirth,
    this.gender,
    this.rank,
    this.rating,
    this.totalReviews,
    this.balance,
  });

  get fullname => '$firstName $lastName';

  Driver copyWith({
    String driverId,
    String firstName,
    String lastName,
    String homeLocationAddress,
    LatLng homeLocationLatLng,
    DateTime userCreatedOn,
    String email,
    String phoneNumber,
    String profilePicture,
    DateTime dateOfBirth,
    Gender gender,
    String rank,
    double rating,
    int totalReviews,
    double balance,
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
      profilePicture: profilePicture ?? this.profilePicture,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      rank: rank ?? this.rank,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
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
      'profilePicture': profilePicture,
      'dateOfBirth': dateOfBirth.millisecondsSinceEpoch,
      'gender': Utils.genderToString(gender),
      'rank': rank,
      'rating': rating,
      'totalReviews': totalReviews,
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
      userCreatedOn: DateTime(map['userCreatedOn']),
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      profilePicture: map['profilePicture'],
      dateOfBirth: DateTime.fromMillisecondsSinceEpoch(map['dateOfBirth']),
      gender: Utils.getGenderFromString(map['gender']),
      rank: map['rank'],
      rating: map['rating'] ?? 0,
      totalReviews: map['totalReviews'] ?? 0,
      balance: map['balance'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  static Driver fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'Driver driverId: $driverId, firstName: $firstName, lastName: $lastName, homeLocationAddress: $homeLocationAddress, homeLocationLatLng: $homeLocationLatLng, userCreatedOn: $userCreatedOn, email: $email, phoneNumber: $phoneNumber, profilePicture: $profilePicture, dateOfBirth: $dateOfBirth, gender: $gender, rank: $rank, rating: $rating, totalReviews: $totalReviews, balance: $balance';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Driver &&
        o.driverId == driverId &&
        o.firstName == firstName &&
        o.lastName == lastName &&
        o.homeLocationAddress == homeLocationAddress &&
        o.homeLocationLatLng == homeLocationLatLng &&
        o.userCreatedOn == userCreatedOn &&
        o.email == email &&
        o.phoneNumber == phoneNumber &&
        o.profilePicture == profilePicture &&
        o.dateOfBirth == dateOfBirth &&
        o.gender == gender &&
        o.rank == rank &&
        o.rating == rating &&
        o.totalReviews == totalReviews &&
        o.balance == balance;
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
        profilePicture.hashCode ^
        dateOfBirth.hashCode ^
        gender.hashCode ^
        rank.hashCode ^
        rating.hashCode ^
        totalReviews.hashCode ^
        balance.hashCode;
  }
}

class OrderFromReceiveIt {
  String orderId;
  String status;
  List<String> items;
  String driverName;
  String email;
  String phoneNumber;
  String house;
  List<LatLng> pickups = [];
  List<double> quantities = [];
  List<String> stores = [];
  LatLng destination;
  String userId;
  String driverId;
  double price;
  DateTime date;
  DateTime deliveryTime;
  OrderFromReceiveIt({
    this.orderId,
    this.status,
    this.quantities,
    this.items,
    this.email,
    this.phoneNumber,
    this.house,
    this.driverName,
    this.pickups,
    this.stores,
    this.destination,
    this.userId,
    this.driverId,
    this.price,
    this.date,
    this.deliveryTime,
  });

  OrderFromReceiveIt copyWith({
    String orderId,
    String status,
    List<String> items,
    String email,
    String phoneNumber,
    String house,
    List<LatLng> pickups,
    List<LatLng> quantities,
    List<String> stores,
    LatLng destination,
    String userId,
    String driverId,
    String driverName,
    double price,
    DateTime orderDate,
    DateTime deliveryTime,
  }) {
    return OrderFromReceiveIt(
      orderId: orderId ?? this.orderId,
      status: status ?? this.status,
      items: items ?? this.items,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      house: house ?? this.house,
      driverName: driverName,
      pickups: pickups ?? this.pickups,
      quantities: quantities ?? this.quantities,
      stores: stores ?? this.stores,
      destination: destination ?? this.destination,
      userId: userId ?? this.userId,
      driverId: driverId ?? this.driverId,
      price: price ?? this.price,
      date: orderDate ?? this.date,
      deliveryTime: deliveryTime ?? this.deliveryTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'status': status,
      'driverName': driverName,
      'items': List<dynamic>.from(items.map((x) => x)),
      'email': email,
      'phoneNumber': phoneNumber,
      'house': house,
      'pickups': List<dynamic>.from(
        pickups.map((x) => Utils.latLngToString(x)),
      ),
      'quantities': List<dynamic>.from(quantities.map((x) => x)),
      'stores': List<dynamic>.from(stores.map((x) => x)),
      'destination': Utils.latLngToString(destination),
      'userId': userId,
      'driverId': driverId,
      'price': price,
      'date': date.millisecondsSinceEpoch,
      'deliveryTime': deliveryTime?.millisecondsSinceEpoch,
    };
  }

  static OrderFromReceiveIt fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return OrderFromReceiveIt(
      orderId: map['orderId'],
      status: map['status'],
      items: List<String>.from(map['items']),
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      house: map['house'],
      driverName: map['driverName'],
      pickups: List<LatLng>.from(
        map['pickups']?.map(
          (x) => Utils.latLngFromString(x),
        ),
      ),
      quantities: List<double>.from(
        map['quantities']?.map((x) => x),
      ),
      stores: List<String>.from(map['stores']),
      destination: Utils.latLngFromString(map['destination']),
      userId: map['userId'],
      driverId: map['driverId'],
      price: map['price'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      deliveryTime: DateTime.fromMillisecondsSinceEpoch(map['deliveryTime']),
    );
  }

  String toJson() => json.encode(toMap());

  static OrderFromReceiveIt fromJson(String source) =>
      fromMap(json.decode(source));

  @override
  String toString() {
    return 'OrderFromReceiveIt orderId: $orderId, status: $status, items: $items, email: $email, phoneNumber: $phoneNumber, house: $house, pickups: $pickups, stores: $stores, destination: $destination, userId: $userId, driverId: $driverId, price: $price, orderDate: $date, deliveryTime: $deliveryTime';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is OrderFromReceiveIt &&
        o.orderId == orderId &&
        o.status == status &&
        o.items == items &&
        o.email == email &&
        o.phoneNumber == phoneNumber &&
        o.house == house &&
        o.pickups == pickups &&
        o.stores == stores &&
        o.destination == destination &&
        o.userId == userId &&
        o.driverId == driverId &&
        o.price == price &&
        o.date == date &&
        o.deliveryTime == deliveryTime;
  }

  @override
  int get hashCode {
    return orderId.hashCode ^
        status.hashCode ^
        items.hashCode ^
        email.hashCode ^
        phoneNumber.hashCode ^
        house.hashCode ^
        pickups.hashCode ^
        stores.hashCode ^
        destination.hashCode ^
        userId.hashCode ^
        driverId.hashCode ^
        price.hashCode ^
        date.hashCode ^
        deliveryTime.hashCode;
  }
}

class OrderFromSennit {
  String orderId;
  DateTime date;
  double price;
  LatLng pickUpLatLng;
  String pickUpAddress;
  String dropOffAddress;
  LatLng dropOffLatLng;
  double serviceCharges;
  String userId;
  String receiverName;
  String receiverPhone;
  String receiverEmail;
  String senderEmail;
  String senderPhone;
  String driverId;
  String driverName;
  BoxSize boxSize;
  bool pickupFromDoor;
  bool dropToDoor;
  int numberOfBoxes;
  bool sleevesRequired;
  String status;
  String senderHouse;
  String receiverHouse;
  OrderFromSennit({
    this.orderId,
    this.date,
    this.price,
    this.pickUpLatLng,
    this.pickUpAddress,
    this.dropOffAddress,
    this.dropOffLatLng,
    this.serviceCharges,
    this.userId,
    this.receiverName,
    this.receiverPhone,
    this.receiverEmail,
    this.senderEmail,
    this.senderPhone,
    this.driverId,
    this.driverName,
    this.boxSize,
    this.pickupFromDoor,
    this.dropToDoor,
    this.numberOfBoxes,
    this.sleevesRequired,
    this.status,
    this.senderHouse,
    this.receiverHouse,
  });

  OrderFromSennit copyWith({
    String orderId,
    DateTime date,
    double price,
    LatLng pickUpLatLng,
    String pickUpAddress,
    String dropOffAddress,
    LatLng dropOffLatLng,
    double serviceCharges,
    String userId,
    String receiverName,
    String receiverPhone,
    String receiverEmail,
    String senderEmail,
    String senderPhone,
    String driverId,
    String driverName,
    BoxSize boxSize,
    bool pickupFromDoor,
    bool dropToDoor,
    int numberOfBoxes,
    bool sleevesRequired,
    String status,
    String senderHouse,
    String receiverHouse,
  }) {
    return OrderFromSennit(
      orderId: orderId ?? this.orderId,
      date: date ?? this.date,
      price: price ?? this.price,
      pickUpLatLng: pickUpLatLng ?? this.pickUpLatLng,
      pickUpAddress: pickUpAddress ?? this.pickUpAddress,
      dropOffAddress: dropOffAddress ?? this.dropOffAddress,
      dropOffLatLng: dropOffLatLng ?? this.dropOffLatLng,
      serviceCharges: serviceCharges ?? this.serviceCharges,
      userId: userId ?? this.userId,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      receiverEmail: receiverEmail ?? this.receiverEmail,
      senderEmail: senderEmail ?? this.senderEmail,
      senderPhone: senderPhone ?? this.senderPhone,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      boxSize: boxSize ?? this.boxSize,
      pickupFromDoor: pickupFromDoor ?? this.pickupFromDoor,
      dropToDoor: dropToDoor ?? this.dropToDoor,
      numberOfBoxes: numberOfBoxes ?? this.numberOfBoxes,
      sleevesRequired: sleevesRequired ?? this.sleevesRequired,
      status: status ?? this.status,
      senderHouse: senderHouse ?? this.senderHouse,
      receiverHouse: receiverHouse ?? this.receiverHouse,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'date': date.millisecondsSinceEpoch,
      'price': price,
      'pickUpLatLng': Utils.latLngToString(pickUpLatLng),
      'pickUpAddress': pickUpAddress,
      'dropOffAddress': dropOffAddress,
      'dropOffLatLng': Utils.latLngToString(dropOffLatLng),
      'serviceCharges': serviceCharges,
      'userId': userId,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'receiverEmail': receiverEmail,
      'senderEmail': senderEmail,
      'senderPhone': senderPhone,
      'driverId': driverId,
      'driverName': driverName,
      'boxSize': Utils.boxSizeToString(boxSize),
      'pickupFromDoor': pickupFromDoor,
      'dropToDoor': dropToDoor,
      'numberOfBoxes': numberOfBoxes,
      'sleevesRequired': sleevesRequired,
      'status': status,
      'senderHouse': senderHouse,
      'receiverHouse': receiverHouse,
    };
  }

  static OrderFromSennit fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return OrderFromSennit(
      orderId: map['orderId'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      price: map['price'],
      pickUpLatLng: Utils.latLngFromString(map['pickUpLatLng']),
      pickUpAddress: map['pickUpAddress'],
      dropOffAddress: map['dropOffAddress'],
      dropOffLatLng: Utils.latLngFromString(map['dropOffLatLng']),
      serviceCharges: map['serviceCharges'],
      userId: map['userId'],
      receiverName: map['receiverName'],
      receiverPhone: map['receiverPhone'],
      receiverEmail: map['receiverEmail'],
      senderEmail: map['senderEmail'],
      senderPhone: map['senderPhone'],
      driverId: map['driverId'],
      driverName: map['driverName'],
      boxSize: Utils.getBoxSizeFromString(map['boxSize']),
      pickupFromDoor: map['pickupFromDoor'],
      dropToDoor: map['dropToDoor'],
      numberOfBoxes: map['numberOfBoxes'],
      sleevesRequired: map['sleevesRequired'],
      status: map['status'],
      senderHouse: map['senderHouse'],
      receiverHouse: map['receiverHouse'],
    );
  }

  String toJson() => json.encode(toMap());

  static OrderFromSennit fromJson(String source) =>
      fromMap(json.decode(source));

  @override
  String toString() {
    return 'OrderFromSennit orderId: $orderId, date: $date, price: $price, pickUpLatLng: $pickUpLatLng, pickUpAddress: $pickUpAddress, dropOffAddress: $dropOffAddress, dropOffLatLng: $dropOffLatLng, serviceCharges: $serviceCharges, userId: $userId, receiverName: $receiverName, receiverPhone: $receiverPhone, receiverEmail: $receiverEmail, senderEmail: $senderEmail, senderPhone: $senderPhone, driverId: $driverId, driverName: $driverName, boxSize: $boxSize, pickupFromDoor: $pickupFromDoor, dropToDoor: $dropToDoor, numberOfBoxes: $numberOfBoxes, sleevesRequired: $sleevesRequired, status: $status, senderHouse: $senderHouse, receiverHouse: $receiverHouse';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is OrderFromSennit &&
        o.orderId == orderId &&
        o.date == date &&
        o.price == price &&
        o.pickUpLatLng == pickUpLatLng &&
        o.pickUpAddress == pickUpAddress &&
        o.dropOffAddress == dropOffAddress &&
        o.dropOffLatLng == dropOffLatLng &&
        o.serviceCharges == serviceCharges &&
        o.userId == userId &&
        o.receiverName == receiverName &&
        o.receiverPhone == receiverPhone &&
        o.receiverEmail == receiverEmail &&
        o.senderEmail == senderEmail &&
        o.senderPhone == senderPhone &&
        o.driverId == driverId &&
        o.driverName == driverName &&
        o.boxSize == boxSize &&
        o.pickupFromDoor == pickupFromDoor &&
        o.dropToDoor == dropToDoor &&
        o.numberOfBoxes == numberOfBoxes &&
        o.sleevesRequired == sleevesRequired &&
        o.status == status &&
        o.senderHouse == senderHouse &&
        o.receiverHouse == receiverHouse;
  }

  @override
  int get hashCode {
    return orderId.hashCode ^
        date.hashCode ^
        price.hashCode ^
        pickUpLatLng.hashCode ^
        pickUpAddress.hashCode ^
        dropOffAddress.hashCode ^
        dropOffLatLng.hashCode ^
        serviceCharges.hashCode ^
        userId.hashCode ^
        receiverName.hashCode ^
        receiverPhone.hashCode ^
        receiverEmail.hashCode ^
        senderEmail.hashCode ^
        senderPhone.hashCode ^
        driverId.hashCode ^
        driverName.hashCode ^
        boxSize.hashCode ^
        pickupFromDoor.hashCode ^
        dropToDoor.hashCode ^
        numberOfBoxes.hashCode ^
        sleevesRequired.hashCode ^
        status.hashCode ^
        senderHouse.hashCode ^
        receiverHouse.hashCode;
  }
}

// class OrderItemForSennita {
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
  List<StoreItem> items = List();
  List<String> itemIds;
  List<double> quantities;
  UserCart({
    this.itemIds,
    this.quantities,
  }) {
    if (itemIds == null) {
      itemIds = [];
    }
    if (quantities == null) {
      quantities = [];
    }
  }

  UserCart copyWith({
    List<String> itemIds,
    List<double> quantities,
  }) {
    return UserCart(
      itemIds: itemIds ?? this.itemIds,
      quantities: quantities ?? this.quantities,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemIds': List<dynamic>.from(itemIds.map((x) => x)),
      'quantities': List<dynamic>.from(quantities.map((x) => x)),
    };
  }

  static UserCart fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return UserCart(
      itemIds: List<String>.from(map['itemIds']),
      quantities: List<double>.from(map['quantities']),
    );
  }

  String toJson() => json.encode(toMap());

  static UserCart fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() => 'UserCart itemIds: $itemIds, quantities: $quantities';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is UserCart && o.itemIds == itemIds && o.quantities == quantities;
  }

  @override
  int get hashCode => itemIds.hashCode ^ quantities.hashCode;
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
  static const String ORDER_COMPLETE = "complete";
  static const String ORDER_PENDING = "pending";
  static const String ORDER_POSTED = "posted";

  String notificationId;
  String title;
  String orderId;
  String description;
  String type;
  UserNotification({
    this.notificationId,
    this.title,
    this.orderId,
    this.description,
    this.type,
  });

  UserNotification copyWith({
    String notificationId,
    String title,
    String orderId,
    String description,
    String type,
  }) {
    return UserNotification(
      notificationId: notificationId ?? this.notificationId,
      title: title ?? this.title,
      orderId: orderId ?? this.orderId,
      description: description ?? this.description,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'title': title,
      'orderId': orderId,
      'description': description,
      'type': type,
    };
  }

  static UserNotification fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return UserNotification(
      notificationId: map['notificationId'],
      title: map['title'],
      orderId: map['orderId'],
      description: map['description'],
      type: map['type'],
    );
  }

  String toJson() => json.encode(toMap());

  static UserNotification fromJson(String source) =>
      fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserNotification notificationId: $notificationId, title: $title, orderId: $orderId, description: $description, type: $type';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is UserNotification &&
        o.notificationId == notificationId &&
        o.title == title &&
        o.orderId == orderId &&
        o.description == description &&
        o.type == type;
  }

  @override
  int get hashCode {
    return notificationId.hashCode ^
        title.hashCode ^
        orderId.hashCode ^
        description.hashCode ^
        type.hashCode;
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
  String storeName;
  String storeAddress;
  double price;
  String description;
  String itemName;
  LatLng latlng;
  StoreItem({
    this.itemId,
    this.storeName,
    this.images,
    this.price,
    this.storeAddress,
    this.description,
    this.itemName,
    this.latlng,
  });

  StoreItem copyWith({
    String itemId,
    List<String> images,
    double price,
    String storeName,
    String storeAddress,
    String description,
    String itemName,
    LatLng latlng,
  }) {
    return StoreItem(
      itemId: itemId ?? this.itemId,
      images: images ?? this.images,
      price: price ?? this.price,
      storeName: storeName ?? this.storeName,
      storeAddress: storeAddress ?? this.storeAddress,
      description: description ?? this.description,
      itemName: itemName ?? this.itemName,
      latlng: latlng ?? this.latlng,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'images': List<dynamic>.from(images.map((x) => x)),
      'price': price,
      'storeName': storeName,
      'storeAddress': storeAddress,
      'description': description,
      'itemName': itemName,
      'latlng': Utils.latLngToString(latlng),
    };
  }

  static StoreItem fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return StoreItem(
      itemId: map['itemId'],
      images: List<String>.from(map['images']),
      price: map['price'].runtimeType == int
          ? (map['price'] as int).toDouble()
          : map['price'].runtimeType == String
              ? double.parse(map['price'])
              : map['price'],
      storeName: map['storeName'],
      storeAddress: map['storeAddress'],
      description: map['description'],
      itemName: map['itemName'],
      latlng: Utils.latLngFromString(map['latlng']),
    );
  }

  String toJson() => json.encode(toMap());

  static StoreItem fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'StoreItem itemId: $itemId, images: $images, price: $price, storeName: $storeName, description: $description, itemName: $itemName, location: $latlng';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is StoreItem &&
        o.itemId == itemId &&
        o.images == images &&
        o.price == price &&
        o.storeName == storeName &&
        o.description == description &&
        o.itemName == itemName &&
        o.latlng == latlng;
  }

  @override
  int get hashCode {
    return itemId.hashCode ^
        images.hashCode ^
        price.hashCode ^
        storeName.hashCode ^
        description.hashCode ^
        itemName.hashCode ^
        latlng.hashCode;
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
