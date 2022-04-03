import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickImageData(ImageSource source) async {
  final path = await ImagePicker().pickImage(source: source);
  if (path != null) {
    return path.readAsBytes();
  }
  return null;
}

Future<File?> pickImageFile(ImageSource source) async {
  final path = await ImagePicker().pickImage(source: source);
  if (path != null) {
    return File(path.path);
  }
  return null;
}

void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
