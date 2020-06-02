import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class RxReceiveItSearchBarTitle {
  static List<String> _titles = [
    'Stores',
    'Search',
    'Notifications',
    'Past Orders'
  ];

  BehaviorSubject<String> title = BehaviorSubject.seeded(_titles[0]);
  Stream<String> get title$ => title.stream;

  void setTitle(int index) {
    title.add(_titles[index]);
  }
}
