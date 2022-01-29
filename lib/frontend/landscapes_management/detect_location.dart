import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
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

  late CameraPosition _cameraPosition;
  List<Placemark> _placemark = [];
  var _position;

  _getCurrentPosition() async {
    _position = await Geolocator.getCurrentPosition();
    debugPrint("lat:${_position.latitude}\nlong: ${_position.longitude}");
    _placemark =
        await placemarkFromCoordinates(_position.latitude, _position.longitude);
    _cameraPosition = CameraPosition(
        target: LatLng(_position.latitude, _position.longitude), zoom: 14);
    setState(() {});
  }

  @override
  void initState() {
    _getCurrentPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    if (_position == null) {
      return const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(64),
          child: Center(
            child: LoadingIndicator(
              indicatorType: Indicator.ballScaleMultiple,
              colors: kDefaultRainbowColors,
              strokeWidth: 4.0,
            ),
          ),
        ),
      );
    } else {
      return _widget(height, width);
    }
  }

  Widget _widget(double height, double width) {
    return SafeArea(
      child: Scaffold(
        body: Consumer<LandscapeProvider>(
            builder: (context, providerValue, child) {
          Set<Marker> markers = {
            Marker(
              markerId: const MarkerId("Land"),
              position: LatLng(_position.latitude, _position.longitude),
              draggable: true,
              onDragEnd: (LatLng latLng) async {
                providerValue.lat = latLng.latitude;
                providerValue.long = latLng.longitude;
                _placemark = await placemarkFromCoordinates(
                    latLng.latitude, latLng.longitude);
                _cameraPosition = CameraPosition(
                    target: LatLng(latLng.latitude, latLng.longitude),
                    zoom: 20);
                setState(() {});
                debugPrint("$latLng");
              },
            ),
          };
          _textEditingController1 =
              TextEditingController(text: providerValue.lat.toString());
          _textEditingController2 =
              TextEditingController(text: providerValue.long.toString());
          return ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Row(
                children: [
                  _textField(
                      labelText: "Latitude",
                      width: width,
                      controller: _textEditingController1,
                      onChanged: (text) {
                        providerValue.lat = text as double;
                      }),
                  _textField(
                      labelText: "Longitude",
                      width: width,
                      controller: _textEditingController2,
                      onChanged: (text) {
                        providerValue.long = text as double;
                      }),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: width * 0.45,
                      child: Text(
                        "The Conntry: ${_placemark[0].country}",
                        style: appTheme()
                            .textTheme
                            .headline3!
                            .copyWith(fontSize: 14),
                      ),
                    ),
                    SizedBox(
                      width: width * 0.45,
                      child: Text(
                        "The Region: ${_placemark[0].locality}",
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
                          initialCameraPosition: _cameraPosition)),
                  Padding(
                    padding: const EdgeInsets.only(right: 15, top: 5),
                    child: ElevatedButton(
                        onPressed: () {
                          providerValue.isLocate = true;
                          providerValue.lat = _cameraPosition.target.latitude;
                          providerValue.long = _cameraPosition.target.longitude;
                          Navigator.pop(context);
                          setState(() {});
                        },
                        child: const Text('Save')),
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
      required TextEditingController controller,
      Function(String)? onChanged}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
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
        onChanged: onChanged,
      ),
    );
  }
}
