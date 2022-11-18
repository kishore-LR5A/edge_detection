import 'package:flutter/material.dart';

class UrlImage extends StatelessWidget {
  const UrlImage({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Image.network(
        imageUrl,
        width: 300,
        height: 300,
        fit: BoxFit.scaleDown,
        loadingBuilder: (context, child, loadingProgress) =>
            loadingProgress == null
                ? child
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
        errorBuilder: (context, error, stackTrace) =>
            Center(
          child: Column(
            children: const [
              Icon(
                Icons.error,
                color: Colors.red,
                size: 60,
              ),
              Text(
                'Error loading image,Try good URL!',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
  }
}
