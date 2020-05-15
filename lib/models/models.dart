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

  String get fullName => "$firstName $lastName";

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
      'dateOfBirth': dateOfBirth?.millisecondsSinceEpoch,
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
      dateOfBirth: DateTime.fromMillisecondsSinceEpoch(map['dateOfBirth'] ?? 0),
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
  String licencePlateNumber;
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
    this.licencePlateNumber,
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

  get fullName => '$firstName $lastName';

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
    String licencePlateNumber,
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
      licencePlateNumber: licencePlateNumber ?? this.licencePlateNumber,
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
      'licencePlateNumber': licencePlateNumber,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'dateOfBirth': dateOfBirth?.millisecondsSinceEpoch,
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
      licencePlateNumber: map['licencePlateNumber'],
      phoneNumber: map['phoneNumber'],
      profilePicture: map['profilePicture'],
      dateOfBirth: DateTime.fromMillisecondsSinceEpoch(map['dateOfBirth'] ?? 0),
      gender: Utils.getGenderFromString(map['gender']),
      rank: map['rank'],
      rating: (map['rating'] as num)?.toDouble() ?? 0,
      totalReviews: map['totalReviews'] ?? 0,
      balance: (map['balance'] as num)?.toDouble() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  static Driver fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'Driver driverId: $driverId, firstName: $firstName, lastName: $lastName, homeLocationAddress: $homeLocationAddress, homeLocationLatLng: $homeLocationLatLng, licencePlateNumber: $licencePlateNumber, userCreatedOn: $userCreatedOn, email: $email, phoneNumber: $phoneNumber, profilePicture: $profilePicture, dateOfBirth: $dateOfBirth, gender: $gender, rank: $rank, rating: $rating, totalReviews: $totalReviews, balance: $balance';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Driver &&
        o.driverId == driverId &&
        o.firstName == firstName &&
        o.lastName == lastName &&
        o.licencePlateNumber == licencePlateNumber &&
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
        licencePlateNumber.hashCode ^
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
  Map<String, Map<String, dynamic>> itemsData;
  String driverName;
  String email;
  String phoneNumber;
  String house;
  List<LatLng> pickups = [];
  // List<double> quantities = [];
  List<String> stores = [];
  List<double> pricePerItem = [];
  List<double> totalPricePerItem = []; //Price x Quantity
  LatLng destination;
  String userId;
  String driverId;
  double price;
  DateTime date;
  DateTime deliveryTime;

  OrderFromReceiveIt({
    this.orderId,
    this.status,
    // this.quantities,
    this.itemsData,
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
    this.pricePerItem,
    this.totalPricePerItem,
  });

  OrderFromReceiveIt copyWith({
    String orderId,
    String status,
    List<String> items,
    String email,
    String phoneNumber,
    String house,
    List<LatLng> pickups,
    // List<LatLng> quantities,
    List<String> stores,
    LatLng destination,
    String userId,
    String driverId,
    String driverName,
    double price,
    DateTime orderDate,
    DateTime deliveryTime,
    List<double> pricePerItem,
    List<double> totalPricePerItem,
  }) {
    return OrderFromReceiveIt(
      orderId: orderId ?? this.orderId,
      status: status ?? this.status,
      itemsData: items ?? this.itemsData,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      house: house ?? this.house,
      driverName: driverName,
      pickups: pickups ?? this.pickups,
      pricePerItem: pricePerItem ?? this.pricePerItem,
      totalPricePerItem: totalPricePerItem ?? this.totalPricePerItem,
      // quantities: quantities ?? this.quantities,
      stores: stores ?? this.stores,
      destination: destination ?? this.destination,
      userId: userId ?? this.userId,
      driverId: driverId ?? this.driverId,
      price: (price as num).toDouble() ?? this.price,
      date: orderDate ?? this.date,
      deliveryTime: deliveryTime ?? this.deliveryTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'status': status,
      'driverName': driverName,
      'itemsData': itemsData,
      'email': email,
      'phoneNumber': phoneNumber,
      'house': house,
      'pickups': List<dynamic>.from(
            pickups?.map((x) => Utils.latLngToString(x)) ?? [],
          ) ??
          [],
      'pricePerItem': pricePerItem ?? [],
      'totalPricePerItem': totalPricePerItem ?? [],
      // 'quantities': List<dynamic>.from(quantities.map((x) => x)),
      'stores': List<dynamic>.from(stores?.map((x) => x) ?? []) ?? [],
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
      itemsData: Map<String, Map<String, dynamic>>.from(map['itemsData']),
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      house: map['house'],
      driverName: map['driverName'],
      pickups: List<LatLng>.from(
        map['pickups']?.map(
              (x) => Utils.latLngFromString(x),
            ) ??
            [],
      ),
      pricePerItem: List<double>.from(map['pricePerItem']?.map(
            (x) => (x as num).toDouble(),
          ) ??
          []),
      totalPricePerItem: List<double>.from(map['totalPricePerItem']?.map(
            (x) => (x as num).toDouble(),
          ) ??
          []),
      // quantities: List<double>.from(
      //   map['quantities']?.map((x) => x),
      // ),
      stores: List<String>.from(map['stores']),
      destination: Utils.latLngFromString(map['destination']),
      userId: map['userId'],
      driverId: map['driverId'],
      price: map['price'] as num,
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      deliveryTime: DateTime.fromMillisecondsSinceEpoch(map['deliveryTime']),
    );
  }

  String toJson() => json.encode(toMap());

  static OrderFromReceiveIt fromJson(String source) =>
      fromMap(json.decode(source));

  @override
  String toString() {
    return '''OrderFromReceiveIt 
    orderId: $orderId, status: $status, itemsData: $itemsData, email: $email, 
    phoneNumber: $phoneNumber, house: $house, pickups: $pickups, stores: $stores, 
    destination: $destination, userId: $userId, driverId: $driverId, price: $price, 
    orderDate: $date, deliveryTime: $deliveryTime, pricePerItem: $pricePerItem, 
    totalPricePerItem: $totalPricePerItem''';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is OrderFromReceiveIt &&
        o.orderId == orderId &&
        o.status == status &&
        o.itemsData == itemsData &&
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
        itemsData.hashCode ^
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
  int numberOfSleevesNeeded;
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
    this.numberOfSleevesNeeded,
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
    bool numberOfSleevesNeeded,
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
      numberOfSleevesNeeded:
          numberOfSleevesNeeded ?? this.numberOfSleevesNeeded,
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
      'numberOfSleevesNeeded': numberOfSleevesNeeded,
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
      price: map['price'] as num,
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
      numberOfSleevesNeeded: map['numberOfSleevesNeeded'],
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
    return 'OrderFromSennit orderId: $orderId, date: $date, price: $price, pickUpLatLng: $pickUpLatLng, pickUpAddress: $pickUpAddress, dropOffAddress: $dropOffAddress, dropOffLatLng: $dropOffLatLng, serviceCharges: $serviceCharges, userId: $userId, receiverName: $receiverName, receiverPhone: $receiverPhone, receiverEmail: $receiverEmail, senderEmail: $senderEmail, senderPhone: $senderPhone, driverId: $driverId, driverName: $driverName, boxSize: $boxSize, pickupFromDoor: $pickupFromDoor, dropToDoor: $dropToDoor, numberOfBoxes: $numberOfBoxes, numberOfSleevesNeeded: $numberOfSleevesNeeded, status: $status, senderHouse: $senderHouse, receiverHouse: $receiverHouse';
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
        o.numberOfSleevesNeeded == numberOfSleevesNeeded &&
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
        numberOfSleevesNeeded.hashCode ^
        status.hashCode ^
        senderHouse.hashCode ^
        receiverHouse.hashCode;
  }
}

// class OrderItemForSennit {
//   String orderItemId;
//   double price;
//   String itemId;
//   String orderId;
//   bool sleevesRequired;
//   BoxSize boxSize;
//   int numberOfBoxes;
//   OrderItemForSennit({
//     this.orderItemId,
//     this.price,
//     this.itemId,
//     this.orderId,
//     this.sleevesRequired,
//     this.boxSize,
//     this.numberOfBoxes,
//   });

//   OrderItemForSennit copyWith({
//     String orderItemId,
//     double price,
//     String itemId,
//     String orderId,
//     bool sleevesRequired,
//     BoxSize boxSize,
//     int numberOfBoxes,
//   }) {
//     return OrderItemForSennit(
//       orderItemId: orderItemId ?? this.orderItemId,
//       price: price ?? this.price,
//       itemId: itemId ?? this.itemId,
//       orderId: orderId ?? this.orderId,
//       sleevesRequired: sleevesRequired ?? this.sleevesRequired,
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
//       'sleevesRequired': sleevesRequired,
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
//       sleevesRequired: map['sleevesRequired'],
//       boxSize: Utils.getBoxSizeFromString(map['boxSize']),
//       numberOfBoxes: map['numberOfBoxes'],
//     );
//   }

//   String toJson() => json.encode(toMap());

//   static OrderItemForSennit fromJson(String source) =>
//       fromMap(json.decode(source));

//   @override
//   String toString() {
//     return 'OrderItemForSennit orderItemId: $orderItemId, price: $price, itemId: $itemId, orderId: $orderId, sleevesRequired: $sleevesRequired, boxSize: $boxSize, numberOfBoxes: $numberOfBoxes';
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
//         sleevesRequired.hashCode ^
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
  String itemPropertyId;
  OrderItemForReceiveIt({
    this.orderItemId,
    this.orderId,
    this.itemId,
    this.quantity,
    this.price,
    this.itemPropertyId,
  });

  OrderItemForReceiveIt copyWith({
    String orderItemId,
    String orderId,
    String itemId,
    int quantity,
    double price,
    String itemPropertyId,
  }) {
    return OrderItemForReceiveIt(
      orderItemId: orderItemId ?? this.orderItemId,
      orderId: orderId ?? this.orderId,
      itemId: itemId ?? this.itemId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      itemPropertyId: itemPropertyId ?? this.itemPropertyId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderItemId': orderItemId,
      'orderId': orderId,
      'itemId': itemId,
      'quantity': quantity,
      'price': price,
      'itemPropertyId': itemPropertyId,
    };
  }

  static OrderItemForReceiveIt fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return OrderItemForReceiveIt(
      orderItemId: map['orderItemId'],
      orderId: map['orderId'],
      itemId: map['itemId'],
      quantity: map['quantity'],
      price: map['price'] as num,
      itemPropertyId: map['itemPropertyId'],
    );
  }

  String toJson() => json.encode(toMap());

  static OrderItemForReceiveIt fromJson(String source) =>
      fromMap(json.decode(source));

  @override
  String toString() {
    return 'OrderItemForReceiveIt orderItemId: $orderItemId, orderId: $orderId, itemId: $itemId, quantity: $quantity, price: $price, itemPropertyId: $itemPropertyId';
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
        itemPropertyId.hashCode;
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
  Map<String, Map<String, dynamic>> itemsData;
  UserCart({
    this.itemsData,
  });

  UserCart copyWith({
    List<Map<String, Map<String, dynamic>>> itemsData,
  }) {
    return UserCart(
      itemsData: itemsData ?? this.itemsData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemsData': itemsData,
    };
  }

  static UserCart fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return UserCart(
      itemsData: Map<String, Map<String, dynamic>>.from(
        map['itemsData'],
      ),
    );
  }

  String toJson() => json.encode(toMap());

  static UserCart fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() => 'UserCart itemsData: $itemsData';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is UserCart && o.itemsData == itemsData;
  }

  @override
  int get hashCode => itemsData.hashCode;
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
  Map<String, String> specifications;
  String itemName;
  LatLng latlng;
  String storeId;
  Store store;

  //temp
  String flavour = '';
  double quantity = 1;

  StoreItem({
    this.itemId,
    this.storeName,
    this.images,
    this.price,
    this.storeAddress,
    this.description,
    this.itemName,
    this.latlng,
    this.specifications,
    this.storeId,
  }) {
    if (specifications == null) {
      specifications = {};
    }
  }

  StoreItem copyWith({
    String itemId,
    List<String> images,
    double price,
    String storeName,
    String storeAddress,
    String description,
    String itemName,
    LatLng latlng,
    String storeId,
    Map<String, String> specifications,
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
      specifications: specifications ?? this.specifications,
      storeId: storeId ?? this.storeId,
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
      'specifications': specifications ?? {},
      'storeId': storeId,
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
      specifications: Map<String, String>.from(map['specifications'] ?? {}),
      storeId: map['storeId'],
    );
  }

  String toJson() => json.encode(toMap());

  static StoreItem fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'StoreItem itemId: $itemId, images: $images, price: $price, storeName: $storeName, description: $description, itemName: $itemName, location: $latlng, storeId: $storeId';
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
        o.latlng == latlng &&
        o.storeId == storeId;
  }

  @override
  int get hashCode {
    return itemId.hashCode ^
        images.hashCode ^
        price.hashCode ^
        storeName.hashCode ^
        description.hashCode ^
        itemName.hashCode ^
        latlng.hashCode ^
        storeId.hashCode;
  }
}

class Store {
  String storeId;
  String storeName;
  List<String> items;
  List<StoreItem> storeItems = [];
  String storeImage;
  String storeMotto;
  LatLng storeLatLng;
  String storeAddress;
  List<String> deviceTokens;

  Store({
    this.storeId,
    this.storeName,
    this.items,
    this.storeImage,
    this.storeMotto,
    this.storeLatLng,
    this.storeAddress,
    this.deviceTokens,
  });

  Store copyWith({
    String storeId,
    String storeName,
    List<String> items,
    String storeImage,
    String storeMotto,
    LatLng storeLatLng,
    String storeAddress,
  }) {
    return Store(
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      items: items ?? this.items,
      storeImage: storeImage ?? this.storeImage,
      storeMotto: storeMotto ?? this.storeMotto,
      storeAddress: storeAddress ?? this.storeAddress,
      storeLatLng: storeLatLng ?? this.storeLatLng,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'storeName': storeName,
      'items': List<dynamic>.from(items.map((x) => x)),
      'storeImage': storeImage,
      'storeMotto': storeMotto,
      'storeAddress': storeAddress,
      'storeLatLng': Utils.latLngToString(storeLatLng),
      'deviceTokens': deviceTokens,
    };
  }

  static Store fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Store(
      storeId: map['storeId'],
      storeName: map['storeName'],
      items: List<String>.from(map['items'] ?? []),
      storeImage: map['storeImage'],
      storeMotto: map['storeMotto'],
      storeAddress: map['storeAddress'],
      storeLatLng: Utils.latLngFromString(map['storeLatLng']),
      deviceTokens: List<String>.from(map['deviceTokens'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  static Store fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'Store storeId: $storeId, storeName: $storeName, items: $items, storeImage: $storeImage, storeMotto: $storeMotto, storeAddress: $storeAddress, storeLatLng: $storeLatLng, deviceTokens: $deviceTokens';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Store &&
        o.storeId == storeId &&
        o.storeName == storeName &&
        o.items == items &&
        o.storeImage == storeImage &&
        o.storeMotto == storeMotto &&
        o.deviceTokens == deviceTokens;
  }

  @override
  int get hashCode {
    return storeId.hashCode ^
        storeName.hashCode ^
        items.hashCode ^
        storeImage.hashCode ^
        storeMotto.hashCode ^
        deviceTokens.hashCode;
  }
}

class ReviewForDriver {
  String userId;
  String reviewedBy;
  String reviewDescription;
  String driverId;
  DateTime createdOn;
  double rating;
  DateTime lastUpdated;
  String orderId;
  ReviewForDriver({
    this.userId,
    this.reviewedBy,
    this.reviewDescription,
    this.driverId,
    this.createdOn,
    this.rating,
    this.lastUpdated,
    this.orderId,
  });

  ReviewForDriver copyWith({
    String userId,
    String reviewedBy,
    String reviewDescription,
    String driverId,
    String orderId,
    DateTime createdOn,
    double rating,
    DateTime lastUpdated,
  }) {
    return ReviewForDriver(
      userId: userId ?? this.userId,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewDescription: reviewDescription ?? this.reviewDescription,
      driverId: driverId ?? this.driverId,
      createdOn: createdOn ?? this.createdOn,
      rating: rating ?? this.rating,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      orderId: orderId ?? this.orderId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'reviewedBy': reviewedBy,
      'reviewDescription': reviewDescription,
      'driverId': driverId,
      'createdOn': createdOn.millisecondsSinceEpoch,
      'rating': rating,
      'orderId': orderId,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  static ReviewForDriver fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return ReviewForDriver(
      userId: map['userId'],
      reviewedBy: map['reviewedBy'],
      reviewDescription: map['reviewDescription'],
      driverId: map['driverId'],
      createdOn: DateTime.fromMillisecondsSinceEpoch(map['createdOn']),
      rating: map['rating'],
      orderId: map['orderId'],
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated']),
    );
  }

  String toJson() => json.encode(toMap());

  static ReviewForDriver fromJson(String source) =>
      fromMap(json.decode(source));

  @override
  String toString() {
    return 'ReviewForDriver userId: $userId, orderId: $orderId, reviewedBy: $reviewedBy, reviewDescription: $reviewDescription, driverId: $driverId, createdOn: $createdOn, rating: $rating, lastUpdated: $lastUpdated';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ReviewForDriver &&
        o.userId == userId &&
        o.reviewedBy == reviewedBy &&
        o.reviewDescription == reviewDescription &&
        o.driverId == driverId &&
        o.createdOn == createdOn &&
        o.rating == rating &&
        o.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        reviewedBy.hashCode ^
        reviewDescription.hashCode ^
        driverId.hashCode ^
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
