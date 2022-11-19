import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class MergeImages extends StatelessWidget {
  const MergeImages({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merge Images'),
      ),
      body: const Center(
        child: Text('Merge Images'),
      ),
    );
  }
}
