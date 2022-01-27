import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nature_map/app_theme.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);
//double _zoom = 10.0;

  final CameraPosition _cameraPosition =
      const CameraPosition(target: LatLng(15.6694253, 32.423543), zoom: 20);

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('value'),
        position: const LatLng(15.6694253, 32.423543),
        infoWindow: InfoWindow(
          title: "My home",
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return _bottomSheet(context);
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
          height: 30,
          child: const Icon(
            Icons.menu,
            size: 35,
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height / 4,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Image.asset(
                "assets/images/mountain.jpg",
              ),
              Image.asset(
                "assets/images/sea.jpg",
              ),
              Image.asset(
                "assets/images/offline.jpg",
              ),
              Image.asset(
                "assets/images/volcano.jpg",
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "landscape name",
                  style: appTheme().textTheme.headline3,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Contery / Area",
                  style: appTheme().textTheme.headline3,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Lat: / Lang:",
                  style: appTheme().textTheme.headline3,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Distance 100 K/M",
                  style: appTheme().textTheme.headline3,
                ),
              ],
            ),
            const SizedBox(
              width: 20,
            ),
            Text(
              "About:",
              style: appTheme().textTheme.headline3,
            ),
          ],
        )
      ],
    );
  }
}
