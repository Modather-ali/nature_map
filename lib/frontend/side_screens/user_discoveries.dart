import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nature_map/app_theme.dart';
import 'package:nature_map/frontend/landscapes_management/discover_landscape.dart';
import 'package:nature_map/frontend/map_screen.dart';
import 'package:nature_map/frontend/ui_widgets/snack_bar.dart';
import 'package:nature_map/methods/backend/auth_methods/google_sign_in.dart';
import 'package:nature_map/methods/backend/firebase_database.dart';
import 'package:nature_map/methods/enums.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class UserDiscoveries extends StatefulWidget {
  const UserDiscoveries({Key? key}) : super(key: key);

  @override
  _UserDiscoveriesState createState() => _UserDiscoveriesState();
}

class _UserDiscoveriesState extends State<UserDiscoveries> {
  List<QueryDocumentSnapshot<Object?>> _landsapesDataList = [];
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase();
  final RoundedLoadingButtonController _roundedLoadingButtonController =
      RoundedLoadingButtonController();
  _getLandscapeData() async {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        _landsapesDataList = await _firebaseDatabase.getLandDataForThisUser(
            userEmail: FirebaseAuth.instance.currentUser!.email.toString());
        debugPrint(_landsapesDataList.toString());
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
    _getLandscapeData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Discoveries'),
      ),
      body: Stack(
        children: [
          GridView.builder(
            itemCount: _landsapesDataList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            itemBuilder: (context, index) {
              return _landscapeCard(_landsapesDataList[index]);
            },
          ),
          _checkCurrentUser(),
        ],
      ),
      floatingActionButton: FirebaseAuth.instance.currentUser == null
          ? SizedBox()
          : Padding(
              padding: const EdgeInsets.all(15),
              child: OpenContainer(
                  closedElevation: 12,
                  transitionDuration: const Duration(milliseconds: 500),
                  closedBuilder: (context, closedBuilder) {
                    return const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(
                        Icons.add,
                        size: 25,
                      ),
                    );
                  },
                  openBuilder: (context, openBuilder) {
                    return const AddLandscape();
                  }),
            ),
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
              children: const [
                Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                Text('0'),
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
              },
            )
          ],
        ),
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
              } else if (signinResult == GoogleSigninResults.signInCompleted) {
                _roundedLoadingButtonController.success();
                await _firebaseDatabase.registerNewUser(
                  userEmail:
                      FirebaseAuth.instance.currentUser!.email.toString(),
                  userName:
                      FirebaseAuth.instance.currentUser!.displayName.toString(),
                );
                _getLandscapeData();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(snackBar(
                    message: "Registration Successful", color: Colors.green));
              }
            } catch (e) {
              _roundedLoadingButtonController.error();
              ScaffoldMessenger.of(context).showSnackBar(
                  snackBar(message: "Registration failede", color: Colors.red));
              print(GoogleSigninResults.signInNotCompleted);
              print("Error in register the user: $e");
            }
          },
          child: const Text("Register your account first"),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
