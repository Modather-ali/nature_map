import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nature_map/app_theme.dart';
import 'package:nature_map/frontend/landscapes_management/detect_location.dart';
import 'package:nature_map/methods/state_management/provider_methods.dart';
import 'package:provider/provider.dart';

class AddLandscape extends StatefulWidget {
  const AddLandscape({Key? key}) : super(key: key);

  @override
  _AddLandscapeState createState() => _AddLandscapeState();
}

class _AddLandscapeState extends State<AddLandscape> {
  final TextEditingController _textEditingController = TextEditingController();

  late CameraPosition _cameraPosition;

  final List<bool> _selections1 = [false, false, false];
  final List<bool> _selections2 = [false, false, false];

  final List<String> landTags1 = ["Mountain", "Sea", "Desert"];
  final List<String> landTags2 = ["Volcano", "Forest", "Civilization"];

  @override
  void initState() {
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
            style:
                appTheme().textTheme.headline3!.copyWith(color: Colors.white),
          ),
        ),
        body: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
          children: [
            Text(
              "Landscape Name:",
              style:
                  appTheme().textTheme.headline4!.copyWith(color: Colors.black),
            ),
            TextField(
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
            _choiceImages(),
            Consumer<LandscapeProvider>(
                builder: (context, providerValue, child) {
              providerValue.getCurrentPosition();

              _cameraPosition = CameraPosition(
                  target: LatLng(providerValue.lat, providerValue.long),
                  zoom: 20);
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
                        })),
              };
              return Column(
                children: [
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
                  providerValue.isLocate
                      ? Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 3,
                              width: double.infinity,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
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
                                    style: appTheme()
                                        .textTheme
                                        .headline3!
                                        .copyWith(fontSize: 14),
                                  ),
                                ),
                                SizedBox(
                                  width: width * 0.45,
                                  child: Text(
                                    "longitude: ${providerValue.long}",
                                    style: appTheme()
                                        .textTheme
                                        .headline3!
                                        .copyWith(fontSize: 14),
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
                                    "The Conntry: ${providerValue.placemark[0].country}",
                                    style: appTheme()
                                        .textTheme
                                        .headline3!
                                        .copyWith(fontSize: 14),
                                  ),
                                ),
                                SizedBox(
                                  width: width * 0.45,
                                  child: Text(
                                    "The Region: ${providerValue.placemark[0].locality}",
                                    style: appTheme()
                                        .textTheme
                                        .headline3!
                                        .copyWith(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  providerValue.landName =
                                      _textEditingController.text;
                                  providerValue.addNewLandscape();
                                  providerValue.isLocate = false;
                                  providerValue.landName = '';
                                  providerValue.landTags = [];
                                  Navigator.pop(context);
                                },
                                child: const Text("Add the Landscape"))
                          ],
                        )
                      : TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const DetectLocation(),
                              ),
                            );
                          },
                          child: const Text("Detect Location")),
                ],
              );
            }),
          ],
        ));
  }

  Widget _choiceImages() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      height: 150,
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            DottedBorder(
                radius: const Radius.circular(10),
                borderType: BorderType.RRect,
                strokeCap: StrokeCap.round,
                dashPattern: [10, 10],
                color: Colors.grey,
                child: InkWell(
                  onTap: () {
                    print("Adding new landscape...");
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const AddLandscape()));
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
                )),
          ],
        ),
      ),
    );
  }
}
