import 'package:flutter/material.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/pages/message_page.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:instagram/src/widgets/get_user.dart';
import 'package:instagram/src/widgets/get_user_list.dart';
import 'package:instagram/src/widgets/user_list_tile.dart';
import 'package:provider/provider.dart';

class NewMessagePage extends StatefulWidget {
  const NewMessagePage({
    Key? key,
    required this.currentUser,
  }) : super(key: key);
  final User currentUser;

  @override
  State<NewMessagePage> createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  late final _firestore = context.read<FirestoreMethods>();
  late final selected = <String>{};
  bool ownership = false;
  final title = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.currentUser;
    final bi = currentUser.following.toSet();
    bi.retainAll(currentUser.followers);
    bi.remove(currentUser.uid);
    final friends = bi.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('새 메시지'),
        actions: [
          TextButton(
            onPressed: _chatting,
            child: const Text('채팅'),
          ),
        ],
      ),
      body: SafeArea(
        child: friends.isEmpty
            ? const Center(
                child: Text('친구가 없습니다. 맞-팔로우를 하세요.'),
              )
            : ListView.builder(
                itemExtent: 60,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final uid = friends[index];
                  return GetUser(
                    uid: uid,
                    builder: (context, o) {
                      if (o == null) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return StatefulBuilder(
                        builder: (context, setStateRow) {
                          final value = selected.contains(uid);
                          return UserListTile(
                            user: o,
                            trailing: IgnorePointer(
                              child: Checkbox(
                                value: value,
                                onChanged: (v) {},
                              ),
                            ),
                            onTap: () {
                              setStateRow(() {
                                if (value) {
                                  selected.remove(uid);
                                } else {
                                  selected.add(uid);
                                }
                              });
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  void _chatting() async {
    if (selected.isEmpty) {
      showSnackbar(context, '1명 이상 멤버를 선택하세요.');
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MessagePage(
          group: true,
          currentUser: widget.currentUser,
          others: selected.toList(),
          autoFocus: false,
        ),
      ),
    );
  }
}