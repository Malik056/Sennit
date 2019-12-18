import 'dart:async';

import 'package:sqflite/sqflite.dart';

class Tables {
  static const String USER_TABLE = "USER_TABLE";
  static const String DRIVER_TABLE = "DRIVER_TABLE";
  static const String ORDER_FROM_RECIEVE_IT_TABLE = "ORDER_FROM_RECIEVE_IT";
  static const String ORDER_FROM_SENNIT_TABLE = "ORDER_FROM_SENNIT_TABLE";
  // static const String USER_ORDER_TABLE = "USER_ORDER_TABLE";
  static const String USER_LOCATION_HISTORY_TABLE =
      "USER_LOCATION_HISTORY_TABLE";
  // static const String USER_DROP_OFF_LOCATION_HISTORY_FOR_SENNIT_TABLE =
  //     "USER_DROP_OFF_LOCATION_HISTORY_FOR_SENNIT_TABLE";
  // static const String USER_PICK_UP_LOCATION_HISTORY_FOR_RECEIVE_IT_TABLE =
  //     "USER_PICK_UP_LOCATION_HISTORY_FOR_RECEIVE_IT_TABLE";
  // static const String USER_DROP_OFF_LOCATION_HISTORY_FOR_RECEIVE_IT_TABLE =
  //     "USER_DROP_OFF_LOCATION_HISTORY_FOR_RECEIVE_IT_TABLE";
  static const String SIGNED_IN_USER_TABLE = "SIGNED_IN_USER_TABLE";
  static const String USER_NOTIFICATION_TABLE = "USER_NOTIFICATION_TABLE";
  static const String DRIVER_NOTIFICATION_TABLE = "DRIVER_NOTIFICATION_TABLE";
  static const String USER_CART_TABLE = "USER_CART_TABLE";
  static const String ITEM_TABLE = "ITEM_TABLE";
  static const String ITEM_IMAGE_TABLE = "ITEM_IMAGE_TABLE";
  static const String ITEM_PROPERTY_TABLE = "ITEM_PROPERTY_TABLE";
  static const String ORDER_ITEM_FOR_SENNIT_TABLE =
      "ORDER_ITEM_FOR_SENNIT_TABLE";
  static const String ORDER_ITEM_FOR_RECEIVE_IT_TABLE =
      "ORDER_ITEM_FOR_RECIEVE_IT_TABLE";
  static const String ORDER_OTHER_CHARGES_TABLE = "ORDER_OTHER_CHARGES_TABLE";
}

class UserTableColumns {
  static const String USER_ID = "userId";
  static const String FIRST_NAME = "firstName";
  static const String LAST_NAME = "lastName";
  static const String HOME_LOCATION_ADDRESS = "homeLocationAddress";
  static const String HOME_LOCATION_LATLNG = "homeLocationLatLng";
  static const String OFFICE_LOCATION_ADDRESS = "officeLocationAddress";
  static const String OFFICE_LOCATION_LATLNG = "officeLocationLatLng";
  static const String USER_CREATED_ON = "userCreatedOn";
  static const String EMAIL = "email";
  static const String PHONE_NUMBER = "phone";
  static const String DATE_OF_BIRTH = "dateOfBirth";
  static const String GENDER = "gender";
  static const String RANK = "rank";
}

class DriverTableColumns {
  static const String DRIVER_ID = "driverId";
  static const String FIRST_NAME = "firstName";
  static const String LAST_NAME = "lastName";
  static const String HOME_LOCATION_ADDRESS = "homeLocationAddress";
  static const String HOME_LOCATION_LATLNG = "homeLocationLatLng";
  static const String USER_CREATED_ON = "userCreatedOn";
  static const String EMAIL = "email";
  static const String PHONE_NUMBER = "phone";
  static const String DATE_OF_BIRTH = "DateOfBirth";
  static const String GENDER = "gender";
  static const String RANK = "rank";
  static const String BALANCE = "balance";
}

class OrderFromRecieveItTableColumns {
  static const String STORE_NAME = "storeName";
  static const String STORE_ADDRESS = "storeLocationAddress";
  static const String STORE_LATLNG = "storeLatLng";
  static const String DROP_OFF_ADDRESS = "dropOffAddress";
  static const String DROP_OFF_LATLNG = "dropOffLatLng";
  static const String ORDER_ID = "orderId";
  static const String DATE_ORDERED = "dateOrdered";
  static const String ORDER_PRICE = "orderPrice";
  static const String USER_ID = "userId";
  static const String DRIVER_ID = "driverId";
}

class OrderFromSennitTableColumns {
  static const String ORDER_ID = "orderId";
  static const String DATE_ORDERED = "dateOrdered";
  static const String ORDER_PRICE = "orderPrice";
  static const String PICK_UP_LATLNG = "pickUpLatLng";
  static const String PICK_UP_ADDRESS = "pickUpAddress";
  static const String DROP_OFF_LATLNG = "dropOffLatLng";
  static const String DROP_OFF_ADDRESS = "dropOffAddress";
  static const String SERVICE_CHARGES = "serviceCharges";
  static const String USER_ID = "userId";
  static const String RECEIVER_NAME = "recieverName";
  static const String RECEIVER_PHONE = "receiverPhone";
  static const String RECEIVER_EMAIL = "receiverEmail";
  static const String DRIVER_ID = "driverId";
}

class OrderItemForSennitTableColumns {
  static const String ORDER_ITEM_ID = "orderItemId";
  static const String PRICE = "pirce";
  static const String ITEM_ID = "itemId";
  // static const String QUANTITY = "QUANTITY";
  static const String ORDER_ID = "orderId";
  // static const String ITEM_PROPERTY_ID = "ITEM_PROPERTY_ID";
  static const String SLEEVES_REQUIRED = "sleevesRequired";
  static const String BOX_SIZE = "boxSize";
  static const String NUMBER_OF_BOXES = "numberOfBoxes";
}

class OrderItemForReceiveItTableColumns {
  static const String ORDER_ITEM_ID = "orderItemId";
  static const String ORDER_ID = "orderId";
  static const String ITEM_ID = "itemId";
  static const String QUANTITY = "quantity";
  static const String PRICE = "price";
  static const String ITEM_PROPERTY_ID = "itemPropertyId";
}

class OrderOtherChargesTableColumns {
  static const String CHARGES_ID = "chargesId";
  static const String CHARGES_NAME = "chargesName";
  static const String CHARGES_PRICE = "chargesPrice";
  static const String ORDER_ID = "orderId";
}

class ItemTableColumns {
  static const String ITEM_ID = "itemId";
  static const String NAME = "name";
  static const String BASE_CATEGORY = "baseCategory";
  static const String SUB_CATEGORY = "subCategory";
  static const String PRICE = "price";
}

class ItemImageTableColumns {
  static const String IMAGE_ID = 'imageId';
  static const String ITEM_ID = "itemId";
  static const String URL = "url";
}

class SignedInUserTableColumns {
  static const String USER_ID = "userId";
}

class UserCartTableColumns {
  static const String USER_ID = "userId";
  static const String TOTAL_PRICE = "totalPrice";
  static const String CART_ID = "cartId";
}

class UserLocationHistoryTableColumns {
  static const String ADDRESS = "address";
  static const String LATLNG = "latLng";
  static const String USER_ID = "userId";
  static const String LAST_USED = "lastUsed";
}

class UserNotificationTableColumns {
  static const String NOTIFICATION_ID = "notificationId";
  static const String TITLE = "title";
  static const String ORDER_ID = "orderId";
  static const String DESCRIPTION = "description";
  static const String IS_NOTIFICATION_FOR_ORDER_COMPLETE =
      "isNotificationForOrderComplete";
}

class DriverNotificationTableColumns {
  static const String NOTIFICATION_ID = "notificationId";
  static const String PICK_UP_ADDRESS = "pickUpAddress";
  static const String DROP_OFF_ADDRESS = "dropOffAddress";
  static const String PICK_UP_LATLNG = "pickUpLatLng";
  static const String DROP_OFF_LATLNG = "dropOffLatLng";
  static const String ORDER_ID = "orderId";
}

class ItemPropertyTableColumn {
  static const String ITEM_PROPERTY_ID = "itemPropertyId";
  static const String PROPERTY_NAME = "propertyName";
  static const String PROPERTY_VALUE = "value";
  static const String ITEM_PRICE = "price";
  static const String ITEM_ID = "itemId";
}

class DatabaseHelper {
  static Database _myDatabase;

  DatabaseHelper._();

  static getDatabase() async {
    String databaseName = 'sennit.db';

    if (_myDatabase != null) {
      return _myDatabase;
    } else {
      _myDatabase = await openDatabase(
        databaseName,
        onCreate: onCreate,
        onUpgrade: (db, pVersion, nVersion) {
          db.rawDelete("DROP DATABASE $databaseName");
          onCreate(db, nVersion);
        },
        version: 1,
      );
      return _myDatabase;
    }
  }

  static FutureOr<void> onCreate(db, version) {
    db.execute("CREATE TABLE IF NOT EXISTS ${Tables.SIGNED_IN_USER_TABLE} ( " +
        "${SignedInUserTableColumns.USER_ID} TEXT PRIMARY KEY" +
        " )");

    db.execute("CREATE TABLE IF NOT EXISTS ${Tables.USER_TABLE} ( " +
        "${UserTableColumns.FIRST_NAME} TEXT, " +
        "${UserTableColumns.LAST_NAME} TEXT, " +
        "${UserTableColumns.EMAIL} TEXT, " +
        "${UserTableColumns.PHONE_NUMBER} TEXT, " +
        "${UserTableColumns.USER_ID} TEXT PRIMARY KEY, " +
        "${UserTableColumns.USER_CREATED_ON} TEXT, " +
        "${UserTableColumns.DATE_OF_BIRTH} TEXT, " +
        "${UserTableColumns.HOME_LOCATION_ADDRESS} TEXT," +
        "${UserTableColumns.HOME_LOCATION_LATLNG} TEXT, " +
        "${UserTableColumns.OFFICE_LOCATION_ADDRESS} TEXT, " +
        "${UserTableColumns.OFFICE_LOCATION_LATLNG} TEXT, " +
        "${UserTableColumns.RANK} TEXT, " +
        "${UserTableColumns.GENDER} TEXT" +
        " )");

    db.execute(
        "CREATE TABLE IF NOT EXISTS ${Tables.USER_LOCATION_HISTORY_TABLE} ( " +
            "${UserLocationHistoryTableColumns.ADDRESS} TEXT PRIMARY KEY, " +
            "${UserLocationHistoryTableColumns.LAST_USED} INT, " +
            "${UserLocationHistoryTableColumns.USER_ID} TEXT, " +
            "${UserLocationHistoryTableColumns.LATLNG} TEXT" +
            " )");

    db.execute("CREATE TABLE IF NOT EXISTS ${Tables.USER_CART_TABLE} ( " +
        "${UserCartTableColumns.CART_ID} TEXT PRIMARY_KEY, " +
        "${UserCartTableColumns.USER_ID} TEXT, " +
        "${UserCartTableColumns.TOTAL_PRICE} INT" +
        " )");

    db.execute("CREATE TABLE IF NOT EXISTS ${Tables.USER_NOTIFICATION_TABLE} ( " +
        "${UserNotificationTableColumns.ORDER_ID} TEXT, " +
        "${UserNotificationTableColumns.NOTIFICATION_ID} TEXT PRIMARY KEY, " +
        "${UserNotificationTableColumns.DESCRIPTION} TEXT , " +
        "${UserNotificationTableColumns.TITLE} TEXT" +
        " )");

    db.execute("CREATE TABLE IF NOT EXISTS ${Tables.DRIVER_TABLE} ( " +
        "${DriverTableColumns.FIRST_NAME} TEXT, " +
        "${DriverTableColumns.LAST_NAME} TEXT, " +
        "${DriverTableColumns.PHONE_NUMBER} TEXT, " +
        "${DriverTableColumns.DATE_OF_BIRTH} TEXT, " +
        "${DriverTableColumns.USER_CREATED_ON} TEXT, " +
        "${DriverTableColumns.DRIVER_ID} TEXT PRIMARY KEY, " +
        "${DriverTableColumns.HOME_LOCATION_ADDRESS} TEXT, " +
        "${DriverTableColumns.HOME_LOCATION_LATLNG} TEXT, " +
        "${DriverTableColumns.EMAIL} TEXT, " +
        "${DriverTableColumns.BALANCE} TEXT, " +
        "${DriverTableColumns.RANK} TEXT, " +
        "${DriverTableColumns.GENDER} TEXT" +
        " )");

    db.execute("CREATE TABLE IF NOT EXISTS ${Tables.DRIVER_NOTIFICATION_TABLE} ( " +
        "${DriverNotificationTableColumns.NOTIFICATION_ID} TEXT PRIMARY KEY, " +
        "${DriverNotificationTableColumns.DROP_OFF_ADDRESS} TEXT, " +
        "${DriverNotificationTableColumns.PICK_UP_ADDRESS} TEXT, " +
        "${DriverNotificationTableColumns.PICK_UP_LATLNG} TEXT, " +
        "${DriverNotificationTableColumns.ORDER_ID} TEXT, " +
        "${DriverNotificationTableColumns.DROP_OFF_LATLNG} TEXT" +
        " )");

    db.execute(
        "CREATE TABLE IF NOT EXISTS ${Tables.ORDER_FROM_RECIEVE_IT_TABLE} ( " +
            "${OrderFromRecieveItTableColumns.ORDER_ID} TEXT PRIMARY KEY, " +
            "${OrderFromRecieveItTableColumns.DRIVER_ID} TEXT, " +
            "${OrderFromRecieveItTableColumns.USER_ID} TEXT, " +
            "${OrderFromRecieveItTableColumns.DATE_ORDERED} TEXT, " +
            "${OrderFromRecieveItTableColumns.DROP_OFF_LATLNG} TEXT, " +
            "${OrderFromRecieveItTableColumns.DROP_OFF_LATLNG} TEXT, " +
            "${OrderFromRecieveItTableColumns.ORDER_PRICE} TEXT, " +
            "${OrderFromRecieveItTableColumns.STORE_ADDRESS} TEXT, " +
            "${OrderFromRecieveItTableColumns.STORE_LATLNG} TEXT, " +
            "${OrderFromRecieveItTableColumns.STORE_NAME} TEXT" +
            " )");

    db.execute(
        "CREATE TABLE IF NOT EXISTS ${Tables.ORDER_FROM_SENNIT_TABLE} ( " +
            "${OrderFromSennitTableColumns.ORDER_ID} TEXT PRIMARY KEY, " +
            "${OrderFromSennitTableColumns.DRIVER_ID} TEXT, " +
            "${OrderFromSennitTableColumns.USER_ID} TEXT, " +
            "${OrderFromRecieveItTableColumns.DATE_ORDERED} TEXT, " +
            "${OrderFromSennitTableColumns.DROP_OFF_LATLNG} TEXT, " +
            "${OrderFromSennitTableColumns.DROP_OFF_ADDRESS} TEXT, " +
            "${OrderFromSennitTableColumns.ORDER_PRICE} TEXT, " +
            "${OrderFromSennitTableColumns.PICK_UP_ADDRESS} TEXT, " +
            "${OrderFromSennitTableColumns.PICK_UP_LATLNG} TEXT, " +
            "${OrderFromSennitTableColumns.RECEIVER_EMAIL} TEXT, " +
            "${OrderFromSennitTableColumns.RECEIVER_NAME} TEXT, " +
            "${OrderFromSennitTableColumns.RECEIVER_PHONE} TEXT" +
            " )");

    db.execute(
        "CREATE TABLE IF NOT EXISTS ${Tables.ORDER_ITEM_FOR_RECEIVE_IT_TABLE} ( " +
            "${OrderItemForReceiveItTableColumns.ORDER_ITEM_ID} TEXT PRIMARY KEY, " +
            "${OrderItemForReceiveItTableColumns.ITEM_ID} TEXT, " +
            "${OrderItemForReceiveItTableColumns.ITEM_PROPERTY_ID} TEXT , " +
            "${OrderItemForReceiveItTableColumns.ORDER_ID} TEXT , " +
            "${OrderItemForReceiveItTableColumns.PRICE} TEXT , " +
            "${OrderItemForReceiveItTableColumns.QUANTITY} TEXT" +
            " )");

    db.execute(
        "CREATE TABLE IF NOT EXISTS ${Tables.ORDER_ITEM_FOR_SENNIT_TABLE} ( " +
            "${OrderItemForSennitTableColumns.ORDER_ITEM_ID} TEXT PRIMARY KEY, " +
            "${OrderItemForSennitTableColumns.ITEM_ID} TEXT, " +
            "${OrderItemForSennitTableColumns.ORDER_ID} TEXT, " +
            "${OrderItemForSennitTableColumns.BOX_SIZE} TEXT, " +
            "${OrderItemForSennitTableColumns.NUMBER_OF_BOXES} TEXT, " +
            "${OrderItemForSennitTableColumns.PRICE} TEXT, " +
            "${OrderItemForSennitTableColumns.SLEEVES_REQUIRED} TEXT" +
            " )");

    db.execute("CREATE TABLE IF NOT EXISTS ${Tables.ITEM_TABLE} ( " +
        "${ItemTableColumns.ITEM_ID} TEXT PRIMARY KEY, " +
        "${ItemTableColumns.NAME} TEXT, " +
        "${ItemTableColumns.SUB_CATEGORY} TEXT, " +
        "${ItemTableColumns.PRICE} TEXT, " +
        "${ItemTableColumns.BASE_CATEGORY} TEXT" +
        " )");

    db.execute("CREATE TABLE IF NOT EXISTS ${Tables.ITEM_IMAGE_TABLE} (" +
        "${ItemImageTableColumns.IMAGE_ID} TEXT PRIMARY KEY," +
        "${ItemImageTableColumns.ITEM_ID} TEXT," +
        "${ItemImageTableColumns.URL} TEXT" +
        " )");

    db.execute("CREATE TABLE IF NOT EXISTS ${Tables.ITEM_PROPERTY_TABLE} ( " +
        "${ItemPropertyTableColumn.ITEM_PROPERTY_ID} TEXT PRIMARY KEY, " +
        "${ItemPropertyTableColumn.PROPERTY_NAME} TEXT, " +
        "${ItemPropertyTableColumn.ITEM_ID} TEXT, " +
        "${ItemPropertyTableColumn.ITEM_PRICE} TEXT, " +
        "${ItemPropertyTableColumn.PROPERTY_VALUE} TEXT" +
        " )");

    db.execute(
        "CREATE TABLE IF NOT EXISTS ${Tables.ORDER_OTHER_CHARGES_TABLE} ( " +
            "${OrderOtherChargesTableColumns.CHARGES_ID} TEXT, " +
            "${OrderOtherChargesTableColumns.CHARGES_NAME} TEXT, " +
            "${OrderOtherChargesTableColumns.ORDER_ID} TEXT, " +
            "${OrderOtherChargesTableColumns.CHARGES_PRICE} TEXT" +
            " )");
  }
}
