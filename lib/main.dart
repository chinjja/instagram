import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/app.dart';
import 'package:instagram/src/auth/bloc/auth_cubit.dart';
import 'package:instagram/src/repo/providers/provider.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/resources/storage_methods.dart';

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
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _storage),
        RepositoryProvider.value(value: _firestore),
      ],
      child: BlocProvider(
        create: (context) => AuthCubit(_firestore),
        child: const App(),
      ),
    ),
  );
}

final _storage = StorageMethods();
final _commentProvider = CommentProvider();
final _userProvider = UserProvider(storage: _storage);
final _bookmarkProvider = BookmarkProvider();
final _likeProvider = LikeProvider();
final _activityProvider = ActivityProvider();
final _firestore = FirestoreMethods(
  users: _userProvider,
  posts: PostProvider(
    storage: _storage,
    comments: _commentProvider,
    likes: _likeProvider,
    activities: _activityProvider,
    bookmarks: _bookmarkProvider,
  ),
  likes: _likeProvider,
  comments: _commentProvider,
  activities: _activityProvider,
  chats: ChatProvider(),
  messages: MessageProvider(),
  bookmarks: _bookmarkProvider,
);
