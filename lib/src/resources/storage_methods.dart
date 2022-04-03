import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart';

class StorageMethods {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadImageData(
    Uint8List data,
    String path,
    String name, [
    Interpolation interpolation = Interpolation.linear,
    int size = 500,
  ]) async {
    var img = decodeImage(data)!;
    if (img.width > size * 1.2 && img.width > img.height) {
      img = copyResize(
        img,
        width: size,
        height: (img.height * (size / img.width)).toInt(),
        interpolation: interpolation,
      );
    } else if (img.height > size * 1.2) {
      img = copyResize(
        img,
        width: (img.width * (size / img.height)).toInt(),
        height: size,
        interpolation: interpolation,
      );
    }
    return uploadData(
      Uint8List.fromList(encodeJpg(img, quality: 75)),
      path,
      name,
    );
  }

  Future<String> uploadData(Uint8List data, String path, String name) async {
    final ref = _storage.ref().child(path).child(name);
    final snapshot = await ref.putData(data);
    return await snapshot.ref.getDownloadURL();
  }

  Future<String> uploadFile(File file, String path, String name) async {
    final ref = _storage.ref().child(path).child(name);
    final snapshot = await ref.putFile(file);
    return await snapshot.ref.getDownloadURL();
  }
}
