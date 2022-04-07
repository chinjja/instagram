import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/src/models/post.dart';
import 'package:instagram/src/models/user.dart' as model;
import 'package:instagram/src/pages/edit_profile_page.dart';
import 'package:instagram/src/pages/follower_page.dart';
import 'package:instagram/src/pages/post_list_page.dart';
import 'package:instagram/src/pages/welcome.dart';
import 'package:instagram/src/resources/auth_methods.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key? key,
    required this.user,
  }) : super(key: key);
  final model.User user;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  late final _auth = context.read<AuthMethods>();
  late final _firestore = context.read<FirestoreMethods>();
  final _gridPostsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<Tuple3<model.User, List<String>, List<String>>>(
      stream: Rx.combineLatest3(
        _firestore.user(uid: widget.user.uid),
        _firestore.followers(uid: widget.user.uid),
        _firestore.following(uid: widget.user.uid),
        (model.User user, List<String> a, List<String> b) => Tuple3(user, a, b),
      ),
      builder: (context, snapshot) {
        final user = snapshot.data?.item1;
        final followers = snapshot.data?.item2 ?? [];
        final following = snapshot.data?.item3 ?? [];
        final curUid = FirebaseAuth.instance.currentUser?.uid;
        if (user == null || curUid == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final isOnwer = user.uid == curUid;
        final isFollowing = followers.contains(curUid);

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
          body: StreamBuilder<List<Post>>(
            stream: _firestore.posts([user.uid]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final posts = snapshot.data ?? [];
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
                              padding: const EdgeInsets.only(right: 24),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                    radius: 36,
                                    backgroundImage: user.photoUrl == null
                                        ? null
                                        : NetworkImage(user.photoUrl!),
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
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
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
                                  _button(
                                    text: isFollowing ? '언팔로잉' : '팔로잉',
                                    color: isFollowing ? null : Colors.blue,
                                    onTap: () {
                                      _toggleFollows(
                                        uid: curUid,
                                        to: user.uid,
                                      );
                                    },
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
            },
          ),
        );
      },
    );
  }

  Widget _gridTab(model.User user, List<Post> posts) {
    if (posts.isEmpty) {
      return const Center(
        child: Text('게시물이 없습니다.'),
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
              _feed(user, posts);
            },
            child: Image.network(
              post.postUrl,
              fit: BoxFit.cover,
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

  void _feed(model.User user, List<Post> posts) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StreamBuilder<List<Post>>(
          initialData: posts,
          stream: _firestore.posts([user.uid]),
          builder: (context, snapshot) {
            return PostListPage(user: user, posts: posts);
          },
        ),
      ),
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

  void _editProfile(model.User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(user: user),
      ),
    );
  }

  void _toggleFollows({
    required String uid,
    required String to,
  }) {
    _firestore.follow(uid: uid, to: to);
  }

  void _signOut() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
        (route) => false);
  }

  void _showFollows({
    required model.User user,
    required List<String> followers,
    required List<String> following,
    required bool showFollows,
  }) {
    Navigator.push(
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
  }

  @override
  bool get wantKeepAlive => true;
}
