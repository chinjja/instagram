import 'package:cloud_firestore/cloud_firestore.dart';

class Token {
  final String tokenId;
  final Timestamp datePublished;

  const Token({
    required this.tokenId,
    required this.datePublished,
  });

  Map<String, dynamic> toJson() => {
        'tokenId': tokenId,
        'datePublished': datePublished,
      };

  static Token fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Token(
      tokenId: data['tokenId'],
      datePublished: data['datePublished'],
    );
  }
}
