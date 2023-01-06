import 'package:synchronized/synchronized.dart';

class LockSynchronized {
  static Lock _lock;

  static Lock getLockInstance() {
    if(_lock != null) {
      return _lock;
    } else {
      _lock = Lock();
      return _lock;
    }
  }
}