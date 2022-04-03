import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/src/models/post.dart';
import 'package:instagram/src/models/user.dart' as model;
import 'package:instagram/src/pages/edit_profile_page.dart';
import 'package:instagram/src/pages/follower_page.dart';
import 'package:instagram/src/pages/welcome.dart';
import 'package:instagram/src/resources/auth_methods.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key? key,
    required this.user,
  }) : super(key: key);
  final model.User user;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final _auth = context.read<AuthMethods>();
  late final _firestore = context.read<FirestoreMethods>();
  final _postGrid = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<model.User>(
        initialData: widget.user,
        stream: _firestore.user(uid: widget.user.uid),
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final isOnwer = user.uid == FirebaseAuth.instance.currentUser?.uid;
          final isFollowing =
              user.followers.contains(FirebaseAuth.instance.currentUser!.uid);

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
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
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
                                  ),
                                  _tap(
                                    value: user.followers.length,
                                    name: '팔로워',
                                    onTap: () {
                                      _showFollows(user, true);
                                    },
                                  ),
                                  _tap(
                                    value: user.following.length,
                                    name: '팔로잉',
                                    onTap: () {
                                      _showFollows(user, false);
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
                                        FirebaseAuth.instance.currentUser!.uid,
                                        user.uid,
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
                    SliverGrid(
                      key: _postGrid,
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = posts[index];
                          return AspectRatio(
                            key: ValueKey(post.postId),
                            aspectRatio: 1,
                            child: Image.network(
                              post.postUrl,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                        childCount: posts.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                        maxCrossAxisExtent: 150,
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        });
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

  void _toggleFollows(String user, String target) {
    _firestore.followUser(user, target);
  }

  void _signOut() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
        (route) => false);
  }

  void _showFollows(model.User user, bool showFollows) {
    Navigator.push(
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
