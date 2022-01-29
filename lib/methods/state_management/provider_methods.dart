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
