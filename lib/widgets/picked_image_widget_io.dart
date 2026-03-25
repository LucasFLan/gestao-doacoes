import 'dart:io';

import 'package:flutter/material.dart';

Widget buildPickedImage(String path) {
  if (path.startsWith('http')) {
    return Image.network(path, fit: BoxFit.cover, width: double.infinity);
  }
  return Image.file(
    File(path),
    fit: BoxFit.cover,
    width: double.infinity,
  );
}
