import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/src/repo/models/user.dart';
import 'package:instagram/src/resources/firestore_methods.dart';
import 'package:instagram/src/utils/utils.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    Key? key,
    required this.user,
  }) : super(key: key);
  final User user;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final _firestore = context.read<FirestoreMethods>();

  Uint8List? _image;
  late final _username = TextEditingController(text: widget.user.username);
  late final _state = TextEditingController(text: widget.user.state);
  late final _website = TextEditingController(text: widget.user.website);
  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    ImageProvider? ip;
    if (_image == null) {
      final url = widget.user.photoUrl;
      ip = networkImage(url);
    } else {
      ip = MemoryImage(_image!);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 수정'),
        actions: [
          TextButton(
            onPressed: _done,
            child: const Text('완료'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Offstage(
              offstage: !_uploading,
              child: const LinearProgressIndicator(),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _selectImage,
                        child: CircleAvatar(
                          radius: 64,
                          backgroundImage: ip,
                        ),
                      ),
                      TextButton(
                        onPressed: _selectImage,
                        child: const Text('프로필 사진 바꾸기'),
                      ),
                      _field('이메일', text: widget.user.email),
                      _field('이름', controller: _username),
                      _field('웹사이트', controller: _website),
                      _field('소개', controller: _state, maxLines: null),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String name, {
    TextEditingController? controller,
    String? text,
    int? maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(name),
          ),
          Expanded(
            child: TextFormField(
              initialValue: text,
              maxLines: maxLines,
              maxLength: maxLines == null ? 500 : null,
              readOnly: controller == null,
              controller: controller,
              decoration: InputDecoration(
                hintText: name,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectImage() async {
    final data = await pickImageData(ImageSource.gallery);
    if (data != null) {
      setState(() {
        _image = data;
      });
    }
  }

  void _done() async {
    setState(() {
      _uploading = true;
    });
    try {
      final username = _username.text.trim();
      final state = _state.text.trim();
      final website = _website.text.trim();
      final value = await _firestore.users.update(
        widget.user,
        photo: _image,
        username: username.isEmpty ? null : username,
        state: state.isEmpty ? null : state,
        website: website.isEmpty ? null : website,
      );
      Navigator.pop(context, value);
    } catch (e) {
      showSnackbar(context, e.toString());
    } finally {
      setState(() {
        _uploading = false;
      });
    }
  }
}
