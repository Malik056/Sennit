import 'package:rxdart/subjects.dart';
import 'package:sennit/models/models.dart';

class RxUserCart {
  BehaviorSubject<UserCart> cart = BehaviorSubject<UserCart>.seeded(UserCart());
}
