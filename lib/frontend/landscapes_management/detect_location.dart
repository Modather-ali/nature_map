import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nature_map/app_theme.dart';
import 'package:nature_map/methods/state_management/provider_methods.dart';
import 'package:provider/provider.dart';

class DetectLocation extends StatefulWidget {
  const DetectLocation({Key? key}) : super(key: key);

  @override
  _DetectLocationState createState() => _DetectLocationState();
}

class _DetectLocationState extends State<DetectLocation> {
  // LatLng _latLng = LatLng(15.6694253, 32.423543);

  late TextEditingController _textEditingController1;
  late TextEditingController _textEditingController2;

  @override
  void initState() {
    // _getCurrentPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: Consumer<LandscapeProvider>(
            builder: (context, providerValue, child) {
          Set<Marker> markers = {
            Marker(
              markerId: MarkerId("Land"),
              position: LatLng(providerValue.position.latitude,
                  providerValue.position.longitude),
              draggable: true,
              onDrag: (LatLng latLng) async {
                providerValue.lat = latLng.latitude;
                providerValue.long = latLng.longitude;
                providerValue.placemark = await placemarkFromCoordinates(
                    latLng.latitude, latLng.longitude);
                providerValue.cameraPosition = CameraPosition(
                    target: LatLng(latLng.latitude, latLng.longitude),
                    zoom: 20);
                debugPrint("$latLng");
              },
            ),
          };
          _textEditingController1 =
              TextEditingController(text: providerValue.lat.toString());
          _textEditingController2 =
              TextEditingController(text: providerValue.long.toString());
          return ListView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              Row(
                children: [
                  _textField(
                    labelText: "Latitude",
                    width: width,
                    controller: _textEditingController1,
                  ),
                  _textField(
                      labelText: "Longitude",
                      width: width,
                      controller: _textEditingController2),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
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
              ),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? height * 0.5
                          : height * 0.75,
                      width: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? double.infinity
                          : width,
                      child: GoogleMap(
                          markers: markers,
                          mapType: MapType.hybrid,
                          initialCameraPosition: providerValue.cameraPosition)),
                  Padding(
                    padding: const EdgeInsets.only(right: 15, top: 5),
                    child: ElevatedButton(
                        onPressed: () {
                          providerValue.isLocate = true;
                          Navigator.pop(context);
                        },
                        child: Text('Save')),
                  )
                ],
              )
            ],
          );
        }),
      ),
    );
  }

  _textField(
      {required String labelText,
      required double width,
      required TextEditingController controller}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      width: width * 0.45,
      height: 60,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          focusedBorder: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 0.3, color: Colors.black),
          ),
          labelText: labelText,
          hintStyle: appTheme().textTheme.headline4,
        ),
      ),
    );
  }
}
