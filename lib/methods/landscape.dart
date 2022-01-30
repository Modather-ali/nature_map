import 'dart:io';

class Landscape {
  final String landName;
  final String contryName;
  final String areaName;

  final List<String> tages;
  final List<File> landImages;

  final double lat;
  final double long;
  final int favoriteNumber;

  Landscape({
    required this.landName,
    required this.tages,
    required this.lat,
    required this.long,
    required this.landImages,
    this.favoriteNumber = 0,
    this.contryName = 'Sudan',
    this.areaName = 'Ombada',
  });
}

List<Landscape> landscapesListItem = [];
