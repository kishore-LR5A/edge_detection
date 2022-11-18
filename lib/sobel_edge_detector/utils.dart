import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/opencv_4.dart';
import 'package:path_provider/path_provider.dart';

// Function to pick an image either from the gallery or the camera
Future pickImage(ImageSource source) async {
  final picker = ImagePicker();
  // pick an image based on the provided source (camera or gallery)
  // source options : ImageSource.camera or ImageSource.gallery
  final pickedImg = await picker.pickImage(source: source);
  return pickedImg;
}

// Function to return the final image with detected edges using sober edge detection with opencv
Future<Uint8List?> detectEdge(String imagePath) async {
  // create a temporary file to store output image
  final tempDir = await getTemporaryDirectory();
  File file = await File('${tempDir.path}/image.png').create();
  // bgr to gray converter
  Uint8List? cvtColor = await Cv2.cvtColor(
    pathFrom: CVPathFrom.GALLERY_CAMERA,
    pathString: imagePath,
    outputType: Cv2.COLOR_BGR2GRAY,
  );
  // dump the image in bytes to the temporary file
  file.writeAsBytesSync(cvtColor!);
  // gaussian blur
  Uint8List? gaussBlur = await Cv2.gaussianBlur(
    pathFrom: CVPathFrom.GALLERY_CAMERA,
    pathString: file.path,
    kernelSize: [3, 3],
    sigmaX: 1,
  );
  // dump the image in bytes to the temporary file
  file.writeAsBytesSync(gaussBlur!);
  // sobel edge detection
  Uint8List? sobel = await Cv2.sobel(
    pathFrom: CVPathFrom.GALLERY_CAMERA,
    pathString: file.path,
    depth: -1,
    dx: 0,
    dy: 1,
  );
  return sobel;
}

File bytesToFile(Uint8List bytes) {
  return File.fromRawPath(bytes);
}

Future<File> bytesToTempFile(Uint8List bytes) async {
  final tempDir = await getTemporaryDirectory();
  File file = await File('${tempDir.path}/image.png').create();
  file.writeAsBytesSync(bytes);
  return file;
}
