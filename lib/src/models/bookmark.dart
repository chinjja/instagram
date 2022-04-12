class Bookmark {
  final String postId;
  final String postUrl;

  const Bookmark({
    required this.postId,
    required this.postUrl,
  });

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'postUrl': postUrl,
      };

  static Bookmark fromJson(Map<String, dynamic> json) {
    return Bookmark(
      postId: json['postId'],
      postUrl: json['postUrl'],
    );
  }
}
