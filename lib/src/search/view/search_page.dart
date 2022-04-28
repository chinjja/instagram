import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/search/bloc/search_bloc.dart';
import 'package:instagram/src/widgets/user_list_tile.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(context.read<FirestoreMethods>())
        ..add(const SearchRefresh()),
      child: const SearchView(),
    );
  }
}

class SearchView extends StatelessWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final username = context.select((SearchBloc bloc) => bloc.state.username);
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          initialValue: username,
          onChanged: (String value) {
            context
                .read<SearchBloc>()
                .add(SearchUsernameChanged(username: value));
          },
          decoration: const InputDecoration(
            hintText: '검색',
            icon: Icon(Icons.search),
          ),
        ),
        actions: [
          if (kIsWeb)
            IconButton(
                onPressed: () {
                  context.read<SearchBloc>().add(const SearchRefresh());
                },
                icon: const Icon(Icons.refresh)),
        ],
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          switch (state.status) {
            case SearchStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case SearchStatus.success:
              return RefreshIndicator(
                  onRefresh: () async {
                    context.read<SearchBloc>().add(const SearchRefresh());
                  },
                  child: const SearchList());
            default:
              return const SizedBox();
          }
        },
      ),
    );
  }
}

class SearchList extends StatelessWidget {
  const SearchList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.select((SearchBloc bloc) => bloc.state);
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: state.filtered.length,
      itemBuilder: (context, index) {
        final user = state.filtered[index];
        return UserListTile(
          key: Key(user.uid),
          user: user,
        );
      },
    );
  }
}
