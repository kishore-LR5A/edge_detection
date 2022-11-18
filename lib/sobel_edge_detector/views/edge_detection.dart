// ignore_for_file: avoid_print

import 'dart:io';
import 'package:edge_detection/sobel_edge_detector/utils.dart';
import 'package:edge_detection/sobel_edge_detector/widgets.dart';
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

    Future<File> saveImagePermanently(String imagePath) async {
      final directory = await getApplicationDocumentsDirectory();
      print('Application directory path is ${directory.path}');
      final name = basename(imagePath);
      print('Image name is $name');
      final image = File('${directory.path}/$name');
      print('Image path is ${image.path}');
      return File(imagePath).copy(image.path);
    }

    Future handlePickImage(ImageSource source) async {
      imageUrl = '';
      image = null;
      byte = null;
      try {
        final selectedImage = await pickImage(source);
        if (selectedImage == null) {
          // showErrorBanner();
          showSnackbar('image not selected', 1);
          return;
        }
        // final tempImage = File(selectedImage.path);
        final permImage = await saveImagePermanently(selectedImage.path);
        Uint8List? sobel = await detectEdge(permImage.path);

        setState(() {
          image = permImage;
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

    void clearImageURl() {
      setState(() {
        imageUrl = '';
        image = null;
        byte = null;
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 5,
              ),
              const Text(
                'Plotline Edge Detection',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              image == null
                  ? imageUrl == ''
                      ? const PlaceholderImage()
                      : UrlImage(imageUrl: imageUrl)
                  : ClipOval(
                      child: Image.file(
                        image!,
                        fit: BoxFit.cover,
                        height: 250,
                        width: 250,
                      ),
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
                          onPressed: clearImageURl,
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
                      fit: BoxFit.scaleDown,
                      height: 300,
                      width: 300,
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
