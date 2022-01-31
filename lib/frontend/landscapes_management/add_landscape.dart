import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:nature_map/app_theme.dart';
import 'package:nature_map/frontend/landscapes_management/detect_location.dart';
import 'package:nature_map/frontend/ui_widgets/snack_bar.dart';
import 'package:nature_map/methods/state_management/provider_methods.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:timer_builder/timer_builder.dart';

class AddLandscape extends StatefulWidget {
  const AddLandscape({Key? key}) : super(key: key);

  @override
  _AddLandscapeState createState() => _AddLandscapeState();
}

class _AddLandscapeState extends State<AddLandscape> {
  final TextEditingController _textEditingController = TextEditingController();
  final GlobalKey<FormState> _textKey = GlobalKey<FormState>();

  bool isLoading = false;

  var _cameraPosition;
  late List<Placemark> _placemark;

  final List<bool> _selections1 = [false, false, false];
  final List<bool> _selections2 = [false, false, false];

  final List<String> landTags1 = ["Mountain", "Sea", "Desert"];
  final List<String> landTags2 = ["Volcano", "Forest", "Civilization"];

  _getPlacemark(latitude, longitude) async {
    _placemark = await placemarkFromCoordinates(latitude, longitude);
    _cameraPosition =
        CameraPosition(target: LatLng(latitude, longitude), zoom: 14);
    setState(() {});
  }

  Future<Position> _checkPermission() async {
    await Permission.storage.request();
    // bool serviceEnabled;
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    _checkPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "New Landscape",
          style: appTheme().textTheme.headline3!.copyWith(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
            children: [
              Text(
                "Landscape Name:",
                style: appTheme()
                    .textTheme
                    .headline4!
                    .copyWith(color: Colors.black),
              ),
              TextFormField(
                key: _textKey,
                validator: (text) {
                  if (text!.isEmpty) {
                    return "This Field can't be empty";
                  }
                  return null;
                },
                controller: _textEditingController,
                maxLength: 20,
                decoration: InputDecoration(
                  focusedBorder: const OutlineInputBorder(),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(width: 0.3, color: Colors.grey),
                  ),
                  hintText: "Press here...",
                  hintStyle: appTheme().textTheme.headline4,
                ),
              ),
              Text(
                "Add images:",
                style: appTheme()
                    .textTheme
                    .headline4!
                    .copyWith(color: Colors.black),
              ),
              Consumer<LandscapeProvider>(
                builder: (context, providerValue, child) {
                  Set<Marker> markers = {
                    Marker(
                      markerId: const MarkerId("Land"),
                      position: LatLng(providerValue.lat, providerValue.long),
                      infoWindow: InfoWindow(
                        title: "Edit",
                        onTap: () {
                          debugPrint("Edit land Location...");
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const DetectLocation(),
                            ),
                          );
                        },
                      ),
                    ),
                  };

                  return Column(
                    children: [
                      TimerBuilder.periodic(
                        const Duration(seconds: 1),
                        builder: (context) => _selectedImages(
                            landImages: providerValue.landImagesList),
                      ),
                      Text(
                        "Tags:",
                        style: appTheme()
                            .textTheme
                            .headline4!
                            .copyWith(color: Colors.black),
                      ),
                      ToggleButtons(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width / 3.5,
                            minHeight: 50,
                          ),
                          onPressed: (index) {
                            setState(() {
                              _selections1[index] = !_selections1[index];
                            });
                            if (_selections1[index]) {
                              providerValue.landTags.add(landTags1[index]);
                            } else {
                              providerValue.landTags.remove(landTags1[index]);
                            }
                            debugPrint('${providerValue.landTags}');
                          },
                          selectedColor: Colors.black,
                          selectedBorderColor: Colors.green,
                          color: Colors.grey,
                          children: const [
                            Text("Mountain"),
                            Text("Sea"),
                            Text("Desert"),
                          ],
                          isSelected: _selections1),
                      ToggleButtons(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width / 3.5,
                            minHeight: 50,
                          ),
                          onPressed: (index) {
                            setState(() {
                              _selections2[index] = !_selections2[index];
                            });
                            if (_selections2[index]) {
                              providerValue.landTags.add(landTags2[index]);
                            } else {
                              providerValue.landTags.remove(landTags2[index]);
                            }
                            print(providerValue.landTags);
                          },
                          selectedColor: Colors.black,
                          selectedBorderColor: Colors.green,
                          color: Colors.grey,
                          children: const [
                            Text("Volcano"),
                            Text("Forest"),
                            Text("Civilization"),
                          ],
                          isSelected: _selections2),
                      TimerBuilder.periodic(const Duration(seconds: 1),
                          builder: (context) {
                        _getPlacemark(providerValue.lat, providerValue.long);

                        if (providerValue.isLocate) {
                          return _googleMap(markers, width, providerValue);
                        } else {
                          return TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const DetectLocation(),
                                ),
                              );
                            },
                            child: const Text("Detect Location"),
                          );
                        }
                      }),
                    ],
                  );
                },
              ),
            ],
          ),
          isLoading ? _loadingData() : const SizedBox(),
        ],
      ),
    );
  }

  Widget _selectedImages({required List<File> landImages}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      height: 150,
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...[
                for (File item in landImages)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(item),
                  )
              ],
              _selectImages(landImages: landImages),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectImages({required List<File> landImages}) {
    return DottedBorder(
      radius: const Radius.circular(10),
      borderType: BorderType.RRect,
      strokeCap: StrokeCap.round,
      dashPattern: [10, 10],
      color: Colors.grey,
      child: InkWell(
        onTap: () {
          debugPrint("Adding new landscape...");

          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  alignment: Alignment.center,
                  height: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _choiceImageButton(
                          landImages: landImages,
                          source: "From Gallery",
                          imageSource: ImageSource.gallery,
                          iconData: Icons.add_a_photo_outlined),
                      _choiceImageButton(
                          landImages: landImages,
                          source: "From Camera",
                          imageSource: ImageSource.camera,
                          iconData: Icons.image_outlined),
                    ],
                  ),
                );
              });
        },
        child: const SizedBox(
          height: 120,
          width: 100,
          child: Icon(
            Icons.add,
            size: 35,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _choiceImageButton(
      {required List<File> landImages,
      required String source,
      required ImageSource imageSource,
      required IconData iconData}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          onPressed: () async {
            try {
              final XFile? _selectedImage = await ImagePicker().pickImage(
                source: imageSource,
                imageQuality: 1,
              );
              if (_selectedImage != null) {
                Navigator.pop(context);
                landImages.add(File(_selectedImage.path));
              }
            } catch (e) {
              debugPrint("error in choice image: $e");
            }
          },
          child: Icon(iconData),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          source,
          style: appTheme().textTheme.headline3!.copyWith(fontSize: 14),
        )
      ],
    );
  }

  Widget _googleMap(
      Set<Marker> markers, double width, LandscapeProvider providerValue) {
    if (_cameraPosition == null) {
      return const Center(
        child: LoadingIndicator(
          indicatorType: Indicator.ballScaleMultiple,
          colors: kDefaultRainbowColors,
          strokeWidth: 4.0,
        ),
      );
    } else {
      return Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 3,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: GoogleMap(
                  markers: markers,
                  mapType: MapType.hybrid,
                  initialCameraPosition: _cameraPosition),
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: width * 0.45,
                child: Text(
                  "latitude: ${providerValue.lat}",
                  style: appTheme().textTheme.headline3!.copyWith(fontSize: 14),
                ),
              ),
              SizedBox(
                width: width * 0.45,
                child: Text(
                  "longitude: ${providerValue.long}",
                  style: appTheme().textTheme.headline3!.copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              SizedBox(
                width: width * 0.45,
                child: Text(
                  "The Conntry: ${_placemark[0].country}",
                  style: appTheme().textTheme.headline3!.copyWith(fontSize: 14),
                ),
              ),
              SizedBox(
                width: width * 0.45,
                child: Text(
                  "The Region: ${_placemark[0].locality}",
                  style: appTheme().textTheme.headline3!.copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          ElevatedButton(
              onPressed: () async {
                if (_textEditingController.text.isNotEmpty) {
                  setState(() {
                    isLoading = true;
                  });
                  try {
                    providerValue.landName = _textEditingController.text;
                    await providerValue.addNewLandToFirebase();
                    providerValue.lat = 0.0;
                    providerValue.long = 0.0;
                    providerValue.isLocate = false;
                    providerValue.landName = '';
                    providerValue.landTags = [];
                    providerValue.landImagesList = [];
                    Navigator.pop(context);
                  } catch (e) {
                    debugPrint("Error in adding new land: $e");
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(snackBar(
                      message: "Landscape name can't be empty",
                      color: Colors.red));
                }
                setState(() {
                  isLoading = false;
                });
              },
              child: const Text("Add the Landscape"))
        ],
      );
    }
  }

  Widget _loadingData() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(64),
      color: Colors.black.withOpacity(0.4),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: const LoadingIndicator(
        indicatorType: Indicator.ballRotateChase,
        colors: kDefaultRainbowColors,
        strokeWidth: 3.0,
      ),
    );
  }
}
