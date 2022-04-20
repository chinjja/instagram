import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/comment/bloc/comment_cubit.dart';
import 'package:instagram/src/comment/view/comment_base_cart.dart';
import 'package:instagram/src/comment/view/comment_cart.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/widgets/send_text_field.dart';

class CommentPage extends StatelessWidget {
  static Route route({
    required User user,
    required Post post,
  }) =>
      MaterialPageRoute(
          builder: (_) => CommentPage(
                user: user,
                post: post,
              ));

  const CommentPage({
    Key? key,
    required this.user,
    required this.post,
  }) : super(key: key);

  final User user;
  final Post post;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CommentCubit(
        context.read<FirestoreMethods>(),
        auth: user,
        post: post,
      )..fetch(),
      child: const CommentView(),
    );
  }
}

class CommentView extends StatelessWidget {
  const CommentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('댓글'),
      ),
      body: BlocBuilder<CommentCubit, CommentState>(
        builder: (context, state) {
          switch (state.status) {
            case CommentStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case CommentStatus.success:
              return RefreshIndicator(
                  onRefresh: () => context.read<CommentCubit>().refresh(),
                  child: CommentList(state: state));
            case CommentStatus.failure:
            default:
              return const Center(child: Text('oops'));
          }
        },
      ),
    );
  }
}

class CommentList extends StatefulWidget {
  const CommentList({
    Key? key,
    required final this.state,
  }) : super(key: key);

  final CommentState state;

  @override
  State<CommentList> createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
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
      context.read<CommentCubit>().fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.state.list;
    final bloc = context.read<CommentCubit>();
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _controller,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: list.length + (widget.state.hasReachedMax ? 0 : 1) + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const CommentHeader();
              }
              if (index == list.length + 1) {
                return const CommentLoading();
              }
              final data = list[index - 1];
              return CommentCard(
                key: Key(data.comment.commentId),
                data: data,
              );
            },
          ),
        ),
        SendTextField(
          user: bloc.auth,
          hintText: '댓글 달기...',
          sendText: '게시',
          onTap: (text) async {
            bloc.create(text);
          },
        ),
      ],
    );
  }
}

class CommentLoading extends StatelessWidget {
  const CommentLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class CommentHeader extends StatelessWidget {
  const CommentHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CommentCubit>();
    return Column(
      children: [
        CommentBaseCard(
          user: bloc.postUser,
          text: bloc.post.description,
          date: bloc.post.date,
        ),
        const Divider(),
      ],
    );
  }
}
