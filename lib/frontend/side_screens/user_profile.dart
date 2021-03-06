import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nature_map/app_theme.dart';
import 'package:nature_map/frontend/landscapes_management/discover_landscape.dart';
import 'package:nature_map/frontend/map_screen.dart';
import 'package:nature_map/frontend/side_screens/edit_profile.dart';
import 'package:nature_map/frontend/ui_widgets/snack_bar.dart';
import 'package:nature_map/methods/backend/auth_methods/google_sign_in.dart';
import 'package:nature_map/methods/backend/firebase_database.dart';
import 'package:nature_map/methods/enums.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:timer_builder/timer_builder.dart';

class UserProfile extends StatefulWidget {
  final String userEmail;
  const UserProfile({Key? key, this.userEmail = ''}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  List<QueryDocumentSnapshot<Object?>> _landsapesDataList = [];
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase();

  final RoundedLoadingButtonController _roundedLoadingButtonController =
      RoundedLoadingButtonController();

  Map<String, dynamic> _userData = {};

  String userEmail = '';

  bool _isCurrentUser = true;

  _getUserData() async {
    _isCurrentUser = widget.userEmail == '';

    userEmail = _isCurrentUser
        ? FirebaseAuth.instance.currentUser!.email.toString()
        : widget.userEmail;

    if (FirebaseAuth.instance.currentUser != null) {
      _userData = await _firebaseDatabase.getUserData(userEmail: userEmail);
      setState(() {});
    }
  }

  _getProfileImage() {
    if (_userData.isNotEmpty) {
      return NetworkImage(_userData["profile_image_link"].toString());
    } else {
      return const AssetImage("assets/images/profile_avatar.png");
    }
  }

  _getLandscapeData() async {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        _landsapesDataList = await _firebaseDatabase.getLandDataForThisUser(
            userEmail: userEmail);

        setState(() {});
      } else {
        _landsapesDataList = [];
      }
    } catch (e) {
      debugPrint("Error while geting data: $e");
    }
  }

  @override
  void initState() {
    _getUserData();
    _getLandscapeData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            ListView(
              physics: const PageScrollPhysics(),
              children: [
                _userCard(context),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    _isCurrentUser
                        ? "landscapes discovered by you:"
                        : "landscapes discovered this user",
                    style: appTheme().textTheme.headline4,
                  ),
                ),
                SizedBox(
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    _isCurrentUser ? Icons.home_outlined : Icons.arrow_back,
                    size: 30,
                  )),
              const SizedBox(
                height: 20,
              ),
              CircleAvatar(
                backgroundColor: Colors.black,
                radius: 50,
                child: InkWell(
                  onTap: () {
                    if (_isCurrentUser) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EditProfile(),
                        ),
                      );
                    }
                  },
                  child: Hero(
                    tag: "profile avatar",
                    child: CircleAvatar(
                      foregroundImage: _getProfileImage(),
                      radius: 48,
                    ),
                  ),
                ),
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
                width: MediaQuery.of(context).size.width * 0.5,
                child: TimerBuilder.periodic(
                  const Duration(seconds: 1),
                  builder: (context) {
                    _getUserData();
                    return Text(
                      _userData.isNotEmpty
                          ? _userData["user_name"].toString()
                          : "User Name",
                      style: appTheme().textTheme.headline3,
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                width: MediaQuery.of(context).size.width * 0.6,
                child: _userData.isNotEmpty
                    ? _userData["show_email"]
                        ? Text(
                            userEmail,
                            style: appTheme().textTheme.headline3,
                          )
                        : const SizedBox()
                    : Text(
                        "User Email",
                        style: appTheme().textTheme.headline3,
                      ),
              ),
              Text(
                "Joine Date",
                style: appTheme().textTheme.headline3,
              ),
              Text(
                _userData.isNotEmpty
                    ? "${_userData["creation_date"]}"
                    : 'dd/mm/yyyy',
                style: appTheme()
                    .textTheme
                    .headline4!
                    .copyWith(color: Colors.black),
              )
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
                  await _firebaseDatabase.registerNewUser(
                    imageUrl:
                        FirebaseAuth.instance.currentUser!.photoURL.toString(),
                    userEmail:
                        FirebaseAuth.instance.currentUser!.email.toString(),
                    userName: FirebaseAuth.instance.currentUser!.displayName
                        .toString(),
                  );
                  await _getUserData();
                  _getLandscapeData();
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
      physics: const BouncingScrollPhysics(),
      children: [
        Wrap(
          direction: Axis.horizontal,
          children: [
            ...[
              for (var landscape in _landsapesDataList)
                _landscapeCard(landscape)
            ],
            _isCurrentUser
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DottedBorder(
                      radius: const Radius.circular(10),
                      borderType: BorderType.RRect,
                      strokeCap: StrokeCap.round,
                      dashPattern: const [10, 10],
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
                      ),
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ],
    );
  }

  Widget _landscapeCard(QueryDocumentSnapshot landscape) {
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
            SizedBox(
              height:
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? MediaQuery.of(context).size.width * 0.2
                      : MediaQuery.of(context).size.height * 0.1,
              child: Image.network(
                landscape["land_images"][0],
                fit: BoxFit.fitWidth,
              ),
            ),
            Text(landscape["land_name"],
                style: appTheme().textTheme.headline3!.copyWith(fontSize: 11)),
            Row(
              children: [
                const Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  landscape["fans"].length.toString(),
                  style: appTheme()
                      .textTheme
                      .headline4!
                      .copyWith(color: Colors.black),
                ),
              ],
            ),
            OpenContainer(
                transitionDuration: const Duration(milliseconds: 500),
                closedColor: const Color(0xFF52b788),
                closedBuilder: (context, closedBuilder) {
                  return Container(
                    alignment: Alignment.center,
                    height: 30,
                    width: double.maxFinite,
                    child: Text(
                      "View",
                      style: appTheme().textTheme.headline2,
                    ),
                  );
                },
                openBuilder: (context, openBuilder) {
                  return MapScreen(landscapeData: landscape);
                })
          ],
        ),
      ),
    );
  }
}
