import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/opencv_4.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

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

Future<File> bytesToTempFile(Uint8List bytes, {String endName = ''}) async {
  final tempDir = await getTemporaryDirectory();
  final String fileName = defaultFileName(endName);
  File file = await File('${tempDir.path}/$fileName').create();
  file.writeAsBytesSync(bytes);
  return file;
}

String defaultFileName(String endName) {
  final String fileName =
      'image_${DateTime.now().millisecondsSinceEpoch}_$endName.jpg';
  return fileName;
}

// merge 2 images to one image
Future<File> mergeImages(String imagePath1, String imagePath2) async {
  final tempDir = await getTemporaryDirectory();
  final String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
  File file = await File('${tempDir.path}/$fileName').create();
  // merge 2 images
  final image1 = decodeImage(File(imagePath1).readAsBytesSync())!;
  final image2 = decodeImage(File(imagePath2).readAsBytesSync())!;
  final mergedImage =
      Image(image1.width + image2.width, max(image1.height, image2.height));
  copyInto(mergedImage, image1, blend: false);
  copyInto(mergedImage, image2, dstX: image1.width, blend: false);
  // write image data to a file
  file.writeAsBytesSync(encodeJpg(mergedImage));
  return file;
}

Future<File> changeFileNameOnly(File file, String newFileName) {
  var path = file.path;
  var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
  var newPath = path.substring(0, lastSeparator + 1) + newFileName;
  return file.rename(newPath);
}
