import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/comment/view/comment_page.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/pages/profile_page.dart';
import 'package:instagram/src/post/bloc/post_cubit.dart';
import 'package:instagram/src/post/models/models.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    Key? key,
    required this.post,
    required this.user,
  }) : super(key: key);
  final PostData post;
  final User user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(user: post.user),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: networkImage(post.user.photoUrl),
                ),
              ),
            ),
            Expanded(
              child: Text(post.user.username),
            ),
            Visibility(
              visible: post.post.uid == user.uid,
              child: PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: const Text('Delete'),
                      onTap: () {
                        context.read<PostCubit>().delete(post);
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
            aspectRatio: post.post.aspectRatio,
            child: Image.network(
              post.post.postUrl,
              fit: BoxFit.fitHeight,
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                context.read<PostCubit>().toggleLike(post);
              },
              icon: Icon(
                post.isLiked ? Icons.favorite : Icons.favorite_outline,
                color: post.isLiked ? Colors.red : null,
              ),
            ),
            IconButton(
              onPressed: () {
                _comment(context, autoFocus: true);
              },
              icon: const Icon(Icons.comment_outlined),
            ),
            const Expanded(child: SizedBox.shrink()),
            IconButton(
              onPressed: () {
                context.read<PostCubit>().toggleBookmark(post);
              },
              icon: Icon(
                post.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
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
                child: Text('${post.likeCount} likes'),
              ),
              if (post.post.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: RichText(
                    text: TextSpan(
                      text: post.user.username + ' ',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                            text: post.post.description,
                            style:
                                const TextStyle(fontWeight: FontWeight.normal)),
                      ],
                    ),
                  ),
                ),
              InkWell(
                onTap: () {
                  _comment(context, autoFocus: false);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'View all ${post.commentCount} comments',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  DateFormat.yMMMd().add_jm().format(post.post.date),
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

  void _comment(BuildContext context, {required bool autoFocus}) {
    Navigator.push(context, CommentPage.route(user: user, post: post.post));
  }
}
