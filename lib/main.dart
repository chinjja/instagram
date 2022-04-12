import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram/src/pages/home_page.dart';
import 'package:instagram/src/pages/welcome.dart';
import 'package:instagram/src/providers/activity_provider.dart';
import 'package:instagram/src/providers/bookmark_provider.dart';
import 'package:instagram/src/providers/chat_provider.dart';
import 'package:instagram/src/providers/comment_provider.dart';
import 'package:instagram/src/providers/like_provider.dart';
import 'package:instagram/src/providers/message_provider.dart';
import 'package:instagram/src/providers/my_post_provider.dart';
import 'package:instagram/src/providers/post_provider.dart';
import 'package:instagram/src/providers/user_provider.dart';
import 'package:instagram/src/resources/auth_methods.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/resources/storage_methods.dart';
import 'package:instagram/src/widgets/current_user.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseOptions? options;
  if (kIsWeb) {
    options = const FirebaseOptions(
        apiKey: 'AIzaSyCgl15S12vqf2MiWtmpZPBds5BX_nBJ3P4',
        appId: '1:479650638727:web:ee9a57c60970a302c24122',
        messagingSenderId: '479650638727',
        projectId: 'instagram-21e39',
        storageBucket: 'instagram-21e39.appspot.com',
        authDomain: 'instagram-21e39.firebaseapp.com');
  }
  await Firebase.initializeApp(options: options);
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: _storage),
        Provider.value(value: _firestore),
        Provider.value(value: _auth),
      ],
      child: MaterialApp(
        title: 'Instagram Demo',
        theme: ThemeData.dark(),
        home: const MyApp(),
      ),
    ),
  );
}

final _storage = StorageMethods();
final _commentProvider = CommentProvider(storage: _storage);
final _messages = MessageProvider(storage: _storage);
final _likeProvider = LikeProvider(storage: _storage);
final _activityProvider = ActivityProvider(storage: _storage);
final _userProvider = UserProvider(
  storage: _storage,
  activityProvider: _activityProvider,
  bookmarkProvider: BookmarkProvider(storage: _storage),
  myPostProvider: MyPostProvider(storage: _storage),
);
final _firestore = FirestoreMethods(
  users: _userProvider,
  posts: PostProvider(
    storage: _storage,
    commentProvider: _commentProvider,
    likeProvider: _likeProvider,
    activityProvider: _activityProvider,
    userProvider: _userProvider,
  ),
  likes: LikeProvider(storage: _storage),
  comments: _commentProvider,
  activities: ActivityProvider(storage: _storage),
  chats: ChatProvider(storage: _storage, messages: _messages),
  messages: _messages,
);
final _auth = AuthMethods(firestore: _firestore);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          return const WelcomePage();
        }
        return const HomePage();
      },
    );
  }
}
