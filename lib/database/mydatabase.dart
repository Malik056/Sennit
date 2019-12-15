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
  static const String RECIEVER_NAME = "RECEIVER_NAME";
  static const String RECIEVER_PHONE = "RECEIVER_PHONE";
  static const String RECIEVER_EMAIL = "RECEIVER_EMAIL";
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
  static const String CHARGGES_PRICE = "CHARGES_PRICE";
}

class ItemTableColumns {
  static const String NAME = "NAME";
  static const String BASE_CATEGORY = "CATEGORY";
  static const String SUB_CATEGORY = "SUB_CATEGORY";
  static const String PRICE = "PRICE";
}

class SignedInUserTableColumns {
  static const String USER_ID = "USER_ID";
}

class UserCartTableColumns {
  static const String CART_ID = "CART_ID";
  static const String PRICE = "PRICE";
}

class UserLocationHistoryTableColumns {
  static const String ADDRESS = "ADDRESS";
}

class UserNotificationTableColumns {
  static const String NOTIFICATION_ID = "NOTIFICATION_ID";
  static const String TITLE = "TITLE";
  static const String ORDER_ID = "ORDER_ID";
  static const String DESCRIPTION = "DESCRIPTION";
  static const String IS_NOTIFICATION_FOR_ORDER_COMPLETE = "IS_NOTIFICATION_FOR_ORDER_COMPLETE";
}

class DriverNotificationTableColumns {
  static const String NOTIFICATION_ID = "NOTIFICATOIN_ID";
  static const String PICK_UP_ADDRESS = "PICK_UP_ADDRESS";
  static const String DROP_OFF_LOCATION = "DROP_OFF_LOCATION";
  static const String PICK_UP_COORDINATES = "PICK_UP_COORDINATES";
  static const String DROP_OF_COORDINATES = "DROP_OFF_COORDINATES";
}

class OtherChargesForOrderTableColumn {
  static const String CHARGES_NAME = "SomeCharges";
  static const String CHARGES_VALUE = "SomeDoubleValue";
  static const String ORDER_ID = "ORDER_ID";
}