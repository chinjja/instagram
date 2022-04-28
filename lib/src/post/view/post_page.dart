import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/auth/bloc/auth_cubit.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/post/view/add_post_view.dart';
import 'package:instagram/src/post/bloc/post_cubit.dart';
import 'package:instagram/src/post/view/view.dart';
import 'package:instagram/src/resources/firestore_methods.dart';

class PostPage extends StatelessWidget {
  static Route route({
    User? byUser,
    bool showActions = false,
    List<Post>? fixed,
  }) {
    return MaterialPageRoute(
        builder: (_) => PostPage(
              byUser: byUser,
              showActions: showActions,
              fixed: fixed,
            ));
  }

  const PostPage(
      {Key? key,
      this.byUser,
      this.showActions = false,
      this.fixed,
      this.onShowChat})
      : super(key: key);

  final User? byUser;
  final bool showActions;
  final List<Post>? fixed;
  final void Function()? onShowChat;

  @override
  Widget build(BuildContext context) {
    final auth = context.select((AuthCubit cubit) => cubit.user);
    return BlocProvider(
      create: (context) => PostCubit(
        context.read<FirestoreMethods>(),
        auth: auth,
        byUser: byUser,
        showActions: showActions,
        fixed: fixed,
      )..fetch(),
      child: PostView(onShowChat: onShowChat),
    );
  }
}

class PostView extends StatelessWidget {
  const PostView({Key? key, this.onShowChat}) : super(key: key);

  final void Function()? onShowChat;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PostCubit>();
    return Scaffold(
      appBar: AppBar(
        title: bloc.showActions ? const Text('Instagram') : null,
        actions: !bloc.showActions
            ? null
            : [
                IconButton(
                    onPressed: () async {
                      final post = await Navigator.push(
                        context,
                        AddPostView.route(),
                      );
                      if (post != null) {
                        context.read<PostCubit>().create(post);
                      }
                    },
                    icon: const Icon(Icons.add)),
                IconButton(onPressed: onShowChat, icon: const Icon(Icons.send)),
              ],
      ),
      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          switch (state.status) {
            case PostStatus.loading:
              return const PostLoading();
            case PostStatus.success:
              return PostList(state: state);
            case PostStatus.failure:
            default:
              return const PostError();
          }
        },
      ),
    );
  }
}
