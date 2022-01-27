class Landscape {
  final String landName;
  final String contryName;
  final String areaName;

  final List<String> tages;
  final List<String> landImages;

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

List<Landscape> landscapesListItem = [
  Landscape(
    landName: "Japane",
    tages: ['home', 'land'],
    lat: 15.716586,
    long: 32.482961,
    landImages: [
      "assets/images/civilization.jpg",
      "assets/images/mountain.jpg",
      "assets/images/sea.jpg",
      "assets/images/desert.jpg",
      "assets/images/volcano.jpg",
      "assets/images/forest.jpg",
    ],
    favoriteNumber: 10,
  ),
  Landscape(
    landName: "Forest",
    tages: ['home', 'land'],
    lat: 23.597970,
    long: 45.158039,
    landImages: [
      "assets/images/forest.jpg",
      "assets/images/mountain.jpg",
      "assets/images/sea.jpg",
      "assets/images/desert.jpg",
      "assets/images/volcano.jpg",
      "assets/images/civilization.jpg",
    ],
    favoriteNumber: 45,
  ),
  Landscape(
    landName: "Desert",
    tages: ['home', 'land'],
    lat: 48.715431,
    long: 17.717854,
    landImages: [
      "assets/images/desert.jpg",
      "assets/images/mountain.jpg",
      "assets/images/sea.jpg",
      "assets/images/volcano.jpg",
      "assets/images/forest.jpg",
      "assets/images/civilization.jpg",
    ],
    favoriteNumber: 18,
  ),
  Landscape(
    landName: "Sea",
    tages: ['home', 'land'],
    lat: 17.715431,
    long: 4.717854,
    landImages: [
      "assets/images/sea.jpg",
      "assets/images/mountain.jpg",
      "assets/images/desert.jpg",
      "assets/images/volcano.jpg",
      "assets/images/forest.jpg",
      "assets/images/civilization.jpg",
    ],
    favoriteNumber: 3,
  ),
];
