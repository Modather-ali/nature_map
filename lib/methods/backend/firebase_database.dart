import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDatabase {
  String collectionPath = "Users";

  registerNewUser({
    required String userEmail,
    required String userName,
  }) async {
    final String currentDate =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection(collectionPath).doc(userEmail);
    try {
      if (documentReference.id.isNotEmpty) {
        await documentReference.set({
          "user_name": userName,
          "profile_image_link": '-',
          "background_image_link": '-',
          "creation_date": currentDate,
          "favorite_landscapes": '-',
          "added_landscapes": '-',
        });
      } else if (documentReference.id.isEmpty) {
        print("this user alredy registred");
      }
    } catch (e) {
      print("Error in register new user: $e");
    }
  }
}
