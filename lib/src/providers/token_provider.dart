import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/src/models/token.dart';
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:rxdart/rxdart.dart';

class TokenProvider {
  TokenProvider({required this.storage});
  final _firestore = FirebaseFirestore.instance;
  final StorageMethods storage;

  Stream<List<Token>> all({required String uid}) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('tokens')
        .snapshots()
        .flatMap((e) => Stream.fromIterable(e.docs)
            .map((doc) => Token.fromJson(doc.data()))
            .toList()
            .asStream());
  }

  Future<Token> update({
    required String uid,
    required String token,
  }) async {
    final tokensRef =
        _firestore.collection('users').doc(uid).collection('tokens');
    final removeDate = DateTime.now().subtract(const Duration(days: 28));
    final tokens = await all(uid: uid).first;
    final batch = _firestore.batch();
    for (final t in tokens) {
      if (t.date.isBefore(removeDate)) {
        batch.delete(tokensRef.doc(t.tokenId));
      }
    }
    final result = Token(
      tokenId: token,
      date: DateTime.now(),
    );
    final data = result.toJson();
    data['date'] = FieldValue.serverTimestamp();
    batch.set(tokensRef.doc(token), data);
    await batch.commit();
    return result;
  }

  Future<void> delete({required String uid, required String tokenId}) async {
    return await _firestore
        .collection('users')
        .doc(uid)
        .collection('tokens')
        .doc(tokenId)
        .delete();
  }
}
