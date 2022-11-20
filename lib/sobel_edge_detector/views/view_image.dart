import 'dart:io';

import 'package:flutter/material.dart';

class ViewImage extends StatelessWidget {
  const ViewImage({
    Key? key,
    required this.path,
    required this.name,
  }) : super(key: key);
  final String name;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Center(
        child: InteractiveViewer(
          clipBehavior: Clip.none,
          child: AspectRatio(
            aspectRatio: 2 / 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                File(path),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
