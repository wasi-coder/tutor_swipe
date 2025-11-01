import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class SwipeProvider extends ChangeNotifier {
  final FirestoreService _fs;
  final String currentUserId;
  List<AppUser> cards = [];

  SwipeProvider(this._fs, this.currentUserId);

  void updateCards(List<AppUser> teachers) {
    cards = teachers;
    notifyListeners();
  }

  Future<void> swipeRight(String teacherId) async {
    await _fs.setSwipe(
      // fromId is current user (student)
      // this provider expects currentUserId set by AuthProvider via proxy update
      // if empty, ensure auth available
      // direction 'right'
      // we use simple SwipeModel object inline
      // ignore: avoid_dynamic_calls
      SwipelessWrapper.set(currentUserId, teacherId, 'right'),
    );
    // notifyListeners optional
  }

  Future<void> swipeLeft(String teacherId) async {
    await _fs.setSwipe(
      SwipelessWrapper.set(currentUserId, teacherId, 'left'),
    );
  }
}

// small helper to avoid importing SwipeModel in this wrapper block
class SwipelessWrapper {
  static dynamic set(String fromId, String toId, String direction) {
    return {
      'fromId': fromId,
      'toId': toId,
      'direction': direction,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
}