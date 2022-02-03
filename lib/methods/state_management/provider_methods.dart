import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:nature_map/methods/backend/firebase_database.dart';

class LandscapeProvider extends ChangeNotifier {
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase();
  bool isLocate = false;

  double lat = 0;
  double long = 0;

  String landName = '';

  List<File> landImagesList = [];
  List<String> landTags = [];

  Future addNewLandToFirebase() async {
    List<String> _landImagesLink = await _firebaseDatabase
        .loadImagesToFireStorage(landImagesList: landImagesList);

    await _firebaseDatabase.addNewLandToFirebase(
        userEmail: FirebaseAuth.instance.currentUser!.email.toString(),
        landName: landName,
        tags: landTags,
        landImagesLink: _landImagesLink,
        lat: lat,
        long: long);
    notifyListeners();
  }
}
