import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/post/bloc/post_cubit.dart';
import 'package:instagram/src/post/view/post_card.dart';

class PostList extends StatefulWidget {
  const PostList({
    Key? key,
    required final this.state,
  }) : super(key: key);

  final PostState state;

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() {
    if (widget.state.hasReachedMax || !_controller.hasClients) return;

    if (_controller.offset >= _controller.position.maxScrollExtent - 120) {
      context.read<PostCubit>().fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PostCubit>();
    final posts = widget.state.posts;
    if (posts.isEmpty) {
      return const Center(child: Text('포스트가 없습니다.'));
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _controller,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: posts.length + (widget.state.hasReachedMax ? 0 : 1),
      itemBuilder: (context, index) {
        if (index == posts.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final post = posts[index];
        return PostCard(
          key: Key(post.post.postId),
          post: post,
          user: bloc.auth,
        );
      },
    );
  }
}
