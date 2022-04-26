import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/add_chat/bloc/add_chat_bloc.dart';
import 'package:instagram/src/auth/bloc/auth_cubit.dart';
import 'package:instagram/src/message/models/chat_info.dart';
import 'package:instagram/src/message/view/message_page.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:instagram/src/widgets/user_list_tile.dart';

class AddChatPage extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => const AddChatPage(),
    );
  }

  const AddChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.select((AuthCubit cubit) => cubit.user);
    return BlocProvider(
      create: (context) => AddChatBloc(context.read<FirestoreMethods>())
        ..add(AddChatFetchRequested(auth: auth)),
      child: MultiBlocListener(
        listeners: [
          BlocListener<AddChatBloc, AddChatState>(
            listenWhen: (previous, current) =>
                previous.submission != current.submission,
            listener: (context, state) {
              switch (state.submission) {
                case AddChatStatus.failure:
                  showSnackbar(context, '1명 이상 멤버를 선택하세요.');
                  break;
                case AddChatStatus.success:
                  Navigator.pushReplacement(
                    context,
                    MessagePage.route(
                        info:
                            ChatInfo(group: true, others: [...state.selected])),
                  );
                  break;
                default:
                  break;
              }
            },
          ),
        ],
        child: const AddChatView(),
      ),
    );
  }
}

class AddChatView extends StatelessWidget {
  const AddChatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.select((AuthCubit cubit) => cubit.user);

    return Scaffold(
      appBar: AppBar(
        title: const Text('새 메시지'),
        actions: [
          TextButton(
            onPressed: () {
              context.read<AddChatBloc>().add(AddChatSubmitted());
            },
            child: const Text('채팅'),
          ),
        ],
      ),
      body: SafeArea(
        child:
            BlocBuilder<AddChatBloc, AddChatState>(builder: (context, state) {
          switch (state.status) {
            case AddChatStatus.loading:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case AddChatStatus.success:
              if (state.friends.isEmpty) {
                return const Center(
                  child: Text('친구가 없습니다. 맞-팔로우를 하세요.'),
                );
              } else {
                return ListView.builder(
                  itemExtent: 60,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: state.friends.length,
                  itemBuilder: (context, index) {
                    final friend = state.friends[index];
                    final value = state.selected.contains(friend);
                    return UserListTile(
                      key: Key(friend.uid),
                      user: auth,
                      trailing: IgnorePointer(
                        child: Checkbox(
                          value: value,
                          onChanged: (v) {},
                        ),
                      ),
                      onTap: () {
                        context
                            .read<AddChatBloc>()
                            .add(AddChatFriendToggled(friend: friend));
                      },
                    );
                  },
                );
              }
            default:
              return const SizedBox();
          }
        }),
      ),
    );
  }
}
