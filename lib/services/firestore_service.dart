import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/swipe_model.dart';
import '../models/message_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<AppUser>> streamTeachers({String? subject, int? maxRate}) {
    Query q = _db.collection('users').where('role', isEqualTo: 'Teacher');

    if (subject != null && subject.isNotEmpty) {
      q = q.where('subjects', arrayContains: subject);
    }
    if (maxRate != null) {
      q = q.where('rate', isLessThanOrEqualTo: maxRate);
    }
    return q.snapshots().map((snap) => snap.docs.map((d) => AppUser.fromMap(d.data() as Map<String, dynamic>, d.id)).toList());
  }

  Future<void> setSwipe(SwipeModel swipe) async {
    final docRef = _db.collection('swipes').doc(swipe.fromId).collection('targets').doc(swipe.toId);
    await docRef.set(swipe.toMap());

    if (swipe.direction == 'right') {
      // quick check for reciprocal right or autoAccept (client-side helper)
      final reciprocal = await _db.collection('swipes').doc(swipe.toId).collection('targets').doc(swipe.fromId).get();
      if (reciprocal.exists && reciprocal.data()?['direction'] == 'right') {
        await createMatch(swipe.fromId, swipe.toId);
      } else {
        final teacherDoc = await _db.collection('users').doc(swipe.toId).get();
        if (teacherDoc.exists && (teacherDoc.data()?['autoAccept'] ?? false)) {
          await createMatch(swipe.fromId, swipe.toId);
        }
      }
    }
  }

  Future<void> createMatch(String studentId, String teacherId) async {
    final matchRef = _db.collection('matches').doc();
    await matchRef.set({
      'studentId': studentId,
      'teacherId': teacherId,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'accepted',
    });

    await _db.collection('chats').doc(matchRef.id).set({
      'matchId': matchRef.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamMessages(String matchId) {
    return _db.collection('chats').doc(matchId).collection('messages').orderBy('timestamp').snapshots().map(
          (snap) => snap.docs.map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>}).toList(),
        );
  }

  Future<void> sendMessage(String matchId, MessageModel message) async {
    final collection = _db.collection('chats').doc(matchId).collection('messages');
    await collection.add(message.toMap());
    await _db.collection('matches').doc(matchId).update({
      'lastMessage': message.text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }
}