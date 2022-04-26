import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/activity/bloc/activity_bloc.dart';
import 'package:instagram/src/auth/bloc/auth_cubit.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/activity/view/activity_cart.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.select((AuthCubit cubit) => cubit.user);
    return BlocProvider(
      create: (context) =>
          ActivityBloc(context.read<FirestoreMethods>(), auth: auth)
            ..add(const ActivityFetched()),
      child: const ActivityView(),
    );
  }
}

class ActivityView extends StatelessWidget {
  const ActivityView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('활동'),
        actions: [
          if (kIsWeb)
            IconButton(
                onPressed: () {
                  context.read<ActivityBloc>().add(const ActivityRefresh());
                },
                icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<ActivityBloc, ActivityState>(
          builder: (context, state) {
            switch (state.status) {
              case ActivityStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case ActivityStatus.success:
                return ActivityList(state: state);
              default:
                return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}

class ActivityList extends StatefulWidget {
  const ActivityList({
    Key? key,
    required final this.state,
  }) : super(key: key);

  final ActivityState state;

  @override
  State<ActivityList> createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> {
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
      context.read<ActivityBloc>().add(const ActivityFetched());
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.state.list;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ActivityBloc>().add(const ActivityRefresh());
      },
      child: Stack(
        children: [
          ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _controller,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: list.length + (widget.state.hasReachedMax ? 0 : 1),
            itemBuilder: (context, index) {
              if (index == list.length) {
                return const Center(child: CircularProgressIndicator());
              }
              final item = list[index];
              return Dismissible(
                key: Key(item.activity.activityId),
                background: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: const Icon(Icons.delete_forever),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.delete_forever),
                ),
                onDismissed: (dir) {
                  context
                      .read<ActivityBloc>()
                      .add(ActivityDeleted(activity: item.activity));
                },
                child: ActivityCard(
                  data: item,
                ),
              );
            },
          ),
          if (list.isEmpty) const Center(child: Text('활동이 없습니다.')),
        ],
      ),
    );
  }
}
