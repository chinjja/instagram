import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/src/models/comments.dart';
import 'package:instagram/src/models/like.dart';
import 'package:instagram/src/models/likes.dart';
import 'package:instagram/src/models/post.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/pages/comment_page.dart';
import 'package:instagram/src/pages/profile_page.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/utils/utils.dart';
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
    final user = widget.user;
    final isBookmark = post.bookmarks.contains(user.uid);
    final commentStream = _firestore.posts.comments(postId: post.postId);
    return StreamBuilder<Tuple2<User, Likes>>(
      stream: Rx.combineLatest2(
        _firestore.users.at(uid: post.uid),
        _firestore.posts.likes(postId: post.postId),
        (User a, Likes b) => Tuple2(a, b),
      ),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final postUser = data?.item1;
        final postUserUrl = postUser?.photoUrl;
        final postUsername = postUser?.username ?? '';
        final likes = data?.item2;
        final isLike = likes?.likes.containsKey(widget.user.uid) ?? false;

        return Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (postUser != null) {
                      _showProfile(postUser);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: networkImage(postUserUrl),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(postUsername),
                ),
                Visibility(
                  visible: post.uid == widget.user.uid,
                  child: PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: const Text('Delete'),
                          onTap: () {
                            _firestore.posts.delete(postId: post.postId);
                          },
                        ),
                      ];
                    },
                  ),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              color: Colors.black,
              constraints: const BoxConstraints(
                minHeight: 250,
                maxHeight: 500,
              ),
              child: AspectRatio(
                aspectRatio: post.aspectRatio,
                child: Image.network(
                  post.postUrl,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    _toggleLike(isLike);
                  },
                  icon: Icon(
                    isLike ? Icons.favorite : Icons.favorite_outline,
                    color: isLike ? Colors.red : null,
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
                  onPressed: () {
                    _bookmark(isBookmark);
                  },
                  icon: Icon(
                    isBookmark ? Icons.bookmark : Icons.bookmark_outline,
                  ),
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
                    child: Text('${likes?.likes.length} likes'),
                  ),
                  if (post.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: RichText(
                        text: TextSpan(
                          text: postUsername + ' ',
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
                      child: StreamBuilder<Comments>(
                          stream: commentStream,
                          builder: (context, snapshot) {
                            final len = snapshot.data?.list.length ?? 0;
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
                      post.datePublished == null
                          ? ''
                          : DateFormat.yMMMd()
                              .add_jm()
                              .format(post.datePublished!.toDate()),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleLike(bool isLike) {
    if (isLike) {
      _firestore.posts.unlike(post: widget.post, uid: widget.user.uid);
    } else {
      _firestore.posts.like(post: widget.post, uid: widget.user.uid);
    }
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

  void _showProfile(User user) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(user: user),
      ),
    );
  }

  void _bookmark(bool isBookmark) {
    if (isBookmark) {
      _firestore.posts
          .unbookmark(postId: widget.post.postId, uid: widget.user.uid);
    } else {
      _firestore.posts
          .bookmark(postId: widget.post.postId, uid: widget.user.uid);
    }
  }
}
