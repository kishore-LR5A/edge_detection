import 'dart:io';

import 'package:edge_detection/sobel_edge_detector/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart';

class ViewImages extends StatefulWidget {
  const ViewImages({
    super.key,
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
        title: const Text('Images'),
      ),
      body: files.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No Images Found'),
                  ElevatedButton(
                    onPressed: () {
                      GoRouter.of(context).pop();
                    },
                    child: const Text('Go to Edge Detector'),
                  )
                ],
              ),
            )
          : GridView.count(
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Image.file(
                            File(file.path),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
