import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:instagram/src/auth/bloc/auth_cubit.dart';
import 'package:instagram/src/message/models/chat_info.dart';
import 'package:instagram/src/post/view/post_page.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/pages/edit_profile_page.dart';
import 'package:instagram/src/pages/follower_page.dart';
import 'package:instagram/src/message/view/message_page.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/user/bloc/user_bloc.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class UserPage extends StatelessWidget {
  static Route route({required User user}) {
    return MaterialPageRoute(
      builder: (context) => UserPage(user: user),
    );
  }

  const UserPage({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserBloc(
        context.read<FirestoreMethods>(),
        auth: context.read<AuthCubit>().user,
      )..add(UserLoaded(user: user)),
      child: const UserView(),
    );
  }
}

class UserView extends StatefulWidget {
  const UserView({
    Key? key,
  }) : super(key: key);

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  final _gridPostsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final state = context.select((UserBloc bloc) => bloc.state);
    return Scaffold(
      appBar: AppBar(
        title: Text(state.user?.username ?? ''),
        actions: state.isOwner
            ? [
                TextButton(
                  onPressed: _signOut,
                  child: const Text('Sign Out'),
                ),
              ]
            : null,
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state.status == UserStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == UserStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return DefaultTabController(
            length: 2,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 16,
                      right: 16,
                    ),
                    child: Column(
                      children: [
                        UserHeader(
                          onTap: () {
                            Scrollable.ensureVisible(
                              _gridPostsKey.currentContext!,
                              duration: const Duration(milliseconds: 250),
                            );
                          },
                        ),
                        const UserWebsiteLink(),
                        const UserStateText(),
                        const UserButton(),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.grid_view_outlined)),
                      Tab(icon: Icon(Icons.portrait_outlined)),
                    ],
                  ),
                ),
              ],
              body: TabBarView(
                key: _gridPostsKey,
                children: [
                  _gridTab(state),
                  _portraitTab(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _gridTab(UserState state) {
    final posts = state.posts;
    if (posts.isEmpty) {
      return const Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: 190),
          child: Text('게시물이 없습니다.'),
        ),
      );
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        maxCrossAxisExtent: 150,
      ),
      itemCount: posts.length + (state.hasReachedMax ? 0 : 1),
      itemBuilder: (context, index) {
        if (index == posts.length) {
          return Container(
            color: Colors.black,
            child: TextButton(
              child: const Text('더보기'),
              onPressed: () {
                context.read<UserBloc>().add(const UserPostFetch());
              },
            ),
          );
        }
        final post = posts[index];
        return AspectRatio(
          key: Key(post.postId),
          aspectRatio: 1,
          child: GestureDetector(
            onTap: () {
              _feed(state.user!);
            },
            child: Container(
              color: Colors.black,
              child: Image.network(
                post.postUrl!,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _portraitTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 160,
          ),
          Icon(
            Icons.photo_camera_outlined,
            size: 48,
          ),
          Text('게시물 없음'),
        ],
      ),
    );
  }

  void _feed(User user) async {
    Navigator.push(
      context,
      PostPage.route(byUser: user, showActions: false),
    );
  }

  void _signOut() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: const Text('로그아웃 하시겠습니까?'),
            actions: [
              TextButton(
                  onPressed: () {
                    context.read<AuthCubit>().signout();
                  },
                  child: const Text('로그아웃')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('취소')),
            ],
          );
        });
  }
}

class UserHeader extends StatelessWidget {
  final GestureTapCallback onTap;
  const UserHeader({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state.status != UserStatus.success) {
          return const SizedBox();
        }
        final user = state.user!;
        return Padding(
          padding: const EdgeInsets.only(right: 24, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage: networkImage(user.photoUrl),
              ),
              _tap(
                value: state.postCount,
                name: '게시물',
                onTap: onTap,
              ),
              _tap(
                value: state.followersCount,
                name: '팔로워',
                onTap: () {
                  _showFollows(
                    context,
                    user: user,
                    showFollows: true,
                  );
                },
              ),
              _tap(
                value: state.followingCount,
                name: '팔로잉',
                onTap: () {
                  _showFollows(
                    context,
                    user: user,
                    showFollows: false,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tap(
      {required int value, required String name, void Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text('$value'),
          Text(name),
        ],
      ),
    );
  }

  void _showFollows(
    BuildContext context, {
    required User user,
    required bool showFollows,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowPage(
          user: user,
          showFollows: showFollows,
        ),
      ),
    );
  }
}

class UserButton extends StatelessWidget {
  const UserButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final user = state.user;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: IndexedStack(
            index: state.isOwner ? 0 : 1,
            children: [
              _button(
                text: '프로필 편집',
                onTap: user == null
                    ? null
                    : () {
                        _editProfile(context, user);
                      },
              ),
              Row(
                children: [
                  Flexible(
                    child: _button(
                      text: state.isFollowing
                          ? '팔로잉'
                          : state.isFollowers
                              ? '맞-팔로우'
                              : '팔로우',
                      color: state.isFollowing ? null : Colors.blue,
                      onTap: () {
                        context
                            .read<UserBloc>()
                            .add(const UserToggleFollowing());
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: _button(
                      text: '메시지',
                      onTap: user == null
                          ? null
                          : () {
                              _message(context, user);
                            },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _button(
      {required String text, required void Function()? onTap, Color? color}) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          width: double.infinity,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: const BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _editProfile(BuildContext context, User user) async {
    final value = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(user: user),
      ),
    ) as User?;
    if (value != null) {
      context.read<UserBloc>().add(UserProfileUpdated(user: value));
    }
  }

  void _message(BuildContext context, User user) async {
    Navigator.pushAndRemoveUntil(
      context,
      MessagePage.route(info: ChatInfo(group: false, others: [user])),
      (route) => route.settings.name == '/',
    );
  }
}

class UserStateText extends StatelessWidget {
  const UserStateText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.select((UserBloc bloc) => bloc.state.user);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 2,
        vertical: 6,
      ),
      child: Text(user?.state ?? ''),
    );
  }
}

class UserWebsiteLink extends StatelessWidget {
  const UserWebsiteLink({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.select((UserBloc bloc) => bloc.state.user);
    if (user?.website == null) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 2,
        vertical: 6,
      ),
      child: Linkify(
        text: user?.website ?? '',
        onOpen: (link) async {
          if (await canLaunch(link.url)) {
            await launch(link.url);
          } else {
            showSnackbar(context, 'Cannot launch ${link.url}');
          }
        },
      ),
    );
  }
}
