import 'dart:io';
import 'package:flutter/widgets.dart';

/// [path] is a local device path until a photo finishes uploading, then a
/// remote URL — render whichever one is currently stored.
ImageProvider? photoImageProvider(String? path) {
  if (path == null || path.isEmpty) return null;
  return path.startsWith('http') ? NetworkImage(path) : FileImage(File(path));
}
