import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:nature_map/app_theme.dart';

class MapScreen extends StatefulWidget {
  final QueryDocumentSnapshot landscapeData;
  MapScreen({Key? key, required this.landscapeData}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late double latitude, longitude;

  late CameraPosition _cameraPosition;
  var _placemark;
  _getLocationData() async {
    latitude = widget.landscapeData["lat"];
    longitude = widget.landscapeData["long"];
    _cameraPosition =
        CameraPosition(target: LatLng(latitude, longitude), zoom: 15);
    _placemark = await placemarkFromCoordinates(latitude, longitude);
  }

  @override
  void initState() {
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
        onTap: () {
          //  _zoom = 2.0;
        },
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
    return Column(
      children: [
        Container(
          alignment: Alignment.topCenter,
          color: Colors.grey,
          width: double.maxFinite,
          height: 10,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height / 4.5,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...[
                for (String imageUrl in widget.landscapeData["land_images"])
                  Image.network(imageUrl)
              ]
            ],
          ),
        ),
        ListView(
          padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          children: [
            SizedBox(
              width: 180,
              child: Text(
                widget.landscapeData['land_name'],
                style: appTheme().textTheme.headline3,
              ),
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
}
