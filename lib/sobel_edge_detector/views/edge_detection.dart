import 'dart:io';
import 'package:edge_detection/constants.dart';
import 'package:edge_detection/sobel_edge_detector/utils.dart';
import 'package:edge_detection/sobel_edge_detector/widgets.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class EdgeDetector extends StatefulWidget {
  const EdgeDetector({super.key});

  @override
  State<EdgeDetector> createState() => _EdgeDetectorState();
}

class _EdgeDetectorState extends State<EdgeDetector> {
  File? image;
  File? edgeImage;
  File? mergedImage;
  String imageUrl = '';

  final inputController = TextEditingController();

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errorBanner = MaterialBanner(
      content: const Text('Platform Exception'),
      actions: [
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          },
          child: const Text('Dismiss'),
        ),
      ],
      // backgroundColor: Colors.indigo,
    );
    void showErrorBanner() {
      ScaffoldMessenger.of(context)
        ..hideCurrentMaterialBanner()
        ..showMaterialBanner(errorBanner);
    }

    void showSnackbar(String message, int duration) {
      ScaffoldMessenger.of(context)
        // this hides the existing snackbar if there is one
        ..hideCurrentMaterialBanner()
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              message,
            ),
            duration: Duration(seconds: duration),
          ),
        );
    }

    // enable save individual flag to save org and edge images individually to EdgeDetection folder
    Future<Map<String, File>> handleImages(
      File orgImage, {
      bool saveIndividual = false,
    }) async {
      final Map<String, File> result = {};

      String orgImageName = defaultFileName('org');
      orgImage = await changeFileNameOnly(orgImage, orgImageName);

      Uint8List? sobel = await detectEdge(orgImage.path);
      final edgeImage = await bytesToTempFile(sobel!, endName: 'edge');
      if (saveIndividual) {
        await GallerySaver.saveImage(orgImage.path,
            albumName: 'Edge Detection');
        await GallerySaver.saveImage(edgeImage.path,
            albumName: 'Edge Detection');
      }
      // merging the original image and the edge image
      var mergeImage = await mergeImages(orgImage.path, edgeImage.path);
      // await GallerySaver.saveImage(mergeImage.path,
      //     albumName: 'Edge Detection');
      await saveImageToAppDocDir(kSobelImagesDir, mergeImage);

      result['orgImage'] = orgImage;
      result['edgeImage'] = edgeImage;
      result['mergedImage'] = mergeImage;
      return result;
    }

    Future handlePickImage(ImageSource source) async {
      imageUrl = '';
      image = null;
      mergedImage = null;
      try {
        final pickedImage = await pickImage(source);
        if (pickedImage == null) {
          showSnackbar('image not selected', 1);
          return;
        }
        var orgImage = File(pickedImage.path);
        Map<String, File> images = await handleImages(orgImage);
        setState(
          () {
            image = images['orgImage'];
            edgeImage = images['edgeImage'];
            mergedImage = images['mergedImage'];
          },
        );
        showSnackbar('image selected', 1);
      } on PlatformException catch (_) {
        showErrorBanner();
      }
    }

    // input on submit
    void handleInputSubmit(String url) async {
      inputController.clear();
      final http.Response responseData = await http.get(Uri.parse(url));
      Uint8List urlBytes = responseData.bodyBytes;
      var orgImage = await bytesToTempFile(urlBytes);

      Map<String, File> images = await handleImages(orgImage);
      setState(
        () {
          imageUrl = url;
          edgeImage = images['edgeImage'];
          mergedImage = images['mergedImage'];
        },
      );
    }

    void clearImage() {
      setState(
        () {
          imageUrl = '';
          image = null;
          mergedImage = null;
          inputController.clear();
        },
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edge Detection'),
          actions: [
            IconButton(
              icon: const Icon(Icons.image_rounded),
              onPressed: () {
                context.pushNamed(
                  'viewImages',
                );
              },
            ),
            IconButton(
              onPressed: () {
                clearImage();
              },
              icon: const Icon(
                Icons.refresh,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              image == null
                  ? imageUrl == ''
                      ? const PlaceholderImage()
                      : UrlImage(imageUrl: imageUrl)
                  : Image.file(
                      image!,
                      fit: BoxFit.scaleDown,
                      // height: 300,
                      // width: 300,
                    ),
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  if (imageUrl != '')
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'Image URL: $imageUrl',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: clearImage,
                          child: const Text('Clear Image URL'),
                        ),
                      ],
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await handlePickImage(ImageSource.gallery);
                        },
                        child: const Text('Upload Image'),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await handlePickImage(ImageSource.camera);
                        },
                        child: const Text('Take a Picture'),
                      ),
                    ],
                  ),
                  if (image != null)
                    ElevatedButton(
                      onPressed: clearImage,
                      child: const Text(
                        'clear image',
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter a image url here',
                      ),
                      controller: inputController,
                      // onChanged: (text) {
                      //   handleInputChange(text);
                      // },
                      onSubmitted: (value) => handleInputSubmit(value),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (mergedImage != null)
                    Image.file(
                      mergedImage!,
                      fit: BoxFit.contain,
                      // height: 300,
                      // width: 300,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
