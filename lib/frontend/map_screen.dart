import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:nature_map/app_theme.dart';
import 'package:nature_map/frontend/support_screens/image_view.dart';
import 'package:nature_map/frontend/ui_widgets/snack_bar.dart';
import 'package:nature_map/methods/backend/firebase_database.dart';
import 'package:nature_map/methods/enums.dart';
import 'package:nature_map/methods/state_management/provider_methods.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  final QueryDocumentSnapshot landscapeData;
  const MapScreen({Key? key, required this.landscapeData}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late double latitude, longitude;
  bool isLoading = false;
  late Map<String, dynamic> _userData = {};
  User? user = FirebaseAuth.instance.currentUser;

  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase();

  late CameraPosition _cameraPosition;
  var _placemark;

  _getDate() async {
    if (user != null) {
      _userData = await _firebaseDatabase.getUserData(
          userEmail: user!.email.toString());
    }

    setState(() {});
  }

  _getLocationData() async {
    latitude = widget.landscapeData["lat"];
    longitude = widget.landscapeData["long"];
    _cameraPosition =
        CameraPosition(target: LatLng(latitude, longitude), zoom: 15);
    _placemark = await placemarkFromCoordinates(latitude, longitude);
  }

  @override
  void initState() {
    _getDate();
    _getLocationData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('landscape'),
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(
          title: widget.landscapeData["land_name"],
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                if (_placemark == null) {
                  return const Center(
                    child: SizedBox(
                      height: 150,
                      width: 150,
                      child: LoadingIndicator(
                        indicatorType: Indicator.ballRotateChase,
                        colors: kDefaultRainbowColors,
                        strokeWidth: 4.0,
                      ),
                    ),
                  );
                } else {
                  return _bottomSheet(context);
                }
              },
            );
          },
        ),
      )
    };

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              initialCameraPosition: _cameraPosition,
              mapType: MapType.hybrid,
              markers: markers,
            ),
          ),
          Positioned(
            top: 30,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.exit_to_app_outlined,
                color: Colors.red,
              ),
              backgroundColor: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget _bottomSheet(BuildContext context) {
    return ListView(
      children: [
        Container(
          alignment: Alignment.topCenter,
          color: Colors.grey,
          width: double.maxFinite,
          height: 10,
        ),
        SizedBox(
          height: MediaQuery.of(context).orientation == Orientation.landscape
              ? MediaQuery.of(context).size.width / 4.5
              : MediaQuery.of(context).size.height / 4.5,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...[
                for (String imageUrl in widget.landscapeData["land_images"])
                  InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ImageView(
                              imageType: ImageType.networkImage,
                              imagePath: imageUrl,
                            ),
                          ),
                        );
                      },
                      child: Image.network(imageUrl))
              ]
            ],
          ),
        ),
        ListView(
          padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Row(
              children: [
                SizedBox(
                  width: 180,
                  child: Text(
                    widget.landscapeData['land_name'],
                    style: appTheme().textTheme.headline3,
                  ),
                ),
                _favoriteButton(
                  landscapeData: widget.landscapeData,
                )

                // _favoriteButton(
                //     landscapeData: widget.landscapeData,
                //     isFan: isFan,
                //     fansNumber: widget.landscapeData["fans"].length.toString())
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Contery:",
              style: appTheme().textTheme.headline4,
            ),
            Text(
              "${_placemark[0].country}",
              style: appTheme().textTheme.headline3,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Region:",
              style: appTheme().textTheme.headline4,
            ),
            Text(
              "${_placemark[0].locality}",
              style: appTheme().textTheme.headline3,
            ),
            Text(
              "Lat: ${widget.landscapeData['lat']}\nLang: ${widget.landscapeData['long']}",
              style: appTheme().textTheme.headline4,
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        )
      ],
    );
  }

  Widget _favoriteButton({
    required QueryDocumentSnapshot<Object?> landscapeData,
  }) {
    return Consumer<DifferentLandsapesValus>(
        builder: (context, providerValue, chlid) {
      return Stack(
        children: [
          Row(
            children: [
              isLoading
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
                            isLoading = true;
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
                            isLoading = false;
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
