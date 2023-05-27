import 'package:flutter/material.dart';
import 'package:instagram/src/activity/bloc/activity_bloc.dart';
import 'package:instagram/src/activity/models/activity_data.dart';
import 'package:instagram/src/post/view/post_page.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    Key? key,
    required this.data,
  }) : super(key: key);

  final ActivityData data;

  @override
  Widget build(BuildContext context) {
    final postId = data.activity.postId;
    final postUrl = data.activity.data['postUrl'];

    final activity = data.activity;
    final user = data.fromUid;
    return ListTile(
      leading: _circleNetwork(user.photoUrl),
      title: _makeTitle(context, user, activity),
      subtitle: activity.type == 'comment'
          ? const Text(
              '답글 달기',
              style: TextStyle(
                color: Colors.grey,
              ),
            )
          : null,
      trailing: _network(postUrl),
      onTap: () async {
        final post = await context.read<ActivityBloc>().getPost(postId: postId);
        if (post != null) {
          Navigator.push(context, PostPage.route(fixed: [post]));
        } else {
          showSnackbar(context, '해당 포스트가 조재하지 않습니다.');
        }
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

  Widget _makeTitle(BuildContext context, User user, Activity activity) {
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
        text: user.username,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(fontWeight: FontWeight.bold),
        children: [
          TextSpan(
            text: text,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
          TextSpan(
            text: DateFormat.Md().add_jm().format(activity.date),
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
