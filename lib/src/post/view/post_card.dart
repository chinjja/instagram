import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as im;
import 'package:instagram/src/auth/bloc/auth_cubit.dart';
import 'package:instagram/src/comment/view/comment_page.dart';
import 'package:instagram/src/post/bloc/post_cubit.dart';
import 'package:instagram/src/post/models/models.dart';
import 'package:instagram/src/user/view/user_page.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:intl/intl.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    Key? key,
    required this.post,
  }) : super(key: key);
  final PostData post;

  @override
  Widget build(BuildContext context) {
    final auth = context.select((AuthCubit cubit) => cubit.user);
    if (post.isCreating) {
      Uint8List data = Uint8List.fromList(im.encodePng(post.post.postImage!));
      return ListTile(
        leading: Image.memory(
          data,
          width: 48,
          height: 48,
        ),
        title: const LinearProgressIndicator(),
        subtitle: Text(post.post.description),
      );
    }
    return Column(
      children: [
        if (post.isDeleting) const LinearProgressIndicator(),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  UserPage.route(user: post.user!),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: networkImage(post.user?.photoUrl),
                ),
              ),
            ),
            Expanded(
              child: Text(post.user?.username ?? ''),
            ),
            Visibility(
              visible: post.post.uid == auth.uid,
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
              post.post.postUrl!,
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
                Navigator.push(
                    context,
                    CommentPage.route(
                      post: post.post,
                    ));
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
                      text: '${post.user?.username ?? ''} ',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
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
                  Navigator.push(
                      context,
                      CommentPage.route(
                        post: post.post,
                      ));
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
}
