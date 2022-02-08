import 'package:flutter/material.dart';
import 'package:nature_map/methods/enums.dart';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatelessWidget {
  final ImageType imageType;
  final dynamic imagePath;
  const ImageView({Key? key, required this.imageType, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoView(
        imageProvider: myImageProvider(),
        enableRotation: true,
        enablePanAlways: true,
      ),
    );
  }

  ImageProvider<Object>? myImageProvider() {
    switch (imageType) {
      case ImageType.fileImage:
        return FileImage(imagePath);
      default:
        return NetworkImage(imagePath);
    }
  }
}
