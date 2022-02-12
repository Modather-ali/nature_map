import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  var file;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          file == null ? const Text("Photo place") : Image.file(file),
          ElevatedButton(
            onPressed: () async {
              await Permission.storage.request();
              try {
                final XFile? _selectedImage = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 100,
                );
                if (_selectedImage != null) {
                  //  Navigator.pop(context);
                  setState(() {
                    file = File(_selectedImage.path);
                  });
                }
              } catch (e) {
                debugPrint("error in choice image: $e");
              }
            },
            child: const Text("Take photo"),
          ),
        ],
      ),
    );
  }
}
