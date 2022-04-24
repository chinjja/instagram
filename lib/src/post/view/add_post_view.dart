import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as im;
import 'package:image_picker/image_picker.dart';
import 'package:instagram/src/auth/bloc/auth_cubit.dart';
import 'package:instagram/src/repo/models/model.dart';
import 'package:instagram/src/utils/utils.dart';

class AddPostView extends StatefulWidget {
  static Route<Post> route() {
    return MaterialPageRoute(builder: (context) => const AddPostView());
  }

  const AddPostView({Key? key}) : super(key: key);

  @override
  State<AddPostView> createState() => _AddPostViewState();
}

class _AddPostViewState extends State<AddPostView> {
  Uint8List? _image;
  bool _uploading = false;
  late final _description = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      final image = await pickImageData(ImageSource.gallery);
      if (image != null) {
        setState(() {
          _image = image;
        });
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.select((AuthCubit cubit) => cubit.user);
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 게시물'),
        actions: [
          TextButton(
            child: const Text('공유'),
            onPressed: () {
              _post(auth);
            },
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Offstage(
            offstage: !_uploading,
            child: const LinearProgressIndicator(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async {
                    final image = await pickImageData(ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        _image = image;
                      });
                    }
                  },
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: _image == null
                        ? Container(
                            child: const Icon(Icons.upload),
                            decoration: BoxDecoration(border: Border.all()),
                          )
                        : Image.memory(_image!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    autofocus: true,
                    controller: _description,
                    maxLength: 1000,
                    minLines: 3,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      hintText: '문구 입력...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: networkImage(auth.photoUrl),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(auth.username)),
                const Switch(value: true, onChanged: null),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _post(User auth) {
    if (_image == null) {
      showSnackbar(context, '사진을 선택을 해주세요.');
      return;
    }
    setState(() {
      _uploading = true;
    });
    final post = Post(
      description: _description.text,
      postImage: im.decodeImage(_image!),
      uid: auth.uid,
      date: DateTime.now(),
    );

    Navigator.pop(context, post);
  }
}
