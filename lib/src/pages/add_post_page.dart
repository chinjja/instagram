import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/src/models/user.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:provider/provider.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({
    Key? key,
    required this.user,
  }) : super(key: key);
  final User user;
  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  late final _firestore = context.read<FirestoreMethods>();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 게시물'),
        actions: [
          TextButton(
            child: const Text('공유'),
            onPressed: _post,
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: _image == null ? null : Image.memory(_image!),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _description,
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
                  backgroundImage: widget.user.photoUrl == null
                      ? null
                      : NetworkImage(widget.user.photoUrl!),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(widget.user.username)),
                const Switch(value: true, onChanged: null),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _post() async {
    setState(() {
      _uploading = true;
    });
    await _firestore.uploadPost(
      description: _description.text,
      file: _image!,
      user: widget.user,
    );

    Navigator.pop(context);
    showSnackbar(context, 'Done!');
  }
}
