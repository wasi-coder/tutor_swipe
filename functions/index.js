const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.onSwipeCreate = functions.firestore
  .document('swipes/{fromId}/targets/{toId}')
  .onCreate(async (snap, context) => {
    const fromId = context.params.fromId;
    const toId = context.params.toId;
    const swipeData = snap.data();

    if (!swipeData || swipeData.direction !== 'right') return null;

    const reciprocalRef = admin.firestore().doc(`swipes/${toId}/targets/${fromId}`);
    const reciprocalSnap = await reciprocalRef.get();

    const teacherDoc = await admin.firestore().doc(`users/${toId}`).get();
    const teacherData = teacherDoc.exists ? teacherDoc.data() : null;

    const shouldMatch = (reciprocalSnap.exists && reciprocalSnap.data().direction === 'right') || (teacherData && teacherData.autoAccept);

    if (shouldMatch) {
      const matchRef = await admin.firestore().collection('matches').add({
        studentId: fromId,
        teacherId: toId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        status: 'accepted'
      });

      await admin.firestore().collection('chats').doc(matchRef.id).set({
        matchId: matchRef.id,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });

      // optional: send FCM notification to both users (implement token storage)
      // const tokens = await getUserTokens([fromId, toId]);
      // await sendFCM(tokens, { title: 'New Match!', body: 'You have a new match on TutorSwipe' });

      return null;
    }
    return null;
  });

// Placeholder helpers (implement token storage & FCM logic as needed)
async function getUserTokens(userIds) {
  // read tokens from a collection like /fcmTokens/{userId}
  return [];
}

async function sendFCM(tokens, payload) {
  if (!tokens.length) return;
  await admin.messaging().sendToDevice(tokens, { notification: payload });
}