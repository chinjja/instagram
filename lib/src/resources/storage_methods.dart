import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart';

class UploadImageResult {
  const UploadImageResult({
    required this.url,
    required this.width,
    required this.height,
  });
  final String url;
  final int width;
  final int height;
}

class StorageMethods {
  final _storage = FirebaseStorage.instance;

  Future<UploadImageResult> uploadImageData(
    Uint8List data,
    String path,
    String name, [
    Interpolation interpolation = Interpolation.average,
    int size = 800,
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
    final url = await uploadData(
      Uint8List.fromList(encodePng(img)),
      path,
      name,
    );
    return UploadImageResult(
      url: url,
      width: img.width,
      height: img.height,
    );
  }

  Future<String> uploadData(Uint8List data, String path, String name) async {
    final ref = _storage.ref(path).child(name);
    final snapshot = await ref.putData(data);
    return await snapshot.ref.getDownloadURL();
  }

  Future<String> uploadFile(File file, String path, String name) async {
    final ref = _storage.ref(path).child(name);
    final snapshot = await ref.putFile(file);
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> delete(String path, String name) async {
    await _storage.ref(path).child(name).delete();
  }
}
