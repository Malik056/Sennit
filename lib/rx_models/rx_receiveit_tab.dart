import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sennit/rx_models/rx_searchbar_title.dart';

class RxReceiveItTab {
  BehaviorSubject<int> index = BehaviorSubject<int>.seeded(0);

  Stream<int> get index$ => index.stream;

  int get currentIndex => index.value;

  setCurrentIndex(int i) {
    index.add(i);
    var searchBarTitle = GetIt.I.get<RxReceiveItSearchBarTitle>();
    searchBarTitle.setTitle(i);
  }
}
