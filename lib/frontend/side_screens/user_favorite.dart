import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:nature_map/app_theme.dart';
import 'package:nature_map/frontend/map_screen.dart';
import 'package:nature_map/frontend/ui_widgets/snack_bar.dart';
import 'package:nature_map/methods/backend/firebase_database.dart';
import 'package:nature_map/methods/state_management/provider_methods.dart';
import 'package:photo_view/photo_view.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';

class UserFavorite extends StatefulWidget {
  const UserFavorite({Key? key}) : super(key: key);

  @override
  _UserFavoriteState createState() => _UserFavoriteState();
}

class _UserFavoriteState extends State<UserFavorite> {
  List<bool> _isLoading = [];
  double _distanceBetween = 0.0;
  late Map<String, dynamic> _userData = {};

  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase();

  List<QueryDocumentSnapshot<Object?>> _favoritesLandscapes = [];

  var _position;
  User? user = FirebaseAuth.instance.currentUser;
  _getFavoriteLandscapeData() async {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        _favoritesLandscapes = await _firebaseDatabase.getLandDataForThisUser(
            userEmail: FirebaseAuth.instance.currentUser!.email.toString());

        for (var land in _favoritesLandscapes) {
          _isLoading.add(false);
        }

        if (user != null) {
          _userData = await _firebaseDatabase.getUserData(
              userEmail: user!.email.toString());
        }
        setState(() {});
      } else {
        _favoritesLandscapes = [];
      }
    } catch (e) {
      debugPrint("Error while geting data: $e");
    }
  }

  _getCurrentPosition() async {
    bool _serviceEnabled;
    LocationPermission _permission;

    //  Test if location services are enabled.
    _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar(
          message: "Please active location service", color: Colors.red));
    }

    _permission = await Geolocator.checkPermission();
    if (_permission == LocationPermission.denied) {
      _permission = await Geolocator.requestPermission();
      if (_permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar(
            message: "Location permissions are denied", color: Colors.red));
        return Future.error('Location permissions are denied');
      }
    }

    if (_permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      ScaffoldMessenger.of(context).showSnackBar(snackBar(
          message:
              "Location permissions are permanently denied, we cannot request permissions.",
          color: Colors.red));
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    _position = await Geolocator.getCurrentPosition();
    setState(() {});
  }

  @override
  void initState() {
    _getFavoriteLandscapeData();
    _getCurrentPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Favorite"),
      ),
      body: _position == null
          ? Center(
              child: Container(
                alignment: Alignment.center,
                height: 100,
                width: 100,
                child: const LoadingIndicator(
                  indicatorType: Indicator.ballRotateChase,
                  colors: kDefaultRainbowColors,
                  strokeWidth: 3.0,
                ),
              ),
            )
          : ListView.builder(
              itemCount: _favoritesLandscapes.length,
              itemBuilder: (context, index) {
                return _landscapeCard(
                  index: index,
                  landscapeData: _favoritesLandscapes[index],
                );
              },
            ),
    );
  }

  Widget _landscapeCard({
    required int index,
    required QueryDocumentSnapshot<Object?> landscapeData,
  }) {
    _distanceBetween = Geolocator.distanceBetween(_position.latitude,
        _position.longitude, landscapeData["lat"], landscapeData["long"]);

    return Card(
      margin: const EdgeInsets.all(10.0),
      elevation: 16,
      child: SizedBox(
        height: MediaQuery.of(context).orientation == Orientation.landscape
            ? MediaQuery.of(context).size.height * 0.7
            : MediaQuery.of(context).size.height / 3,
        child: Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 3, top: 2, right: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _favoriteButton(
                      landscapeData: landscapeData,
                      index: index,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? MediaQuery.of(context).size.height * 0.4
                          : MediaQuery.of(context).size.height / 7,
                      width: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? MediaQuery.of(context).size.width * 0.5
                          : MediaQuery.of(context).size.width / 4,
                      child: Image.network(
                        landscapeData["land_images"][0],
                        fit: BoxFit.fill,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    OpenContainer(
                        transitionDuration: const Duration(milliseconds: 650),
                        closedElevation: 8,
                        transitionType: ContainerTransitionType.fade,
                        closedBuilder: (context, closedBuilder) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "View",
                              style: appTheme().textTheme.headline3,
                            ),
                          );
                        },
                        openBuilder: (context, openBuilder) {
                          return MapScreen(
                            landscapeData: landscapeData,
                          );
                        })
                  ],
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.65,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    landscapeData["land_name"].toString(),
                    style: appTheme().textTheme.headline3,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "country / area",
                    style: appTheme().textTheme.headline4,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "$_distanceBetween".split(".")[0] +
                        "." +
                        "$_distanceBetween".split(".")[0][0] +
                        " meters\nfar away",
                    style: appTheme().textTheme.headline4,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _tagsCard(landscapeData["tages"]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagsCard(List tags) {
    return Wrap(
      children: [
        ...[for (String tag in tags) _tagCard(tag: tag)]
      ],
    );
  }

  Widget _tagCard({required String tag}) {
    Color cardColor;
    switch (tag) {
      case "Mountain":
        cardColor = const Color(0xFF7f4f24);
        break;
      case "Sea":
        cardColor = const Color(0xFF014f86);
        break;
      case "Desert":
        cardColor = const Color(0xFFffba08);
        break;
      case "Volcano":
        cardColor = const Color(0xFFae2012);
        break;
      case "Forest":
        cardColor = const Color(0xFF2d6a4f);
        break;
      default:
        cardColor = const Color(0xFF7b2cbf);
    }
    return Card(
      elevation: 18,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text("$tag"),
      ),
      color: cardColor,
    );
  }

  Widget _favoriteButton({
    required QueryDocumentSnapshot<Object?> landscapeData,
    int index = 0,
  }) {
    return Consumer<FavoriteLandsapesProvider>(
        builder: (context, providerValue, chlid) {
      if (_userData.isNotEmpty) {
        providerValue.isFan =
            _userData["favorite_landscapes"].contains(landscapeData.id);
      }
      providerValue.fansNumber = landscapeData["fans"].length;

      return Stack(
        children: [
          Row(
            children: [
              _isLoading[index]
                  ? const SizedBox(
                      height: 50.0,
                      child: LoadingIndicator(
                        indicatorType: Indicator.ballScale,
                        colors: kDefaultRainbowColors,
                        strokeWidth: 4.0,
                      ),
                    )
                  : IconButton(
                      onPressed: () async {
                        if (user != null) {
                          setState(() {
                            _isLoading[index] = true;
                          });
                          try {
                            await _firebaseDatabase
                                .updateUserFavoriteLandscapes(
                                    userEmail: FirebaseAuth
                                        .instance.currentUser!.email
                                        .toString(),
                                    landscape: landscapeData);
                            await _firebaseDatabase.updateLandscapesFans(
                                userEmail: FirebaseAuth
                                    .instance.currentUser!.email
                                    .toString(),
                                landscape: landscapeData);
                            await _getFavoriteLandscapeData();
                          } catch (e) {
                            debugPrint("Error while update fans: $e");
                          }

                          setState(() {
                            _isLoading[index] = false;
                            providerValue.isFan = !providerValue.isFan;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(snackBar(
                              message: "Error you are not registered",
                              color: Colors.red));
                        }
                      },
                      icon: Icon(
                        providerValue.isFan
                            ? Icons.favorite
                            : Icons.favorite_border_outlined,
                        color: providerValue.isFan ? Colors.red : Colors.grey,
                      ),
                    ),
              Text(
                providerValue.fansNumber.toString(),
                style: appTheme().textTheme.headline4!.copyWith(
                      color: providerValue.isFan ? Colors.red : Colors.black,
                    ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
