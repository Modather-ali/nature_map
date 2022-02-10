import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseDatabase {
  String usersCollectionPath = "Users";
  String landsCollectionPath = "Landscapes";

  Future<bool> isUserRegistred() async {
    List docsId = [];

    QuerySnapshot result =
        await FirebaseFirestore.instance.collection("Users").get();

    for (var queryDocumentSnapshot in result.docs) {
      docsId.add(queryDocumentSnapshot.id);
    }

    debugPrint('$docsId');

    return docsId.contains(FirebaseAuth.instance.currentUser!.email);
  }

  registerNewUser({
    required String userEmail,
    required String userName,
    required String imageUrl,
  }) async {
    final String currentDate =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";

    DocumentReference documentReference = FirebaseFirestore.instance
        .collection(usersCollectionPath)
        .doc(userEmail);

    try {
      if (await isUserRegistred()) {
        debugPrint("this user alredy registred");
      } else {
        await documentReference.set({
          "user_name": userName,
          "profile_image_link": imageUrl,
          "creation_date": currentDate,
          "about_user": "",
          "favorite_landscapes": [],
          "show_email": true
        });
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
      {required List landTag}) async {
    try {
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection(landsCollectionPath);
      QuerySnapshot<Object?> querySnapshotn = await collectionReference
          .where("tages", arrayContainsAny: landTag)
          .get();
      return querySnapshotn.docs;
    } catch (e) {
      debugPrint("error when get data from firebase: $e");
      return [];
    }
  }

  Future<QueryDocumentSnapshot<Object?>?> getLandscapesDataByName({
    required String landscapeName,
  }) async {
    try {
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection(landsCollectionPath);
      QuerySnapshot<Object?> querySnapshotn = await collectionReference
          .where("land_name", isEqualTo: landscapeName)
          .get();
      return querySnapshotn.docs.first;
    } catch (e) {
      debugPrint("error when get data from firebase: $e");
      return null;
    }
  }

  Future getUserData({required String userEmail}) async {
    CollectionReference userReference =
        FirebaseFirestore.instance.collection(usersCollectionPath);

    DocumentSnapshot<Object?> userData =
        await userReference.doc(userEmail).get();

    return userData.data();
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

  Future<List<QueryDocumentSnapshot<Object?>>> getUserFavoritesLandscapes(
      {required String userEmail}) async {
    try {
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection(landsCollectionPath);
      QuerySnapshot<Object?> querySnapshotn = await collectionReference
          .where("fans", arrayContains: userEmail)
          .get();
      return querySnapshotn.docs;
    } catch (e) {
      debugPrint("error when get data from firebase: $e");
      return [];
    }
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

  Future<String> saveFileAndGetLink(
    String filePath,
  ) async {
    File file = File(filePath);
    String fileName = basename(filePath);

    Reference firestore =
        FirebaseStorage.instance.ref("users_profile").child(fileName);

    await firestore.putFile(file);

    String imageUrl = await firestore.getDownloadURL();

    return imageUrl;
  }

  Future<bool> updateUserProfile({
    required String imagePath,
    required String userEmail,
    required String userName,
    required String aboutUser,
    required bool showEmail,
  }) async {
    try {
      final DocumentReference<Map<String, dynamic>> currentUserDocument =
          FirebaseFirestore.instance
              .collection(usersCollectionPath)
              .doc(userEmail);

      if (imagePath == '') {
        await currentUserDocument.update({
          "user_name": userName,
          'about_user': aboutUser,
          "show_email": showEmail,
        });
        debugPrint("Profile update success without profile image");
      } else {
        String imageLink = await saveFileAndGetLink(
          imagePath,
        );
        await currentUserDocument.update({
          'profile_image_link': imageLink,
          "user_name": userName,
          'about_user': aboutUser,
          "show_email": showEmail,
        });
        debugPrint("Profile update success");
      }
      return true;
    } catch (e) {
      print('Error in profile update : $e');
      debugPrint("Profile failed");
      return false;
    }
  }
}
