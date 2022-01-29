import 'package:flutter/foundation.dart';
import 'package:nature_map/methods/landscape.dart';

class LandscapeProvider extends ChangeNotifier {
  bool isLocate = false;

  double lat = 0;
  double long = 0;

  String landName = '';

  List<String> landImages = [];
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
