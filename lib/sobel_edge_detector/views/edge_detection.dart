// ignore_for_file: avoid_print

import 'dart:io';
import 'package:edge_detection/sobel_edge_detector/utils.dart';
import 'package:edge_detection/sobel_edge_detector/widgets.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class EdgeDetector extends StatefulWidget {
  const EdgeDetector({super.key});

  @override
  State<EdgeDetector> createState() => _EdgeDetectorState();
}

class _EdgeDetectorState extends State<EdgeDetector> {
  File? image;
  Uint8List? byte;
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
      content: const Text('Photo Not Selected'),
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
      ScaffoldMessenger.of(context).showMaterialBanner(errorBanner);
    }

    void showSnackbar(String message, int duration) {
      ScaffoldMessenger.of(context)
        // this hides the existing snackbar if there is one
        ..hideCurrentMaterialBanner
        ..showSnackBar(
          SnackBar(
            content: Text(
              message,
            ),
            duration: Duration(seconds: duration),
          ),
        );
    }

    Future handlePickImage(ImageSource source) async {
      imageUrl = '';
      image = null;
      byte = null;
      try {
        final pickedImage = await pickImage(source);
        if (pickedImage == null) {
          showSnackbar('image not selected', 1);
          return;
        }
        var orgImage = File(pickedImage.path);
        String orgImageName = defaultFileName('org');
        orgImage = await changeFileNameOnly(orgImage, orgImageName);

        // saving original image to gallery
        await GallerySaver.saveImage(orgImage.path,
            albumName: 'Edge Detection');

        Uint8List? sobel = await detectEdge(orgImage.path);
        // saving edge image to gallery
        final img = await bytesToTempFile(sobel!, endName: 'edge');
        await GallerySaver.saveImage(img.path, albumName: 'Edge Detection');

        setState(() {
          image = orgImage;
          byte = sobel;
        });
        showSnackbar('image selected', 1);
      } on PlatformException catch (e) {
        print(e.message);
        showErrorBanner();
      } catch (e) {
        print(e);
      }
    }

    // input on submit
    void handleInputSubmit(String url) async {
      inputController.clear();
      final http.Response responseData = await http.get(Uri.parse(url));
      Uint8List urlBytes = responseData.bodyBytes;
      final img = await bytesToTempFile(urlBytes);
      Uint8List? sobel = await detectEdge(img.path);

      setState(() {
        imageUrl = url;
        byte = sobel;
      });
    }

    void clearImage() {
      setState(() {
        imageUrl = '';
        image = null;
        byte = null;
      });
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edge Detection'),
          actions: [
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
                  if (byte != null)
                    Image.memory(
                      byte!,
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
