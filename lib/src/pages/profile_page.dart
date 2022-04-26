import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:instagram/src/auth/bloc/auth_cubit.dart';
import 'package:instagram/src/message/models/chat_info.dart';
import 'package:instagram/src/post/view/post_page.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/pages/edit_profile_page.dart';
import 'package:instagram/src/pages/follower_page.dart';
import 'package:instagram/src/message/view/message_page.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key? key,
    required this.user,
  }) : super(key: key);
  final User user;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final _firestore = context.read<FirestoreMethods>();
  final _gridPostsKey = GlobalKey();
  late User user = widget.user;
  late var followers = user.followers;
  late var following = user.following;
  late final postStream = _firestore.posts.fetch(byUser: user, limit: 12);

  Future<void> _refresh() async {
    final value = await _firestore.users.get(uid: user.uid);
    if (value != null) {
      setState(() {
        user = value;
        followers = user.followers;
        following = user.following;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = _firestore.users.currentUid;
    final isOnwer = user.uid == currentUid;
    final isFollower = followers.contains(currentUid);
    final isFollowing = following.contains(currentUid);

    return Scaffold(
      appBar: AppBar(
        title: Text(user.username),
        actions: isOnwer
            ? [
                TextButton(
                  onPressed: _signOut,
                  child: const Text('Sign Out'),
                ),
              ]
            : null,
      ),
      body: FutureBuilder<List<Post>>(
          future: postStream,
          builder: (context, snapshot) {
            final posts = snapshot.data;
            if (posts == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
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
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 24, bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  radius: 36,
                                  backgroundImage: networkImage(user.photoUrl),
                                ),
                                _tap(
                                  value: posts.length,
                                  name: '게시물',
                                  onTap: () {
                                    Scrollable.ensureVisible(
                                      _gridPostsKey.currentContext!,
                                      duration:
                                          const Duration(milliseconds: 250),
                                    );
                                  },
                                ),
                                _tap(
                                  value: followers.length,
                                  name: '팔로워',
                                  onTap: () {
                                    _showFollows(
                                      user: user,
                                      followers: followers,
                                      following: following,
                                      showFollows: true,
                                    );
                                  },
                                ),
                                _tap(
                                  value: following.length,
                                  name: '팔로잉',
                                  onTap: () {
                                    _showFollows(
                                      user: user,
                                      followers: followers,
                                      following: following,
                                      showFollows: false,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          if (user.website != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                                vertical: 6,
                              ),
                              child: Linkify(
                                text: user.website ?? '',
                                onOpen: (link) async {
                                  if (await canLaunch(link.url)) {
                                    await launch(link.url);
                                  } else {
                                    showSnackbar(
                                        context, 'Cannot launch ' + link.url);
                                  }
                                },
                              ),
                            ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 6,
                            ),
                            child: Text(user.state ?? ''),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: IndexedStack(
                              index: isOnwer ? 0 : 1,
                              children: [
                                _button(
                                  text: '프로필 편집',
                                  onTap: () {
                                    _editProfile(user);
                                  },
                                ),
                                Row(
                                  children: [
                                    Flexible(
                                      child: _button(
                                        text: isFollower
                                            ? '팔로잉'
                                            : isFollowing
                                                ? '맞-팔로우'
                                                : '팔로우',
                                        color: isFollower ? null : Colors.blue,
                                        onTap: () {
                                          _toggleFollows(
                                            isFollow: isFollower,
                                            uid: currentUid,
                                            to: user.uid,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: _button(
                                        text: '메시지',
                                        onTap: () {
                                          _message(user);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
                    _gridTab(user, posts),
                    _portraitTab(),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget _gridTab(User user, List<Post> posts) {
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
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return AspectRatio(
          key: ValueKey(post.postId),
          aspectRatio: 1,
          child: GestureDetector(
            onTap: () {
              _feed(user);
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: const [
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

  Widget _tap(
      {required int value, required String name, void Function()? onTap}) {
    return InkWell(
      child: Column(
        children: [
          Text('$value'),
          Text(name),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _button(
      {required String text, required void Function() onTap, Color? color}) {
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

  void _editProfile(User user) async {
    final value = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(user: user),
      ),
    ) as User?;
    if (value != null) {
      _refresh();
    }
  }

  void _toggleFollows({
    required bool isFollow,
    required String uid,
    required String to,
  }) async {
    await _firestore.users.follow(uid: uid, to: to, follow: !isFollow);
    setState(() {
      if (isFollow) {
        followers.removeWhere((element) => element == uid);
      } else {
        followers.add(uid);
      }
    });
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

  void _showFollows({
    required User user,
    required List<String> followers,
    required List<String> following,
    required bool showFollows,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowPage(
          user: user,
          followers: followers,
          following: following,
          showFollows: showFollows,
        ),
      ),
    );
    _refresh();
  }

  void _message(User user) async {
    Navigator.pushAndRemoveUntil(
      context,
      MessagePage.route(info: ChatInfo(group: false, others: [user])),
      (route) => route.settings.name == '/',
    );
  }
}
