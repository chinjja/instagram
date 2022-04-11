import 'package:flutter/material.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/widgets/user_list_tile.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final _firestore = context.read<FirestoreMethods>();
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onSubmitted: (String value) {
            setState(() {});
          },
          decoration: const InputDecoration(
            hintText: '검색',
            icon: Icon(Icons.search),
          ),
        ),
      ),
      body: StreamBuilder<List<User>>(
        stream: _firestore.users.search(username: _searchController.text),
        builder: (context, snapshot) {
          final users = snapshot.data;
          if (users == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return UserListTile(
                key: ValueKey(user.uid),
                user: user,
              );
            },
          );
        },
      ),
    );
  }
}
