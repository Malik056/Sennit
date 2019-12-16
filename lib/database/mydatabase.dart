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
  static const String ITEM_PROPERTY_TABLE = "ITEM_PROPERTY_TABLE";
  static const String ORDER_ITEM_FOR_SENNIT_TABLE =
      "ORDER_ITEM_FOR_SENNIT_TABLE";
  static const String ORDER_ITEM_FOR_RECEIVE_IT_TABLE =
      "ORDER_ITEM_FOR_RECIEVE_IT_TABLE";
  static const String ORDER_OTHER_CHARGES_TABLE = "ORDER_OTHER_CHARGES_TABLE";
}

class UserTableColumns {
  static const String USER_ID = "USER_ID";
  static const String FIRST_NAME = "FIRST_NAME";
  static const String LAST_NAME = "LAST_NAME";
  static const String HOME_LOCATION_ADDRESS = "HOME_LOCATION";
  static const String HOME_LOCATION_LATLNG = "HOME_LOCATION_LATLNG";
  static const String OFFICE_LOCATION_ADDRESS = "OFFICE_LOCATION";
  static const String OFFICE_LOCATION_LATLNG = "OFFICE_LOCATION_LATLNG";
  static const String DATE_CREATED = "DATE_CREATED";
  static const String EMAIL = "EMAIL";
  static const String PHONE_NUMBER = "PHONE";
  static const String DATE_OF_BIRTH = "DATE_OF_BIRTH";
  static const String GENDER = "GENDER";
  static const String RANK = "USER_RANK";
}

class DriverTableColumns {
  static const String DRIVER_ID = "USER_ID";
  static const String FIRST_NAME = "FIRST_NAME";
  static const String LAST_NAME = "LAST_NAME";
  static const String HOME_LOCATION_ADDRESS = "HOME_LOCATION";
  static const String HOME_LOCATION_LATLNG = "HOME_LOCATION_LATLNG";
  static const String DATE_CREATED = "DATE_CREATED";
  static const String EMAIL = "EMAIL";
  static const String PHONE_NUMBER = "PHONE";
  static const String DATE_OF_BIRTH = "DATE_OF_BIRTH";
  static const String GENDER = "GENDER";
  static const String RANK = "USER_RANK";
  static const String BALANCE = "BALANCE";
}

class OrderFromRecieveItTableColumns {
  static const String STORE_NAME = "STORE_NAME";
  static const String STORE_ADDRESS = "STORE_LOCATION";
  static const String STORE_COORDINATES = "STORE_COORDINATES";
  static const String DROP_OFF_LOCATION = "DROP_OFF_LOCATION";
  static const String DROP_OFF_COORDINATES = "DROP_OFF_COORDINATES";
  static const String ORDER_ID = "ORDER_ID";
  static const String DATE_ORDERED = "DATE_ORDERED";
  static const String ORDER_PRICE = "ORDER_PRICE";
  static const String USER_ID = "USER_ID";
  static const String DRIVER_ID = "DRIVER_ID";
}

class OrderFromSennitTableColumns {
  static const String ORDER_ID = "ORDER_ID";
  static const String DATE_ORDERED = "DATE_ORDERED";
  static const String ORDER_PRICE = "ORDER_PRICE";
  static const String PICK_UP_COORDINATES = "PICK_UP_COORDINATES";
  static const String PICK_UP_ADDRESS = "PICK_UP_ADDRESS";
  static const String DROP_OFF_COORDINATES = "DROP_OFF_COORDINATES";
  static const String DROP_OFF_ADDRESS = "DROP_OFF_ADDRESS";
  static const String SERVICE_CHARGES = "SERVICE_CHARGES";
  static const String USER_ID = "USER_ID";
  static const String RECIEVER_NAME = "RECEIVER_NAME";
  static const String RECIEVER_PHONE = "RECEIVER_PHONE";
  static const String RECIEVER_EMAIL = "RECEIVER_EMAIL";
  static const String DRIVER_ID = "DRIVER_ID";
}

class OrderItemForSennitTableColumns {
  static const String ORDER_ITEM_ID = "ORDER_ITEM_ID";
  static const String PRICE = "PRICE";
  static const String ITEM_ID = "ITEM_ID";
  // static const String QUANTITY = "QUANTITY";
  static const String ORDER_ID = "ORDER_ID";
  // static const String ITEM_PROPERTY_ID = "ITEM_PROPERTY_ID";
  static const String SLEEVES_REQUIRED = "SLEEVES_REQUIRES";
  static const String BOX_SIZE = "BOX_SIZE";
  static const String NUMBER_OF_BOXES = "NUMBER_OF_BOXES";
}

class OrderItemForReceiveItTableColumns {
  static const String ORDER_ITEM_ID = "ORDER_ITEM_ID";
  static const String ORDER_ID = "ORDER_ID";
  static const String ITEM_ID = "ITEM_ID";
  static const String QUANTITY = "QUANTITY";
  static const String PRICE = "PRICE";
  static const String ITEM_PROPERTY_ID = "ITEM_PROPERTY_ID";
}

class OrderOtherChargesTableColumns {
  static const String CHARGES_NAME = "CHARGES_NAME";
  static const String CHARGES_PRICE = "CHARGES_PRICE";
  static const String ORDER_ID = "ORDER_ID";
}

class ItemTableColumns {
  static const String ITEM_ID = "ITEM_ID";
  static const String NAME = "NAME";
  static const String BASE_CATEGORY = "CATEGORY";
  static const String SUB_CATEGORY = "SUB_CATEGORY";
  static const String PRICE = "PRICE";
}

class SignedInUserTableColumns {
  static const String USER_ID = "USER_ID";
}

class UserCartTableColumns {
  static const String USER_ID = "USER_ID";
  static const String TOTAL_PRICE = "TOTAL_PRICE";
  static const String CART_ID = "CART_ID";
}

class UserLocationHistoryTableColumns {
  static const String ADDRESS = "ADDRESS";
  static const String COORDINATES = "COORDINATES";
  static const String USER_ID = "USER_ID";
}

class UserNotificationTableColumns {
  static const String NOTIFICATION_ID = "NOTIFICATION_ID";
  static const String TITLE = "TITLE";
  static const String ORDER_ID = "ORDER_ID";
  static const String DESCRIPTION = "DESCRIPTION";
  static const String IS_NOTIFICATION_FOR_ORDER_COMPLETE =
      "IS_NOTIFICATION_FOR_ORDER_COMPLETE";
}

class DriverNotificationTableColumns {
  static const String NOTIFICATION_ID = "NOTIFICATOIN_ID";
  static const String PICK_UP_ADDRESS = "PICK_UP_ADDRESS";
  static const String DROP_OFF_ADDRESS = "DROP_OFF_LOCATION";
  static const String PICK_UP_COORDINATES = "PICK_UP_COORDINATES";
  static const String DROP_OFF_COORDINATES = "DROP_OFF_COORDINATES";
}

class ItemPropertyTableColumn {
  static const String PROPERTY_NAME = "PROPERTY_NAME";
  static const String PROPERTY_VALUE = "PROPERTY_VALUE";
  static const String ITEM_PRICE = "ITEM_PRICE";
  static const String ITEM_ID = "ITEM_ID";
}

class MyDatabase {
  static Database _myDatabase;

  getDatabase() async {
    if (_myDatabase != null) {
      return _myDatabase;
    } else {
      _myDatabase = await openDatabase('sennit.db', onCreate: (db, version) {
        db.execute(
            "CREATE TABLE IF NOT EXISTS ${Tables.SIGNED_IN_USER_TABLE} ( " +
                "${SignedInUserTableColumns.USER_ID} TEXT PRIMARY KEY" +
                " )");

        db.execute("CREATE TABLE IF NOT EXISTS ${Tables.USER_TABLE} ( " +
            "${UserTableColumns.FIRST_NAME} TEXT, " +
            "${UserTableColumns.LAST_NAME} TEXT, " +
            "${UserTableColumns.EMAIL} TEXT, " +
            "${UserTableColumns.PHONE_NUMBER} TEXT, " +
            "${UserTableColumns.USER_ID} TEXT PRIMARY KEY, " +
            "${UserTableColumns.DATE_CREATED} TEXT, " +
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
                "${UserLocationHistoryTableColumns.USER_ID} TEXT, " +
                "${UserLocationHistoryTableColumns.COORDINATES} TEXT" +
                " )");

        db.execute("CREATE TABLE IF NOT EXISTS ${Tables.USER_CART_TABLE} ( " +
            "${UserCartTableColumns.CART_ID} TEXT PRIMARY_KEY, " +
            "${UserCartTableColumns.USER_ID} TEXT" +
            " )");
        db.execute(
            "CREATE TABLE IF NOT EXISTS ${Tables.USER_NOTIFICATION_TABLE} ( " +
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
            "${DriverTableColumns.DATE_CREATED} TEXT, " +
            "${DriverTableColumns.DRIVER_ID} TEXT PRIMARY KEY, " +
            "${DriverTableColumns.HOME_LOCATION_ADDRESS} TEXT, " +
            "${DriverTableColumns.HOME_LOCATION_LATLNG} TEXT, " +
            "${DriverTableColumns.EMAIL} TEXT, " +
            "${DriverTableColumns.BALANCE} TEXT, " +
            "${DriverTableColumns.RANK} TEXT, " +
            "${DriverTableColumns.GENDER} TEXT" +
            " )");

        db.execute(
            "CREATE TABLE IF NOT EXISTS ${Tables.DRIVER_NOTIFICATION_TABLE} ( " +
                "${DriverNotificationTableColumns.NOTIFICATION_ID} TEXT PRIMARY KEY, " +
                "${DriverNotificationTableColumns.DROP_OFF_ADDRESS} TEXT, " +
                "${DriverNotificationTableColumns.PICK_UP_ADDRESS} TEXT, " +
                "${DriverNotificationTableColumns.PICK_UP_COORDINATES} TEXT, " +
                "${DriverNotificationTableColumns.DROP_OFF_COORDINATES} TEXT" +
                " )");

        db.execute(
            "CREATE TABLE IF NOT EXISTS ${Tables.ORDER_FROM_RECIEVE_IT_TABLE} ( " +
                "${OrderFromRecieveItTableColumns.ORDER_ID} TEXT PRIMARY KEY, " +
                "${OrderFromRecieveItTableColumns.DRIVER_ID} TEXT, " +
                "${OrderFromRecieveItTableColumns.USER_ID} TEXT, " +
                "${OrderFromRecieveItTableColumns.DATE_ORDERED} TEXT, " +
                "${OrderFromRecieveItTableColumns.DROP_OFF_COORDINATES} TEXT, " +
                "${OrderFromRecieveItTableColumns.DROP_OFF_COORDINATES} TEXT, " +
                "${OrderFromRecieveItTableColumns.ORDER_PRICE} TEXT, " +
                "${OrderFromRecieveItTableColumns.STORE_ADDRESS} TEXT, " +
                "${OrderFromRecieveItTableColumns.STORE_COORDINATES} TEXT, " +
                "${OrderFromRecieveItTableColumns.STORE_NAME} TEXT" +
                " )");
        db.execute(
            "CREATE TABLE IF NOT EXISTS ${Tables.ORDER_FROM_SENNIT_TABLE} ( " +
                "${OrderFromSennitTableColumns.ORDER_ID} TEXT PRIMARY KEY, " +
                "${OrderFromSennitTableColumns.DRIVER_ID} TEXT, " +
                "${OrderFromSennitTableColumns.USER_ID} TEXT, " +
                "${OrderFromRecieveItTableColumns.DATE_ORDERED} TEXT, " +
                "${OrderFromSennitTableColumns.DROP_OFF_COORDINATES} TEXT, " +
                "${OrderFromSennitTableColumns.DROP_OFF_ADDRESS} TEXT, " +
                "${OrderFromSennitTableColumns.ORDER_PRICE} TEXT, " +
                "${OrderFromSennitTableColumns.PICK_UP_ADDRESS} TEXT, " +
                "${OrderFromSennitTableColumns.PICK_UP_COORDINATES} TEXT, " +
                "${OrderFromSennitTableColumns.RECIEVER_EMAIL} TEXT, " +
                "${OrderFromSennitTableColumns.RECIEVER_NAME} TEXT, " +
                "${OrderFromSennitTableColumns.RECIEVER_PHONE} TEXT" +
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

        db.execute(
            "CREATE TABLE IF NOT EXISTS ${Tables.ITEM_PROPERTY_TABLE} ( " +
                "${ItemPropertyTableColumn.PROPERTY_NAME} TEXT PRIMARY KEY, " +
                "${ItemPropertyTableColumn.ITEM_ID} TEXT, " +
                "${ItemPropertyTableColumn.ITEM_PRICE} TEXT, " +
                "${ItemPropertyTableColumn.PROPERTY_VALUE} TEXT" +
                " )");

        db.execute(
            "CREATE TABLE IF NOT EXISTS ${Tables.ORDER_OTHER_CHARGES_TABLE} ( " +
                "${OrderOtherChargesTableColumns.CHARGES_NAME} TEXT PRIMARY KEY, " +
                "${OrderOtherChargesTableColumns.ORDER_ID} TEXT, " +
                "${OrderOtherChargesTableColumns.CHARGES_PRICE} TEXT" +
                " )");
      });
    }
  }
}
