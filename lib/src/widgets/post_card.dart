import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/src/models/post.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/pages/comment_page.dart';
import 'package:instagram/src/pages/profile_page.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    Key? key,
    required this.post,
    required this.user,
  }) : super(key: key);
  final Post post;
  final User user;
  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late final _firestore = context.read<FirestoreMethods>();
  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return StreamBuilder<Tuple2<User, List<String>>>(
        stream: Rx.combineLatest2(
          _firestore.user(uid: post.uid),
          _firestore.likes(post: post),
          (User a, List<String> b) => Tuple2(a, b),
        ),
        builder: (context, snapshot) {
          final data = snapshot.data;
          final user = data?.item1;
          final userImage = user?.photoUrl;
          final username = user?.username ?? '';
          final likes = data?.item2 ?? [];
          final like = likes.contains(widget.user.uid);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _showProfile,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage: userImage == null
                              ? null
                              : NetworkImage(userImage),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(username),
                    ),
                    if (post.uid == widget.user.uid)
                      PopupMenuButton(
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              child: const Text('Delete'),
                              onTap: () {
                                _firestore.deletePost(post);
                              },
                            ),
                          ];
                        },
                      ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  color: Colors.black,
                  constraints: const BoxConstraints(
                    minHeight: 200,
                    maxHeight: 500,
                  ),
                  child: Image.network(
                    post.postUrl,
                    fit: BoxFit.fitHeight,
                    width: post.width?.toDouble(),
                    height: post.height?.toDouble(),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _toggleLike,
                      icon: Icon(
                        like ? Icons.favorite : Icons.favorite_outline,
                        color: like ? Colors.red : null,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _comment(autoFocus: true);
                      },
                      icon: const Icon(Icons.comment_outlined),
                    ),
                    const Expanded(child: SizedBox.shrink()),
                    IconButton(
                      onPressed: _bookmark,
                      icon: const Icon(Icons.bookmark_outline),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text('${likes.length} likes'),
                      ),
                      if (post.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: RichText(
                            text: TextSpan(
                              text: username + ' ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(
                                    text: post.description,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                        ),
                      InkWell(
                        onTap: () {
                          _comment(autoFocus: false);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: FutureBuilder<
                                  QuerySnapshot<Map<String, dynamic>>>(
                              future: FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(post.postId)
                                  .collection('comments')
                                  .get(),
                              builder: (context, snapshot) {
                                final len = snapshot.data?.docs.length ?? 0;
                                return Text(
                                  'View all $len comments',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                );
                              }),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          DateFormat.yMMMd()
                              .add_jm()
                              .format(post.datePublished),
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _toggleLike() {
    _firestore.likePost(
      post: widget.post,
      user: widget.user,
    );
  }

  void _comment({required bool autoFocus}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentPage(
          post: widget.post,
          user: widget.user,
          autoFocus: autoFocus,
        ),
      ),
    );
  }

  void _showProfile() async {
    final user = await _firestore.user(uid: widget.post.uid).first;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(user: user),
      ),
    );
  }

  void _bookmark() {}
}
