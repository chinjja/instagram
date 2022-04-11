import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/src/models/user.dart';

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

NetworkImage? networkImage(String? url) {
  return url == null ? null : NetworkImage(url);
}

Map<String, dynamic> serverTimestamp(
  Map<String, dynamic> json, {
  String key = 'datePublished',
}) {
  json[key] = FieldValue.serverTimestamp();
  return json;
}

User? opposite(List<User>? list, User user) {
  if (list == null) return null;
  if (list.length < 2) return null;
  return list.firstWhere((element) => element.uid != user.uid);
}

T? oppositeItem<T>(List<T>? list, T uid) {
  if (list == null) return null;
  if (list.length < 2) return null;
  return list.firstWhere((element) => element != uid);
}
