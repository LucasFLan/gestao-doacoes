import 'package:flutter/material.dart';

Widget buildPickedImage(String path) {
  if (path.startsWith('http')) {
    return Image.network(path, fit: BoxFit.cover, width: double.infinity);
  }
  return Container(
    color: Colors.grey.shade300,
    child: const Center(
      child: Icon(Icons.image_not_supported, size: 48),
    ),
  );
}
