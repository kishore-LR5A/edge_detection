import 'dart:io';

import 'package:edge_detection/sobel_edge_detector/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart';

class ViewImages extends StatefulWidget {
  const ViewImages({
    super.key,
    // required this.files,
  });

  @override
  State<ViewImages> createState() => _ViewImagesState();
}

class _ViewImagesState extends State<ViewImages> {
  List<FileSystemEntity> files = [];
  @override
  void initState() {
    super.initState();
    getFiles();
  }

  void getFiles() async {
    files = await getSobelImages();
    files = files.reversed.toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Images'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          for (var file in files)
            Card(
              child: InkWell(
                onTap: () {
                  GoRouter.of(context).pushNamed(
                    'viewImage',
                    params: {
                      'name': basename(file.path),
                    },
                    queryParams: {
                      'path': file.path,
                    },
                  );
                },
                child: Image.file(
                  File(file.path),
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
