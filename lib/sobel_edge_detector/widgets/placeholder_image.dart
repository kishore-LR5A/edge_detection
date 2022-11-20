import 'package:flutter/material.dart';

class PlaceholderImage extends StatelessWidget {
  const PlaceholderImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          Image.asset(
            'assets/images/splash_background.png',
            fit: BoxFit.cover,
            width: 250,
            height: 250,
          ),
          const Positioned(
            bottom: 5,
            left: 40,
            child: Text(
              'No Image Selected',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
                backgroundColor: Colors.black,
              ),
            ),
          ),
        ],
      );
  }
}

