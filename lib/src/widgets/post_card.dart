import 'package:flutter/material.dart';
import 'package:instagram/src/models/post.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/pages/comment_page.dart';
import 'package:instagram/src/pages/profile_page.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    Key? key,
    required this.post,
    required this.user,
    this.onDelete,
  }) : super(key: key);
  final Post post;
  final User user;
  final void Function()? onDelete;
  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late final _firestore = context.read<FirestoreMethods>();

  late final post = widget.post;
  late final user = widget.user;

  User? postUser;

  int likeCount = 0;
  int commentCount = 0;
  bool? bookmarkd;
  bool? liked;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    _firestore.users
        .once(
          uid: post.uid,
        )
        .then((value) => setState(() {
              postUser = value;
            }));

    _firestore.likes
        .exists(
          uid: user.uid,
          postId: post.postId,
        )
        .then((value) => setState(() {
              liked = value;
            }));

    _firestore.bookmarks
        .exists(
          uid: user.uid,
          postId: post.postId,
        )
        .then((value) => setState(() {
              bookmarkd = value;
            }));

    _firestore.likes
        .getCount(
          postId: post.postId,
        )
        .then((value) => setState(() {
              likeCount = value;
            }));

    _firestore.comments
        .getCount(
          postId: post.postId,
        )
        .then((value) => setState(() {
              commentCount = value;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                if (postUser != null) {
                  _showProfile(postUser!);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: networkImage(postUser?.photoUrl),
                ),
              ),
            ),
            Expanded(
              child: Text(postUser?.username ?? ''),
            ),
            Visibility(
              visible: post.uid == widget.user.uid && widget.onDelete != null,
              child: PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: const Text('Delete'),
                      onTap: () async {
                        await _firestore.posts.delete(post: post);
                        widget.onDelete!();
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
              onPressed: liked == null
                  ? null
                  : () async {
                      await _firestore.posts.setLike(
                        post: post,
                        uid: user.uid,
                        value: !liked!,
                      );
                      setState(() {
                        likeCount += liked! ? -1 : 1;
                        liked = !liked!;
                      });
                    },
              icon: Icon(
                liked ?? false ? Icons.favorite : Icons.favorite_outline,
                color: liked ?? false ? Colors.red : null,
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
              onPressed: bookmarkd == null
                  ? null
                  : () async {
                      await _firestore.posts.setBookmark(
                        post: post,
                        uid: user.uid,
                        value: !bookmarkd!,
                      );
                      setState(() {
                        bookmarkd = !bookmarkd!;
                      });
                    },
              icon: Icon(
                bookmarkd ?? false ? Icons.bookmark : Icons.bookmark_outline,
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
                child: Text('$likeCount likes'),
              ),
              if (post.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: RichText(
                    text: TextSpan(
                      text: (postUser?.username ?? '') + ' ',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                            text: post.description,
                            style:
                                const TextStyle(fontWeight: FontWeight.normal)),
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
                  child: Text(
                    'View all $commentCount comments',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  post.date == null
                      ? ''
                      : DateFormat.yMMMd().add_jm().format(post.date!.toDate()),
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
}
