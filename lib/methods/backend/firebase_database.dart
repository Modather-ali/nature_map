import 'dart:io';
import 'dart:math';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseDatabase {
  String usersCollectionPath = "Users";
  String landsCollectionPath = "Landscapes";

  registerNewUser({
    required String userEmail,
    required String userName,
  }) async {
    final String currentDate =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection(usersCollectionPath)
        .doc(userEmail);
    try {
      if (documentReference.id != userEmail) {
        await documentReference.set({
          "user_name": userName,
          "profile_image_link": '-',
          "background_image_link": '-',
          "creation_date": currentDate,
          "favorite_landscapes": [],
        });
      } else {
        debugPrint("this user alredy registred");
      }
    } catch (e) {
      debugPrint("Error in register new user: $e");
    }
  }

  Future<List<String>> loadImagesToFireStorage(
      {required List<File> landImagesList}) async {
    List<String> landImagesLink = [];

    try {
      for (File image in landImagesList) {
        String imageName = basename(image.path);
        int random = Random().nextInt(10000);
        Reference storageRef =
            FirebaseStorage.instance.ref('images').child('$random$imageName');
        await storageRef.putFile(image);
        String imageUrl = await storageRef.getDownloadURL();
        landImagesLink.add(imageUrl);
      }
    } catch (e) {
      print('Error in load image: $e');
    }

    return landImagesLink;
  }

  addNewLandToFirebase({
    required String userEmail,
    required String landName,
    required List<String> tags,
    required List<String> landImagesLink,
    required double lat,
    required double long,
  }) {
    int randomInt = Random().nextInt(1000);
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection(landsCollectionPath);
    DocumentReference documentReference =
        collectionReference.doc(userEmail + "-$randomInt");
    try {
      documentReference.set({
        "added_by": userEmail,
        "land_name": landName,
        "lat": lat,
        "long": long,
        "land_images": landImagesLink,
        "tages": tags,
        "fans": [], // this will contain all users ids that liked this landscape
      });
    } catch (e) {
      debugPrint("Error in adding new land to firbs: $e");
    }
  }

  Future<List<QueryDocumentSnapshot<Object?>>> getLandscapesData(
      {required String landTag}) async {
    try {
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection(landsCollectionPath);
      QuerySnapshot<Object?> querySnapshotn = await collectionReference
          .where("tages", arrayContains: landTag)
          .get();
      return querySnapshotn.docs;
    } catch (e) {
      debugPrint("error when get data from firebase: $e");
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot<Object?>>> getLandDataForThisUser(
      {required String userEmail}) async {
    try {
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection(landsCollectionPath);
      QuerySnapshot<Object?> querySnapshotn = await collectionReference
          .where("added by", isEqualTo: userEmail)
          .get();
      return querySnapshotn.docs;
    } catch (e) {
      debugPrint("error when get data from firebase: $e");
      return [];
    }
  }

  Future getUserData({required String userEmail}) async {
    CollectionReference userReference =
        FirebaseFirestore.instance.collection(usersCollectionPath);

    DocumentSnapshot<Object?> userData =
        await userReference.doc(userEmail).get();

    return userData.data();
  }

  Future updateUserFavoriteLandscapes(
      {required String userEmail,
      required QueryDocumentSnapshot landscape}) async {
    try {
      WriteBatch writeBatch = FirebaseFirestore.instance.batch();

      DocumentReference userReference = FirebaseFirestore.instance
          .collection(usersCollectionPath)
          .doc(userEmail);

      DocumentSnapshot userData = await userReference.get();

      List favoriteLandscapes = userData["favorite_landscapes"];

      if (favoriteLandscapes.contains(landscape.id)) {
        favoriteLandscapes.remove(landscape.id);
      } else {
        favoriteLandscapes.add(landscape.id);
      }

      userReference.update({
        "favorite_landscapes": favoriteLandscapes,
      });

      favoriteLandscapes.clear();
      debugPrint("Update succeeded");
    } catch (e) {
      debugPrint("error while update users  favorite landscape: $e");
    }
  }

  Future updateLandscapesFans(
      {required String userEmail,
      required QueryDocumentSnapshot landscape}) async {
    try {
      DocumentReference landscapeReference = FirebaseFirestore.instance
          .collection(landsCollectionPath)
          .doc(landscape.id);

      DocumentSnapshot landscapeData = await landscapeReference.get();

      List favoriteLandscapes = landscapeData["fans"];

      if (favoriteLandscapes.contains(userEmail)) {
        favoriteLandscapes.remove(userEmail);
      } else {
        favoriteLandscapes.add(userEmail);
      }
      landscapeReference.update({
        "fans": favoriteLandscapes,
      });
      favoriteLandscapes.clear();
      debugPrint("Update succeeded");
    } catch (e) {
      debugPrint("error while update landscape fans: $e");
    }
  }
}
