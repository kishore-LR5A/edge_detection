import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';

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
    // String fileName = basename(path);
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Center(
        child: Image.file(
          File(path),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
