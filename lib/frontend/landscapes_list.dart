import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:nature_map/app_theme.dart';
import 'package:nature_map/frontend/map_screen.dart';
import 'package:nature_map/frontend/search_screen.dart';
import 'package:nature_map/frontend/ui_widgets/snack_bar.dart';
import 'package:nature_map/methods/backend/firebase_database.dart';
import 'package:nature_map/methods/state_management/provider_methods.dart';
import 'package:provider/provider.dart';

class LandscapesList extends StatefulWidget {
  final List<String> landscapeName;
  final Color color;
  const LandscapesList(
      {Key? key, this.color = Colors.blue, required this.landscapeName})
      : super(key: key);

  @override
  _LandscapesListState createState() => _LandscapesListState();
}

class _LandscapesListState extends State<LandscapesList>
    with SingleTickerProviderStateMixin {
  double _distanceBetween = 0.0;
  var _position;
  List<QueryDocumentSnapshot<Object?>> _landscapesDataList = [];

  final List<bool> _isLoading = [];

  late Map<String, dynamic> _userData = {};

  User? user = FirebaseAuth.instance.currentUser;

  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase();

  // late AnimationController _animationController;

  // bool isListView = true;
  Future<List<Placemark>> _getPlacemark(latitude, longitude) async {
    return await placemarkFromCoordinates(latitude, longitude);
  }

  _getDate() async {
    _landscapesDataList = await _firebaseDatabase.getLandscapesData(
        landTag: widget.landscapeName);
    for (var land in _landscapesDataList) {
      _isLoading.add(false);
    }

    if (user != null) {
      _userData = await _firebaseDatabase.getUserData(
          userEmail: user!.email.toString());
    }
    setState(() {});
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
    // _animationController =
    //     AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _getDate();
    _getCurrentPosition();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: widget.color.withAlpha(200),
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         setState(() {
        //           isListView = !isListView;
        //         });
        //         if (!isListView) {
        //           _animationController.reverse();
        //         } else {
        //           _animationController.forward();
        //         }
        //       },
        //       icon: AnimatedIcon(
        //           icon: AnimatedIcons.list_view,
        //           progress: _animationController)),
        // ],
        title: Consumer<DifferentLandsapesValus>(
          builder: (context, providerValue, child) {
            return GestureDetector(
              onTap: () {
                showSearch(
                    context: context,
                    delegate: SearchScreen(providerValue.allLandscapesNames));
              },
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                    Text(
                      "Search?",
                      style: appTheme().textTheme.headline4,
                    ),
                  ],
                ),
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            );
          },
        ),
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
              itemCount: _landscapesDataList.length,
              itemBuilder: (context, index) {
                return _landscapeCard(
                  index: index,
                  landscapeData: _landscapesDataList[index],
                );
              },
            ),
    );
  }

  Widget _landscapeCard({
    required int index,
    required QueryDocumentSnapshot<Object?> landscapeData,
  }) {
    // List<Placemark> _placemark =
    //     _getPlacemark(landscapeData["lat"], landscapeData["long"]);
    _distanceBetween = Geolocator.distanceBetween(_position.latitude,
        _position.longitude, landscapeData["lat"], landscapeData["long"]);

    return Card(
      margin: const EdgeInsets.all(10.0),
      elevation: 6,
      child: SizedBox(
        height: MediaQuery.of(context).orientation == Orientation.landscape
            ? MediaQuery.of(context).size.height * 0.7
            : MediaQuery.of(context).size.height / 3,
        child: Stack(
          children: [
            OpenContainer(
              transitionDuration: const Duration(milliseconds: 650),
              closedElevation: 0.0,
              transitionType: ContainerTransitionType.fade,
              closedBuilder: (context, closedBuilder) {
                return Row(
                  children: [
                    SizedBox(
                      width: 15,
                    ),
                    Container(
                      height: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? MediaQuery.of(context).size.height * 0.4
                          : MediaQuery.of(context).size.height / 7,
                      width: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? MediaQuery.of(context).size.width * 0.5
                          : MediaQuery.of(context).size.width * 0.3,
                      alignment: Alignment.topCenter,
                      padding:
                          const EdgeInsets.only(left: 8, top: 35, right: 25),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            landscapeData["land_images"][0],
                          ),
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: SizedBox(
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
                            // Text(
                            //   "${_placemark[0].country} / ${_placemark[0].locality}",
                            //   style: appTheme().textTheme.headline4,
                            // ),
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
                    ),
                  ],
                );
              },
              openBuilder: (context, openBuilder) {
                return MapScreen(
                  landscapeData: landscapeData,
                );
              },
            ),
            _favoriteButton(
              landscapeData: landscapeData,
              index: index,
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
        child: Text(tag),
      ),
      color: cardColor,
    );
  }

  Widget _favoriteButton({
    required QueryDocumentSnapshot<Object?> landscapeData,
    int index = 0,
  }) {
    return Consumer<DifferentLandsapesValus>(
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
                              await _getDate();
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
      },
    );
  }
}
