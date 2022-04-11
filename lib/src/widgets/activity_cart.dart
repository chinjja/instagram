import 'package:flutter/material.dart';
import 'package:instagram/src/models/activity.dart';
import 'package:instagram/src/models/comment.dart';
import 'package:instagram/src/models/like.dart';
import 'package:instagram/src/models/post.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/pages/post_list_page.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:instagram/src/widgets/get_user.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ActivityCard extends StatefulWidget {
  const ActivityCard({
    Key? key,
    required this.activity,
  }) : super(key: key);

  final Activity activity;

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  late final _firestore = context.read<FirestoreMethods>();
  Post? _post;

  @override
  void initState() {
    super.initState();
    if ({'like', 'unlike', 'comment'}.contains(widget.activity.type)) {
      _firestore.posts.at(postId: widget.activity.data['postId']).first.then(
            (post) => setState(() {
              _post = post;
            }),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;
    return GetUser(
      uid: activity.uid,
      builder: (context, user) {
        return ListTile(
          leading: _circleNetwork(user?.photoUrl),
          title: _makeTitle(user, activity),
          subtitle: activity.type == 'comment'
              ? const Text(
                  '답글 달기',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                )
              : null,
          trailing: _network(_post?.postUrl),
          onTap: _post == null
              ? null
              : () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PostListPage(user: user!, posts: [_post!])));
                },
        );
      },
    );
  }

  Widget _circleNetwork(String? url) {
    return CircleAvatar(
      backgroundImage: networkImage(url),
      radius: 20,
    );
  }

  Widget _network(String? url) {
    if (url == null) {
      return const SizedBox(
        width: 40,
        height: 40,
      );
    } else {
      return Image.network(
        url,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _makeTitle(User? user, Activity activity) {
    String text;
    if (activity.type == 'like') {
      text = '님이 게시물을 좋아합니다. ';
    } else if (activity.type == 'unlike') {
      text = '님이 게시물을 좋아요를 취소했습니다. ';
    } else if (activity.type == 'comment') {
      text = '님이 댓글을 남겼습니다: ${activity.data['text']}  ';
    } else {
      throw '님이 unsupport type ';
    }
    return RichText(
      text: TextSpan(
        text: '${user?.username}',
        style: Theme.of(context)
            .textTheme
            .bodyText1
            ?.copyWith(fontWeight: FontWeight.bold),
        children: [
          TextSpan(
            text: text,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
          TextSpan(
            text: activity.datePublished == null
                ? ''
                : DateFormat.Md()
                    .add_jm()
                    .format(activity.datePublished!.toDate()),
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
