import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nature_map/frontend/landscapes_list.dart';
import 'package:nature_map/methods/landscape.dart';
import 'package:provider/provider.dart';

class LandscapeProvider extends ChangeNotifier {
  bool isLocate = false;
  double lat = 0;
  double long = 0;

  String landName = '';

  List<String> landImages = [
    "assets/images/civilization.jpg",
    "assets/images/mountain.jpg",
    "assets/images/sea.jpg",
    "assets/images/desert.jpg",
    "assets/images/volcano.jpg",
    "assets/images/forest.jpg",
  ];
  List<String> landTags = [];

  late CameraPosition cameraPosition;
  late List<Placemark> placemark;
  late Position position;

  getCurrentPosition() async {
    position = await Geolocator.getCurrentPosition();
    debugPrint("lat:${position.latitude}\nlong: ${position.longitude}");
    placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    cameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 20);
    lat = position.latitude;
    long = position.longitude;
    notifyListeners();
  }

  addNewLandscape() {
    landscapesListItem.add(Landscape(
      landName: landName,
      lat: lat,
      long: long,
      landImages: landImages,
      tages: landTags,
    ));
    notifyListeners();
  }
}
