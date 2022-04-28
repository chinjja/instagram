import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/auth/bloc/auth_cubit.dart';
import 'package:instagram/src/bookmark/bloc/bookmark_cubit.dart';
import 'package:instagram/src/post/view/post_page.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/utils/utils.dart';

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookmarkCubit(
        context.read<FirestoreMethods>(),
        auth: context.read<AuthCubit>().user,
      )..fetch(),
      child: const BookmarkView(),
    );
  }
}

class BookmarkView extends StatelessWidget {
  const BookmarkView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('저장됨'),
        actions: [
          if (kIsWeb)
            IconButton(
                onPressed: () {
                  context.read<BookmarkCubit>().refresh();
                },
                icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SafeArea(child: BlocBuilder<BookmarkCubit, BookmarkState>(
        builder: (context, state) {
          switch (state.status) {
            case BookmarkStatus.loading:
              return const BookmarkLoading();
            case BookmarkStatus.success:
            case BookmarkStatus.fetching:
              return BookmarkList(state: state);
            case BookmarkStatus.initial:
              return const SizedBox();
            default:
              return const BookmarkError();
          }
        },
      )),
    );
  }
}

class BookmarkError extends StatelessWidget {
  const BookmarkError({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('oops!'),
    );
  }
}

class BookmarkLoading extends StatelessWidget {
  const BookmarkLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class BookmarkList extends StatelessWidget {
  const BookmarkList({
    Key? key,
    required this.state,
  }) : super(key: key);

  final BookmarkState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BookmarkCubit>();
    return RefreshIndicator(
      onRefresh: () async {
        return context.read<BookmarkCubit>().refresh();
      },
      child: Stack(
        children: [
          GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              mainAxisSpacing: 1,
              crossAxisSpacing: 1,
              maxCrossAxisExtent: 150,
            ),
            itemCount: state.list.length + (state.hasReachedMax ? 0 : 1),
            itemBuilder: (context, index) {
              if (index == state.list.length) {
                if (state.status == BookmarkStatus.fetching) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return TextButton(
                    onPressed: () {
                      bloc.fetch();
                    },
                    child: const Text('더보기'),
                  );
                }
              }
              final bookmark = state.list[index];
              return GestureDetector(
                key: Key(bookmark.postId),
                onTap: () async {
                  final post = await bloc.getPost(bookmark);
                  if (post != null) {
                    Navigator.push(context, PostPage.route(fixed: [post]));
                  } else {
                    showSnackbar(context, '해당 포스트가 조재하지 않습니다.');
                  }
                },
                child: Container(
                  color: Colors.black,
                  child: Image.network(
                    bookmark.postUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          if (state.list.isEmpty) const Center(child: Text('북마크가 없습니다.'))
        ],
      ),
    );
  }
}
