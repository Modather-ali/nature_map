import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nature_map/app_theme.dart';
import 'package:nature_map/frontend/landscapes_management/add_landscape.dart';
import 'package:nature_map/frontend/landscapes_list.dart';
import 'package:nature_map/frontend/start_screen.dart';
import 'package:nature_map/frontend/ui_widgets/snack_bar.dart';
import 'package:nature_map/methods/backend/auth_methods/google_sign_in.dart';
import 'package:nature_map/methods/backend/firebase_database.dart';
import 'package:nature_map/methods/enums.dart';
import 'package:nature_map/methods/landscape.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:dotted_border/dotted_border.dart';

class UserProfile extends StatefulWidget {
  UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  FirebaseDatabase firebaseDatabase = FirebaseDatabase();

  final RoundedLoadingButtonController _roundedLoadingButtonController =
      RoundedLoadingButtonController();

  _getProfileImage() {
    if (FirebaseAuth.instance.currentUser != null) {
      return NetworkImage(
          FirebaseAuth.instance.currentUser!.photoURL.toString());
    } else {
      return const AssetImage("assets/images/profile_avatar.png");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            ListView(
              physics: PageScrollPhysics(),
              children: [
                _userCard(context),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    "Landscapes added by you:",
                    style: appTheme().textTheme.headline4,
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 1.8,
                  child: _addedlandscapesList(),
                ),
              ],
            ),
            _checkCurrentUser(),
          ],
        ),
      ),
    );
  }

  Widget _userCard(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      height: MediaQuery.of(context).orientation == Orientation.landscape
          ? MediaQuery.of(context).size.width / 3.0
          : MediaQuery.of(context).size.height / 3.0,
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(75),
            bottomLeft: Radius.circular(75),
          ),
          border: Border.all(width: 0.5)),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.home_outlined,
                    size: 30,
                  )),
              const SizedBox(
                height: 20,
              ),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 50,
                    child: Hero(
                      tag: "profile avatar",
                      child: CircleAvatar(
                        foregroundImage: _getProfileImage(),
                        radius: 49,
                      ),
                    ),
                  ),
                  // IconButton(

                  //     onPressed: () {},
                  //     icon: Icon(
                  //       Icons.add_a_photo_outlined,
                  //       // color: Colors.grey,
                  //       size: 40,
                  //     ))
                ],
              ),
            ],
          ),
          const SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Text(
                  FirebaseAuth.instance.currentUser != null
                      ? FirebaseAuth.instance.currentUser!.displayName
                          .toString()
                      : "User Name",
                  style: appTheme().textTheme.headline3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                width: MediaQuery.of(context).size.width * 0.6,
                child: Text(
                  FirebaseAuth.instance.currentUser != null
                      ? FirebaseAuth.instance.currentUser!.email.toString()
                      : "User Email",
                  style: appTheme().textTheme.headline3,
                ),
              ),
              Text(
                "Joine Date",
                style: appTheme().textTheme.headline3,
              ),
              const Text("22/1/2022")
            ],
          ),
        ],
      ),
    );
  }

  Widget _checkCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Container(
        alignment: Alignment.center,
        color: Colors.black.withOpacity(0.4),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: RoundedLoadingButton(
            controller: _roundedLoadingButtonController,
            color: appTheme().colorScheme.primary,
            successColor: Colors.green,
            errorColor: Colors.red,
            onPressed: () async {
              try {
                GoogleSigninResults signinResult = await signInWithGoogle();

                if (signinResult == GoogleSigninResults.alreadySignedIn) {
                  _roundedLoadingButtonController.success();
                  setState(() {});
                } else if (signinResult ==
                    GoogleSigninResults.signInCompleted) {
                  _roundedLoadingButtonController.success();
                  await firebaseDatabase.registerNewUser(
                    userEmail:
                        FirebaseAuth.instance.currentUser!.email.toString(),
                    userName: "Modaser",
                  );

                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(snackBar(
                      message: "Registration Successful", color: Colors.green));
                }
              } catch (e) {
                _roundedLoadingButtonController.error();
                ScaffoldMessenger.of(context).showSnackBar(snackBar(
                    message: "Registration failede", color: Colors.red));
                print(GoogleSigninResults.signInNotCompleted);
                print("Error in register the user: $e");
              }
            },
            child: const Text("Register your account first")),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _addedlandscapesList() {
    return ListView(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      children: [
        Wrap(
          direction: Axis.horizontal,
          children: [
            ...[
              for (Landscape landscape in landscapesListItem)
                _landscapeCard(landscape)
            ],
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DottedBorder(
                  radius: const Radius.circular(10),
                  borderType: BorderType.RRect,
                  strokeCap: StrokeCap.round,
                  dashPattern: [10, 10],
                  color: Colors.grey,
                  child: InkWell(
                    onTap: () {
                      print("Adding new landscape...");
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const AddLandscape()));
                    },
                    child: SizedBox(
                      height: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? MediaQuery.of(context).size.width * 0.5
                          : MediaQuery.of(context).size.height * 0.25,
                      width: MediaQuery.of(context).size.width / 3.5,
                      child: const Icon(
                        Icons.add,
                        size: 35,
                        color: Colors.grey,
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _landscapeCard(Landscape landscape) {
    return Card(
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(5),
        height: MediaQuery.of(context).orientation == Orientation.landscape
            ? MediaQuery.of(context).size.width * 0.5
            : MediaQuery.of(context).size.height * 0.25,
        width: MediaQuery.of(context).size.width / 3.3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(
              landscape.landImages[0],
              height:
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? MediaQuery.of(context).size.width * 0.2
                      : MediaQuery.of(context).size.height * 0.1,
              fit: BoxFit.fitWidth,
            ),
            Text(
              landscape.landName,
              style: landscape.landName.length > 12
                  ? appTheme().textTheme.headline3!.copyWith(fontSize: 10)
                  : appTheme().textTheme.headline3!.copyWith(fontSize: 14),
            ),
            Row(
              children: [
                const Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                Text(landscape.favoriteNumber.toString()),
              ],
            ),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("View"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
